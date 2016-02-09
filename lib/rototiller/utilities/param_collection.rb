require 'rototiller/utilities/flag'
require 'rototiller/utilities/env_var'
require 'forwardable'

class ParamCollection

  # This may be useful if we use individual ParamCollection objects for EnvVars and Flags
  extend Forwardable

  def_delegators :@collection, :clear, :delete_if, :include?, :include, :inspect

  # a class to collect and check a tasks params
  # EnvVar or Flag
  def initialize
    @argument_error = 'Argument can not be of class'
    @allowed_contents = [EnvVar, Flag]
    @collection = []
  end

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

  def stop?
    # do any of the contents require the task to stop?
    @collection.any?{ |param| param.stop }
  end

  private :filter_contents
end
