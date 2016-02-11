require 'rototiller/utilities/command_flag'
require 'rototiller/utilities/env_var'
require 'forwardable'

class ParamCollection

  # This may be useful if we use individual ParamCollection objects for EnvVars and Flags
  extend Forwardable

  def_delegators :@collection, :clear, :delete_if, :include?, :include, :inspect

  # collect a given task's params
  def initialize
    @argument_error = 'Argument can not be of class'
    @allowed_contents = [EnvVar, CommandFlag]
    @collection = []
  end

  # push a param or params into the ParamCollection
  # @param args [EnvVar, Flag] an instance of the EnvVar or Flag class
  def push_params(*args)

    # Only allows classes inside @allowed_contents to be pushed
    # behaves like push
    # unlimited number of arguments allowed
    args.each do |arg|
      if @allowed_contents.none? { |klass| arg.is_a?(klass) }
        @argument_error << arg.class.to_s
        raise(ArgumentError, @argument_error)
      end
    end

    @collection.push(*args)
  end

  # format the messages inside this ParamCollection
  # @param [Hash] filters any method from EnvVar can be used as a key
  # @option filters [String, false, true] :stop the value of the return from .stop on EnvVar
  # @option filters [String, false, true] :message_level the value of the return from .message_level on EnvVar
  # @option filters [String, false, true] :default the value of the return from .default on EnvVar
  # @option filters [String, false, true] :message the value of the return from .message on EnvVar
  # @option filters [String, false, true] :var the value of the return from .var on EnvVar
  # @return [String] messages from the contents of this ParamCollection, formatted with new lines and color
  # @example Get the messages where :stop is true & :message_level is :warning
    'format_message({:stop => true, :message_level => :warning})'
  def format_messages(filters=nil)
    # Example use
    # format_message({:stop => true, :message_level => :warning})
    formatted_message = String.new
    build_message = lambda { |param| formatted_message << param.message << "\n"}
    filters ? filter_contents(filters).each(&build_message) : @collection.each(&build_message)
    formatted_message
  end

  def filter_contents(filters={})
    filtered = []
    @collection.each do |param|
      filtered.push(param) if filters.all? do |method, value|
        if param.send(method) == nil
          value == nil
        else
          param.send(method).to_s =~ /#{value.to_s}/
        end
      end
    end
    filtered
  end

  # Do any of the contents of this ParamCollection require the task to stop
  # @return [true, nil] should the values of this ParamCollection stop the task
  def stop?
    # do any of the contents require the task to stop?
    @collection.any?{ |param| param.stop }
  end

  private :filter_contents
end
