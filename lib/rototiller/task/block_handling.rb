module Rototiller
  module Task
    module BlockHandling

      class BlockSyntax

        def initialize(param_array)
          self.class.class_eval { param_array.each { |i| attr_accessor i } }
        end

        def to_h
          h = Hash.new
          self.instance_variables.each do |var|
            h[var.to_s.delete('@').to_sym] = self.instance_variable_get(var)
          end
          h
        end
      end

      def pull_params_from_block(param_array, &block)
        block_syntax_obj = Rototiller::BlockSyntax.new(param_array)
        yield(block_syntax_obj)
        block_syntax_obj.to_h
      end

    end
  end
end
