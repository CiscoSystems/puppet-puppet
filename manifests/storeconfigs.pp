# Class: puppet::storeconfiguration
#
# This class installs and configures Puppet's stored configuration capability
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::storeconfigs (
    $puppetdb_host,
    $dbadapter,
    $dbuser,
    $dbpassword,
    $dbserver,
    $dbsocket
) {

   case $dbadapter {
    'sqlite3': {
      include puppet::storeconfigs::sqlite
    }
    'mysql': {

      if $::osfamily == 'Debian' {
        package{ 'activerecord':
          ensure => present,
          name   => 'libactiverecord-ruby'
        }
        package{ 'libmysql-ruby':
          ensure => present,
        }
      }

      class { "puppet::storeconfigs::mysql":
          dbuser     => $dbuser,
          dbpassword => $dbpassword,
      }
      # This version of activerecord works with Ruby 1.8.5 and Centos 5.
      # This ensure should be fixed.
      Package['activerecord'] -> Class['puppet::storeconfigs']
    }
    'puppetdb': {
      class {'puppetdb::terminus': 
        puppetmaster_service => $puppet::master::service_notify,
        puppetdb_host        => $puppetdb_host
      }
    }
    default: { err("target dbadapter $dbadapter not implemented") }
  }

  concat::fragment { 'puppet.conf-master-storeconfig':
    order   => '03',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master-storeconfigs.erb");
  }

}