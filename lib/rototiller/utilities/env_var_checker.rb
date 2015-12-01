require 'rototiller/utilities/color_text'

module EnvVar

  include ColorText

  @@vars = []
  @@env = Struct.new(:name, :message, :default_value)

  def check_env_vars
    required_vars = []
    @@vars.each do |v|
      if v.default_value
        # check if set, then set default if no value present
        yellow = yellow_text("WARNING: the variable #{v.name} is not set, proceeding with default value: ")
        green = green_text(v.default_value)
        puts yellow << green
        set_default_value(v)
      else
        # var is required
        # ad var to required_vars array if no value is set
        required_vars.push(v) unless ENV[v.name]
      end
    end
    abort_message = 'Aborting Rake:'
    required_vars.each{ |v| abort_message << red_text("\nThe environment variable #{v.name} is required. #{v.message}")}
    raise ArgumentError.new(abort_message) unless required_vars.empty?
  end

  def set_default_value(var)
    ENV[var.name] = var.default_value
  end

  def track_env_var(var, message, required=false)
    @@vars.push(@@env.new(var, message, required))
  end

end
