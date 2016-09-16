require 'rototiller/task/collections/param_collection'

module Rototiller
  module Task

    class OptionsCollection < ParamCollection

      def push(*args)
        check_classes(CommandOption, *args)
        super
      end

      # Joins contents into a String, works with no value flags and flags with value
      # @return [String] flags formatted into a single string
      def to_s

        flag_str = String.new

        @collection.each do |flag|
          if (flag.value.nil? || flag.value.empty?) && !flag.required
            #do nothing
          elsif flag.value.nil?
            flag_str << flag.flag << ' '
          else
            flag_str << flag.flag << ' ' << flag.value << ' '
          end
        end

        flag_str.rstrip
      end
    end

  end
end
