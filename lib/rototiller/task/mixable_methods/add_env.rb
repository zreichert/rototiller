require 'rototiller/task/mixable_methods/addible'

module Rototiller
  module Task

    module AddEnv

      include Addible

      # adds environment variables to be tracked
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      # @option args [Boolean] :required Is used internally by CommandFlag, ignored for a standalone EnvVar
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys
      def add_env(*args, &block)
        add_something(Rototiller::Task::EnvVar, @env_vars, *args, &block)
      end
    end
  end
end

