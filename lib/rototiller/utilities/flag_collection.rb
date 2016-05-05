require 'rototiller/utilities/param_collection'

class FlagCollection < ParamCollection

  def push(*args)
    check_classes(CommandFlag, *args)
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
