require 'spec_helper'

describe 'puppet::storeconfigs::mysql', :type => :class do
    let (:params) do
    {
    }
    end
    context 'on Debian operatingsystems' do
       
        let(:facts) do
            { 
                :operatingsystem  => 'debian',
            }
        end
        it {
                should contain_package('libactiverecord-ruby')
                should contain_package('libmysql-ruby')

        }
    end
    context 'on Redhat operatingsystems' do
       
        let(:facts) do
            { 
                :operatingsystem  => 'redhat',
            }
        end
        it {
                should contain_package('mysql-devel')
                should contain_package('ruby-mysql')
                should contain_package('rubygem-activerecord')
        }
    end
end
