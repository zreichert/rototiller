module TestUtilities

  def random_string
    (0...10).map { ('a'..'z').to_a[rand(26)] }.join.upcase
  end

  def set_random_env_on(host)
    name = unique_env_on(host)
    host.add_env_var(name, random_string)
    return name
  end

  def unique_env_on(host)
    env = {}
    env_var = random_string

    # pars out the env on the sut
    on(host, 'printenv') do |r|
      r.stdout.split("\n").each do |line|
        l = line.split("=")
        env[l.first] = l.last
      end
    end
    env_var = random_string until !env[env_var]
    return env_var
  end

  def execute_task_on(host, task_name)
    step "Execute task '#{task_name}', ensure success"
    on(host, "rake #{task_name}", :accept_all_exit_codes => true) do |result|
      assert(result.exit_code == 0, "Unexpected exit code: #{result.exit_code}")
      assert_no_match(/error/i, result.output, "An unexpected error was observed: '#{result.output}'")
      return result
    end
  end

end
