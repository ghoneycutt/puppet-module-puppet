# Class: puppet::server
#
# sets up a system to be a puppetmaster
#
# Requires:
#   class apache::ssl
#   class certs
#   class generic
#   class pam
#   class ssh
#   class svn
#   $contactEmail is used in puppetmaster.conf.erb template and set in site manifest
#   $lsbProvider must be set in your site manifest - used in puppetrepo.conf.erb template
#   $puppetmasterroot which is set in class puppet
#   $puppetrepo_http_listen_ip_private - puppetrepo.conf.erb - set in nodes.pp
#   $puppetrepo_http_listen_ip_public - puppetrepo.conf.erb - set in nodes.pp
#
class puppet::server inherits puppet {

    include apache::ssl
    include certs
    include generic
    include pam
    include ssh
    include svn

    $real_puppetmaster_ports = $puppetmaster_ports ? {
        ''      => ["18140", "18141", "18142", "18143", "18144", "18145", "18146", "18147"],
        default => $puppetmaster_ports
    }

    # local user on the puppetserver that interacts with the repo
    $repouser = "puppetreposvn-master"

    # local user on the puppetserver that runs puppetmasterd
    $puppetuser = "puppet"

    # home directory of the puppet user
    $puppetuserhome = "/var/lib/${puppetuser}"

    # branch is defined using get_branch function 
    $repoconfurl = "http://${primary_puppet_server}/puppet/conf/branch.conf"
    $puppetmaster_branch = get_branch($pop,$repoconfurl)

    package { [ "puppet-server", "rubygem-mongrel" ]:
        ensure => latest;
    }

    file {
        "/etc/puppet/fileserver.conf":
            source  => "puppet:///modules/puppet/fileserver.conf",
            require => Package["puppet-server"],
            mode    => "644";
        # rh specific
        "/etc/sysconfig/puppetmaster":
            content => template("puppet/sysconfig_puppetmaster.erb");
        "/var/lib/puppet/yaml":
            ensure  => directory,
            owner   => "puppet",
            group   => "puppet",
            require => Package["puppet-server"];
    } # file

    # override the client puppet.conf
    File ["/etc/puppet/puppet.conf"] {
            content => template("puppet/server-puppet.conf.erb"),
    } # File

    # setup public key - so the svn server can push updates via ssh
    ssh::authorized_keys { "${repouser}":
        users   => ["${repouser}"],
        require => Generic::Mkuser["${repouser}"]
    } # ssh::authorized_keys

    realize Generic::Mkuser["${repouser}"]

    # check out initial copy of the repository
    svn::checkout { "puppetmaster":
        branch     => "$puppetmaster_branch",
        localuser  => "puppet",
        method     => "http",
        repopath   => "puppet",
        reposerver => "$primary_puppet_server",
        workingdir => "$puppetmasterroot",
        #require    => [ Class["certs"] ],
    } # svn::checkout

    apache::vhost { "puppetmaster":
        content => template("puppet/puppetmaster.conf.erb"),
    }

    # ensure puppetmaster service is enabled and running
    service { "puppetmaster":
        ensure    => running,
        enable    => true,
        subscribe => [ File["/etc/puppet/fileserver.conf"], File["/etc/puppet/puppet.conf"], File["/etc/sysconfig/puppetmaster"] ],
        require   => [ File["/etc/sysconfig/puppetmaster"], Package["rubygem-mongrel"] ],
    } # service

    pam::accesslogin {"puppetreposvn-master": }

} # class puppet::server
