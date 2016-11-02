require 'rototiller/task/params/argument'
require 'rototiller/task/collections/switch_collection'

module Rototiller
  module Task

    class ArgumentCollection < SwitchCollection
      def allowed_class
        Argument
      end
    end

  end
end