require 'spec_helper'

describe 'puppet::storeconfigs', :type => :class do

    context 'Pointing at remote puppetdb server' do
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
                :puppetdb_startup_timeout => '60',
                :puppetdb_strict_validation => true
            }
        end

        it {
             should contain_class("puppetdb::master::config").with(
               :require => nil
             )
        }
    end
    context 'Pointing at local puppetdb server' do
        let(:facts) do
            {
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
            }
        end
        let (:params) do
            {
                :dbserver              => 'localhost',
                :dbport                => '8081',
                :puppet_service        => 'Service[httpd]',
                :puppet_confdir        => '/etc/puppet/',
                :puppet_conf           => '/etc/puppet/puppet.conf',
                :puppet_master_package => 'puppstmaster',
                :puppetdb_startup_timeout => '60',
                :puppetdb_strict_validation => true
            }
        end

        it {
             should contain_class("puppetdb::master::config").with(
               :require => 'Class[Puppetdb]'
             )
        }
    end

end
