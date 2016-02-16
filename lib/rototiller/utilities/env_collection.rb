require 'rototiller/utilities/param_collection'

class EnvCollection < ParamCollection

  def push(*args)
    check_classes(EnvVar, *args)
    super
  end

  # Do any of the contents of this ParamCollection require the task to stop
  # @return [true, nil] should the values of this ParamCollection stop the task
  def stop?
    @collection.any?{ |param| param.stop }
  end
end
