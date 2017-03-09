require 'puppet'

Facter.add("environment") do
  setcode do
    Puppet[:environment]
  end
end
