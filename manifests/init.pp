# Class: puppet
#
# Puppet - all systems will use this
#
# Requires:
#   class facter
#   $puppetmasterroot is used in puppet::server class and in the puppet.conf.erb template
#
class puppet {

    include facter

    # root of puppetmaster stuff
    $puppetmasterroot = "/opt/$lsbProvider/puppetmaster"

    # path to semaphores - these are used to track states of exec's
    $semaphores = "/var/lib/puppet/semaphores"

    $package_provider = $operatingsystem ? {
        redhat  => "yum",
        centos  => "yum",
        default => "yum",
    }

    package {
        "puppet":
            ensure => latest,
            notify => Service["puppet"];
        "ruby-rdoc":;
        #"ruby-shadow":;
        #"ruby-augeas":;
    } # package

    file {
        "/etc/puppet/puppet.conf":
            content  => template("puppet/puppet.conf.erb"),
            mode     => "644",
            checksum => md5,
            require  => Package["puppet"];
        "/var/lib/puppet/.ssh":
            ensure   => directory,
            mode     => "700",
            group    => "puppet",
            owner    => "puppet";
        # this can be used in exec{}'s 'create' paramater
        "$semaphores":
            mode     => "754",
            ensure   => directory,
            require  => Package["puppet"];
#        "/var/lib/puppet/ssl/certs/ca.pem":
#            source   => [ "puppet:///modules/puppet/ca.pem-$pop", "puppet:///modules/puppet/ca.pem" ],
#            require  => Package["puppet"];
    } # file

    service { "puppet":
        ensure     => running,
        enable     => true,
        subscribe  => File["/etc/puppet/puppet.conf"],
        hasrestart => true,
    } # service
} # class puppet
