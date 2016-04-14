require 'rototiller/utilities/color_text'

class CommandFlag

  include ColorText

  # @return [String] the flag to be set on a CLI '-v' or '--verbose'
  attr_reader :flag

  # @return [true, false, nil, String] the value if any of the flag
  attr_reader :value

  # Creates a new instance of CommandFlag, holds information about desired state of a CLI flag
  # @param [Hash] attribute_hash hashes of information about the command line flag
  # @option attribute_hash [String] :name The command line flag
  # @option attribute_hash [String] :value The value for the command line flag
  # @option attribute_hash [String] :message A message describing the use of this command line flag
  def initialize(attribute_hash)
    validate_attribute_hash(attribute_hash)
    @flag = attribute_hash[:name]
    @message = attribute_hash[:message]
    @value = attribute_hash[:value]
  end

  # The formatted message to be displayed to the user
  # @return [String] the CommandFlag's message, formatted with color
  def message
    @message ? green_text(@message) << "\n" << describe_flag_state : describe_flag_state
  end

  private
  def describe_flag_state
    only_flag = "The CLI flag #{@flag} will be used, no value was provided."
    flag_with_value = "The CLI flag #{@flag} will be used with value #{@value}."
    green_text(@value.nil? ? only_flag : flag_with_value)
  end

  def validate_attribute_hash(h)
    # validate the contents of the hash
    name_error = 'A name must be supplied to add_flag'
    value_error = 'A value must be supplied to add flag'
    error = nil

    if !h[:name] && !h[:value]
      error = name_error << "\n" << value_error
    elsif h[:name] && !h[:value]
      error = value_error
    elsif !h[:name] && h[:value]
      error = name_error
    end

    raise(ArgumentError, error) if error
  end
end
