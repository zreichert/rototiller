require 'rototiller/utilities/env_var'
module Rototiller
  class Command

    include ColorText

    # @return [String] the command to be used, could be considered a default
    attr_reader :name

    # @return [EnvVar] the ENV that is equal to this command
    attr_reader :override_env

    # Creates a new instance of CommandFlag, holds information about desired state of a command
    # @param [Hash] attribute_hash hashes of information about the command
    # @option attribute_hash [String] :command The command
    # @option attribute_hash [String] :override_env The environment variable that can override this command
    def initialize(attribute_hash)
      # translate the keys from 'Command' to Env
      if attribute_hash[:override_env]
        @override_env = EnvVar.new({:name => attribute_hash [:override_env], :default => attribute_hash[:name]})
        @name = @override_env.value
      else
        @name = attribute_hash[:name]
      end
    end
  end
end

