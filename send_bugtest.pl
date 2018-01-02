#!/usr/bin/perl 
use warnings;
use strict;
use MIME::Lite;
use Net::SMTP_auth;

#login once
my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', '6192_sb', 'passe123' );

my $msg = MIME::Lite->new( 
  From  => 'sb@dutyfreeconcept.com',
  TO    => 'sylvainbrandicourt@gmail.com', 
  Subject  => 'Testing Text Message',
  Data     => 'How\'s it going.' );

$smtp->mail('sb@dutyfreeconcept.com');
$smtp->to('sylvainbrandicourt@gmail.com');
$smtp->data();
$smtp->datasend( $msg->as_string() );
$smtp->dataend();

 
############################

## quit when finished loop
$smtp -> quit;
