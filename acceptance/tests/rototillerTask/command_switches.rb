require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97821: can set switches (boolean options) for commands in a RototillerTask' do
  extend Beaker::Hosts
  extend RakefileTools

  test_filename = File.basename(__FILE__, '.*')

  def create_rakefile_task_segment(flags)
    segment = ''
    flags.each.with_index do |flag,index|
      sut.add_env_var(flag[:override_env], flag[:env_value]) if flag[:override_env]
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
    [:block_syntax, :env_value].each do |key|
      hash.delete(key)
    end
    return hash
  end

  command_flags = [
      {:name => '--name1',                  :is_boolean => true},
      {:name => '--name2',  :default => '', :is_boolean => true},
      {:name => '--name3',                  :is_boolean => true, :override_env => 'NODEFAULT1',  :env_value => 'VAL1'},
      {:name => '--name4',  :default => '', :is_boolean => true, :override_env => 'HASDEFAULT1', :env_value => 'VAL2'},
      {:name => '--name5',                  :is_boolean => true, :override_env => 'NODEFAULT2',  :env_value => ''},
      {:name => '--name6',  :default => '', :is_boolean => true, :override_env => 'HASDEFAULT2', :env_value => ''},
      {:name => '--name7',                  :is_boolean => true,                                                        :block_syntax => true},
      {:name => '--name8',  :default => '', :is_boolean => true,                                                        :block_syntax => true},
      {:name => '--name9',                  :is_boolean => true, :override_env => 'NODEFAULT3',  :env_value => 'VAL3',  :block_syntax => true},
      {:name => '--nameA',  :default => '', :is_boolean => true, :override_env => 'HASDEFAULT3', :env_value => 'VAL4',  :block_syntax => true},
      {:name => '--nameB',                  :is_boolean => true, :override_env => 'NODEFAULT4',  :env_value => '',      :block_syntax => true},
      {:name => '--nameC',  :default => '', :is_boolean => true, :override_env => 'HASDEFAULT4', :env_value => '',      :block_syntax => true},
  ]


  @task_name    = test_filename
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

      # i plainly refuse to re-implement rototiller's is_boolean option logic here
      expected_out = <<-HERE
\e[32mThe CLI switch '--name1' will be used.\e[0m
\e[33mThe CLI switch '--name2' will NOT be used.\e[0m
\e[32mThe CLI switch 'VAL1' will be used.\e[0m
\e[32mThe CLI switch 'VAL2' will be used.\e[0m
\e[33mThe CLI switch '--name5' will NOT be used.\e[0m
\e[33mThe CLI switch '--name6' will NOT be used.\e[0m
\e[32mThe CLI switch '--name7' will be used.\e[0m
\e[33mThe CLI switch '--name8' will NOT be used.\e[0m
\e[32mThe CLI switch 'VAL3' will be used.\e[0m
\e[32mThe CLI switch 'VAL4' will be used.\e[0m
\e[33mThe CLI switch '--nameB' will NOT be used.\e[0m
\e[33mThe CLI switch '--nameC' will NOT be used.\e[0m

--name1 VAL1 VAL2 --name7 VAL3 VAL4
HERE
      assert_equal(expected_out,result.output, 'output did not match')

    end
  end
end
