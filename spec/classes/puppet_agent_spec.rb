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
                :environment            => 'production'
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
            should contain_file('/etc/puppet').with(
                :ensure  => 'directory',
                :require => "Package[#{params[:puppet_agent_package]}]",
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => "Service[#{params[:puppet_agent_service]}]"
            )
            should contain_file('/etc/puppet').with(
                :require => "Package[#{params[:puppet_agent_package]}]",
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify  => "Service[#{params[:puppet_agent_service]}]"
            )
            should contain_concat__fragment('puppet.conf-common').with(
                :order      => '00',
                :target     => '/etc/puppet/puppet.conf'
            )
            should contain_concat__fragment('puppet.conf-agent').with(
                :order      => '01',
                :target     => '/etc/puppet/puppet.conf',
                :content    => /server\s*= #{params[:puppet_server]}/,
                :content    => /splay\s*= #{params[:splay]}/
            )

        }
    end
end
