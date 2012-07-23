Facter.add(:etckepper_puppet) do
    confine :kernel => "Linux"
    setcode do
        if File.exists?("/etc/puppet/etckeeper-commit-pre") && File.exists?("/etc/puppet/etckeeper-commit-post")
            return true
        else
            return false
        end
    end
end
