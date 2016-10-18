require 'rototiller/task/hash_handling'

module Rototiller
  module Task

    class RototillerParam

      include HashHandling

      #TODO add initialize method to this base class
      # the initialization of every RototillerParam shares common elements
      # its possible to DRY out these common elements into this base class
      # the differences can be implemented in a individual classes implementation
      # with a super to call back to this base class

      attr_accessor :name, :message

      def message
        ''
      end

      def stop
        false
      end

    end

  end
end
