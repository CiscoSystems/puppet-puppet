# Puppet module #

This module provides classes for managing the puppet agent and puppet master. 
It will setup passenger and apache on the puppetmaster. Please note this will 
not setup puppetdb. This can be configured using the puppetdb module 
https://github.com/cprice-puppet/puppetlabs-puppetdb. Storedconfigs with puppetdb 
will only work on puppet versions newer than 2.7.12.

## Prerequisites ##

If you are going to use the puppetdb, you need to have the puppetlabs apt / yum 
repo configured as it will need to install the puppetdb-terminus package.  

## Master ##

	class { 'puppet::master':
	     storeconfigs              => true,
	}

## Agent ##

	class { 'puppet::agent':
	 	puppet_server             => master.puppetlabs.vm,
	 	environment               => production,
	 	splay                     => true,
	 }
