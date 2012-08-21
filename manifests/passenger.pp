# Class: puppet::passenger
#
# This class installs and configures the puppetdb terminus pacakge
#
# Parameters:
#   ['puppet_passenger_port']    - The config directory of puppet
#   ['puppet_docroot']           - The service needing to be notified of the change puppetmasterd or httpd
#   ['apache_serveradmin']       - The port of the puppetdb 
#   ['puppet_site']              - The dns name of the puppetdb server
#   ['puppet_conf']              - The puppet config file
#   ['puppet_ssldir']            - The puppet config file
#   ['certname']                 - The puppet config file
#
# Actions:
# - Configures apache and passenger for puppet master use. 
#
# Requires:
# - Inifile
# - Class['puppet::params']
# - Class['apache']
#
# Sample Usage:
#   class { 'puppet::passenger':
#           puppet_passenger_port  => 8140,
#           puppet_docroot         => '/etc/puppet/docroot',
#           apache_serveradmin     => 'wibble',
#           puppet_site            => 'puppet.example.com',
#           puppet_conf            => '/etc/puppet/puppet.conf',
#           puppet_ssldir          => '/var/lib/puppet/ssl',
#           certname               => 'puppet.example.com',
#   }
#
class puppet::passenger(
  $puppet_passenger_port,
  $puppet_docroot,
  $apache_serveradmin,
  $puppet_site,
  $puppet_conf,
  $puppet_ssldir,
  $certname
){
  include apache
  include puppet::params

  case $::operatingsystem {
    'ubuntu', 'debian': {

      if ! defined(Package[$::puppet::params::passenger_package]) {
        package{$::puppet::params::passenger_package:
          ensure => 'present',
          before => File['/etc/puppet/rack'],
        }
      }else {
        Package<| title == $::puppet::params::passenger_package |> {
          notify +> Service['httpd'],
        }
      }

      if ! defined(Package[$::puppet::params::rails_package]) {
        package{$::puppet::params::rails_package:
          ensure => 'present',
          before => File['/etc/puppet/rack'],
        }
      }
      else {
        Package<| title == $::puppet::params::rails_package |> {
          before +> File['/etc/puppet/rack'],
        }
      }

      if ! defined(Package[$::puppet::params::rack_package]) {
        package{$::puppet::params::rack_package:
          ensure => 'present',
          before => File['/etc/puppet/rack'],
        }
      }
      else {
        Package<| title == $::puppet::params::rack_package |> {
          before +> File['/etc/puppet/rack'],
        }
      }

      a2mod {'passenger':
        ensure  => 'present',
        require => Package[$::puppet::params::passenger_package],
      }

    }
    default: {
      err('The Puppet passenger module does not support your os')
    }
  }

  exec { 'Certificate_Check':
    command   => "puppet cert --generate ${certname} --trace",
    unless    => "/bin/ls ${puppet_ssldir}/certs/${certname}.pem",
    path      => '/usr/bin:/usr/local/bin',
    logoutput => on_failure,
    require   => File[$puppet_conf]
  }

  apache::vhost { "puppet-${puppet_site}":
    port               => $puppet_passenger_port,
    priority           => '40',
    docroot            => $puppet_docroot,
    configure_firewall => false,
    serveradmin        => $apache_serveradmin,
    servername         => $puppet_site,
    template           => 'puppet/apache2.conf.erb',
    require            => [ File['/etc/puppet/rack/config.ru'], File[$puppet_conf] ],
    ssl                => true,
  }

  file { ['/etc/puppet/rack']:
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0755',
  }

  file { '/etc/puppet/rack/config.ru':
    ensure => present,
    owner  => 'puppet',
    group  => 'puppet',
    source => 'puppet:///modules/puppet/config.ru',
    mode   => '0644',
  }

  ini_setting {'puppetmastersslclient':
    ensure  => present,
    section => 'master',
    setting => 'ssl_client_header',
    path    => $puppet_conf,
    value   => 'SSL_CLIENT_S_DN',
    require => File[$puppet_conf],
  }

  ini_setting {'puppetmastersslclientverify':
    ensure  => present,
    section => 'master',
    setting => 'ssl_client_verify_header',
    path    => $puppet_conf,
    value   => 'SSL_CLIENT_VERIFY',
    require => File[$puppet_conf],
  }
}