require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'C97798: existing workflows shall be supported for using ENV vars to override command flags' do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  step 'Test flags that will let command continue' do

    test_filename = File.basename(__FILE__, '.*')
    command_flags = [
      {:name => '--setenv-nodefault', :override_env => "NODEFAULT_#{test_filename.upcase}", :exists => true},
      {:name => '--setenv-default',                                                         :exists => true, :default => 'Author specified default', :block_syntax => true},
    ]
    command_flags = command_flags.each{|e| e[:type] = :option }


    @task_name    = 'command_flags_with_override'
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(command_flags)}
    t.add_command({:name => 'echo'})
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      command_flags.each do |flag|
        value = flag[:default] || "#{flag[:override_env]}: env present value"
        command_regex = /#{flag[:name]} #{value}/
        rototiller_output_regex = /The CLI flag '#{flag[:name]}' will be used with value '#{value}'/

        assert_match(command_regex, result.stdout, "The expected output from rototiller was not observed")
        assert_match(rototiller_output_regex, result.stdout, "The flag #{flag[:name]} was not observed on the command line")
      end
    end
  end

  step 'Test flags that will stop the rake task' do

    # todo flags that will stop
    command_flags = [
      {:name => '--unset-nodefault', :override_env => 'NOTSET'},
    ]
    command_flags = command_flags.each{|e| e[:type] = :option }

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
      on(sut, "rake #{@task_name} --rakefile #{rakefile_path}", :accept_all_exit_codes => true) do |result|
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
    command_flags = command_flags.each{|e| e[:type] = :option }

    @task_name    = 'command_flags_that_stop_rake'
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(command_flags)}
    t.add_command({:name => 'echo'})
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      command_flags.each do |flag|
        regex = /The CLI flag #{flag[:name]} has no value assigned and will not be included./
        assert_match(regex, result.stdout, "The expected output from rototiller for an optional flag was not observed.")
      end
    end
  end

end
