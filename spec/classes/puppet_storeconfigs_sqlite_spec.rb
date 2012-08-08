require 'spec_helper'

describe 'puppet::storeconfigs::sqlite', :type => :class do
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
                should contain_package('sqlite3')
                should contain_package('libactiverecord-ruby')
                should contain_package('libsqlite3-ruby')

        }
    end
    context 'on Redhat operatingsystems' do
       
        let(:facts) do
            { 
                :operatingsystem  => 'redhat',
            }
        end
        it {
                should contain_package('sqlite')
                should contain_package('rubygem-activerecord')
                should contain_package('rubygem-sqlite3-ruby')
        }
    end
end
