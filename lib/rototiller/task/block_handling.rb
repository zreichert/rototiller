old =<<-OLD
module Rototiller
  module Task
    module BlockHandling

      class BlockSyntax

        def initialize(param_array, module_array)
          self.class.class_eval do
            param_array.each { |i| attr_accessor i }
            module_array.each do |m|
              include m
            end
          end
        end

        def to_h
          h = Hash.new
          self.instance_variables.each do |var|
            h[var.to_s.delete('@').to_sym] = self.instance_variable_get(var)
          end
          h
        end
      end

      # creates a hash of attributes from a block and array of parameter names
      #   that match method calls in the block
      # @param [Array<Symbol>] param_array the parameters to pull from the block
      # for block { |b| ... }
      # @yield object with attributes matching param_array
      # @return [Hash] hash of param_arr
ay keys and their values from the block
      def pull_params_from_block(param_array, module_array, &block)
        block_syntax_obj = BlockSyntax.new(param_array, module_array)
        yield(block_syntax_obj)
        block_syntax_obj.to_h
      end

    end
  end
end
OLD

module Rototiller
  module Task
    module BlockHandling

      class BlockSyntax

        def initialize(param_array, module_array)

          self.class.class_eval do

            # what modules need to be mixed in???
            module_array.each do |m|
              # mix in the module
              include m
            end
            # create setter and getter methods for all that need it
            param_array.each{ |p| attr_accessor p }
            attr_accessor :env_vars, :options
          end
          # add possible collection
          # this is a bit cludgy :(
          @env_vars = Rototiller::Task::EnvCollection.new
          @options = Rototiller::Task::OptionsCollection.new
        end

        #TODO might need new data structure
        def to_h
          h = Hash.new
          self.instance_variables.each do |var|
            h[var.to_s.delete('@').to_sym] = self.instance_variable_get(var)
          end
          require 'pry'; binding.pry
          h
        end
      end

      # creates a hash of attributes from a block and array of parameter names
      #   that match method calls in the block
      # @param [Array<Symbol>] param_array the parameters to pull from the block
      # for block { |b| ... }
      # @yield object with attributes matching param_array
      # @return [Hash] hash of param_array keys and their values from the block
      def pull_params_from_block(param_array, module_array, &block)
        block_syntax_obj = BlockSyntax.new(param_array, module_array)
        yield(block_syntax_obj)
        block_syntax_obj.to_h
      end

    end
  end
end