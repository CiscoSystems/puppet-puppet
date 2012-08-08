
class puppet::storeconfigs::puppetdb(
    $puppetdb_host = $settings::certname,
    $puppetmaster_service = undef,
    $puppet_confdir
)
{
    package { "puppetdb-terminus":
        ensure  => present,
    }

    # TODO: this will overwrite any existing routes.yaml;
    #  to handle this properly we should just be ensuring
    #  that the proper lines exist
    file { "$puppet_confdir/routes.yaml":
        ensure      => file,
        source      => 'puppet:///modules/puppet/routes.yaml',
        notify      => $puppetmaster_service,
        require     => Package['puppetdb-terminus'],
    }

    # TODO: Add port support 
    file { "$puppet_confdir/puppetdb.conf":
        ensure      => file,
        content     => template('puppet/puppetdb.conf.erb'),
        require     => File["$puppet_confdir/routes.yaml"],
        notify      => $puppetmaster_service,
    }
}