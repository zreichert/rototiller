require 'rototiller/utilities/env_var'
module Rototiller
  class Command

    include ColorText

    # @return [String] the command to be used, could be considered a default
    attr_accessor :name

    # @return [EnvVar] the ENV that is equal to this command
    attr_reader :override_env

    # @return [String, nil] the value that should be used as an argument to the given command
    attr_reader :argument

    # @return [EnvVar] the ENV that is equal to the argument to be used with this command
    attr_reader :argument_override_env

    # Creates a new instance of CommandFlag, holds information about desired state of a command
    # @param [Hash] attribute_hash hashes of information about the command
    # @option attribute_hash [String] :command The command
    # @option attribute_hash [String] :override_env The environment variable that can override this command
    def initialize(attribute_hash = {})

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
  end
end

