require 'spec_helper'

describe 'puppet::storeconfigs', :type => :class do

    context 'on Debian' do
        let (:params) do
            {
                :dbserver         => 'test.example.com',
                :dbport           => '8081',
                :puppet_service   => 'Service[puppetmaster]',
                :puppet_confdir   => '/etc/puppet/',
                :puppet_conf      => '/etc/puppet/puppet.conf',
            }
        end

        it {
                should contain_package('puppetdb-terminus').with(
                    :ensure     => 'present'
                )
                should contain_file("#{params[:puppet_confdir]}/routes.yaml").with(
                    :ensure     => 'file',
                    :source     => 'puppet:///modules/puppet/routes.yaml',
                    :notify     => params[:puppet_service],
                    :require    => 'Package[puppetdb-terminus]'
                )
                should contain_file("#{params[:puppet_confdir]}/puppetdb.conf").with(
                    :ensure     => 'file',
                    :notify     => params[:puppet_service],
                    :require    => "File[#{params[:puppet_confdir]}/routes.yaml]"
                )
                should contain_ini_setting('puppetmasterstoreconfig').with(
                    :ensure  => 'present',
                    :section => 'master',
                    :setting => 'storeconfigs',
                    :path    => params[:puppet_conf],
                    :value   =>'true'
                )
                should contain_ini_setting('puppetmasterstorebackend').with(
                    :ensure  => 'present',
                    :section => 'master',
                    :setting => 'storeconfigs_backend',
                    :path    => params[:puppet_conf],
                    :value   =>'puppetdb'
                )
        }
    end
end