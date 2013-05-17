# Class: puppet::passenger
#
# This class installs and configures the puppetdb terminus pacakge
#
# Parameters:
#   ['puppet_passenger_port']    - The port for the virtual host
#   ['puppet_docroot']           - Apache documnet root
#   ['apache_serveradmin']       - The apache server admin
#   ['puppet_conf']              - The puppet config dir
#   ['puppet_ssldir']            - The pupet ssl dir
#   ['certname']                 - The puppet certname
#   [conf_dir]                   - The configuration directory of the puppet install
#
# Actions:
# - Configures apache and passenger for puppet master use.
#
# Requires:
# - Inifile
# - Class['puppet::params']
# - Class['apache']
#
# Sample Usage:
#   class { 'puppet::passenger':
#           puppet_passenger_port  => 8140,
#           puppet_docroot         => '/etc/puppet/docroot',
#           apache_serveradmin     => 'wibble',
#           puppet_conf            => '/etc/puppet/puppet.conf',
#           puppet_ssldir          => '/var/lib/puppet/ssl',
#           certname               => 'puppet.example.com',
#           conf_dir               => '/etc/puppet',
#   }
#
class puppet::passenger(
  $puppet_passenger_port,
  $puppet_docroot,
  $apache_serveradmin,
  $puppet_conf,
  $puppet_ssldir,
  $certname,
  $conf_dir
){
  include apache
  include puppet::params
  class { 'apache::mod::passenger': passenger_max_pool_size => 12, }
  include apache::mod::ssl

  if $::osfamily == 'redhat' {

    file{'/var/lib/puppet/reports':
      ensure => directory,
      owner  => $::puppet::params::puppet_user,
      group  => $::puppet::params::puppet_group,
      mode   => '0750',
    }
  }

  exec { 'Certificate_Check':
    command   => "puppet cert --generate ${certname} --trace",
    unless    => "/bin/ls ${puppet_ssldir}/certs/${certname}.pem",
    path      => '/usr/bin:/usr/local/bin',
    logoutput => on_failure,
    require   => File[$puppet_conf]
  }

  file { $puppet_docroot:
    ensure => directory,
    owner  => $::puppet::params::puppet_user,
    group  => $::puppet::params::puppet_group,
    mode   => '0755',
  }

  apache::vhost { "puppet-${certname}":
    port               => $puppet_passenger_port,
    priority           => '40',
    docroot            => $puppet_docroot,
    configure_firewall => false,
    serveradmin        => $apache_serveradmin,
    servername         => $certname,
    require            => [ File['/etc/puppet/rack/config.ru'], File[$puppet_conf] ],
    ssl                => true,
    ssl_cert           => "${puppet_ssldir}/certs/${certname}.pem",
    ssl_key            => "${puppet_ssldir}/private_keys/${certname}.pem",
    ssl_chain          => "${puppet_ssldir}/ca/ca_crt.pem",
    ssl_ca             => "${puppet_ssldir}/ca/ca_crt.pem",
    ssl_crl            => "${puppet_ssldir}/ca/ca_crl.pem",
    rack_base_uris     => '/',
    custom_fragment    => template('puppet/apache_custom_fragment.erb'),
  }

  #Hack to add extra passenger configurations for puppetmaster
  file { 'puppet_passenger.conf':
    ensure  => file,
    path    => "${apache::mod_dir}/puppet_passenger.conf",
    content => template('puppet/puppet_passenger.conf.erb'),
    notify  => Service['httpd'],
  }
    
  file { '/etc/puppet/rack':
    ensure => directory,
    owner  => $::puppet::params::puppet_user,
    group  => $::puppet::params::puppet_group,
    mode   => '0755',
  }

  file { '/etc/puppet/rack/config.ru':
    ensure => present,
    owner  => $::puppet::params::puppet_user,
    group  => $::puppet::params::puppet_group,
    content => template('puppet/config.erb'),
    mode   => '0644',
  }

  ini_setting {'puppetmastersslclient':
    ensure  => present,
    section => 'master',
    setting => 'ssl_client_header',
    path    => $puppet_conf,
    value   => 'SSL_CLIENT_S_DN',
    require => File[$puppet_conf],
  }

  ini_setting {'puppetmastersslclientverify':
    ensure  => present,
    section => 'master',
    setting => 'ssl_client_verify_header',
    path    => $puppet_conf,
    value   => 'SSL_CLIENT_VERIFY',
    require => File[$puppet_conf],
  }
}

