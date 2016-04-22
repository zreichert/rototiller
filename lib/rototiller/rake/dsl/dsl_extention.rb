require 'rototiller/task/rototiller_task'

module Rake
  module DSL

    def rototiller_task(*args, &block)
      Rototiller::Task::RototillerTask.define_task(*args, &block)
    end
  end
end
