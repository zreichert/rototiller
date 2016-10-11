module RakefileTools

  def create_rakefile_on(sut, rakefile_contents)
    # using blocks for step in here causes beaker to not un-indent log
    path_to_rakefile = ''
    step 'Copy rake file to SUT' do
      # bit hackish.  find name of calling file (from the stack) minus the extension
      test_name = File.basename(caller[0].split(':')[0], '.*')
      path_to_rakefile = "/tmp/Rakefile_#{test_name}_#{random_string}"

      create_remote_file(sut, path_to_rakefile, rototiller_rakefile_header + rakefile_contents)
    end
    return path_to_rakefile
  end

  def create_rakefile_task_segment(segment_configs)
    segment = ''
    segment_configs.each do |this_segment|
      if this_segment[:type] == :env
        sut.add_env_var(this_segment[:name], "#{this_segment[:name]}: env present value") if this_segment[:exists]
        add_type = 'add_env'
      elsif this_segment[:type] == :option
        sut.add_env_var(this_segment[:override_env], "#{this_segment[:override_env]}: env present value") if this_segment[:exists]
        add_type = 'add_flag'
      elsif this_segment[:type] == :switch
        sut.add_env_var(this_segment[:override_env], this_segment[:env_value]) if this_segment[:override_env]
        add_type = 'add_flag'
      end
      if this_segment[:block_syntax]
        segment += "t.#{add_type} do |this_segment|\n"
        remove_reserved_keys(this_segment).each do |k, v|
          segment += "  this_segment.#{k.to_s} = '#{v}'\n"
        end
        segment += "end\n"
      else
        segment += "  t.#{add_type}({"
        remove_reserved_keys(this_segment).each do |k, v|
          segment += ":#{k} => '#{v}',"
        end
        segment += "})\n"
      end
    end
    return segment
  end

  def rototiller_rakefile_header
    header = <<-HEADER
      require 'rototiller'
    HEADER
  end

end
