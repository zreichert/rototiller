require 'rototiller/task/collections/switch_collection'
require 'rototiller/task/params/option'

module Rototiller
  module Task

    # The OptionCollection class to collect more than one option for a Command
    #   delegates to Array via inheritance from ParamCollection
    # @since v1.0.0
    class OptionCollection < SwitchCollection

      # set allowed classes to be inserted into this Collection/Array
      # @return [Option] the collection's allowed class
      def allowed_class
        Option
      end

    end
  end
end
