# Class: puppet::storeconfigs
#
# This class installs and configures the puppetdb terminus pacakge
#
# Parameters:
#   ['puppet_confdir']    - The config directory of puppet
#   ['puppet_service']    - The service needing to be notified of the change puppetmasterd or httpd
#   ['dbport']            - The port of the puppetdb
#   ['dbserver']          - The dns name of the puppetdb server
#   ['puppet_conf']       - The puppet config file
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
#   }
#
class puppet::storeconfigs(
    $dbserver,
    $dbport,
    $puppet_service,
    $puppet_confdir =  $::puppet::params::puppet_confdir,
    $puppet_conf    =  $::puppet::params::puppet_conf,
)inherits puppet::params {

  if ! defined(Class['puppetdb::storeconfigs']) {
      class{ 'puppetdb::storeconfigs':
        dbserver       => $dbserver,
        dbport         => $dbport,
        puppet_confdir => $puppet_confdir,
        puppet_conf    => $puppet_conf,
      }
  }  
}
