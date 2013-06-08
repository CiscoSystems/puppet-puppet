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
      { :osfamily        => 'Redhat' }
    end
    it 'should fail until proper support is added' do
      expect do
        subject
      end.to raise_error(Puppet::Error, /The puppetlabs yum repos are not yet supported/)
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
