require 'spec_helper'

describe 'puppet::master', :type => :class do

    context 'on Debian operatingsystems' do
        let(:facts) do
            { 
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
                :concat_basedir  => '/var/lib/puppet/concat',
            }
        end
        let (:params) do
            {
                :version                => 'present',
                :puppet_master_package  => 'puppetmaster',
                :puppet_master_service  => 'puppetmaster',
                :modulepath             => '/etc/puppet/modules',
                :manifest               => '/etc/puppet/manifests/site.pp',
                :autosign               => 'true',
                :certname               => 'test.example.com',  
                :storeconfigs           => 'true',
                :storeconfigs_dbserver  => 'test.example.com'

            }
        end
        it {
            should include_class('concat::setup')
            should contain_user('puppet').with(
                :ensure => 'present',
                :uid    => nil,
                :gid    => 'puppet'
            )
            should contain_group('puppet').with(
                :ensure => 'present',
                :gid    => nil
            )
            should contain_package(params[:puppet_master_package]).with(
                :ensure => params[:version]
            )
            should contain_service(params[:puppet_master_service]).with(
                :ensure    => 'stopped',
                :enable    => 'false',
                :require   => 'File[/etc/puppet/puppet.conf]',
                :subscribe => "Package[#{params[:puppet_master_package]}]"
            )
            should contain_concat__fragment('puppet.conf-master').with(
                :order      => '02',
                :target     => '/etc/puppet/puppet.conf',
                :notify     => "Service[httpd]",
                :content    => /modulepath\s*= #{params[:modulepath]}/,
                :content    => /manifest\s*= #{params[:manifest]}/,
                :content    => /autosign\s*= #{params[:autosign]}/,
                :content    => /certname\s*= #{params[:certname]}/
            )
            should contain_concat('/etc/puppet/puppet.conf').with(
                :mode    => '0644',
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => "Service[httpd]"

            )
            should contain_file('/etc/puppet').with(
                :require => "Package[#{params[:puppet_master_package]}]",
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify => "Service[httpd]"
            )
            should contain_file('/var/lib/puppet').with(
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify => 'Service[httpd]'
            )
            should include_class('puppet::storeconfigs')
        }
    end
end
