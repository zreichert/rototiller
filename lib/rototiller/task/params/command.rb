require 'rototiller/task/params/env_var'

module Rototiller
  module Task

    class Command
      include Rototiller::ColorText

      # @return [String] the command to be used, could be considered a default
      attr_accessor :name

      # @return [Struct] the command results, if run
      attr_accessor :result

      # @return [EnvVar] the ENV that is equal to this command
      attr_reader :override_env

      # @return [String, nil] the value that should be used as an argument to the given command
      attr_reader :argument

      # @return [EnvVar] the ENV that is equal to the argument to be used with this command
      attr_reader :argument_override_env

      # Creates a new instance of Command, holds information about desired state of a command
      # @param [Hash,Array<Hash>] args hashes of information about the command
      # for block { |b| ... }
      # @yield Command object with attributes matching method calls supported by Command
      # @return Command object
      def initialize(args={}, &block)
        if block_given?
          required_attributes = [:name, :override_env, :argument, :argument_override_env]
          attribute_hash = pull_params_from_block(required_attributes, &block)
        else
          attribute_hash = args
        end
        # TODO: make this a global options hash?
        #   no, needs to be per-param with a default to false except in task's env_var, the other env_vars should not pollute the environment space
        #attribute_hash[:set_env] = true if opts[:set_env]

        # check if an override_env is provided
        if attribute_hash[:override_env]
          @override_env = EnvVar.new({:name => attribute_hash[:override_env], :default => attribute_hash[:name]})
          @name = @override_env.value
        else
          @name = attribute_hash[:name]
        end

        # check if an argument_override_env is provided
        if attribute_hash[:argument_override_env]
          @argument_override_env = EnvVar.new({:name => attribute_hash[:argument_override_env], :default => attribute_hash[:argument]})
          @argument = @argument_override_env.value
        else
          @argument = attribute_hash[:argument]
        end
      end

      # convert a Command object to a string (runable command string)
      # @return [String]
      def to_str
        [(name if name), @flags.to_s, (argument if argument)
        ].delete_if{ |i| [nil, '', false].any?{|forbidden| i == forbidden}}.join(' ').to_s
      end
      alias :to_s :to_str

      Result = Struct.new(:stdout, :stderr, :exit_code)
      # run Command locally, capture relevent result data
      # @return [Struct<Result>] a Result Struct with stdout, stderr, exit_code members
      def run
        # make this look a bit like beaker's result class
        #   we may have to convert this to a class if it gets complex
        @result = Result.new
        # splat the result of popen3 to a new Result struct
        @result.stdout, @result.stderr, status = Open3.capture3(self)
        @result.exit_code = status.exitstatus
        if block_given? # if block, send result to the block
          yield @result
        end
        @result
      end

      def stop
        false
      end

    end

  end
end
