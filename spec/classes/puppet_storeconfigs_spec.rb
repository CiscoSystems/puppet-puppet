require 'spec_helper'

describe 'puppet::storeconfigs', :type => :class do

    context 'on Debian operatingsystems with puppetdb' do
        let (:params) do
            {
                :dbadapter            => 'puppetdb',
                :dbserver             => 'localhost',
                :dbpassword           => 'password',
                :dbuser               => 'puppet',
                :dbsocket             => '/var/run/mysqld/mysqld.sock',
                :puppet_conf          => '/etc/puppet/puppet.conf',
                :puppet_service       => 'Service[puppetmaster]'
            }
        end

        let(:facts) do
            { 
                :concat_basedir  => '/var/lib/puppet/concat',
            }
        end
         it {
                should include_class('puppetdb::terminus')
                should contain_concat__fragment('puppet.conf-master-storeconfig').with(
                    :order      => '03',
                    :target     => params[:puppet_conf],
                    :notify     => params[:puppet_service],
                    :content    => /server\s*= #{params[:dbserver]}/,
                    :content    => /storeconfigs_backend\s*= #{params[:dbadapter]}/
                )
        }
    end

    context 'on Debian operatingsystems with sqlite3' do
        let (:params) do
            {
                :dbadapter            => 'sqlite3',
                :dbserver             => 'localhost',
                :dbpassword           => 'password',
                :dbuser               => 'puppet',
                :dbsocket             => '/var/run/mysqld/mysqld.sock',
                :puppet_conf          => '/etc/puppet/puppet.conf',
                :puppet_service       => 'Service[puppetmaster]'
            }
        end

        let(:facts) do
            { 
                :concat_basedir  => '/var/lib/puppet/concat',
            }
        end
         it {
                should include_class('puppet::storeconfigs::sqlite')
                should contain_concat__fragment('puppet.conf-master-storeconfig').with(
                    :order      => '03',
                    :target     => params[:puppet_conf],
                    :notify     => params[:puppet_service],
                    :content    => /dbadapter\s*= #{params[:dbadapter]}/
                )
        }
    end

    context 'on Debian operatingsystems with mysql' do
        let (:params) do
            {
                :dbadapter            => 'mysql',
                :dbserver             => 'localhost',
                :dbpassword           => 'password',
                :dbuser               => 'puppet',
                :dbsocket             => '/var/run/mysqld/mysqld.sock',
                :puppet_conf          => '/etc/puppet/puppet.conf',
                :puppet_service       => 'Service[puppetmaster]'
            }
        end

        let(:facts) do
            { 
                :concat_basedir  => '/var/lib/puppet/concat',
            }
        end
         it {
                should include_class('puppet::storeconfigs::mysql')
                should contain_concat__fragment('puppet.conf-master-storeconfig').with(
                    :order      => '03',
                    :target     => params[:puppet_conf],
                    :notify     => params[:puppet_service],
                    :content    => /dbadapter\s*= #{params[:dbadapter]}/,
                    :content    => /dbuser\s*= #{params[:dbuser]}/,
                    :content    => /dbpassword\s*= #{params[:dbpassword]}/,
                    :content    => /dbserver\s*= #{params[:dbserver]}/,
                    :content    => /dbsocket\s*= #{params[:dbsocket]}/
                )
        }
    end

end
