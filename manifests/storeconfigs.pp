# Class: puppet::storeconfigs
#
# This class installs and configures the puppetdb terminus pacakge
#
# Parameters:
#   ['puppet_confdir']           - The config directory of puppet
#   ['puppet_service']           - The service needing to be notified of the change puppetmasterd or httpd
#   ['puppet_master_package']    - The name of the puppetmaster pacakge
#   ['dbport']                   - The port of the puppetdb
#   ['dbserver']                 - The dns name of the puppetdb server
#   ['puppet_conf']              - The puppet config file
#   ['puppetdb_startup_timeout'] - The time out for puppetdb
#
# Actions:
# - Configures the puppet to use stored configs
#
# Requires:
# - Inifile
# - Class['puppet::storeconfigs']
#
# Sample Usage:
#   class { 'puppet::storeconfigs':
#       puppet_service             => Service['httpd'],
#       dbport                     => 8081,
#       dbserver                   => 'localhost'
#       puppet_master_package      => 'puppetmaster'
#   }
#
class puppet::storeconfigs(
    $dbserver,
    $dbport,
    $puppet_service,
    $puppet_master_package,
    $puppetdb_startup_timeout,
    $puppetdb_strict_validation,
    $puppet_confdir =  $::puppet::params::confdir,
    $puppet_conf    =  $::puppet::params::puppet_conf
)inherits puppet::params {

  ##If we point at a puppetdb on this machine
  if ($dbserver  == 'localhost') or ($dbserver  == '127.0.0.1') or ($dbserver  == $::fqdn)
  {
    $require  =  Class[puppetdb]
  }
  else
  {
    $require = undef
  }
  if ! defined(Class['puppetdb::master::config']) {
    class{ 'puppetdb::master::config':
      puppetdb_server          => $dbserver,
      puppetdb_port            => $dbport,
      puppet_confdir           => $puppet_confdir,
      puppet_conf              => $puppet_conf,
      restart_puppet           => false,
      notify                   => $puppet_service,
      puppetdb_startup_timeout => $puppetdb_startup_timeout,
      strict_validation        => $puppetdb_strict_validation,
      require                  => $require,
    }
  }
}
