class puppet(
  $run_master = false,
  $run_agent = false,
  $puppetmaster_address = $::fqdn,
  $certname = $::fqdn,
  $master_autosign_cert = undef,
  $runinterval = 120,
  $extra_modules = "",
  $mysql_root_password = 'changeMe',
  $mysql_password = 'changeMe'
) {
  include puppet::params
  include apache
 
  package { 'puppet':
    name   => $::puppet::params::puppet,
    ensure => present
  }

  if ($run_master) {
    package { 'puppetmaster':
      name   => $::puppet::params::puppetmaster,
      ensure => present
    }

    # now fix the rails.log permissions issue
    file { 'railslog':
      path    => '/var/log/puppet/rails.log',
      ensure  => present,
      mode    => 0644,
      owner   => 'puppet',
      group   => 'puppet',
    }

    # set up mysql server
    class { 'mysql::server':
      config_hash => {
        'root_password' => $mysql_root_password,
        'bind_address'  => '127.0.0.1'
      }
    }

    mysql::db { puppet:
      user         => puppet,
      password     => $mysql_password,
      host         => localhost,
    }

    file { '/var/lib/puppet/reports':
      ensure => 'directory',
      owner  => 'puppet',
      group  => 'puppet'
    }

    package { 'activerecord':
      name   => $::puppet::params::activerecord,
      ensure => present
    }

    package { 'ruby-mysql':
      ensure => present
    }

    File <| title == "/etc/puppet/puppet.conf" |> {
      notify +> Service['httpd']
    }

    file { '/etc/puppet/autosign.conf':
      ensure => present,
      content   => template('puppet/autosign.conf.erb'),
    }

    if ($::osfamily == 'Redhat') {
      service { 'puppetmaster':
        ensure => 'running',
        require => Package[ $::puppet::params::puppetmaster ],
      }

      Service['httpd'] ~> Service['puppetmaster']
    }
  }

  if ($run_agent) {
    package { puppet:
      ensure => present
    }

    file { '/etc/default/puppet':
      content => template('puppet/defaults.erb'),
      notify => Service['puppet'],
    }

    File <| title == "/etc/puppet/puppet.conf" |> {
      notify +> Service["puppet"]
    }

    file { '/etc/init.d/puppet':
      mode => 0755,
      owner => root,
      group => root,
      content => template('puppet/init.erb'),
      notify => Service["puppet"]
    }

    service { 'puppet':
      ensure  => 'running',
      require => Package['puppet'],
      refreshonly => true
    }

  }

  file { '/etc/puppet/puppet.conf':
    content => template('puppet/puppet.conf.erb'),
    require => Package['puppet']
  }

  file { '/etc/cron.d/puppet_cleanup':
    content => template('puppet/puppet_cleanup.erb'),
    require => Package['puppet'],
    owner   => root,
    group   => root,
    mode    => 0644
  }
}
