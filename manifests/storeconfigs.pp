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
# - Class['puppet::dbterminus']
#
# Sample Usage:
#   class { 'puppet::storecofnigs':
#       puppet_service             => Service['httpd'],
#       dbport                     => 8081,
#       dbserver                   => 'localhost'
#   }
#
class puppet::storeconfigs(
    $dbserver,
    $dbport,
    $puppet_service,
    $puppet_confdir = '/etc/puppet/',
    $puppet_conf = '/etc/puppet/puppet.conf',
)
{
  class{ 'puppet::dbterminus':
    puppet_confdir => $puppet_confdir,
    puppet_service => $puppet_service,
    dbport         => $dbport,
    dbserver       => $dbserver,
  }

  ini_setting {'puppetmasterstoreconfigserver':
    ensure  => present,
    section => 'master',
    setting => 'server',
    path    => $puppet_conf,
    value   => $dbserver,
    require => [File[$puppet_conf],Class[puppet::dbterminus]],
  }

  ini_setting {'puppetmasterstoreconfig':
    ensure  => present,
    section => 'master',
    setting => 'storeconfigs',
    path    => $puppet_conf,
    value   => true,
    require => [File[$puppet_conf],Class[puppet::dbterminus]],
  }

  ini_setting {'puppetmasterstorebackend':
    ensure  => present,
    section => 'master',
    setting => 'storeconfigs_backend',
    path    => $puppet_conf,
    value   => 'puppetdb',
    require => [File[$puppet_conf],Class[puppet::dbterminus]],
  }
}