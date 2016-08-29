require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'C97821: can set switches (boolean options) for commands in a RototillerTask' do
  skip_test 'switches disabled for now'
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  test_filename = File.basename(__FILE__, '.*')

  def create_rakefile_task_segment(switches)
    segment = ''
    switches.each.with_index do |switch,index|
      sut.add_env_var(switch[:override_env], switch[:env_value]) if switch[:override_env]
      if switch[:block_syntax]
        segment += "t.add_flag do |switch|\n"
        remove_reserved_keys(switch).each do |k, v|
          segment += "  switch.#{k.to_s} = '#{v}'\n"
        end
        segment += "end\n"
      else
        segment += "  t.add_flag({"
        remove_reserved_keys(switch).each do |k, v|
          segment += ":#{k} => '#{v}',"
        end
        segment += "})\n"
      end
    end
    return segment
  end

  command_switches = [
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
  command_switches = command_switches.each{|e| e[:type] = :switch }

  @task_name    = test_filename
  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(command_switches)}
    t.add_command({:name => 'echo'})
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  execute_task_on(sut, @task_name, rakefile_path) do |result|
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
