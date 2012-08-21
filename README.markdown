# Puppet Module

This module is a configuration manager module that ensures the configuration of puppet agent, master, and dashboard.  

## NOTE ##
This is currently going under a massive refactor 

## Requirements ##
stdlib:  "git://github.com/puppetlabs/puppetlabs-stdlib.git"
apache:  "git://github.com/puppetlabs/puppetlabs-apache.git"
inifile: "git://github.com/cprice-puppet/puppetlabs-inifile.git"

## Quick Start

### For a puppet master ###

```ruby
class { 'puppet::master':
     autosign                  => true,
     storeconfigs              => true,
     storeconfigs_dbserver     => master.puppetlabs.vm,
}
```

### For a puppet agent ###
```ruby
 class { 'puppet::agent':
 	puppet_server             => master.puppetlabs.vm,
 	environment               => production,
 	splay                     => true,
 }
 ```
