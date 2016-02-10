# rototiller

A shared rake task library for use at Puppet.
Goals of Rototiller

* Provide a tool that can house shared rake task code for Puppet Labs.  

* Reduce duplication in rakefiles across projects at Puppet Labs.

* Reduce effort required to write first class rake tasks.

* Reduce time and effort trying to understand requirement to run rake tasks. 

* Provide a standard interface for executing tests in a given test tier regardless of framework (Not MVP)

## Classes & Modules under development
For more detailed documentation please refer to the yard docs.  

####[EnvVar](lib/rototiller/utilities/env_var.rb)

  A class that tracks the state of an ENV variable.  
  This class is responsible for formatting its own messaging, the value that should be used, and if a task should stop.  
    
####[Flag](lib/rototiller/utilities/flag.rb)

   A class that tracks the desired state of command line flags used in test invocation.  
   The desired state of these flags is determined by the user.  
    
####[ParamCollection](lib/rototiller/utilities/param_collection.rb)

  A class to contain EnvVar and Flag classes.  
  Behaves similar to an Array.  
    
####[RototillerTask](lib/rototiller/task/rototiller_task.rb)

  A class used to build a rake task.  
  Similar in approach to [RSpec::Core::RakeTask](https://github.com/rspec/rspec-core/blob/master/lib/rspec/core/rake_task.rb)  
    
####[CLIFlags](lib/rototiller/task/flags/cli_flags.rb)

  A class to contain the known CLI flags.

## More Documentation


Rototiller is documented using yard 
to view yard docs

First build a local copy of the gem

    $ bundle exec rake build 
    
Next start the yard server

    $ bundle exec yard server
    
Finally navigate to http://0.0.0.0:8808/ to view the documentation