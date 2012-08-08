# Class: puppet::master
#
# This class installs and configures a Puppet master
#
# Parameters:
#   [*user_id*]               - Userid of the puppet user
#   [*group_id*]              - Groupid of the puppet groud
#   [*modulepath*]            - The modulepath configuration value used in
#                               puppet.conf
#   [*manifest*]              - The manifest configuration value in puppet.conf
#   [*storeconfigs*]          - Boolean determining whether storeconfigs is
#                               to be enabled.
#   [*storeconfigs_dbadapter*] - The database adapter to use with storeconfigs
#   [*storeconfigs_dbuser*]   - The database username used with storeconfigs
#   [*storeconfigs_dbpassword*] - The database password used with storeconfigs
#   [*storeconfigs_dbserver*]   - Fqdn of the storeconfigs database server
#   [*storeconfigs_dbsocket*]   - The path to the mysql socket file
#   [*certname*]              - The certname configuration value in puppet.conf
#   [*autosign*]              - The autosign configuration value in puppet.conf
#   [*dashboard_port*]          - The port on which puppet-dashboard should run
#   [*puppet_conf*]           - The puppet configuration file path
#   [*puppet_passenger*]      - Boolean value to determine whether puppet is
#                               to be run with Passenger
#   [*puppet_passenger_class*]- string which determines which puppet class
#                               holds the passenger definition
#   [*puppet_site*]           - The VirtualHost value used in the apache vhost
#                               configuration file when Passenger is enabled
#   [*puppet_ssldir*]         - Puppets ssl dir
#   [*puppet_docroot*]        - The DocumentRoot value used in the apache vhost
#                               configuration file when Passenger is enabled
#   [*puppet_vardir*]         - The path to the puppet vardir
#   [*puppet_passenger_port*] - The port on which puppet is listening when
#                               Passenger is enabled
#   [*puppet_master_package*]   - The name of the puppet master package
#   [*package_provider*]        - The provider used for package installation
#   [*puppet_master_service*]   - The serice that is used to control the puppetmaster
#   [*version*]               - The value of the ensure parameter for the
#                               puppet master and agent packages
#
# Actions:
#
# Requires:
#
#  Class['concat']
#  Class['stdlib']
#  Class['concat::setup']
#
# Sample Usage:
#
#  $modulepath = [
#    "/etc/puppet/modules/site",
#    "/etc/puppet/modules/dist",
#  ]
#
#  class { "puppet::master":
#    modulepath => inline_template("<%= modulepath.join(':') %>"),
#    dbadapter  => 'puppetdb',
#    storeconfigs_dbserver     => 'master.puppetlabs.vm',
#  }
#
class puppet::master (
  $user_id                  = undef,
  $group_id                 = undef,
  $modulepath               = $::puppet::params::modulepath,
  $manifest                 = $::puppet::params::manifest,
  $storeconfigs             = false,
  $storeconfigs_dbadapter   = $::puppet::params::storeconfigs_dbadapter,
  $storeconfigs_dbuser      = $::puppet::params::storeconfigs_dbuser,
  $storeconfigs_dbpassword  = $::puppet::params::storeconfigs_dbpassword,
  $storeconfigs_dbserver    = $::puppet::params::storeconfigs_dbserver,
  $storeconfigs_dbsocket    = $::puppet::params::storeconfigs_dbsocket,
  $certname                 = $::fqdn,
  $autosign                 = false,
  $dashboard_port           = 'UNSET',
  $puppet_conf              = $::puppet::params::puppet_conf,
  $puppet_passenger         = false,
  $puppet_passenger_class   = 'passenger',
  $puppet_site              = $::puppet::params::puppet_site,
  $puppet_ssldir            = $::puppet::params::puppet_ssldir,
  $puppet_docroot           = $::puppet::params::puppet_docroot,
  $puppet_vardir            = $::puppet::params::puppet_vardir,
  $puppet_passenger_port    = false,
  $puppet_master_package    = $::puppet::params::puppet_master_package,
  $package_provider         = undef,
  $puppet_master_service    = $::puppet::params::puppet_master_service,
  $version                  = 'present',
  $puppet_group             = $::puppet::params::puppet_group,
  $puppet_user              = $::puppet::params::puppet_user,
  $apache_serveradmin       = $::puppet::params::apache_serveradmin
) inherits puppet::params {
  include concat::setup

  if ! defined(User[$puppet_user]) {
    user { $puppet_user:
      ensure => present,
      uid    => $user_id,
      gid    => $puppet_group,
    }
  }

  if ! defined(Group[$puppet_group]) {
    group { $puppet_group:
      ensure => present,
      gid    => $group_id,
    }
  }

  if ! defined(Package[$puppet_master_package]) {
    package { $puppet_master_package:
      ensure   => $version,
      provider => $package_provider,
    }
  }

  if $puppet_passenger {
    $service_notify  = Service['httpd']
    $service_require = [Package[$puppet_master_package], Class[$puppet_passenger_class]]
    class {'puppet::apache':
      puppet_passenger_class => $puppet_passenger_class,
      puppet_passenger_port  => $puppet_passenger_port,
      puppet_docroot         => $puppet_docroot,
      apache_serveradmin     => $apache_serveradmin,
      puppet_site            => $puppet_site,
      puppet_conf            => $puppet_conf,
    }
  } else {
    $service_require = Package[$puppet_master_package]
    $service_notify = Service[$puppet_master_service]

    service { $puppet_master_service:
      ensure    => true,
      enable    => true,
      require   => File[$puppet_conf],
      subscribe => Package[$puppet_master_package],
    }

    Concat::Fragment['puppet.conf-master'] -> Service[$puppet_master_service]

    concat::fragment { 'puppet.conf-master':
      order   => '02',
      target  => $puppet_conf,
      content => template('puppet/puppet.conf-master.erb'),
      notify  =>  $service_notify,
    }
  }

  if ! defined(Concat[$puppet_conf]) {
    concat { $puppet_conf:
      mode    => '0644',
      owner   => $puppet_user,
      group   => $puppet_group,
      require => [$puppet::master::service_require,File[$::puppet::params::confdir]],
      notify  => $puppet::master::service_notify,
    }
  }
  else {
    Concat<| title == $puppet_conf |> {
      require +> $service_require,
      notify  +> $service_notify,
    }
  }

  if ! defined(Concat::Fragment['puppet.conf-common']) {
    concat::fragment { 'puppet.conf-common':
      order   => '00',
      target  => $puppet_conf,
      content => template('puppet/puppet.conf-common.erb'),
    }
  }

  if ! defined(File[$::puppet::params::confdir]) {
    file { $::puppet::params::confdir:
      ensure  => directory,
      require => Package[$puppet_master_package],
      owner   => $puppet_user,
      group   => $puppet_group,
      notify  => $service_notify,
    }
  }
  else {
    File<| title == $::puppet::params::confdir |> {
      notify  +> $service_notify,
      require +> Package[$puppet_master_package],
    }
  }

  file { $puppet_vardir:
    ensure       => directory,
    owner        => $puppet_user,
    group        => $puppet_group,
    notify       => $service_notify,
    require      => Package[$puppet_master_package]
  }

  if $storeconfigs {
    class { 'puppet::storeconfigs':
      dbadapter       => $storeconfigs_dbadapter,
      dbuser          => $storeconfigs_dbuser,
      dbpassword      => $storeconfigs_dbpassword,
      dbserver        => $storeconfigs_dbserver,
      dbsocket        => $storeconfigs_dbsocket,
      puppet_service  => $service_notify,
      puppet_conf     => $puppet_conf,
    }
  }
}