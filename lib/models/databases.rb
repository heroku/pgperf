require 'attr_secure'

class Database < Sequel::Model
  one_to_many :testset

  plugin :timestamps
  plugin :paranoid

  attr_secure :resource_url
  attr_secure :admin_url

  def enqueue_benchmark
    PGPerf::PGBenchToolsWorker.perform_async(uuid)
  end
end
