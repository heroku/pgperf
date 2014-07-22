require 'attr_secure'

class Database < Sequel::Model
  plugin :timestamps
  plugin :paranoid

  attr_secure :resource_url
  attr_secure :admin_url

  def enqueue_benchmark
    PGPerf::PGBenchToolsWorker.perform_async(Config.database_url,
      admin_url, description, "select")
  end
end
