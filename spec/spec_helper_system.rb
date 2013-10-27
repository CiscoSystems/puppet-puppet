require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'

include RSpecSystemPuppet::Helpers
include Serverspec::Helper::RSpecSystem
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
    # Project root
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    # Enable colour
    c.tty = true

    c.include RSpecSystemPuppet::Helpers

    # This is where we 'setup' the nodes before running our tests
    c.before :suite do
        # Install puppet
        puppet_install
        puppet_module_install(:source => proj_root, :module_name => 'puppet')
        # Install dependencies from Modulefile
        shell('puppet module install puppetlabs-inifile --version ">= 1.0.0"')
        shell('puppet module install puppetlabs-apache --version ">= 0.8.0"')
        shell('puppet module install puppetlabs-puppetdb --version ">= 2.0.0"')
        if node.facts['osfamily'] == 'Debian'
            shell('puppet module install puppetlabs-apt')
        end
        # puppetlabs-apache requires EPEL for mod_passenger
        if node.facts['osfamily'] == 'RedHat'
            shell('puppet module install stahnma-epel')
            puppet_apply('class {"epel": }')
        end
    end
end
