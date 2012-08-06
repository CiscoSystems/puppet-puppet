require 'spec_helper'

describe 'puppet::master', :type => :class do
    let (:params) do
        {
            :puppet_user            => 'puppet',
            :puppet_group           => 'puppet',
            :version                => 'present',
            :puppet_conf            => '/etc/puppet/puppet.conf',
            :puppet_master_package  => 'puppetmaster',
            :puppet_master_service  => 'puppetmaster'
        }
    end
    context 'on Debian operatingsystems without storedconfigs/passenger' do
        let(:facts) do
            { 
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
                :concat_basedir  => '/var/lib/puppet/concat',
            }
        end
         it {
            should include_class('concat::setup')
            should contain_user(params[:puppet_user]).with(
                :ensure => 'present',
                :uid    => nil,
                :gid    => params[:puppet_group]
            )
            should contain_group(params[:puppet_group]).with(
                :ensure => 'present',
                :gid    => nil
            )
            should contain_package(params[:puppet_master_package]).with(
                :ensure => params[:version]
            )
            should contain_service(params[:puppet_master_service]).with(
                :ensure    => 'true',
                :enable    => 'true',
                :require   => "File[#{params[:puppet_conf]}]",
                :subscribe => "Package[#{params[:puppet_master_package]}]"
            )
            should contain_concat__fragment('puppet.conf-master').with(
                :order      => '02',
                :target     => params[:puppet_conf],
                :notify     => "Service[#{params[:puppet_master_service]}]"
            )
            should contain_concat(params[:puppet_conf]).with(
                :mode   => '0644',
                :owner  => params[:puppet_user],
                :group  => params[:puppet_group],
                :notify => "Service[#{params[:puppet_master_service]}]"

            )
            should contain_file('/etc/puppet').with(
                :require => "Package[#{params[:puppet_master_package]}]",
                :ensure => 'directory',
                :owner  => params[:puppet_user],
                :group  => params[:puppet_group],
                :notify => "Service[#{params[:puppet_master_service]}]"
            )
            should contain_file('/var/lib/puppet').with(
                :ensure => 'directory',
                :owner  => params[:puppet_user],
                :group  => params[:puppet_group],
                :notify => "Service[#{params[:puppet_master_service]}]"
            )
            

         }
    end
end
