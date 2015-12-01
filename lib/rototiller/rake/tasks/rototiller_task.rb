require 'rototiller/utilities/env_var_checker'
require 'rototiller/rake/tasks/common_tasks'

module Rake
  class RototillerTask < Task

    include EnvVar

    def initialize(task_name=:acceptance, app)
      super
    end

    def test_framework(framework)
      case framework.downcase
        when 'beaker'
          Rake::RototillerTask[:acceptance].enhance do
            Rake::RototillerTask[:beaker].invoke
          end
        when 'beaker-rspec'
          Rake::RototillerTask[:acceptance].enhance do
            Rake::RototillerTask[:beaker_rspec].invoke
          end
      end
    end
  end
end
