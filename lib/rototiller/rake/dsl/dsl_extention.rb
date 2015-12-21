require 'rototiller/task/rototiller_task'

module Rake
  module DSL

    def acceptance_task(*args, &block)
      desc "Tests in the 'Acceptance' tier" unless ::Rake.application.last_comment
      Rototiller::Task::RototillerTask.define_task :acceptance, &block
    end

  end
end
