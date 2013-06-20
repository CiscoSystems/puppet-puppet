class puppet::params {

  case $::osfamily {
    'redhat' : {
      $puppet         = 'puppet'
      $puppetmaster   = 'puppet-server'
      $apache_service = 'httpd'
      $activerecord   = 'rubygem-activerecord'
    }
    'debian' : {
      $puppet         = 'puppet-common'
      $puppetmaster   = 'puppetmaster-passenger'
      $apache_service = 'apache2'
      $activerecord   = 'ruby-activerecord'
    }
    default: {
      fail("unsupported osfamily: $::osfamily")
    }
  }
}
