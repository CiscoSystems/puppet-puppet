#"
# This module is used to setup the puppetlabs repos
# that can be used to install puppet.
#
class puppet::repo::puppetlabs() {

  if($::osfamily == 'Debian') {
    Apt::Source {
      location    => 'http://apt.puppetlabs.com',
      key         => '4BD6EC30',
      key_content => template('puppet/pgp.key'),
    }
    apt::source { 'puppetlabs':      repos => 'main' }
    apt::source { 'puppetlabs-deps': repos => 'dependencies' }
    } elsif $::osfamily == 'Redhat' {
      if $::operatingsystem == 'Fedora' {
        $ostype='fedora'
        $prefix='f'
      } else {
          $ostype='el'
          $prefix=''
      }
      yumrepo { 'puppetlabs-deps':
        baseurl  => "http://yum.puppetlabs.com/${ostype}/${prefix}\$releasever/dependencies/\$basearch",
        descr    => 'Puppet Labs Dependencies $releasever - $basearch ',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
      }

      yumrepo { 'puppetlabs':
        baseurl  => "http://yum.puppetlabs.com/${ostype}/${prefix}\$releasever/products/\$basearch",
        descr    => 'Puppet Labs Products $releasever - $basearch',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
      }
    } else {
      fail("Unsupported osfamily ${::osfamily}")
    }
}
