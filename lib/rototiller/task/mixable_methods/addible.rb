module Rototiller
  module Task

    module Addible

      def add_something(what, where, *args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        things_to_add = []
        if block_given?
          # this would be a instance variable by the name of the value of where
          #where.push(Option.new(&block))
          things_to_add.push(what.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            where.push(what.new(arg))
            things_to_add.push(arg)
          end
          return things_to_add
        end
      end
    end
  end
end
