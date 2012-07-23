Facter.add(:etckepper_puppet) do
    confine :kernel => "Linux"
    setcode do
        if File.exists?("/etc/puppet/etckeeper-commit-pre") && File.exists?("/etc/puppet/etckeeper-commit-post")
            true
        else
            false
        end
    end
end
