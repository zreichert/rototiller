require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'C97797: ensure environment variable operation in RototillerTasks' do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  def create_rakefile_task_segment(envs)
    segment = ''
    envs.each do |env|
      sut.add_env_var(env[:name], "#{env[:name]}: present value") if env[:exists]
      if env[:block_syntax]
        segment += "t.add_env do |env|\n"
        remove_reserved_keys(env).each do |k, v|
          segment += "  env.#{k.to_s} = '#{v}'\n"
        end
        segment += "end\n"
      else
        segment += "  t.add_env({"
        remove_reserved_keys(env).each do |k, v|
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

  step 'For environment variables that will succeed' do
    env_vars = [
      {:name => 'NO_DEFAULT-EXISTS',        :message => 'no default, previously exists',
       :exists => true},
      {:name => 'DEFAULT-EXISTS',           :message => 'default, previously exists',
       :exists => true,   :default => 'present default value'},
      {:name => 'DEFAULT-NO_EXISTS',        :message => 'default, does notpreviously exist',
       :exists => false,  :default => 'DEFAULT-NO_EXISTS: notpresent default value'},
      {:name => 'DEFAULT-EXISTS-BLOCK',     :message => 'default, previously exists',
       :exists => true,   :default => 'present default value',  :block_syntax => true},
      {:name => 'DEFAULT-NO_EXISTS-BLOCK',  :message => 'default, does notpreviously exist',
       :exists => false,  :default => 'DEFAULT-NO_EXISTS-BLOCK: notpresent default value',  :block_syntax => true},
      {:name => 'NO_DEFAULT-EXISTS-BLOCK',  :message => 'no default, previously exists',
       :exists => true,   :block_syntax => true},
    ]

    @task_name    = 'env_var_testing_task'
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(env_vars)}
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    execute_task_on(sut, @task_name) do |result|
      env_vars.each do |env|
        # validate notification to user of ENV value
        rototiller_message_match = env[:exists] ?
          /INFO:.*'#{env[:name]}'.*value:.*present value': #{env[:message]}/m :
          /INFO:.*'#{env[:name]}'.*value:.*notpresent default value': #{env[:message]}/
          assert_match(rototiller_message_match, result.stdout,
                       "The expected messaging was not observed for: '#{env[:name]}")

          # Use test command output to validate value of ENV used by task
          task_out_match = env[:exists] ? /#{env[:name]}: present value/m :
            /#{env[:name]}: notpresent default value/m
            assert_match(task_out_match, result.stdout,
                         "The printed env was different than expected for: '#{env[:name]}'")
      end
    end
  end

  step 'For environment variables that will fail' do
    env_vars_fail = [
      {:name => 'NO_DEFAULT-NO_EXISTS', :message => 'no default, does not previously exist',
       :exists => false},
      {:name => 'NO_DEFAULT-NO_EXISTS-BLOCK', :message => 'no default, does not previously exist',
       :exists => false},
    ]
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(env_vars_fail)}
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step 'Execute task defined in rake task' do
      on(sut, "rake #{@task_name}", :accept_all_exit_codes => true) do |result|
        # exit code & no error in output
        assert(result.exit_code == 1, 'The expected exit code 1 was not observed')

        env_vars_fail.each do |env|
          # validate notification to user of ENV value
          rototiller_message_match = /ERROR:.*'#{env[:name]}' is required: #{env[:message]}/
            assert_match(rototiller_message_match, result.stdout,
                         "The expected messaging was not observed for: '#{env[:name]}")
        end
      end
    end
  end

end
