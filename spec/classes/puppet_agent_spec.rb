require 'spec_helper'

describe 'puppet::agent', :type => :class do

    context 'on Debian operatingsystems' do
        let(:facts) do
            { 
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
                :concat_basedir  => '/var/lib/puppet/concat',
                :kernel          => 'Linux'
            }
        end
        let (:params) do
            {
                :puppet_server          => 'test.exaple.com',
                :puppet_agent_service   => 'puppet',
                :puppet_agent_package   => 'puppet',
                :version                => '/etc/puppet/manifests/site.pp',
                :puppet_run_style       => 'service',
                :splay                  => 'true',  
                :environment            => 'production',
                :puppet_run_interval    => 30,
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
            should contain_package(params[:puppet_agent_package]).with(
                :ensure => params[:version]
            )
            should contain_file('/etc/default/puppet').with(
                :mode     => '0644',
                :owner    => 'root',
                :group    => 'root',
                :content  => /START=yes/,
                :require  => "Package[#{params[:puppet_agent_package]}]"
            )
            should contain_service(params[:puppet_agent_service]).with(
                :ensure  => true,
                :enable  => true,
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_file('/etc/puppet/puppet.conf').with(
                :ensure  => 'file',
                :require => "Package[#{params[:puppet_agent_package]}]",
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => "Service[#{params[:puppet_agent_service]}]"
            )
            should contain_file('/etc/puppet').with(
                :require => "Package[#{params[:puppet_agent_package]}]",
                :ensure  => 'directory',
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => "Service[#{params[:puppet_agent_service]}]"
            )
            should contain_ini_setting('puppetagentmaster').with(
                :ensure  => 'present',
                :section => 'agent',
                :setting => 'master',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:puppet_server]
            )
            should contain_ini_setting('puppetagentenvironment').with(
                :ensure  => 'present',
                :section => 'agent',
                :setting => 'environment',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:environment]
            )
            should contain_ini_setting('puppetagentruninterval').with(
                :ensure  => 'present',
                :section => 'agent',
                :setting => 'runinterval',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:puppet_run_interval] * 60
            )
            should contain_ini_setting('puppetagentsplay').with(
                :ensure  => 'present',
                :section => 'agent',
                :setting => 'splay',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:splay]
            )
            
        }
    end
end