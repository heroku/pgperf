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

    def perform(results_db, target_db, description, script_name)
      results_db_uri = URI.parse(results_db)
      target_db_uri = URI.parse(target_db)
      env = pgbench_env(results_db_uri, target_db_uri, script_name)
      write_pgpass_file(results_db_uri, target_db_uri)
      set_id = run("./newset '#{description}'", env, chdir: '/app/vendor/pgbench-collector')
      env.merge!({ 'CURRENT_SET' => set_id })
      run("./runset", env, chdir: '/app/vendor/pgbench-collector')
    end

    def run(command, env={}, opts={})
      logger.info "running #{command}"
      result = nil
      output = nil
      Open3.popen3(env, *command, opts) do |stdin, stdout, stderr, wait_thread|
        # Close STDIN.
        stdin.close

        # Log STDERR.
        err_thread = Thread.new do
          stderr.each_line do |l|
            logger.info("stderr: #{l.chomp}")
          end
        end

        # Read STDOUT.
        output = stdout.read.chomp

        # Collect exit status.
        err_thread.join
        result = wait_thread.value.exitstatus
      end
    ensure
      logger.info "#{command} completed with exit status #{result}"
    end

    def pgpass_filename
      '/app/.pgpass'
    end

    def write_pgpass_file(rdb_uri, tdb_uri)
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

    def pgbench_env(rdb_uri, tdb_uri, script_name)
      px_config.merge(
        target_db_config(tdb_uri)
      ).merge(
        results_db_config(rdb_uri)
      ).merge({
          'SCRIPT' => "%s.sql" % script_name,
      })
    end

    def target_db_config(db_uri)
      {
      'TESTHOST'    => db_uri.host,
      'TESTUSER'    => db_uri.user,
      'TESTPORT'    => db_uri.port.to_s,
      'TESTDB'      => db_uri.path.gsub('/',''),
      }
    end

    def results_db_config(db_uri)
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

