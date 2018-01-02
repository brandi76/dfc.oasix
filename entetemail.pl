#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;

require 'outils_perl.lib';

$user = &user();

print <<"eof";
<HTML>
<HEAD>
<TITLE>INTRANET :: Menu :: I.B.S. FRANCE</TITLE>
</HEAD>
<body topmargin=5 alink=red vlink=black link=darkgoldenrod>
<table border=1 width=100% cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod  rules=none><tr>
<td align=left width=10%>&nbsp;</td><td align=center><font size=4><b>
Menu Intranet</td><td width=10% align=right>
&nbsp;</td>
</tr></table>
<br>
eof

open(MAIL,"more /var/spool/mail/alex | grep Subject | ");
@mail = <MAIL>;
if( $#mail != -1 ){
	foreach(@mail){
		@temp = split(/:/,$_);
		print "$temp[1]<br>";
	}
}
close(MAIL);

