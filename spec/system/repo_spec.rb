require 'spec_helper_system'

describe 'repo tests:' do
    it 'make sure we have copied the module across' do
        # No point diagnosing any more if the module wasn't copied properly
        shell("ls /etc/puppet/modules/puppet") do |r|
            r[:exit_code].should == 0
            r[:stdout].should =~ /Modulefile/
            r[:stderr].should == ''
        end
    end

    # Using puppet_apply as a helper
    it 'puppet::repo::puppetlabs class should work with no errors' do
        pp = <<-EOS
            class { 'puppet::repo::puppetlabs': }
        EOS

        # Run it twice and test for idempotency
        puppet_apply(pp) do |r|
            r.exit_code.should_not == 1
            r.refresh
            r.exit_code.should be_zero
        end
    end
end
