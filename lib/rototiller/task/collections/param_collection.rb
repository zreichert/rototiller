require 'forwardable'

module Rototiller
  module Task

    class ParamCollection

      extend Forwardable

      def_delegators :@collection, :clear, :delete_if, :include?, :include, :inspect, :each, :[], :map

      # collect a given task's params
      def initialize
        @collection = []
      end

      def push(*args)
        check_classes(allowed_class, *args)
        @collection.push(*args)
      end

      # format the messages inside this ParamCollection
      # @param [Hash] filters any method from inner Type which can be used as a key
      # @option filters [String, false, true] :stop the value of the return from .stop on EnvVar
      # @option filters [String, false, true] :message_level the value of the return from .message_level on EnvVar
      # @option filters [String, false, true] :default the value of the return from .default on EnvVar
      # @option filters [String, false, true] :message the value of the return from .message on EnvVar
      # @option filters [String, false, true] :var the value of the return from .var on EnvVar
      # @return [String] messages from the contents of this ParamCollection, formatted with new lines and color
      # @example Get the messages where :stop is true & :message_level is :warning
      def format_messages(filters=nil)

        formatted_message = String.new
        build_message = lambda { |param| formatted_message << param.message << "\n"}
        filters ? filter_contents(filters).each(&build_message) : @collection.each(&build_message)
        formatted_message
      end

      #@private
      def filter_contents(filters={})

        filtered = []

        @collection.each do |param|

          filtered.push(param) if filters.all? do |method, value|

            if param.respond_to?(method)
              if param.send(method).nil?
                value.nil?
              else
                param.send(method).to_s =~ /#{value.to_s}/
              end
            end
          end
        end
        filtered
      end

      #@private
      def check_classes(allowed_klass, *args)

        args.each do |arg|

          unless arg.is_a?(allowed_klass)
            argument_error = "Argument was of class #{arg.class}, Can only be of class #{allowed_klass}"
            raise(ArgumentError, argument_error)
          end
        end
      end

      # Do any of the contents of this ParamCollection require the task to stop
      # @return [true, nil] should the values of this ParamCollection stop the task
      def stop?
        @collection.any?{ |param| param.stop }
      end

      private :filter_contents, :check_classes
    end

  end
end
