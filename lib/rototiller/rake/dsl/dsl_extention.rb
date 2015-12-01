require 'rototiller/rake/tasks/rototiller_task'

module Rake
  module DSL

    def acceptance_task(*args, &block)
      Rake::RototillerTask.define_task :acceptance, &block
      description = "Tests in the 'Acceptance' tier"
      unless Rake::RototillerTask[:acceptance].comment
        Rake::RototillerTask[:acceptance].add_description(description)
      end
    end
  end
end
