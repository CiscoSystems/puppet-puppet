# Define: puppet::masterenv
#
# This define configures puppet master environment
#
# Parameters:
#   ['modulepath']         - The modulepath for the environment
#   ['manifest']           - The manifest for the environmen
#
# Actions:
# - Add enviroments to the puppet master
#
# Requires:
# - Inifile
#
# Sample Usage:
#   puppet::masterenv{ 'dev':
#       modulepath             => '/etc/puppet/modules'
#       manifest               => 'dev'
#   }
#
define  puppet::masterenv ($modulepath, $manifest, $puppet_conf = $::puppet::params::puppet_conf){
  Ini_setting {
      path    => $puppet_conf,
      require => [File[$puppet_conf], Class['puppet::master']],
      notify  => Service['httpd'],
  }

  ini_setting {"masterenvmodule${name}":
    ensure  => present,
    section => $name,
    setting => 'modulepath',
    value   => $modulepath,
  }
  ini_setting {"masterenvmanifest${name}":
    ensure  => present,
    section => $name,
    setting => 'manifest',
    value   => $manifest,
  }
}
