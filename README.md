# Rototiller

A [Rake](https://github.com/ruby/rake) helper for command-oriented tasks.

* simplifies the building of command strings in :rototiller_task for task authors
* abstracts the overriding of command string components: commands, flags, arguments for task users
* unifies and standardizes messaging surrounding the use of environment variables for task operations
* Provides a tool that can house shared rake task code for Puppet.
* Reduce duplication in Rakefiles across projects at Puppet.
* Reduce effort required to write first class rake tasks.
* Reduce time and effort trying to understand requirement to run rake tasks.
* Provide a standard interface for executing tests in a given test tier regardless of framework (Not MVP)

## Install
    gem install rototiller

## Write
Rototiller provides a Rake DSL addition called 'rototiller_task' which is a fully featured Rake task with environment variable handling, messaging and command-string-building functionality.

    require 'rototiller'

    desc "task dependencies work. this one also uses an environment variable"
    rototiller_task :parent_task do |task|
      # most method initializers take either a hash, or block syntax (see next task)
      task.add_env({:name     => 'RANDOM_VAR', :default => 'default value'})
      task.add_command({:name => "echo 'i am testing everything with $RANDOM_VAR = #{ENV['RANDOM_VAR']}'"})
    end

    desc "override command-name with environment variable"
    rototiller_task :test => :parent_task do |task|
      # block syntax here. We give up some lines for more readability
      task.add_command do |cmd|
        cmd.name         = 'test'
        cmd.override_env = 'ECHO_EXECUTABLE'
      end
      task.add_flag({:name => '-f', :default => 'Rakefile'})
    end

    desc "override flag values with environment variables"
    rototiller_task :test_flag_env do |task|
      task.add_command do |cmd|
        cmd.name = 'test'
      end
      task.add_flag do |flag|
        flag.name         = '-f'
        flag.default      = 'Rakefile'
        flag.override_env = 'FLAG_VALUE'
      end
    end

    desc "do not include flag if the final value (either the default or override_env) is nil or empty and not required"
    rototiller_task :test_flag_env do |task|
      task.add_command do |cmd|
        cmd.name = 'test'
      end
      task.add_flag do |flag|
        flag.name         = '-f'
        flag.default      = ''
        flag.override_env = 'FLAG_VALUE'
        flag.required     = false
      end
    end

    desc "override command argument values with environment variables"
    rototiller_task :test_arg_env do |task|
      task.add_command do |cmd|
        cmd.name                  = 'ls'
        cmd.argument              = 'Rakefile'
        cmd.argument_override_env = 'FILENAME'
      end
    end

## Use
(with the above sample Rakefile)

    $) rake -T
    rake parent_task  # some parent task
    rake test         # test all the things

    $) rake -D
    rake parent_task
        task dependencies work. this one also uses an environment variable
    rake test
        override command-name with environment variable

    # added environment variable defaults are set, implicitly, if not found
    #   this way, their value can be used in the task
    $) rake test
    INFO: The environment variable: 'RANDOM_VAR' was found with value: 'default value':
    i am testing everything with $RANDOM_VAR = default value
    The CLI flag -f will be used with value Rakefile.

    $) rake parent_task RANDOM_VAR=redrum
    INFO: The environment variable: 'RANDOM_VAR' was found with value: 'redrum':
    i am testing everything with $RANDOM_VAR = redrum

    $) rake test ECHO_EXECUTABLE='ls' --verbose
    INFO: The environment variable: 'RANDOM_VAR' was found with value: 'default value':
    echo 'i am testing everything with $RANDOM_VAR = default value'
    i am testing everything with $RANDOM_VAR = default value
    The CLI flag -f will be used with value Rakefile.

    ls -f Rakefile
    Rakefile

    $) rake test_flag_env
    The CLI flag -f will be used with value Rakefile.
    $) echo $?
    0

    $) rake test_flag_env --verbose
    The CLI flag -f will be used with value Rakefile.

    test -f Rakefile

    $) rake test_flag_env --verbose FLAG_VALUE='README.md'
    The CLI flag -f will be used with value README.md.

    test -f README.md

    $) rake test_flag_env --verbose FLAG_VALUE='nonesuch'
    The CLI flag -f will be used with value README.md.

    test -f README.md
    test -f nonesuch failed

    $) rake test_arg_env
    Rakefile

    $) rake test_arg_env FILENAME=README.md
    README.md

## Issues

* none. it's perfect
* [Jira: Rototiller](https://tickets.puppetlabs.com/issues/?jql=project%20%3D%20QA)

## More Documentation

Rototiller is documented using yard
to view yard docs, including internal Classes and Modules:

First build a local copy of the gem

    $) bundle exec rake build

Next start the yard server

    $) bundle exec yard server

Finally navigate to http://0.0.0.0:8808/ to view the documentation

## Maintainers
* [Zach Reichert](zach.reichert@puppetlabs.com), github:[zreichert](https://github.com/zreichert), jira:zach.reichert
* [Eric Thompson](erict@puppetlabs.com), github:[er0ck](https://github.com/er0ck), jira:erict
* [QA](qa-team@puppetlabs.com)
