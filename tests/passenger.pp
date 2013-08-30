class{ 'puppet::passenger':
  puppet_passenger_port => '8140',
  puppet_docroot => '/etc/puppet/doc',
  apache_serveradmin => 'me@example.com',
  puppet_site => 'master.example.com',
  puppet_conf => '/etc/puppet/puppet.conf',
  puppet_ssldir => '/var/lib/puppet/ssl',
  certname => 'master.example.com',
}
