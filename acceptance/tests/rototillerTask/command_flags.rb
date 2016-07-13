require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97820: can set key/value flag in a RototillerTask' do
  extend Beaker::Hosts
  extend RakefileTools

  def create_rakefile_task_segment(flags)
    segment = ''
    flags.each do |flag|
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
    [:block_syntax].each do |key|
      hash.delete(key)
    end
    return hash
  end

  command_flags = [
      {:name => '--hash-syntax',  :default => 'wow such hash syntax'},
      {:name => '--use-a-block',   :default => 'wow much block syntax', :block_syntax => true}
  ]


  @task_name    = 'command_flag_testing_key_value'
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
        command_regex = /#{flag[:name]} #{flag[:default]}/
        rototiller_output_regex = /The CLI flag '#{flag[:name]}' will be used with value '#{flag[:default]}'/
        assert_match(command_regex, result.stdout, "The expected output from rototiller was not observed")
        assert_match(rototiller_output_regex, result.stdout, "The flag #{flag[:name]} was not observed on the command line")
      end
    end
  end
end
