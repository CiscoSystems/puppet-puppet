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

        let(:facts) do
            { 
                :concat_basedir  => '/var/lib/puppet/concat',
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
                should contain_file("#{params[:puppet_confdir]}/routes.yaml").with(
                    :ensure     => 'file',
                    :source     => 'puppet:///modules/puppet/routes.yaml',
                    :notify     => params[:puppet_service],
                    :require    => 'Package[puppetdb-terminus]'
                )
                should contain_file("#{params[:puppet_confdir]}/puppetdb.conf").with(
                    :ensure     => 'file',
                    :content    => /server\s*= #{params[:dbserver]}/,
                    :content    => /port\s*= #{params[:dbport]}/,
                    :notify     => params[:puppet_service],
                    :require    => "File[#{params[:puppet_confdir]}/routes.yaml]"
                )

                should contain_concat__fragment('puppet.conf-master-storeconfig').with(
                    :order      => '03',
                    :target     => params[:puppet_conf],
                    :notify     => params[:puppet_service],
                    :content    => /server\s*= #{params[:dbserver]}/,
                    :content    => /storeconfigs_backend\s*= #{params[:dbadapter]}/
                )
        }
    end
end