require 'rototiller/task/collections/param_collection'
require 'rototiller/task/params/env_var'

module Rototiller
  module Task

    class EnvCollection < ParamCollection
      def allowed_class
        EnvVar
      end
    end

  end
end
