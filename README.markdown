# Puppet module #

This module provides classes for managing the puppet agent and puppet master. 
It will setup passenger and apache on the puppetmaster. Please note this will 
not setup puppetdb. This can be configured using the puppetdb module 
http://forge.puppetlabs.com/puppetlabs/puppetdb. Storedconfigs with puppetdb 
will only work on puppet versions newer than 2.7.12.

## Prerequisites ##

If you are going to use the puppetdb, you need to have the puppetlabs apt / yum 
repo configured as it will need to install the puppetdb-terminus package.  

## Usage Note ##

If you are using this module to install a puppetmaster and serving the manifest of 
the machine. You may have issues with it halting the puppet master if it is 
running through webrick. In which case run a single puppet run using

	puppet apply -e "class { 'puppet::master': storeconfigs => true }"

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

