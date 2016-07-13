module RakefileTools

  def create_rakefile_on(sut, rakefile_contents)
    # using blocks for step in here causes beaker to not un-indent log
    step 'Copy rake file to SUT'
    path_to_rakefile = '/root/Rakefile'

    teardown do
      step 'Remove Rakefile on SUT'
      on(sut, "rm -f #{path_to_rakefile}" )
    end

    create_remote_file(sut, path_to_rakefile, rakefile_contents)
    return path_to_rakefile
  end
end
