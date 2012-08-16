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
    value   => 'true',
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