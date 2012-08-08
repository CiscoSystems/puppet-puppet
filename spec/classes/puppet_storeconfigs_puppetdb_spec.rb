require 'spec_helper'

describe 'puppet::storeconfigs::puppetdb', :type => :class do
    let (:params) do
    {
        :puppetdb_host        => 'localhost',
        :puppetmaster_service => 'Service[puppetmaster]',
        :puppet_confdir       => '/etc/puppet',
    }
    end
    context 'Install puppetdb on linux' do
       
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
                    :notify     => params[:puppetmaster_service],
                    :require    => 'Package[puppetdb-terminus]'
                )
                should contain_file("#{params[:puppet_confdir]}/routes.yaml").with(
                    :ensure     => 'file',
                    :source     => 'puppet:///modules/puppet/routes.yaml',
                    :notify     => params[:puppetmaster_service],
                    :require    => 'Package[puppetdb-terminus]'
                )
                should contain_file("#{params[:puppet_confdir]}/puppetdb.conf").with(
                    :ensure     => 'file',
                    :content    => /server\s*= #{params[:puppetdb_host]}/,
                    :notify     => params[:puppetmaster_service],
                    :require    => "File[#{params[:puppet_confdir]}/routes.yaml]"
                )
        }
    end
end
