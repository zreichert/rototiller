require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'C97820: can set key/value flag in a RototillerTask' do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  command_flags = [
      {:name => '--hash-syntax', :default => 'wow such hash syntax'},
      {:name => '--use-a-block', :default => 'wow much block syntax', :block_syntax => true}
  ]
  command_flags = command_flags.each{|e| e[:type] = :option }


  @task_name    = 'command_flag_testing_key_value'
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
      command_regex = /#{flag[:name]} #{flag[:default]}/
      rototiller_output_regex = /The CLI flag '#{flag[:name]}' will be used with value '#{flag[:default]}'/
      assert_match(command_regex, result.stdout, "The expected output from rototiller was not observed")
      assert_match(rototiller_output_regex, result.stdout, "The flag #{flag[:name]} was not observed on the command line")
    end
  end

end
