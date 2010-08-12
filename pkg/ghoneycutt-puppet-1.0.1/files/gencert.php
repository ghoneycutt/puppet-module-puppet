<?php
  # Written by Robert Long IV and released to the Public Domain

  # don't assume we have a path
  $gencert = "/usr/sbin/puppetca -g";
  $tar     = "/bin/tar";
  $sudo    = "/usr/bin/sudo";
  
  # set some paths up.
  $cabase  = "/var/lib/puppet/ssl/";
  $certdir = "$cabase/certs";
  $private = "$cabase/private_keys";

  # yeah, its reverse DNS, but don't assume its safe.
  $host    = escapeshellarg(gethostbyaddr($_SERVER['REMOTE_ADDR']));
  
  # create the certs
  exec("$sudo $gencert $host", $out, $ret);
  $ret && error_log("Error creating cert for $host: $out\n");

  # tar up the three files we need to make the client work.
  exec("$sudo $tar -c $certdir/$host.pem $private/$host.pem $certdir/ca.pem 2>/dev/null", $certs, $ret);
  $ret && error_log("Error tar'ing cert for $host: $certs\n");

  # most of this is useless, but it will give curl an idea of what to expect in terms of content
  header("Content-Description: File Transfer");
  header('Content-disposition: attachment; filename='.$host.'tar');
  header("Content-Type: application/octet-stream");
  header("Content-Transfer-Encoding: binary");

  # and the content goes here.
  print join("\n", $certs);
?>
