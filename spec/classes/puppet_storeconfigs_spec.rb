require 'spec_helper'

describe 'puppet::storeconfigs', :type => :class do

    context 'on Debian' do
        let(:facts) do
            { 
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
            }
        end
        let (:params) do
            {
                :dbserver              => 'test.example.com',
                :dbport                => '8081',
                :puppet_service        => 'Service[httpd]',
                :puppet_confdir        => '/etc/puppet/',
                :puppet_conf           => '/etc/puppet/puppet.conf',
                :puppet_master_package => 'puppstmaster',
                :puppetdb_startup_timeout => '60'
            }
        end

        it {
             should include_class("puppetdb::master::config")
        }
    end
end
