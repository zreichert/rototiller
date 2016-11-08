require 'rototiller/task/params'
require 'rototiller/utilities/color_text'

module Rototiller
  module Task

    # The main EnvVar type to implement envrironment variable handling
    #   contains its messaging, status, and whether it is required.
    #   The rototiller Param using it knows what to do with its value.
    # @since v0.1.0
    # @attr [String]         var      The name of the env_var in the system environment
    # @attr [String]         default  The default value of this env_var to use if
    #   the system ENV does not have a value this implies required is false
    # @attr_reader [Boolean] required Whether the env_var should error if no value is set.
    #   Used internally by CommandFlag, ignored for standalone EnvVar.
    # @attr_reader [Symbol] message_level the debug level of the message, ':warning', ':error', ':info'
    # @attr_reader [Boolean] stop     Whether the state of the EnvVar requires the task to stop
    # @attr_reader [Boolean] value    The value of the ENV based on specified default and environment state
    class EnvVar < RototillerParam
      MESSAGE_TYPES = {:nodefault_noexist=>0, :exist=>1, :default_noexist=>2, :not_required=>3}
      include Rototiller::ColorText

      attr_accessor :name
      attr_accessor :default
      attr_accessor :required
      # FIXME: does (api) user need to read this directly?
      attr_reader :message_level
      attr_reader :value
      attr_accessor :message
      attr_accessor :set_env
      attr_reader :stop

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
        block_given? ? (yield self) : send_hash_keys_as_methods_to_self(args)

        raise(ArgumentError, 'A name must be supplied to add_env') unless @name
        @set_env ||= true
        reset
      end

      # The formatted messages about this EnvVar's status to be displayed to the user
      # @return [String] the EnvVar's message, formatted for color and meaningful to the state of the EnvVar
      def message
        if message_level == :error
          level_str = 'ERROR:'
        elsif message_level == :info
          level_str = 'INFO:'
        elsif message_level == :warning
          level_str = 'WARNING:'
        end
        message_prepend = "#{level_str} The environment variable: '#{@name}'"
        if get_message_type == MESSAGE_TYPES[:default_noexist]
          return yellow_text("#{message_prepend} is not set. Proceeding with default value: '#{@default}': #{@user_message}")
        end
        if get_message_type == MESSAGE_TYPES[:not_required]
          return yellow_text("#{message_prepend} is not set, but is not required. Proceeding with no flag: #{@user_message}")
        end
        if get_message_type == MESSAGE_TYPES[:exist]
          return green_text("#{message_prepend} was found with value: '#{ENV[@name]}': #{@user_message}")
        end
        if get_message_type == MESSAGE_TYPES[:nodefault_noexist]
          return red_text("#{message_prepend} is required: #{@user_message}")
        end
      end

      # The string representation of this EnvVar; the value on the system, or nil
      # @return [String] the EnvVar's value
      def to_str
        ENV[@name]
      end
      alias :to_s :to_str

      # Sets the name of the EnvVar
      # @raise [ArgumentError] if name contains an illegal character for bash environment variable
      def name=(name)
        name.each_char do |char|
          message = "You have defined an environment variable with an illegal character: #{char}"
          raise ArgumentError.new(message) unless char =~ /[a-zA-Z]|\d|_/
        end
        @name = name
      end

      private

      # @private
      #TODO cleanup WTF
      def reset

        (env_value_provided_by_user? || @default) ? @stop = false : @stop = true

        if @name
          @value = ENV[@name] || @default
          ENV[@name] = @value if @set_env
          set_message_level
        else
          @value = @default
          set_message_level
        end
      end

      # @private
      def env_value_provided_by_user?
        # its possible that name could not be set
        (ENV.key?(@name) if @name) ? true : false
      end

      # @private
      def get_message_type
        if (value.nil? || value.empty?) && !required
          MESSAGE_TYPES[:not_required]
        elsif !@default && env_value_provided_by_user?
          # ENV is not Present and it has no default value
          MESSAGE_TYPES[:nodefault_noexist]
        elsif !env_value_provided_by_user?
          # ENV is present; may or may not have default, who cares
          MESSAGE_TYPES[:exist]
        elsif @default && env_value_provided_by_user?
          # ENV is not present and it has default value
          MESSAGE_TYPES[:default_noexist]
        end
      end

      # @private
      def set_message_level
        case get_message_type
        when MESSAGE_TYPES[:nodefault_noexist]
          @message_level = :error
        when MESSAGE_TYPES[:exist], MESSAGE_TYPES[:default_noexist], MESSAGE_TYPES[:not_required]
          @message_level = :info
        else
          raise 'EnvVar: message type not supported'
        end
      end
    end

  end
end
