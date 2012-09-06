require 'spec_helper'

describe 'puppet::storeconfigs', :type => :class do

    context 'on Debian' do
        let (:params) do
            {
                :dbserver         => 'test.example.com',
                :dbport           => '8081',
                :puppet_service   => 'Service[httpd]',
                :puppet_confdir   => '/etc/puppet/',
                :puppet_conf      => '/etc/puppet/puppet.conf',
            }
        end

        it {
             should include_class("puppetdb::storeconfigs")
        }
    end
end