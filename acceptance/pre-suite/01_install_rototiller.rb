sut = find_only_one('agent')

# copy dir to SUT
source_path = File.expand_path('./')
scp_to(sut, source_path, '/root')
