require 'spec_helper'

describe 'puppet::passenger', :type => :class do
      let (:params) do
            {
                :puppet_passenger_port  => '8140',
                :puppet_docroot         => '/etc/puppet/rack/public/',
                :apache_serveradmin     => 'root',
                :puppet_conf            => '/etc/puppet/puppet.conf',
                :puppet_ssldir          => '/var/lib/puppet/ssl',
                :certname               => 'test.test.com',
                :conf_dir               => '/etc/puppet',
        }
        end
    context 'on Debian' do
        let(:facts) do
            {
                :osfamily               => 'debian',
                :operatingsystem        => 'debian',
                :operatingsystemrelease => '5',
                :concat_basedir         => '/dne',
            }
        end
         it {
                should include_class('apache')
                should include_class('puppet::params')
                should include_class('apache::mod::passenger')
                should include_class('apache::mod::ssl')
                should contain_exec('Certificate_Check').with(
                    :command =>
                      "puppet cert clean #{params[:certname]} ; " +
                      "puppet certificate --ca-location=local --dns_alt_names=puppet generate #{params[:certname]}" +
                      " && puppet cert sign --allow-dns-alt-names #{params[:certname]}" +
                      " && puppet certificate --ca-location=local find #{params[:certname]}",
                    :unless  => "/bin/ls #{params[:puppet_ssldir]}/certs/#{params[:certname]}.pem",
                    :path    => '/usr/bin:/usr/local/bin',
                    :require  => "File[#{params[:puppet_conf]}]"
                )
                should contain_file(params[:puppet_docroot]).with(
                    :ensure => 'directory',
                    :owner  => 'puppet',
                    :group  => 'puppet',
                    :mode   => '0755'
                )
                should contain_file('/etc/puppet/rack').with(
                    :ensure => 'directory',
                    :owner  => 'puppet',
                    :group  => 'puppet',
                    :mode   => '0755'
                )
                 should contain_file('/etc/puppet/rack/config.ru').with(
                    :ensure => 'present',
                    :owner  => 'puppet',
                    :group  => 'puppet',
                    :mode   => '0644'
                )
                should contain_ini_setting('puppetmastersslclient').with(
                    :ensure  => 'present',
                    :section => 'master',
                    :setting => 'ssl_client_header',
                    :path    => params[:puppet_conf],
                    :value   =>'SSL_CLIENT_S_DN',
                    :require => "File[#{params[:puppet_conf]}]"
                )
                should contain_ini_setting('puppetmastersslclientverify').with(
                    :ensure  => 'present',
                    :section => 'master',
                    :setting => 'ssl_client_verify_header',
                    :path    => params[:puppet_conf],
                    :value   =>'SSL_CLIENT_VERIFY',
                    :require => "File[#{params[:puppet_conf]}]"
                )
        }
    end
    context 'on Redhat' do
        let(:facts) do
            {
                :osfamily               => 'Redhat',
                :operatingsystem        => 'Redhat',
                :operatingsystemrelease => '5',
                :concat_basedir         => '/dne',
            }
        end
         it {
                should contain_file('/var/lib/puppet/reports')
                should contain_file('/var/lib/puppet/ssl/ca/requests')
        }
    end
end
