require "spec_helper"

describe Database do
  let(:database) do
    Fabricate(:database)
  end

  it "enqueues a benchmark" do
    expect(PGPerf::PGBenchToolsWorker).to receive(:perform_async).with(database.uuid, "select")
    expect(PGPerf::PGBenchToolsWorker).to receive(:perform_async).with(database.uuid, "tpc-b")
    database.enqueue_benchmark
  end
end
