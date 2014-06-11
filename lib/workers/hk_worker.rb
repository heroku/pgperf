module PGPerf
  class HkWorker
    include Sidekiq::Worker
    sidekiq_options queue: :hk_worker, retry: false

    def initialize
      @heroku = PlatformAPI.connect_oauth(Config.heroku_platform_api_token, cache: Moneta.new(:Null))
      @heroku_app_name = Config.heroku_app_name
    end

    def perform(target_worker_count, queue, size = "1X")
      top_off_workers(target_worker_count, queue, size)
    end

    def run_a_worker(queue, size)
      @heroku.dyno.create(
        @heroku_app_name,
        command: "bundle exec sidekiq -q #{queue} -g ${DYNO} -t #{4.days.to_i} -r ./lib/initializer.rb -c 1",
        size: "#{size}"
      )
    end

    def running_worker_count(queue)
      @heroku.dyno.list(@heroku_app_name).
        select{|p| p['command'] =~ /^bundle exec sidekiq -q #{queue}/}.
        count
    end

    def needed_workers(top, queue)
      top - running_worker_count(queue)
    end

    def top_off_workers(top, queue, size)
      needed_workers(top, queue).times do |i|
        run_a_worker(queue, size)
      end
    end
  end
end
