require 'rototiller/utilities/color_text'

class EnvVar

  include ColorText

  attr_accessor :var, :message, :default
  attr_reader :message_level, :stop

  def initialize(var, message, default=false)
    @var = var
    @message = message
    @default = default
    set_message_level
  end

  def value
    ENV[@var] || @default
  end

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
