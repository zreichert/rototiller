require 'rototiller/utilities/param_collection'

class EnvCollection < ParamCollection

  def push(*args)
    check_classes(EnvVar, *args)
    super
  end

end
