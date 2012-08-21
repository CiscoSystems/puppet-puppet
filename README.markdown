# Puppet module #

This module provides classes for managing the puppet agent and puppet master. 
It will setup passenger and apache on the puppetmaster. Please note this will 
not setup puppetdb this can be configured using 

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
