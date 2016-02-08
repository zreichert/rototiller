require 'rototiller/utilities/color_text'

class EnvVar

  include ColorText

  attr_accessor :var, :message, :default

  # @return [Symbol] the debug level of the message, ':warning', ':error', ':info'
  attr_reader :message_level

  # @return [true, nil] if the state of the EnvVar requires the task to stop
  attr_reader :stop

  # Creates a new instance of EnvVar, holds information about the ENV in the environment
  # @param var [String] the ENV in the environment, 'HOME'
  # @param message [String] the message describing the ENV
  # @param default [String] the value to use as the default if the ENV is not present
  def initialize(var, message, default=false)
    @var = var
    @message = message
    @default = default
    set_message_level
  end

  # The value of the ENV determined by the EnvVar class
  # @return [String] the value determined by the EnvVar class
  def value
    ENV[@var] || @default
  end

  # The formatted message to be displayed to the user
  # @return [String] the EnvVar's message, formatted for color and meaningful to the state of the EnvVAr
  def message
    if message_level == :error
      red_text("The ENV #{@var} is required, #{@message}")
    elsif message_level == :info
      green_text("The ENV #{@var} was found in the environment with the value #{value}")
    elsif message_level == :warning
      yellow_text("WARNING: the ENV #{@var} is not set, proceeding with default value: #{@default}")
    end
  end

  private
  def check
    ENV.key?(@var)
  end

  def set_message_level
    if !@default && !check
      # ENV is not Present and it has no default value
      @message_level = :error
      @stop = true
    elsif !@default && check || @default && check
      # ENV is present and it has no default value
      @message_level = :info
    elsif @default && !check
      # ENV is not present and it has default value
      @message_level = :warning
    end
  end
end
