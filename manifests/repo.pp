# Class: puppet::repo
#
# SVN repository for puppet code
#
# Requires:
#   class apache::ssl
#   class generic
#   class pam
#   class sites
#   class ssh
#   class svn::repo
#   $lsbProvider must be set in your site manifest - used in puppetrepo.conf.erb template
#   $puppetmasters must be set in your site manifest - space separated list of puppetmasters - used in puppet-svn-push.erb template
#   $puppetrepo_listen_ip used in the template, puppetrepo.conf.erb, and set in node manifest
#   $puppetrepo_http_listen_ip_public used in the template, puppetrepo.conf.erb, and set in node manifest
#   $puppetrepo_http_listen_ip_private used in the template, puppetrepo.conf.erb, and set in node manifest
#
class puppet::repo {

    include apache::ssl
    include generic
    include pam
    include sites
    include ssh
    include svn::repo

    svn::server::setup { "puppet":
        base => "/opt/$lsbProvider/svn/",
    } # svn::server::setup

    realize Apache::Ssl::Set_cert["default"]

    apache::vhost { "puppetrepo":
        content => template("puppet/puppetrepo.conf.erb"),
    } # apache::vhost

    # ensure the user is created
    realize Generic::Mkuser[puppetreposvn]

    file {
        "/opt/$lsbProvider/bin/puppet-svn-push":
            content => template("puppet/puppet-svn-push.erb"),
            mode    => "750";
        "/opt/$lsbProvider/bin/branchdiff":
            source  => "puppet:///modules/svn/branchdiff",
            mode    => "755";
    } # file

    # setup private key for post-commit
    ssh::private_key { "puppetreposvn":
        user    => "puppetreposvn",
        require => Generic::Mkuser[puppetreposvn]
    } # ssh::private_key

    # setup authorized key for post-commit
    ssh::authorized_keys { "puppetreposvn":
        users   => [ "puppetreposvn-puppetrepo" ],
        require => Generic::Mkuser[puppetreposvn]
    } # ssh::authorized_keys

    # allow puppetreposvn to login
    pam::accesslogin {"puppetreposvn": }

} # class puppet::repo
