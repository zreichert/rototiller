# Rototiller

A [Rake](https://github.com/ruby/rake) helper library for command-oriented tasks.

:warning: This version of Rototiller (master branch) is a work in progress!
It is already known that the API will change quite a bit for the next release. These API changes are underway.
Please see the notes at the top of the [Write](#write) section.

## Rototiller Goals
* Simplifies the building of command strings in :rototiller_task for task authors
* Abstracts the overriding of command string components: commands, switches, options, arguments for task users
* Unifies and standardizes messaging surrounding the use of environment variables for task operations
* Reduce duplication in Rakefiles across projects
* Reduce effort required to write first-class rake tasks
* Reduce time and effort to understand how to run rake tasks

<a name="install"></a>
## Install
    gem install rototiller

<a name="write"></a>
## Write
Rototiller provides a Rake DSL addition called '[rototiller_task](docs/rototiller_task_reference.md)' which is a fully featured Rake task with environment variable handling, messaging and command-string-building functionality.

:warning: The API below will change for the next release.
The known changes include (not comprehensive):
* moving `#add_flag` to `Command` and renaming it `#add_option`
* adding `#add_env` to `Command` and `#add_option`, so one can add multiple environment variables
* adding `#add_switch` to Command so one does not have to use the `:is_boolean` parameter for `#add_flag`
* adding some sort of env_var type so one does not have to use the `:required` parameter for `#add_flag`
* the above will allow for multiple commands in a task with independent option, switch, and environment variable tracking

Rototiller has 4 main _types_ of arguments that can be passed to a command in a task. `RototillerTasks` can accept multiple commands.  Each of these argument types has a similar API that looks similar to `add_command()`.

<a name="use"></a>
## Use
It's just like normal Rake. We just added a bunch of environment variable handling and messaging!
(with the below example Rakefile):

    $) rake -T
    rake child        # override command-name with environment variable
    rake parent_task  # parent task for dependent tasks

    $) rake -D
    rake child
        override command-name with environment variable

    rake parent_task
        parent task for dependent tasks. this one also uses two environment variables and two commands

### The old way

    desc 'the old, bad way. This is for the README.md file.'
      task :demo_old do |t|
        echo_args = ENV['COMMAND_NAME'] || "my_sweet_command #{ENV['HOME']}"
        overriding_options = ENV['OPTIONS'].to_s
        args = [echo_args, *overriding_options.split(' '), '--switch'].compact
        sh("echo", *args)
      end

this does, _mostly_ the same as below.  but what do the various environment variables do?  they aren't documented anywhere, especially in Rake's output. why do we have to split on a space for the overriding options?  why do we compact?  We shouldn't have to do this in all our Rakefiles, and then forget to do it, _correctly_ in most.  Rototiller does all this for us, but uniformly handling environment variables for any command piece, optionally. But anytime we do, we automatically get messaging in Rake's output, and this can be controlled with Rake's --verbose flag.  Now we don't have to dig into the Rakefile to see what the author intended for an interface.  Now we can provide a uniform interface for our various tasks based upon this library and have messaging come along for the ride.  Now we can remove the majority of repeated code from our Rakefiles.

### The rototiller way

    require 'rototiller'
    desc 'the new, rototiller way. This is for the README.md file.'
      rototiller_task :demo_new do |t|
        t.add_env({:name => 'FOO', :message => 'I am describing FOO, my task needs me, but has a default. this default will be set in the environment unless it exists', :default => 'FOO default'})
        t.add_env do |e|
          e.name    = 'HOME'
          e.message = 'I am describing HOME, my task needs me. all rototiller methods can take a hash or a block'
        end

        t.add_command do |c|
          c.name = 'echo my_sweet_command ${HOME}'
          c.add_env({:name => 'COMMAND_NAME', :message => 'use me to override this command name (`echo my_sweet_command`)'})
          # anti-pattern: this is really an option.  FIXME once add_option is implemented
          c.add_switch({:name => '--switch ${FOO}', :message => 'echo uses --switch to switch things'})
          # FYI, add_switch can also take a block and add_env
          # command blocks also have add_option, and add_arg, each of which can add environment variables which override themselves.
          # add_option actually has its own add_arg and each of those have add_env.  so meta
        end
      end

