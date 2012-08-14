class puppet::storeconfigs(
    $dbserver,
    $dbport,
    $puppet_service,
    $puppet_confdir = '/etc/puppet/',
    $puppet_conf = '/etc/puppet/puppet.conf',
)
{
  package { 'puppetdb-terminus':
    ensure  => present,
  }

  # TODO: this will overwrite any existing routes.yaml;
  #  to handle this properly we should just be ensuring
  #  that the proper lines exist
  file { "$puppet_confdir/routes.yaml":
    ensure      => file,
    source      => 'puppet:///modules/puppet/routes.yaml',
    notify      => $puppet_service,
    require     => Package['puppetdb-terminus'],
  }

  # TODO: Add port support
  file { "$puppet_confdir/puppetdb.conf":
    ensure      => file,
    require     => File["$puppet_confdir/routes.yaml"],
    notify      => $puppet_service,
  }

  ini_setting {'puppetmasterstoreconfigserver':
    ensure  => present,
    section => 'master',
    setting => 'server',
    path    => $puppet_conf,
    value   => $dbserver,
    require => File[$puppet_conf],
  }

  ini_setting {'puppetmasterstoreconfig':
    ensure  => present,
    section => 'master',
    setting => 'storeconfigs',
    path    => $puppet_conf,
    value   => 'true',
    require => File[$puppet_conf],
  }

  ini_setting {'puppetmasterstorebackend':
    ensure  => present,
    section => 'master',
    setting => 'storeconfigs_backend',
    path    => $puppet_conf,
    value   => 'puppetdb',
    require => File[$puppet_conf],
  }
}