# Class: puppet::agent
#
# This class installs and configures the puppet agent
#
# Parameters:
#   ['puppet_server']         - The dns name of the puppet master
#   ['puppet_server_port']    - The Port the puppet master is running on
#   ['puppet_agent_service']  - The service the puppet agent runs under
#   ['puppet_agent_package']  - The name of the package providing the puppet agent
#   ['version']               - The version of the puppet agent to install
#   ['puppet_run_style']      - The run style of the agent either cron or service
#   ['puppet_run_interval']   - The run interval of the puppet agent in minutes, default is 30 minutes
#   ['user_id']               - The userid of the puppet user
#   ['group_id']              - The groupid of the puppet group
#   ['splay']                 - If splay should be enable defaults to false
#   ['environment']           - The environment of the puppet agent
#   ['report']                - Whether to return reports
#   ['pluginsync']            - Whethere to have pluginsync
#   ['use_srv_records']       - Whethere to use srv records
#   ['srv_domain']            - Domain to request the srv records
#
# Actions:
# - Install and configures the puppet agent
#
# Requires:
# - Inifile
#
# Sample Usage:
#   class { 'puppet::agent':
#       puppet_server             => master.puppetlabs.vm,
#       environment               => production,
#       splay                     => true,
#   }
#
class puppet::agent(
  $puppet_server          = $::puppet::params::puppet_server,
  $puppet_server_port     = $::puppet::params::puppet_server_port,
  $puppet_agent_service   = $::puppet::params::puppet_agent_service,
  $puppet_agent_package   = $::puppet::params::puppet_agent_package,
  $version                = 'present',
  $puppet_run_style       = 'service',
  $puppet_run_interval    = 30,
  $user_id                = undef,
  $group_id               = undef,
  $splay                  = false,
  $environment            = 'production',
  $report                 = true,
  $pluginsync             = true,
  $use_srv_records        = false,
  $srv_domain             = undef
) inherits puppet::params {

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
  package { $puppet_agent_package:
    ensure   => $version,
  }

  if $puppet_run_style == 'service'{
    $startonboot = 'yes'
  }
  else {
    $startonboot = 'no'
  }

  if ($::osfamily == 'Debian') or  ($::osfamily == 'Redhat') {
    file { $puppet::params::puppet_defaults:
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package[$puppet_agent_package],
      content => template("puppet/${puppet::params::puppet_defaults}.erb"),
    }
  }

  if ! defined(File[$::puppet::params::confdir]) {
    file { $::puppet::params::confdir:
      ensure  => directory,
      require => Package[$puppet_agent_package],
      owner   => $::puppet::params::puppet_user,
      group   => $::puppet::params::puppet_group,
      notify  => Service[$puppet_agent_service],
      mode    => '0655',
    }
  }

  case $puppet_run_style {
    'service': {
          $service_notify = Service[$puppet_agent_service]
          service { $puppet_agent_service:
            ensure    => true,
            enable    => true,
            require   => File [$::puppet::params::puppet_conf],
            subscribe => Package[$puppet_agent_package],
            }
    }
    'cron': {
      # ensure that puppet is not running and will start up on boot
      service { $puppet_agent_service:
        ensure      => 'stopped',
        enable      => false,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package[$puppet_agent_package],
      }

      # Run puppet as a cron - this saves memory and avoids the whole problem
      # where puppet locks up for no reason. Also spreads out the run intervals
      # more uniformly.
      $time1  =  fqdn_rand($puppet_run_interval)
      $time2  =  fqdn_rand($puppet_run_interval) + 30

      cron { 'puppet-client':
        command => '/usr/bin/puppet agent --no-daemonize --onetime --logdest syslog > /dev/null 2>&1',
        user    => 'root',
        # run twice an hour, at a random minute in order not to collectively stress the puppetmaster
        hour    => '*',
        minute  => [ $time1, $time2 ],
      }
    }
    # Run Puppet through external tooling, like MCollective
    external: {
    }
    default: {
      err 'Unsupported puppet run style in Class[\'puppet::agent\']'
    }
  }

  if ! defined(File[$::puppet::params::puppet_conf]) {
      file { $::puppet::params::puppet_conf:
        ensure  => 'file',
        mode    => '0644',
        require => File[$::puppet::params::confdir],
        owner   => $::puppet::params::puppet_user,
        group   => $::puppet::params::puppet_group,
        notify  => $service_notify,
      }
    }
    else {
      if $puppet_run_style == 'service' {
        File<| title == $::puppet::params::puppet_conf |> {
          notify  +> $service_notify,
        }
      }
    }

  #run interval in seconds
  $runinterval = $puppet_run_interval * 60

  Ini_setting {
      path    => $::puppet::params::puppet_conf,
      require => File[$::puppet::params::puppet_conf],
      section => 'agent',
  }

  if (($use_srv_records == true) and ($srv_domain == undef))
  {
    fail("${module_name} has attribute use_srv_records set but has srv_domain unset")
  }
  elsif (($use_srv_records == true) and ($srv_domain != undef))
  {
    ini_setting {'puppetagentsrv_domain':
      ensure  => present,
      setting => 'srv_domain',
      value   => $srv_domain,
    }
  }
  elsif($use_srv_records == false)
  {
    ini_setting {'puppetagentsrv_domain':
      ensure  => absent,
      setting => 'srv_domain',
    }
  }

  ini_setting {'puppetagentenvironment':
    ensure  => present,
    setting => 'environment',
    value   => $environment,
  }

  ini_setting {'puppetagentmaster':
    ensure        => present,
    setting   => 'server',
    value => $puppet_server,
  }

  ini_setting {'puppetagentuse_srv_records':
    ensure  => present,
    setting => 'use_srv_records',
    value   => $use_srv_records,
  }

  ini_setting {'puppetagentruninterval':
    ensure  => present,
    setting => 'runinterval',
    value   => $runinterval,
  }

  ini_setting {'puppetagentsplay':
    ensure  => present,
    setting => 'splay',
    value   => $splay,
  }

  ini_setting {'puppetmasterport':
    ensure  => present,
    setting => 'masterport',
    value   => $puppet_server_port,
  }
  ini_setting {'puppetagentreport':
    ensure  => present,
    setting => 'report',
    value   => $report,
  }
  ini_setting {'puppetagentpluginsync':
    ensure  => present,
    setting => 'pluginsync',
    value   => $pluginsync,
  }
}
