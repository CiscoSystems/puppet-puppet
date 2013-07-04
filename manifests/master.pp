# Class: puppet::master
#
# This class installs and configures a Puppet master
#
# Parameters:
#  ['user_id']                  - The userid of the puppet user
#  ['group_id']                 - The groupid of the puppet group
#  ['modulepath']               - Module path to be served by the puppet master
#  ['manifest']                 - Manifest path
#  ['reports']                  - Turn on puppet reports
#  ['storeconfigs']             - Use storedcofnigs
#  ['storeconfigs_dbserver']    - Puppetdb server
#  ['storeconfigs_dbport']      - Puppetdb port
#  ['certname']                 - The certname the puppet master should use
#  ['autosign']                 - Auto sign agent certificates default false
#  ['reporturl']                - Url to send reports to, if reporting enabled
#  ['puppet_ssldir']            - Puppet sll directory
#  ['puppet_docroot']           - Doc root to be configured in apache vhost
#  ['puppet_vardir']            - Vardir used by puppet
#  ['puppet_passenger_port']    - Port to conifgure passenger on default 8140
#  ['puppet_master_package']    - Puppet master package
#  ['puppet_master_service']    - Puppet master service
#  ['version']                  - Version of the puppet master package to install
#  ['apache_serveradmin']       - Apache server admin
#  ['puppetdb_startup_timeout'] - The timeout for puppetdb
#
# Requires:
#
#  - inifile
#  - Class['puppet::params']
#  - Class[puppet::passenger]
#  - Class['puppet::storeconfigs']
#
# Sample Usage:
#
#  $modulepath = [
#    "/etc/puppet/modules/site",
#    "/etc/puppet/modules/dist",
#  ]
#
#  class { "puppet::master":
#    modulepath             => inline_template("<%= modulepath.join(':') %>"),
#    storedcofnigs          => 'true',
#  }
#
class puppet::master (
  $user_id                  = undef,
  $group_id                 = undef,
  $modulepath               = $::puppet::params::modulepath,
  $manifest                 = $::puppet::params::manifest,
  $reports                  = store,
  $storeconfigs             = false,
  $storeconfigs_dbserver   =  $::puppet::params::storeconfigs_dbserver,
  $storeconfigs_dbport      = $::puppet::params::storeconfigs_dbport,
  $certname                 = $::fqdn,
  $autosign                 = false,
  $reporturl                = 'UNSET',
  $puppet_ssldir            = $::puppet::params::puppet_ssldir,
  $puppet_docroot           = $::puppet::params::puppet_docroot,
  $puppet_vardir            = $::puppet::params::puppet_vardir,
  $puppet_passenger_port    = $::puppet::params::puppet_passenger_port,
  $puppet_master_package    = $::puppet::params::puppet_master_package,
  $puppet_master_service    = $::puppet::params::puppet_master_service,
  $version                  = 'present',
  $apache_serveradmin       = $::puppet::params::apache_serveradmin,
  $pluginsync               = 'true',
  $puppetdb_startup_timeout = '60'
) inherits puppet::params {

  anchor { 'puppet::master::begin': }

  if ! defined(User[$::puppet::params::puppet_user]) {
    user { $::puppet::params::puppet_user:
      ensure => present,
      uid    => $user_id,
      gid    => $::puppet::params::puppet_group,
    }
  }

  if ! defined(Group[$::puppet::params::puppet_group]) {
    group { $::puppet::params::puppet_group:
      ensure => present,
      gid    => $group_id,
    }
  }

  if ! defined(Package[$puppet_master_package]) {
    package { $puppet_master_package:
      ensure   => $version,
    }
  }

  Anchor['puppet::master::begin'] ->
  class {'puppet::passenger':
    puppet_passenger_port  => $puppet_passenger_port,
    puppet_docroot         => $puppet_docroot,
    apache_serveradmin     => $apache_serveradmin,
    puppet_conf            => $::puppet::params::puppet_conf,
    puppet_ssldir          => $::puppet::params::puppet_ssldir,
    certname               => $certname,
    conf_dir               => $::puppet::params::confdir,
  } ->
  Anchor['puppet::master::end']

  service { $puppet_master_service:
    ensure    => stopped,
    enable    => false,
    require   => File[$::puppet::params::puppet_conf],
  }

  if ! defined(File[$::puppet::params::puppet_conf]){
    file { $::puppet::params::puppet_conf:
      ensure  => 'file',
      mode    => '0655',
      require => File[$::puppet::params::confdir],
      owner   => $::puppet::params::puppet_user,
      group   => $::puppet::params::puppet_group,
      notify  => Service['httpd'],
    }
  }
  else {
    File<| title == $::puppet::params::puppet_conf |> {
      notify  => Service['httpd'],
    }
  }

  if ! defined(File[$::puppet::params::confdir]) {
    file { $::puppet::params::confdir:
      ensure  => directory,
      mode    => '0655',
      require => Package[$puppet_master_package],
      owner   => $::puppet::params::puppet_user,
      group   => $::puppet::params::puppet_group,
      notify  => Service['httpd'],
    }
  }
  else {
    File<| title == $::puppet::params::confdir |> {
      notify  +> Service['httpd'],
      require +> Package[$puppet_master_package],
    }
  }

  file { $puppet_vardir:
    ensure       => directory,
    owner        => $::puppet::params::puppet_user,
    group        => $::puppet::params::puppet_group,
    notify       => Service['httpd'],
    require      => Package[$puppet_master_package]
  }

  if $storeconfigs {
    Anchor['puppet::master::begin'] ->
    class { 'puppet::storeconfigs':
      dbserver                  => $storeconfigs_dbserver,
      dbport                    => $storeconfigs_dbport,
      puppet_service            => Service['httpd'],
      puppet_confdir            => $::puppet::params::puppet_confdir,
      puppet_conf               => $::puppet::params::puppet_conf,
      puppet_master_package     => $puppet_master_package,
      puppetdb_startup_timeout  => $puppetdb_startup_timeout,
    } ->
    Anchor['puppet::master::end']
  }

  Ini_setting {
      path    => $::puppet::params::puppet_conf,
      require => File[$::puppet::params::puppet_conf],
      notify  => Service['httpd'],
      section => 'master',
  }

  ini_setting {'puppetmastermodulepath':
    ensure  => present,
    setting => 'modulepath',
    value   => $modulepath,
  }

  ini_setting {'puppetmastermanifest':
    ensure  => present,
    setting => 'manifest',
    value   => $manifest,
  }

  ini_setting {'puppetmasterautosign':
    ensure  => present,
    setting => 'autosign',
    value   => $autosign,
  }

  ini_setting {'puppetmastercertname':
    ensure  => present,
    setting => 'certname',
    value   => $certname,
  }

  ini_setting {'puppetmasterreports':
    ensure  => present,
    setting => 'reports',
    value   => $reports,
  }

  ini_setting {'puppetmasterpluginsync':
    ensure  => present,
    setting => 'pluginsync',
    value   => $pluginsync,
  }

  if $reporturl != 'UNSET'{
    ini_setting {'puppetmasterreport':
      ensure  => present,
      setting => 'reporturl',
      value   => $reporturl,
    }
  }

  anchor { 'puppet::master::end': }
}
