 class {'puppet::dbterminus': 
  puppet_confdir =>: '/etc/puppet/puppet.conf', 
  puppet_service => Service['httpd'], 
  dbport =>m '8081',
  dbserver => 'test.example.com'
  }
