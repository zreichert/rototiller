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
end
