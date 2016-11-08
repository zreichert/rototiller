# Rototiller Task Reference
* herein lies the reference to the rototiller_task API

* [#rototiller_task](#rototiller_task)
  * [#add_command](#rototiller_task:add_command)
  * [#add_env](#rototiller_task:add_env)
* [Command](#Command)
  * [#add\_env](#Command:add_env)
  * [#add\_switch](#Command:add_switch)

<a name="rototiller_task"></a>
## #rototiller_task
* behaves just like any other rake task name (see below)

<a name="rototiller_task:add_command"></a>
### #add_command
* adds a command to a rototiller_task. This command can in turn contain environment variables, switches, options and arguments
* this command (and any others) will be run with the task is executed
* (!) currently a task will fail if its command fails _only_ if `#fail_on_error` is set
  * the error message from the command will only be shown when rake is run with `--verbose`
  * this will be fixed post-1.0

<a name="rototiller_task:add_env"></a>
### #add_env
* parent methods such as `add_command`, `add_argument`, `add_switch`, and  `add_option` can utilize the method `add_env` to add an env to a param
* adds an arbitrary environment variable for use in the task
* If the parent does call the `name=` method and the method `default=` is not called under `add_env` the value passed to `name=` is the default
* If the parent does not call the `name=` method and the method `default=` is called under `add_env` the value passed to `default=` is the default
* If the parent does not call the `name=` method and the method `name=` is called under `add_env` the task will only continue if a value is found in the environment
* if specified with a default value, and the system environment does not have this variable set, rototiller will set it, for later use in a task or otherwise
* Specific uses are described in [add_env reference examples](docs/env_var_example_reference.md)
* FIXME: add a bunch more examples with messaging and default values

&nbsp;

    require 'rototiller'

    desc "parent task for dependencies test. this one also uses an environment variable"
    rototiller_task :parent_task do |task|
      # most method initializers take either a hash, or block syntax (see next task)
      task.add_env({:name     => 'RANDOM_VAR', :default => 'default value'})
      task.add_env({:name     => 'RANDOM_VAR2', :default => 'default value2'})
      task.add_command({:name => "echo 'i am testing everything with $RANDOM_VAR = #{ENV['RANDOM_VAR']}'"})
      task.add_command({:name => "echo 'some other command!'"})
    end

produces:

    # added environment variable defaults are set, implicitly, if not found
    #   this way, their value can be used in the task
    # FIXME... this is a bug?  i think it's supposed to set vars with default values even at task level??
    $) rake parent_task
    INFO: The environment variable: 'RANDOM_VAR' is not set. Proceeding with default value: 'default value':
    INFO: The environment variable: 'RANDOM_VAR2' is not set. Proceeding with default value: 'default value2':
    i am running this command with $RANDOM_VAR =
    some other command!

    $) rake parent_task RANDOM_VAR=redrum
    INFO: The environment variable: 'RANDOM_VAR' was found with value: 'redrum':
    INFO: The environment variable: 'RANDOM_VAR2' is not set. Proceeding with default value: 'default value2':
    i am running this command with $RANDOM_VAR = redrum
    some other command!
&nbsp;

<a name="Command"></a>
## Command
<a name="Command:add_env"></a>
### #add_env
* adds an arbitrary environment variable which overrides the name of the command
* if specified with a default value, and the system environment does not have this variable set, rototiller will set it, for later use in a task or otherwise
* FIXME: add a bunch more examples with messaging and default values

&nbsp;

    desc "override a command-name with environment variable"
    rototiller_task :child => :parent_task do |task|
      task.add_command({:name => 'nonesuch', :add_env => {:name => 'COMMAND_EXE1'}})
      # block syntax here. We give up some lines for more readability
      task.add_command do |cmd|
        cmd.name = 'meneither'
        cmd.add_env({:name => 'COMMAND_EXE2'})
      end
    end

produces:

    # we didn't override the command with its env_var, so shell complains about nonsuch and exits
    $ rake child RANDOM_VAR=redrum
    INFO: The environment variable: 'RANDOM_VAR' was found with value: 'redrum':
    INFO: The environment variable: 'RANDOM_VAR2' is not set. Proceeding with default value: 'default value2':
    i am running this command with $RANDOM_VAR = redrum
    some other command!
    sh: nonesuch: command not found

    # now we've overridden the first command to echo partial success
    #  but the next command was not overridden by its environment variable, which has no default
    $ rake child COMMAND_EXE1='echo partial success'
    INFO: The environment variable: 'RANDOM_VAR' is not set. Proceeding with default value: 'default value':
    INFO: The environment variable: 'RANDOM_VAR2' is not set. Proceeding with default value: 'default value2':
    i am running this command with $RANDOM_VAR =
    some other command!
    partial success
    sh: meneither: command not found

    # NOW our silly example works!
    $ rake child COMMAND_EXE1='echo partial success' COMMAND_EXE2='echo awwww yeah!'
    INFO: The environment variable: 'RANDOM_VAR' is not set. Proceeding with default value: 'default value':
    INFO: The environment variable: 'RANDOM_VAR2' is not set. Proceeding with default value: 'default value2':
    i am running this command with $RANDOM_VAR =
    some other command!
    partial success
    awwww yeah!

<a name="Command:add_switch"></a>
### #add_switch
<a name="Command:add_argument"></a>
### #add_argument
* adds an arbitrary string to a command
  * intended to add `--switch` type binary switches that do not take arguments (see [add_option](#Command:add_option))
  * add_argument is intended to add strings to the end of the command string (options and switches are added prior to arguments

&nbsp;

    desc "add command-switch or option or argument with overriding environment variables"
    rototiller_task :variable_switch do |task|
      task.add_command do |cmd|
        cmd.name = 'echo command_name'
        cmd.add_switch do |s|
          s.name = '--switch'
          s.add_env({:name => 'CRASH_OVERRIDE'})
        end
        cmd.add_argument do |a|
          a.name = 'arguments go last'
          a.add_env({:name => 'ARG_OVERRIDE2'})
        end
        cmd.add_option do |o|
          o.name = '--option'
          o.add_env({:name => 'OPT_OVERRIDE'})
          o.add_argument do |arg|
            arg.name = 'argument'
            arg.add_env({:name => 'ARG_OVERRIDE', :message => 'message at the env for argument'})
            arg.message = 'This is the message at the option argument level'
          end
        end
      end
    end

produces:

    $ rake -f docs/Rakefile.example variable_switch
    command_name --switch --option argument arguments go last

    $ rake --rakefile docs/Rakefile.example variable_switch --verbose
    echo command_name --switch --option argument arguments go last
    command_name --switch --option argument arguments go last

    $ rake --rakefile docs/Rakefile.example variable_switch CRASH_OVERRIDE='and burn'
    command_name and burn --option argument arguments go last

    $ rake --rakefile docs/Rakefile.example variable_switch OPT_OVERRIDE='--real_option'
    command_name --switch --real_option argument arguments go last

    $ rake --rakefile docs/Rakefile.example variable_switch ARG_OVERRIDE='opt arg'
    command_name --switch --option opt arg arguments go last

    # what do you think ARG_OVERRIDE2 does?
