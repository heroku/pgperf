require 'sidekiq'
require 'sidekiq/api'
require 'open3'
require_relative './hk_worker'

module PGPerf
  class PGBenchToolsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :pgbenchtools, retry: false

    def self.mark_restart
      queue = self.get_sidekiq_options["queue"].to_s
      Sidekiq::ProcessSet.new.
        select{|v| v['queues'].include?(queue)}.
        each(&:stop!)
    end

    def self.top_off_workers
      queue = self.get_sidekiq_options["queue"].to_s
      PGPerf::HkWorker.perform_async(5, queue, "PX")
    end

    def perform(database_uuid, script_name)
      database = Database[database_uuid]

      # Create test set
      testset = create_testset(database)

      # Write credentials to disk
      write_pgpass_file(Config.database_url, database.admin_url)

      # Run test set
      env = pgbench_env(database, testset, script_name)
      run("./runset", env, chdir: '/app/vendor/pgbench-collector')
    end

    private
    def run(command, env={}, opts={})
      logger.info "running #{command}"
      result = nil
      Open3.popen3(env, *command, opts) do |stdin, stdout, stderr, wait_thread|
        # Close STDIN.
        stdin.close

        # Log STDERR.
        err_thread = Thread.new do
          stderr.each_line do |l|
            logger.info("stderr: #{l.chomp}")
          end
        end

        # Log STDOUT.
        stdout.each_line do |l|
          logger.info("stdout: #{l.chomp}")
        end

        # Collect exit status.
        err_thread.join
        result = wait_thread.value.exitstatus
      end
    ensure
      logger.info "#{command} completed with exit status #{result}"
    end

    def create_testset(database)
      testinfo = target_db_config(database.admin_url)
      TestSet.create(database_uuid: database.uuid,
        testdb: testinfo['TESTDB'],
        testport: testinfo['TESTPORT'],
        testuser: testinfo['TESTUSER'],
        testhost: testinfo['TESTHOST'],
        info: database.description)
    end

    def pgpass_filename
      '/app/.pgpass'
    end

    def write_pgpass_file(rdb_url, tdb_url)
      rdb_uri = URI.parse(rdb_url)
      tdb_uri = URI.parse(tdb_url)
      File.open(pgpass_filename, 'a') do |f|
        f.puts "%s:%s:%s:%s:%s" % [rdb_uri.host,
                                   rdb_uri.port,
                                   rdb_uri.path.gsub('/',''),
                                   rdb_uri.user,
                                   rdb_uri.password]
        f.puts "%s:%s:%s:%s:%s" % [tdb_uri.host,
                                   tdb_uri.port,
                                   tdb_uri.path.gsub('/',''),
                                   tdb_uri.user,
                                   tdb_uri.password]
      end
      File.chmod(0600, pgpass_filename)
    end

    def pgbench_env(database, testset, script_name)
      px_config.merge(
        target_db_config(database.admin_url)
      ).merge(
        results_db_config(Config.database_url)
      ).merge({
        'SCRIPT' => "%s.sql" % script_name,
        'CURRENT_SET' => testset.pk
      })
    end

    def target_db_config(db_url)
      db_uri = URI.parse(db_url)
      {
        'TESTHOST'    => db_uri.host,
        'TESTUSER'    => db_uri.user,
        'TESTPORT'    => db_uri.port.to_s,
        'TESTDB'      => db_uri.path.gsub('/',''),
      }
    end

    def results_db_config(db_url)
      db_uri = URI.parse(db_url)
      {
        'RESULTHOST'  => db_uri.host,
        'RESULTUSER'  => db_uri.user,
        'RESULTPORT'  => db_uri.port.to_s,
        'RESULTDB'    => db_uri.path.gsub('/',''),
      }
    end

    def px_config
      {
        'SKIPINIT'    => '0',
        'SKIPREPORT'  => '1',
        'TABBED'      => '0',
        'OSDATA'      => '0',
        'MAX_WORKERS' => '8',
        'SCALES'      => '750',
        'SETCLIENTS'  => '1 10 50 100 150 200 250 300',
        'SETTIMES'    => '1',
        'RUNTIME'     => '600',
        'PGPASSFILE'  => pgpass_filename,
      }
    end
  end
end

