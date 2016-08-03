require 'rototiller/task/collections/param_collection'
require 'rototiller/task/params/command'

module Rototiller
  module Task

    class CommandCollection < ParamCollection

      def push(*args)
        check_classes(Command, *args)
        super
      end

    end

  end
end