### Reference
* [rototiller\_task reference](docs/rototiller_task_reference.md)
  * contains usage information on all rototiller_task API methods

## Issues

* none. it's perfect, but just in case (sorry, this is Puppet-internal for now)
* [Jira: Rototiller](https://tickets.puppetlabs.com/issues/?jql=project%20%3D%20QA)
* [Puppet QA-team](mailto:qa-team@puppet.com)

## More Documentation

Rototiller is documented using yard
to view yard docs, including internal Classes and Modules:

First build a local copy of the gem

    $) bundle exec rake build

Next start the yard server

    $) bundle exec yard server

Finally navigate to http://0.0.0.0:8808/ to view the documentation

## Contributing
* [Contributing](CONTRIBUTING.md)

## abandon hope, all ye who enter here
### All permutations of v2 API (remove and refactor into useful doc sections below upon testing, merge-up to stable)

* all things that can take multiples should use add\_ as precursor to method name
* all things that only take one should use set\_ as precursor to method name?
    require 'rototiller'

    ## all task methods
    rototiller_task :name do |t|
      t.add_command # t.add_cmd? me no likey
      t.add_env
    end
    rototiller_task do |t|
      t.set_name = 'string_name' # should this be validated??  e.g.: spaces, etc
      t.add_command
      t.add_env
    end


    ## all task's add_env invocations with just name
    t.add_env('env_name') #required, default messaging
    t.add_env :env_name
    t.add_env 'env_name' # implicitly allowed by ruby
    t.add_env do |e|
      e.name
    end

    ## all task's add_env invocations with name, message
    #t.add_env('env_name')  # impossible
    t.add_env :env_name do |e|
    t.add_env 'env_name' do |e|  # should we do this too?
      e.set_message
    end
    t.add_env do |e|
      e.name
      e.message
    end

    ## all task's add_env invocations with name, value
    #t.add_env('env_name')  # impossible
    t.add_env :env_name do |e|
    t.add_env 'env_name' do |e|  # should we do this too?
      e.default/value  # does value imply the env will be set by rototiller?  does default NOT?
    end
    t.add_env do |e|
      e.name
      e.default/value
    end

    ## all task's add_env invocations with name, value, message
    #t.add_env('env_name')  # impossible
    t.add_env :env_name do |e|
      e.default/value  # does value imply the env will be set by rototiller?  does default NOT?
      e.message
    end
    t.add_env do |e|
      e.name
      e.default/value
      e.message
    end


    ## all task's add_command invocations with only name
    # default messaging, no env override?
    t.add_command('echo --blah my name is ray')
    t.add_command :echo
    t.add_command 'echo'
    t.add_command do |c|
      c.name = 'echo'
    end

    ## all task's add_command invocations with name (string), message
    #t.add_command('echo --blah my name is ray', 'message') # ArgumentError
    t.add_command :echo
    t.add_command 'echo' do |c|
      c.name = 'echo' # # nomethod error?
      c.message = 'why we echo'
    end
    t.add_command do |c|
      c.name = 'echo'
      c.message = 'blah'
    end

    ## all task's add_command invocations with name (block) (could be same for message?)
    #t.add_command('echo --blah my name is ray', 'message') # ArgumentError
    #t.add_command :echo
    #t.add_command 'echo' do |c|
    #  c.message = 'blah'
    #end
    t.add_command do |c|
      c.name 'echo' do |n|
        n.add_env
      end
      c.add_arg 'some_arg' do |a|
        a.add_env
        a.message
      end
      c.add_option '--option_name' do |o|
        o.add_arg 'switch_arg' do |a|
          a.add_env 'opion-arg_env' do |e|
            e.set_name
            e.set_message
            e.set_value
          end
        end
        o.add_env 'option-name_env' do |e|
          e.set_name
          e.set_message
          e.set_value
        end
        o.message
      end
      c.add_switch '--some_switch' do |s|
        s.add_env 'env_name' do |e|
          e.set_name
          e.set_message
          e.set_value
        end
        s.message
      end
    end

    #should we be able to add an env for any given message?  i don't see a use case, we should probably just save users from themselves here.
