#!/usr/bin/perl  
use strict;  
use warnings;  
use MIME::Lite;  

my $from = 'I Programmer <user@szabgab.com>';  
my $subject = 'I am a Perl programmer'; 
my $to = 'sylvainbrandicourt@gmail.com';  
my $html = <<"END_HTML";  
<a href="http://www.i-programmer.info/">
 I-Programmer ייייטטטטט
</a>
END_HTML

my $text = <<"END_TEXT";  
We can only have text links here     
http://www.i-programmer.info/ ייייטטטט 
END_TEXT

MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $msg = MIME::Lite->new(
 From     => $from,
 To       => $to,
 Type     => 'multipart/alternative',
 Subject  => $subject,
 );

 my $att_text = MIME::Lite->new(
   Type     => 'text',
   Data     => $text,
   Encoding => 'quoted-printable',
 );
 $att_text->attr('content-type'
   => 'text/plain; charset=iso-8859-1');
 $msg->attach($att_text); 

 my $att_html = MIME::Lite->new(  
  Type     => 'text',
  Data     => $html,  
  Encoding => 'quoted-printable', 
 );  
 $att_html->attr('content-type'   
   => 'text/html; charset=iso-8859-1');  
 $msg->attach($att_html);  

 $msg->send;
