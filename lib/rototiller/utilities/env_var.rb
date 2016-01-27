require 'rototiller/utilities/color_text'

class EnvVar

  include ColorText

  attr_accessor :var, :message, :default

  def initialize(var, message, default = nil)
    @var = var
    @message = message
    @default = default
  end

  def value
    ENV[@var] || @default
  end

  def message

    if @default && check
      # ENV is present and it has a default value
      green_text("The ENV #{@var} is being used with the value #{value} from the environment")
    elsif !@default && !check
      # ENV is not Present and it has no default value
      red_text("The ENV #{@var} is required, #{@message}")
    elsif !@default && check
      # ENV is present and it has no default value
      green_text("The ENV #{@var} was found in the environment with the value #{value}")
    elsif @default && !check
      # ENV is not present and it has default value
      yellow = yellow_text("WARNING: the ENV #{@var} is not set, proceeding with default value: ")
      green = green_text(value)
      yellow << green
    end
  end

  private
  def check
    ENV.key?(@var)
  end
end
