sut = find_only_one('agent')

rake_version = `rake --version`.split[2]
on(sut, "gem install rake -v #{rake_version}")
