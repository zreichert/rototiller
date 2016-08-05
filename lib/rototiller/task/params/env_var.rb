require 'rototiller/utilities/color_text'
require 'rototiller/task/block_handling'

module Rototiller
  module Task

    class EnvVar
      MESSAGE_TYPES = {:nodefault_noexist=>0, :exist=>1, :default_noexist=>2, :not_required=>3}
      include Rototiller::ColorText
      include BlockHandling

      # @return [String] the value of the :name argument
      attr_accessor :var

      # @return [String] the value of the :message argument
      attr_accessor :message

      # @return [String] the value of the :default argument
      attr_accessor :default

      # @return  [true, nil] If the env_var should error if no value is set. Used internally by CommandFlag, ignored for standalone EnvVar.
      attr_reader :required

      # @return [Symbol] the debug level of the message, ':warning', ':error', ':info'
      attr_reader :message_level

      # @return [true, nil] if the state of the EnvVar requires the task to stop
      attr_reader :stop

      # @return [String] the value of the ENV based on specified default and environment state
      attr_reader :value

      # Creates a new instance of EnvVar, holds information about the ENV in the environment
      # @param [Hash, Array<Hash>] args hash of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      # @option args [Boolean] :required Used internally by CommandFlag, ignored for a standalone EnvVar
      # for block { |b| ... }
      # @yield EnvVar object with attributes matching method calls supported by EnvVar
      # @return EnvVar object
      def initialize(args={}, &block)
        if block_given?
          required_attributes = [:name, :default, :message, :required, :set_env] # maybe should be a CONST
          attribute_hash = pull_params_from_block(required_attributes, &block)
        else
          attribute_hash = args
        end
        # TODO: make this a global options hash?
        #attribute_hash[:set_env] = true if opts[:set_env]

        raise(ArgumentError, 'A name must be supplied to add_env') unless attribute_hash[:name]
        @var = attribute_hash[:name]
        @message = attribute_hash[:message]
        @default = attribute_hash[:default]
        @set_env = attribute_hash[:set_env] || false
        # FIXME: create env_var truthy helper
        attribute_hash[:required].is_a?(String) ? attribute_hash[:required] = (attribute_hash[:required].downcase == 'true') : attribute_hash[:required]
        @required = ( !!attribute_hash[:required] == attribute_hash[:required] ? attribute_hash[:required] : true)

        reset
      end

      # The formatted messages about this EnvVar's status to be displayed to the user
      # @return [String] the EnvVar's message, formatted for color and meaningful to the state of the EnvVAr
      def message
        if message_level == :error
          level_str = 'ERROR:'
        elsif message_level == :info
          level_str = 'INFO:'
        elsif message_level == :warning
          level_str = 'WARNING:'
        end
        message_prepend = "#{level_str} The environment variable: '#{@var}'"
        if get_message_type == MESSAGE_TYPES[:default_noexist]
          return yellow_text("#{message_prepend} is not set. Proceeding with default value: '#{@default}': #{@message}")
        end
        if get_message_type == MESSAGE_TYPES[:not_required]
          return yellow_text("#{message_prepend} is not set, but is not required. Proceeding with no flag: #{@message}")
        end
        if get_message_type == MESSAGE_TYPES[:exist]
          return green_text("#{message_prepend} was found with value: '#{ENV[@var]}': #{@message}")
        end
        if get_message_type == MESSAGE_TYPES[:nodefault_noexist]
          return red_text("#{message_prepend} is required: #{@message}")
        end
      end

      # If any of these variables are assigned a new value after this object's creation, reset @value and @message_level.
      def var=(var)
        @var = var
        reset
      end

      def default=(default)
        @default = default
        reset
      end

      def message=(message)
        @message = message
        reset
      end

      def required=(required)
        @required = required
        reset
      end

      private
      def reset
        # TODO should an env automatically set the ENV? possibly a global config option
        @value = ENV[@var] || @default
        ENV[@var] = @value if @set_env
        set_message_level
      end

      def check
        ENV.key?(@var)
      end

      def get_message_type
        if (value.nil? || value.empty?) && !required
          MESSAGE_TYPES[:not_required]
        elsif !@default && !check
          # ENV is not Present and it has no default value
          MESSAGE_TYPES[:nodefault_noexist]
        elsif check
          # ENV is present; may or may not have default, who cares
          MESSAGE_TYPES[:exist]
        elsif @default && !check
          # ENV is not present and it has default value
          MESSAGE_TYPES[:default_noexist]
        end
      end

      def set_message_level
        case get_message_type
        when MESSAGE_TYPES[:nodefault_noexist]
          @message_level = :error
          @stop = true
        when MESSAGE_TYPES[:exist], MESSAGE_TYPES[:default_noexist], MESSAGE_TYPES[:not_required]
          @message_level = :info
        else
          raise 'EnvVar: message type not supported'
        end
      end
    end

  end
end
