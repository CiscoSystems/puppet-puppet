class puppet::storeconfigs::mysql (
    $dbuser,
    $dbpassword,
    $install_packages = false
  ){

  include puppet::params

   if $install_packages {
     package { $puppet::params::puppet_storeconfigs_packages:
       ensure => installed,
     }

     package { 'mysql':
       ensure   => installed,
       provider => 'gem',
     }
  }

  mysql::db { 'puppet':
    user     => $dbuser,
    password => $dbpassword,
    charset  => 'utf8',
    host     => 'localhost',
    grant    => 'all',
  }
}
