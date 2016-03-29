sut = find_only_one('agent')

# copy dir to SUT
source_path = File.expand_path('./')
excludes = ['.bundle', '.rubocop.yml', '.git', 'coverage', '.gitignore',
                  'Gemfile.lock', 'junit', 'log']
scp_to(sut, source_path, '/root', {:ignore => excludes})
