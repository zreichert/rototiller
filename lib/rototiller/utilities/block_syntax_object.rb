module Rototiller
  class Block_syntax

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
end