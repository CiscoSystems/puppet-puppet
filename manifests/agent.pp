# Class: puppet::agent
#
# This class installs and configures the puppet agent
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::agent(
  $puppet_group           = $::puppet::params::puppet_group,
  $puppet_server          = $::puppet::params::puppet_server,
  $puppet_user            = $::puppet::params::puppet_user,
  $puppet_agent_service   = $::puppet::params::puppet_agent_service,
  $puppet_agent_name      = $::puppet::params::puppet_agent_name,
  $puppet_conf            = $::puppet::params::puppet_conf,
  $package_provider       = undef,
  $version                = 'present',
  $puppet_agent_enabled   = true,
  $puppet_run_style       = 'service',
  $puppet_run_interval    = 30,
  $user_id                = undef,
  $group_id               = undef,
  $splay                  = 'UNSET',
  $environment            = "production"
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

  if $::kernel == 'Linux' {
    file { $puppet::params::puppet_defaults:
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template("puppet/${puppet::params::puppet_defaults}.erb"),
    }
  }

  package { $puppet_agent_name:
    ensure   => $version,
    provider => $package_provider,
  }

  case $puppet_run_style {
    'service': {
      if $package_provider == 'gem' {
        $service_notify = Exec['puppet_agent_start']

        exec { 'puppet_agent_start':
          command   => '/usr/bin/nohup puppet agent &',
          refresh   => '/usr/bin/pkill puppet && /usr/bin/nohup puppet agent &',
          unless    => '/bin/ps -ef | grep -v grep | /bin/grep \'puppet agent\'',
          require   => File[$puppet_conf],
          subscribe => Package[$puppet_agent_name],
        }
        } else {
          $service_notify = Service[$puppet_agent_service]

          service { $puppet_agent_service:
            ensure    => $puppet_agent_enabled,
            enable    => $puppet_agent_enabled,
            hasstatus => true,
            require   => File[$puppet_conf],
            subscribe => Package[$puppet_agent_name],
            #before   => Service['httpd'];
            }
        }
        if ! defined(File[$::puppet::params::confdir]) {
          file { $::puppet::params::confdir:
            require => Package[$puppet_agent_name],
            owner   => $puppet_user,
            group   => $puppet_group,
            notify  => $puppet::agent::service_notify,
          }
        }
    }
    'cron': {
      # ensure that puppet is not running and will start up on boot
      service { $puppet_agent_service:
        ensure      => 'stopped',
        enable      => false,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package[$puppet_agent_name],
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
    default: {
      err 'Unsupported puppet run style in Class[\'puppet::agent\']'
    }
  }

  if ! defined(Concat[$puppet_conf]) {
    concat { $puppet_conf:
      mode    => '0644',
      require => Package['puppet'],
      owner   => $puppet_user,
      group   => $puppet_group,
      notify  => $service_notify,
    }
  }
  else {
    Concat<| title == $puppet_conf |> {
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

  concat::fragment { 'puppet.conf-agent':
  order   => '01',
  target  => $puppet_conf,
  content => template('puppet/puppet.conf-agent.erb'),
  notify  =>  $service_notify,
  }

}
