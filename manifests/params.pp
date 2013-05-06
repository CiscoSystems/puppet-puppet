# Class: puppet::params
#
# This class installs and configures parameters for Puppet
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::params {

  $puppet_server                    = 'puppet'
  $modulepath                       = '/etc/puppet/modules'
  $puppet_user                      = 'puppet'
  $puppet_group                     = 'puppet'
  $storeconfigs_dbserver            = $::fqdn
  $storeconfigs_dbport              = '8081'
  $certname                         = $::fqdn
  $confdir                          = '/etc/puppet'
  $manifest                         = '/etc/puppet/manifests/site.pp'
  $puppet_docroot                   = '/etc/puppet/rack/public/'
  $puppet_passenger_port            = '8140'
  $puppet_server_port               = '8140'
  $puppet_agent_enabled             = true
  $apache_serveradmin               = 'root'

  case $::osfamily {
    RedHat: {
      $puppet_master_package        = 'puppet-server'
      $puppet_master_service        = 'puppetmaster'
      $puppet_agent_service         = 'puppet'
      $puppet_agent_package         = 'puppet'
      $puppet_defaults              = '/etc/sysconfig/puppet'
      $puppet_conf                  = '/etc/puppet/puppet.conf'
      $puppet_vardir                = '/var/lib/puppet'
      $puppet_ssldir                = '/var/lib/puppet/ssl'
      $passenger_package            = 'mod_passenger'
      $rack_package                 = 'rubygem-rack'
    }
    Debian: {
      $puppet_master_package        = 'puppetmaster'
      $puppet_master_service        = 'puppetmaster'
      $puppet_agent_service         = 'puppet'
      $puppet_agent_package         = 'puppet'
      $puppet_defaults              = '/etc/default/puppet'
      $puppet_conf                  = '/etc/puppet/puppet.conf'
      $puppet_vardir                = '/var/lib/puppet'
      $puppet_ssldir                = '/var/lib/puppet/ssl'
      $passenger_package            = 'libapache2-mod-passenger'
      $rack_package                 = 'librack-ruby'
    }
    FreeBSD: {
      $puppet_agent_service         = 'puppet'
      $puppet_agent_package         = 'puppet'
      $puppet_conf                  = '/usr/local/etc/puppet/puppet.conf'
      $puppet_vardir                = '/var/puppet'
      $puppet_ssldir                = '/var/puppet/ssl'
    }
    Darwin: {
      $puppet_agent_service         = 'com.puppetlabs.puppet'
      $puppet_agent_package         = 'puppet'
      $puppet_conf                  = '/etc/puppet/puppet.conf'
      $puppet_vardir                = '/var/lib/puppet'
      $puppet_ssldir                = '/etc/puppet/ssl'
    }
    default: {
      err('The Puppet module does not support your os')
    }
  }
}
