require "spec_helper"

describe Database do
  let(:database) do
    Fabricate(:database)
  end

  it "enqueues a benchmark" do
    expect(PGPerf::PGBenchToolsWorker).to receive(:perform_async).with(Config.database_url,
      database.admin_url, database.description, "select")
    database.enqueue_benchmark
  end
end
