require 'rototiller/task/params/option'
require 'rototiller/task/mixable_methods/addible'
require 'rototiller/task/mixable_methods/add_env'

module Rototiller
  module Task

    module AddOption

      include Addible
      # adds options to a command
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The option to be used
      # @option args [String] :default The default value for this option
      # @option args [String] :message A message describing the use of this option
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys
      def add_option(*args, &block)
        add_something(Rototiller::Task::Option, @options, *args, &block)
      end
    end
  end
end
