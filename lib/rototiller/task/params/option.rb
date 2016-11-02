require 'rototiller/task/collections/env_collection'
require 'rototiller/task/params/argument'
require 'rototiller/task/collections/argument_collection'

module Rototiller
  module Task

    # The Option class to implement rototiller command Option handling
    #   via a RototillerTask's #add_command and Command's #add_option
    #   contains information about a Switch's state, as influenced by environment variables, for instance
    # @since v1.0.0
    # @attr [String] name The name of the option to add to a command string
    class Option < Switch

      def initialize(args={}, &block)
        @arguments = ArgumentCollection.new
        super(args, &block)
      end

      # adds argument to append to option.
      #   In the Option context this Argument is added to an Option '--option argument'
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The value to be used as teh argument
      # @option args [String] :message A message describing the use of argument
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys
      def add_argument(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        if block_given?
          @arguments.push(Rototiller::Task::Argument.new(&block))
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @arguments.push(Rototiller::Task::Argument.new(arg))
          end
        end
      end

      def to_str
        [@name.to_s, @arguments.to_s].compact.join(' ')
      end
    end
  end
end
