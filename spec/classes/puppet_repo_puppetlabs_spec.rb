require 'spec_helper'

describe 'puppet::repo::puppetlabs', :type => :class do

  context 'on Debian operatingsystems' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :lsbdistcodename => 'Precise'
      }
    end
    it 'should contain puppetlabs apt repos' do
      should contain_apt__source('puppetlabs').with(
        :repos      => 'main',
        :location   => 'http://apt.puppetlabs.com',
        :key        => '4BD6EC30',
        :key_server => 'pgp.mit.edu'
      )
      should contain_apt__source('puppetlabs-deps').with(
        :repos      => 'dependencies',
        :location   => 'http://apt.puppetlabs.com',
        :key        => '4BD6EC30',
        :key_server => 'pgp.mit.edu'
      )
    end
  end

  context 'on redhat systems' do
    let :facts do
      {
        :osfamily        => 'Redhat',
        :operatingsystem => 'Redhat'
      }
    end
    it 'should add the redhat specific repoos' do
      should contain_yumrepo('puppetlabs').with(
        :baseurl  => 'http://yum.puppetlabs.com/el/$releasever/products/$basearch'
      )
      should contain_yumrepo('puppetlabs-deps').with(
        :baseurl  => 'http://yum.puppetlabs.com/el/$releasever/dependencies/$basearch'
      )
    end
  end

  context 'on fedora systems' do
    let :facts do
      {
        :osfamily        => 'Redhat',
        :operatingsystem => 'Fedora'
      }
    end
    it 'should add the fedora specific repos' do
      should contain_yumrepo('puppetlabs').with(
        :baseurl  => 'http://yum.puppetlabs.com/fedora/f$releasever/products/$basearch'
      )
      should contain_yumrepo('puppetlabs-deps').with(
        :baseurl  => 'http://yum.puppetlabs.com/fedora/f$releasever/dependencies/$basearch'
      )
    end
  end

  context 'on redhat systems' do
    let :facts do
      { :osfamily        => 'FreeBSD' }
    end
    it 'should fail for unsupported os families' do
      expect do
        subject
      end.to raise_error(Puppet::Error, /Unsupported osfamily FreeBSD/)
    end
  end
end
