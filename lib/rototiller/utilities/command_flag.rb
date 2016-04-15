require 'rototiller/utilities/color_text'
require 'rototiller/utilities/env_var'

class CommandFlag

  include ColorText

  # @return [String] the flag to be set on a CLI '-v' or '--verbose'
  attr_reader :flag

  # @return [true, false, nil, String] the value if any of the flag
  attr_reader :value

  # @return [EnvVar] the ENV that is equal to this flag
  attr_reader :override_env

  # @return [true, nil] if the state of the EnvVar requires the task to stop
  attr_reader :stop

  # Creates a new instance of CommandFlag, holds information about desired state of a CLI flag
  # @param [Hash] attribute_hash hashes of information about the command line flag
  # @option attribute_hash [String] :name The command line flag
  # @option attribute_hash [String] :value The value for the command line flag
  # @option attribute_hash [String] :message A message describing the use of this command line flag
  # @option attribute_hash [String] :override_env The environment variable that can override this flags value
  def initialize(attribute_hash)
    validate_attribute_hash(attribute_hash)
    @flag = attribute_hash[:name]
    @message = attribute_hash[:message]

    if attribute_hash[:default] && !attribute_hash[:override_env]

      # the default is the implied hard coded value
      @value = attribute_hash[:default]
    else

      # Create a new EnvVar instance and aks it what the value is
      @override_env = EnvVar.new({:name => attribute_hash[:override_env], :default => attribute_hash[:default]})

      @value = @override_env.value
      @stop = @override_env.stop
    end
  end

  # The formatted message to be displayed to the user
  # @return [String] the CommandFlag's message, formatted with color
  def message
    @message ? green_text(@message) << "\n" << describe_flag_state : describe_flag_state
  end

  private
  def describe_flag_state
    if @stop
      required_env = "The CLI flag #{@flag} needs a value.\nYou can specify this value with the environment variable #{override_env.var}"
      return red_text(required_env)
    else
      flag_with_value = "The CLI flag #{@flag} will be used with value #{@value}."
      return green_text(flag_with_value)
    end
  end

  def validate_attribute_hash(h)
    # validate the contents of the hash
    error = String.new
    error << "A 'name' is required\n" unless h[:name]
    error << "You must specify a 'default' or an 'override_env'\n" unless h[:default] || h[:override_env]

    raise(ArgumentError, error) unless error.empty?
  end
end
