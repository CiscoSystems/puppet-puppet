# Class: puppet::master
#
# This class installs and configures a Puppet master
#
# Parameters:
# * modulepath
# * storeconfigs
# * dbadapter
# * dbuser
# * dbpassword
# * dbserver
# * dbsocket
# * certname
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#  $modulepath = [
#    "/etc/puppet/modules/site",
#    "/etc/puppet/modules/dist",
#  ]
#
#  class { "puppet::master":
#    modulepath => inline_template("<%= modulepath.join(':') %>"),
#    dbadapter  => "mysql",
#    dbuser     => "puppet",
#    dbpassword => "password"
#    dbsocket   => "/var/run/mysqld/mysqld.sock",
#  }
#
class puppet::master (
  $modulepath,
  $storeconfigs,
  $storeconfigs_dbadapter,
  $storeconfigs_dbuser,
  $storeconfigs_dbpassword,
  $storeconfigs_dbserver,
  $storeconfigs_dbsocket,
  $certname,
  $puppet_master_package,
  $puppet_master_service,
  $package_provider = undef,
  $version

) {

  if $package_provider == 'gem' {
    Concat::Fragment['puppet.conf-header']->Exec['puppet_master_start']
  } else {
    Concat::Fragment['puppet.conf-header']->Service[$puppet_master_service]
  }

  if $storeconfigs {
    class { 'puppet::storeconfigs':
      dbadapter  => $storeconfigs_dbadapter,
      dbuser     => $storeconfigs_dbuser,
      dbpassword => $storeconfigs_dbpassword,
      dbserver   => $storeconfigs_dbserver,
      dbsocket   => $storeconfigs_dbsocket,
    }
  }

  package { $puppet_master_package:
    ensure => $version,
    provider => $package_provider,
  }

  file { '/etc/puppet/namespaceauth.conf':
    owner  => root,
    group  => root,
    mode   => 644,
    source => 'puppet:///modules/puppet/namespaceauth.conf',
  }

  concat::fragment { 'puppet.conf-header':
    order   => '05',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master.erb"),
  }

  if $package_provider == 'gem' {
    exec { 'puppet_master_start':
      command   => '/usr/bin/nohup puppet master &',
      refresh   => '/usr/bin/pkill puppet && /usr/bin/nohup puppet master &',
      unless    => "/bin/ps -ef | grep -v grep | /bin/grep 'puppet master'",
      require   => File['/etc/puppet/puppet.conf'],
      subscribe => Package[$puppet_master_package],
    }
  } else {
    service { $puppet_master_service:
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => File['/etc/puppet/puppet.conf'],
      subscribe => Package[$puppet_master_package],
      #before    => Service['httpd'];
    }
  }
}

