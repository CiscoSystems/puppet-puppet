class puppet::storeconfigs(
    $dbserver,
    $dbport,
    $puppet_service,
    $puppet_confdir = '/etc/puppet/',
    $puppet_conf = '/etc/puppet/puppet.comf',
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
    content     => template('puppet/puppetdb.conf.erb'),
    require     => File["$puppet_confdir/routes.yaml"],
    notify      => $puppet_service,
  }
  concat::fragment { 'puppet.conf-master-storeconfig':
    order   => '03',
    target  => $puppet_conf,
    content => template('puppet/puppet.conf-master-storeconfigs.erb'),
    notify  => $puppet_service,
  }
}