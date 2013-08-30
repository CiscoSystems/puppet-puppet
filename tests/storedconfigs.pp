class {'puppet::storeconfigs':
  dbserver => 'test.example.com',
  dbport => '8081',
  puppet_service => Service['httpd']
}
