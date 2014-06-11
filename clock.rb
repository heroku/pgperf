require "./lib/initializer"
require "clockwork"

module Clockwork
  every(1.minute, "top-off-workers") do
    PGPerf::PGBenchToolsWorker.top_off_workers
  end

  every(4.hours, "mark-restart") do
    PGPerf::PGBenchToolsWorker.mark_restart
  end
end
