require 'rototiller/task/hash_handling'

module Rototiller
  module Task

    class RototillerParam
      #include BlockHandling
      include HashHandling

      #TODO add initialize method to this base class

      attr_accessor :name, :message

      def message
        ''
      end

    end

  end
end
