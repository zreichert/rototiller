module RakefileTools

  def create_rakefile_on(sut, rakefile_contents)
    # using blocks for step in here causes beaker to not un-indent log
    step 'Copy rake file to SUT'
    # bit hackish.  find name of calling file (from the stack) minus the extension
    test_name = File.basename(caller[0].split(':')[0], '.*')
    path_to_rakefile = "/tmp/Rakefile_#{test_name}_#{random_string}"

    create_remote_file(sut, path_to_rakefile, rakefile_contents)
    return path_to_rakefile
  end

  def rototiller_rakefile_header
    header = <<-HEADER
      $LOAD_PATH.unshift('/root/rototiller/lib')
      require 'rototiller'

    HEADER
  end

end
