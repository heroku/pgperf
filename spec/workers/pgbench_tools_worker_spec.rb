require "spec_helper"

describe PGPerf::PGBenchToolsWorker do
  let(:database) do
    Fabricate(:database)
  end

  let(:worker) do
    PGPerf::PGBenchToolsWorker.new
  end

  let(:env) do
    {
      "SKIPINIT"=>"0", "SKIPREPORT"=>"1",
      "TABBED"=>"0", "OSDATA"=>"0",
      "MAX_WORKERS"=>"8", "SCALES"=>"750",
      "SETCLIENTS"=>"10 50 100 150 200 250 300 400 500",
      "SETTIMES"=>"2", "RUNTIME"=>"1800",
      "PGPASSFILE"=>"/app/.pgpass",
      "TESTHOST"=>"localhost", "TESTUSER"=>"admin", "TESTPORT"=>"5432", "TESTDB"=>"perf",
      "RESULTHOST"=>"localhost", "RESULTUSER"=>nil, "RESULTPORT"=>"", "RESULTDB"=>"pgperf_test",
    }
  end

  it "creates a new test set and run it" do
    expect(worker).to receive(:write_pgpass_file).with(Config.database_url,
      database.admin_url)
    expect(worker).to receive(:run).with("./runset", hash_including(env), chdir: '/app/vendor/pgbench-collector')
    expect(worker).to receive(:run).with("./runset", hash_including(env), chdir: '/app/vendor/pgbench-collector')
    worker.perform(database.uuid)
  end
end
