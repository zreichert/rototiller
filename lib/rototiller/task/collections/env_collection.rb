require 'rototiller/task/collections/param_collection'

module Rototiller
  module Task

    class EnvCollection < ParamCollection

      def push(*args)
        check_classes(EnvVar, *args)
        super
      end

    end

  end
end
