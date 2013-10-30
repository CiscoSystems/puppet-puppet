[![Build Status](https://travis-ci.org/stephenrjohnson/puppetmodule.png)](https://travis-ci.org/stephenrjohnson/puppetmodule)
# Puppet module #

This module provides classes for managing the puppet agent and puppet master. 
It will setup passenger and apache on the puppetmaster. Please note this will 
not setup puppetdb. This can be configured using the puppetdb module 
http://forge.puppetlabs.com/puppetlabs/puppetdb. Storedconfigs with puppetdb 
will only work on puppet versions newer than 2.7.12.

## Prerequisites ##
If you are using a RedHat based OS you also need to have the EPEL repo configured
as this module requires the passenger apache module.

Requires the following modules from puppetforge: [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib), [apache](https://forge.puppetlabs.com/puppetlabs/apache), [concat](https://forge.puppetlabs.com/puppetlabs/concat), [inifile](https://forge.puppetlabs.com/puppetlabs/inifile)

## Usage Note ##

If you are using this module to install a puppetmaster and serving the manifest of 
the machine. You may have issues with it halting the puppet master if it is 
running through webrick. In which case run a single puppet run using

    puppet apply -e "class{'puppet::repo::puppetlabs': } Class['puppet::repo::puppetlabs'] -> Package <| |> class { 'puppetdb': }  class { 'puppet::master': storeconfigs => true }"

## Master ##
    class { 'puppetdb': }
    class { 'puppet::master':
        storeconfigs              => true,
    }

### Master environments ###
    puppet::masterenv {'dev':
        modulepath => '/etc/puppet/evn/dev/modules',
        manifest   => '/etc/puppet/env/dev/site.pp',
    }
    puppet::masterenv {'production':
        modulepath => '/etc/puppet/evn/production/modules',
        manifest   => '/etc/puppet/env/production/site.pp',
    }

## Agent ##
    class { 'puppet::agent':
        puppet_server             => master.puppetlabs.vm,
        environment               => production,
        splay                     => true,
    }

## Testing ##

Install gems:

    bundle install --path vendor/bundle

Lint and rspec-puppet:

    bundle exec rake lint
    bundle exec rake spec

If you have a working Vagrant setup you can run the rspec-system tests:

    bundle exec rake spec:system

To use different base boxes than the default pass the name of the box to
the rake command with the ```RSPEC_SET``` environment variable (check out
.nodelist.yml for box names):

    RSPEC_SET=centos-64-x64 bundle exec rake spec:system
