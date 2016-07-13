require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'C97798: existing workflows shall be supported for using ENV vars to override command flags' do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  def create_rakefile_task_segment(flags)
    segment = ''
    flags.each do |flag|
      sut.add_env_var(flag[:override_env], "#{flag[:override_env]}: env present value") if flag[:exists]
      if flag[:block_syntax]
        segment += "t.add_flag do |flag|\n"
        remove_reserved_keys(flag).each do |k, v|
          segment += "  flag.#{k.to_s} = '#{v}'\n"
        end
        segment += "end\n"
      else
        segment += "  t.add_flag({"
        remove_reserved_keys(flag).each do |k, v|
          segment += ":#{k} => '#{v}',"
        end
        segment += "})\n"
      end
    end
    return segment
  end

  def remove_reserved_keys(h)
    hash = h.dup
    [:block_syntax, :exists].each do |key|
      hash.delete(key)
    end
    return hash
  end

  step 'Test flags that will let command continue' do

    test_filename = File.basename(__FILE__, '.*')
    command_flags = [
      {:name => '--setenv-nodefault', :override_env => "NODEFAULT_#{test_filename.upcase}", :exists => true},
      {:name => '--setenv-default', :block_syntax => true, :exists => true, :default => 'Author specified default'},
    ]


    @task_name    = 'command_flags_with_override'
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(command_flags)}
    t.add_command({:name => 'echo'})
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step 'Execute task defined in rake task' do
      on(sut, "rake #{@task_name}", :accept_all_exit_codes => true) do |result|
        # exit code & no error in output
        assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed')

        command_flags.each do |flag|
          value = flag[:default] || "#{flag[:override_env]}: env present value"
          command_regex = /#{flag[:name]} #{value}/
          rototiller_output_regex = /The CLI flag '#{flag[:name]}' will be used with value '#{value}'/

          assert_match(command_regex, result.stdout, "The expected output from rototiller was not observed")
          assert_match(rototiller_output_regex, result.stdout, "The flag #{flag[:name]} was not observed on the command line")
        end
      end
    end
  end

  step 'Test flags that will stop the rake task' do

    # todo flags that will stop
    command_flags = [
      {:name => '--unset-nodefault', :override_env => 'NOTSET'},
    ]

    @task_name    = 'command_flags_that_stop_rake'
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(command_flags)}
    t.add_command({:name => 'echo'})
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step 'Execute task defined in rake task' do

      on(sut, "rake #{@task_name}", :accept_all_exit_codes => true) do |result|
        # exit code & no error in output
        assert(result.exit_code == 1, 'The expected exit code 1 was not observed')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed')

        command_flags.each do |flag|
          regex = /The CLI flag '#{flag[:name]}' needs a value.\nYou can specify this value with the environment variable '#{flag[:override_env]}'/
          assert_match(regex, result.stdout, "The expected output from rototiller was not observed")
        end
      end
    end
  end

  step 'Test flags that are not required' do
    override = random_string
    command_flags = [
        {:name => '--not-required', :override_env => 'required_override', :required => false},
        {:name => '--not-required-with-default', :override_env => override, :default => 'def_val', :required => false},
    ]

    @task_name    = 'command_flags_that_stop_rake'
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(command_flags)}
    t.add_command({:name => 'echo'})
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step 'Execute task defined in rake task' do

      on(sut, "rake #{@task_name} #{override}=''", :accept_all_exit_codes => true) do |result|
        # exit code & no error in output
        assert(result.exit_code == 0, 'The expected exit code 0 was not observed, (non-required flags)')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed (non-required flags)')

        command_flags.each do |flag|
          regex = /The CLI flag #{flag[:name]} has no value assigned and will not be included./
          assert_match(regex, result.stdout, "The expected output from rototiller for an optional flag was not observed.")
        end
      end
    end
  end
end
