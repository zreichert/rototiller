require 'rototiller/utilities/color_text'

class CommandFlag

  include ColorText

  # @return [String] the flag to be set on a CLI '-v' or '--verbose'
  attr_reader :flag

  # @return [true, false, nil, String] the value if any of the flag
  attr_reader :value

  # Creates a new instance of CommandFlag, holds information about desired state of a CLI flag
  # @param flag [String] the flag to be set on a CLI '-v' or '--verbose'
  # @param message [String] the message describing the Flag
  # @param value [String] the value to use as the value if one is required
  def initialize(flag, message, value=nil)
    @flag = flag
    @message = message
    @value = value
  end

  # The formatted message to be displayed to the user
  # @return [String] the CommandFlag's message, formatted with color
  def message
    green_text(@message) << "\n" << describe_flag_state
  end

  private
  def describe_flag_state
    only_flag = "The CLI flag #{@flag} will be used, no value was provided."
    flag_with_value = "The CLI flag #{@flag} will be used with value #{@value}."
    green_text(@value.nil? ? only_flag : flag_with_value)
  end
end
