require 'spec_helper'

describe 'puppet::master', :type => :class do

    context 'on Debian operatingsystems' do
        let(:facts) do
            {
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
                :operatingsystemrelease => '5',
                :concat_basedir => '/nde',
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
                :require   => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_file('/etc/puppet/puppet.conf').with(
                :ensure  => 'file',
                :require => 'File[/etc/puppet]',
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => 'Service[httpd]'
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
            should contain_class('puppet::storeconfigs').with(
              :before => 'Anchor[puppet::master::end]'
            )
            should contain_class('puppet::passenger').with(
              :before => 'Anchor[puppet::master::end]'
            )
            should contain_ini_setting('puppetmastermodulepath').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'modulepath',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:modulepath],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmastermanifest').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'manifest',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:manifest],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterautosign').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'autosign',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:autosign],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmastercertname').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'certname',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:certname],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterreports').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'reports',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'store',
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterpluginsync').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'pluginsync',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'true'
            )
            should contain_anchor('puppet::master::begin').with_before(
              ['Class[Puppet::Passenger]', 'Class[Puppet::Storeconfigs]']
            )
            should contain_anchor('puppet::master::end')
        }
    end
end
