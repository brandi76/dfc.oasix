#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;

require 'manip_table.lib';
require 'outils_perl.lib';

$mailprog = "/usr/sbin/sendmail"; 
$mailto = &user()."\@ibs.dom"; 
$MAILTO = $html->param('mailto');
#$MAILTO =~ s/\@/\\\@/g;
#$MAILTO =~ s/ /;/g;
$user = &user();
$ACTION = $html->param('action');
$SUBJECT= $html->param('subject');
$TEXTE= $html->param('TEXTE');
print "<HTML>\n";
print "<BODY TOPMARGIN='3'>\n";
&tete('Envoyer un mail','','');

if($ACTION ne 'send'){
print "<P>&nbsp;</P>";
print "<FORM METHOD='POST'>\n";
print "<INPUT TYPE='HIDDEN' NAME='action' VALUE='send'>\n";
print "Sujet : <INPUT TYPE='TEXT' SIZE='30' NAME='subject'><BR>\n";
print "Envoyer à : <INPUT TYPE='TEXT' SIZE='30' NAME='mailto' VALUE='$MAILTO'><BR>\n";
print "Message : <TEXTAREA NAME='TEXTE'COLS='30' ROWS='6'></TEXTAREA>";
print "<INPUT TYPE='SUBMIT' VALUE='Envoyer'>\n";
print "</FORM>\n";

}else{

$MAILTO_html =~ s/</&lt;/g;

print "<BR>Votre Message portant comme titre <B><I>$SUBJECT</I></B> en destination de <B><I>$MAILTO_html</I></B> à bien été envoyé !\n"; 

@temp = split(/;/,$MAILTO);

#foreach(@temp){
$_ =~ s/\@/\\\@/g;	
open (MAIL, "|$mailprog -t -n -oi\n") || die "Can't open $mailprog!\n";   
#print MAIL "Cc: $MAILTO\n";
print MAIL "From: \"N.G.H. - $user\" <$user\@ibs.dom>\n"; 
print MAIL "To: $MAILTO\n";
#print MAIL "Cc: $MAILTO\n";
print MAIL"Subject: $SUBJECT\n\n"; 
print MAIL "$TEXTE\n\n"; 

print MAIL "\n";  
close(MAIL); 
#}
}


# -E Envoyer des mails !
