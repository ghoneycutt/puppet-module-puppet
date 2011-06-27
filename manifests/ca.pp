# Class: puppet::ca
#
# Certificate Authority - this class goes on the machines that generate the
# certs for our puppet clients
#
# Requires:
#   class apache::php
#   class apache::ssl
#   $contactEmail is used by the puppetca.conf.erb template and set in site manifest
#   $puppetca_listen_ip is used by the puppetca.conf.erb template and site in node manifest
#
class puppet::ca inherits puppet {

    include apache::php
    include apache::ssl

    realize Apache::Ssl::Set_cert["default"]

    apache::vhost {"puppetca":
        content => template("puppet/puppetca.conf.erb"),
    } # apache::vhost

    file {
        "/var/www/puppetca":
            ensure => directory;
        "/var/www/puppetca/index.php":
            source => "puppet:///modules/puppet/gencert.php";
    } # file
} # class puppet::ca
