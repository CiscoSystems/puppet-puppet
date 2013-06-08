#
# This module is used to setup the puppetlabs repos
# that can be used to install puppet.
#
class puppet::repo::puppetlabs() {

  if($::osfamily == 'Debian') {
    Apt::Source {
      location   => 'http://apt.puppetlabs.com',
      key        => '4BD6EC30',
      key_server => 'pgp.mit.edu',
    }
    apt::source { 'puppetlabs':      repos => 'main' }
    apt::source { 'puppetlabs-deps': repos => 'dependencies' }
  } elsif $::osfamily == 'Redhat' {
    fail('The puppetlabs yum repos are not yet supported')
  } else {
    fail("Unsupported osfamily ${::osfamily}")
  }
}
