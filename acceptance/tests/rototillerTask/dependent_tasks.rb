require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97794: ensure RototillerTasks can be parent/child tasks' do
  extend Beaker::Hosts
  extend RakefileTools

  ['rototiller_task', 'Rototiller::Task::RototillerTask.define_task'].each do |new_task_method|
    rakefile_contents = <<-EOS
  $LOAD_PATH.unshift('/root/rototiller/lib')
  require 'rototiller'

  task :child do |t|
    system('echo "i am the native child"')
  end
  task :parent => [:r_child, :child] do |t|
    system('echo "i am the native parent"')
  end
  #{new_task_method} :r_child do |t|
    t.command = 'echo "i am the tiller child"'
  end
  #{new_task_method} :r_parent => [:r_child, :child] do |t|
    t.command = 'echo "i am the tiller parent"'
  end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step "Execute task defined in rake task 'r_parent'" do
      on(sut, "rake r_parent", :accept_all_exit_codes => true) do |result|
        assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed')
        assert_match(/tiller child.*native child.*tiller parent/m, result.output, 'r_parent: not all children were called')
      end
      on(sut, "rake parent", :accept_all_exit_codes => true) do |result|
        assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed')
        assert_match(/tiller child.*native child.*native parent/m, result.output, 'parent: not all children were called')
      end
    end
  end
end
