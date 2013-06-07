require 'spec_helper'

describe 'puppet::agent', :type => :class do
        let(:facts) do
            { 
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
                :kernel          => 'Linux'
            }
        end
    context 'on Debian operatingsystems as a service' do
        let(:params) do
            {
                :puppet_server          => 'test.exaple.com',
                :puppet_agent_service   => 'puppet',
                :puppet_agent_package   => 'puppet',
                :version                => '/etc/puppet/manifests/site.pp',
                :puppet_run_style       => 'service',
                :splay                  => 'true',
                :environment            => 'production',
                :puppet_run_interval    => 30,
                :puppet_server_port     => 8140,
            }
        end
        it {
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
        }
    end
 context 'on Debian operatingsystems using cron' do
        let(:params) do
            {
                :puppet_server          => 'test.exaple.com',
                :puppet_agent_service   => 'puppet',
                :puppet_agent_package   => 'puppet',
                :version                => '/etc/puppet/manifests/site.pp',
                :puppet_run_style       => 'cron',
                :splay                  => 'true',
                :environment            => 'production',
                :puppet_run_interval    => 30,
                :puppet_server_port     => 8140,
            }
        end
        it{
            should contain_file('/etc/default/puppet').with(
                :mode     => '0644',
                :owner    => 'root',
                :group    => 'root',
                :content  => /START=no/,
                :require  => "Package[#{params[:puppet_agent_package]}]"
            )
            should contain_service(params[:puppet_agent_service]).with(
                :ensure  => 'stopped',
                :enable  => false,
                :require => "Package[#{params[:puppet_agent_package]}]"
            )
            should contain_cron('puppet-client').with(
                :command  => '/usr/bin/puppet agent --no-daemonize --onetime --logdest syslog > /dev/null 2>&1',
                :user  => 'root',
                :hour => '*'
            )
        }
    end

 context 'on Debian with use_srv_records but no srv_domain set' do
        let(:params) do
            {
                :puppet_server          => 'test.exaple.com',
                :puppet_agent_service   => 'puppet',
                :puppet_agent_package   => 'puppet',
                :version                => '/etc/puppet/manifests/site.pp',
                :puppet_run_style       => 'cron',
                :splay                  => 'true',
                :environment            => 'production',
                :puppet_run_interval    => 30,
                :puppet_server_port     => 8140,
                :use_srv_records        => true,
            }
        end

        it{
          expect{ subject }.to raise_error()
        }
  end

 context 'on Debian with use_srv_records false' do
        let(:params) do
            {
                :puppet_server          => 'test.exaple.com',
                :puppet_agent_service   => 'puppet',
                :puppet_agent_package   => 'puppet',
                :version                => '/etc/puppet/manifests/site.pp',
                :puppet_run_style       => 'cron',
                :splay                  => 'true',
                :environment            => 'production',
                :puppet_run_interval    => 30,
                :puppet_server_port     => 8140,
                :use_srv_records        => false,
            }
        end

        it{
            should contain_ini_setting('puppetagentsrv_domain').with(
                :ensure  => 'absent',
                :section => 'agent',
                :setting => 'srv_domain',
                :path    => '/etc/puppet/puppet.conf'
            )
        }
 end

 context 'on Debian with use_srv_records and srv_domain set' do
        let(:params) do
            {
                :puppet_server          => 'test.exaple.com',
                :puppet_agent_service   => 'puppet',
                :puppet_agent_package   => 'puppet',
                :version                => '/etc/puppet/manifests/site.pp',
                :puppet_run_style       => 'cron',
                :splay                  => 'true',
                :environment            => 'production',
                :puppet_run_interval    => 30,
                :puppet_server_port     => 8140,
                :use_srv_records        => true,
                :srv_domain             => 'example.com',
            }
        end

        it{
            should contain_ini_setting('puppetagentuse_srv_records').with(
                :ensure  => 'present',
                :section => 'agent',
                :setting => 'use_srv_records',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'true'
            )
            should contain_ini_setting('puppetagentsrv_domain').with(
              :ensure  => 'present',
              :section => 'agent',
              :setting => 'srv_domain',
              :path    => '/etc/puppet/puppet.conf',
              :value   => params[:srv_domain]
            )
        }
        end
end
