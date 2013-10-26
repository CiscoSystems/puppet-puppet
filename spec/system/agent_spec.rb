require 'spec_helper_system'

describe 'agent tests:' do
    it 'make sure we have copied the module across' do
        # No point diagnosing any more if the module wasn't copied properly
        shell("ls /etc/puppet/modules/puppet") do |r|
            r[:exit_code].should == 0
            r[:stdout].should =~ /Modulefile/
            r[:stderr].should == ''
        end
    end

    context 'default parameters puppet::agent' do
        it 'should work with no errors' do
            pp = <<-EOS
                class { 'puppet::agent': }
            EOS

            # Run it twice and test for idempotency
            puppet_apply(pp) do |r|
                r.exit_code.should_not == 1
                r.refresh
                r.exit_code.should be_zero
            end
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
            it { should be_running }
            it { should be_enabled }
        end
    end

    context 'agent run from cron' do
        it 'should work with no errors' do
            pp = <<-EOS
                class { 'puppet::agent':
                    puppet_run_style => 'cron',
                }
            EOS

            # Run it twice and test for idempotency
            puppet_apply(pp) do |r|
                r.exit_code.should_not == 1
                r.refresh
                r.exit_code.should be_zero
            end
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
            # Service detection on Debian seems to be broken,
            # at least for the puppet service
            if node.facts['osfamily'] != 'Debian'
                it { should_not be_running }
                it { should_not be_enabled }
            end
        end

        describe cron do
            # Note: This only has four *'s since the minute part is randomized
            # by the agent module.
            it { should have_entry "* * * * \/usr\/bin\/puppet agent --no-daemonize --onetime --logdest syslog > \/dev\/null 2>&1" }
        end

    end

    context 'agent with external scheduler' do
        it 'should run without errors' do
            pp = <<-EOS
                class { 'puppet::agent':
                    puppet_run_style => external,
                }
            EOS
            # Run it twice and test for idempotency
            puppet_apply(pp) do |r|
                r.exit_code.should_not == 1
                r.refresh
                r.exit_code.should be_zero
            end
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
            # Service detection on Debian seems to be broken,
            # at least for the puppet service
            if node.facts['osfamily'] != 'Debian'
                it { should_not be_running }
                it { should_not be_enabled }
            end
        end
    end

end
