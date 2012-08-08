class puppet::storeconfigs::mysql {
  case $::operatingsystem
  {
    'ubuntu', 'debian':{
      package{ 'libactiverecord-ruby':
        ensure => installed,
      }

      package{ 'libmysql-ruby':
        ensure => installed,
      }
    }
    'centos', 'redhat', 'fedora':{
      package{ 'mysql-devel':
        ensure => installed,
      }

      package { 'ruby-mysql':
        ensure => installed,
      }

      package { 'rubygem-activerecord':
        ensure => installed,
      }
    }
    default: {
      err('sqlite support is not completed for your OS')
    }
  }
}