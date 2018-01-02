#!/usr/bin/perl 
$message=$ARGV[0];
print $message;
print "\n";
if ($message=~m/[^a-zA-Z 0-9-_]/){print "oui";}
