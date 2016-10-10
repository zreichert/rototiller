require 'rototiller/task/collections/param_collection'
require 'rototiller/task/params/switch'

module Rototiller
  module Task

    # The SwitchCollection class to collect more than one switch for a Command
    #   delegates to Array via inheritance from ParamCollection
    # @since v1.0.0
    class SwitchCollection < ParamCollection

      # set allowed classes to be inserted into this Collection/Array
      # @return [Switch] the collection's allowed class
      def allowed_class
        Switch
      end

      # convert a SwitchCollection to a string (runable switch portions of a command string)
      #   the value sent by author, or overridden by any EnvVar
      # @return [String] the Switch's value
      def to_str
        @collection.join(' ').to_s
      end
      alias :to_s :to_str

    end

  end
end
