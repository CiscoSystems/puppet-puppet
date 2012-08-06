class puppet::apache($puppet_passenger_class,$puppet_passenger_port,$puppet_docroot,$apache_serveradmin,$puppet_site,$puppet_conf)
{
    Concat::Fragment['puppet.conf-master'] -> Service['httpd']

    exec { 'Certificate_Check':
      command   => "puppet cert --generate ${certname} --trace",
      unless    => "/bin/ls ${puppet_ssldir}/certs/${certname}.pem",
      path      => '/usr/bin:/usr/local/bin',
      #before   => Class[$puppet_passenger_class],
      #require  => Package[$puppet_master_package],
      logoutput => on_failure,
    }

    if ! defined(Class[$puppet_passenger_class]) {
      class { $puppet_passenger_class: }
    }

    include apache

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

    concat::fragment { 'puppet.conf-master':
      order   => '02',
      target  => $puppet_conf,
      content => template('puppet/puppet.conf-master.erb'),
    }
}