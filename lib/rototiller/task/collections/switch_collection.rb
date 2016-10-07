require 'rototiller/task/collections/param_collection'
require 'rototiller/task/params/switch'

module Rototiller
  module Task

    class SwitchCollection < ParamCollection

      def allowed_class
        Switch
      end

      # convert a SwitchCollection to a string (runable switch portions of a command string)
      # @return [String]
      def to_str
        @collection.join(' ').to_s
      end
      alias :to_s :to_str

    end

  end
end
