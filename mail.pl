#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;

require 'outils_perl.lib';
$ip=$html->param("user");
#if($ip eq ""){
#	$ip = $ENV{"REMOTE_ADDR"};
#}
$user = &user($ip);

# <!--A:link, A:visited { text-decoration: none;}A:hover {  text-decoration: none ;color:#FF6600}-->
$nbmessage = `cat /var/spool/mail/alex | grep "^From " | wc -l`;
#Verification des mails
open(MAIL,"cat /var/spool/mail/$user | ");
@mail = <MAIL>;
if( $#mail != -1 ){

#<script>
#		mywidth =((screen.Width-500)/2)
#		myheight =((screen.Height-250)/2)
#		open("entetemail.pl?titre=Intranet Information&info=$user.winpopup","popup","width=500,height=250,top="+myheight+",left="+mywidth);
#</script>
print <<"eof";
<HTML>
<HEAD>
<TITLE>$nbmessage Message(s) pour $user - MailAlert Intranet</TITLE>
<meta HTTP-EQUIV="Refresh" CONTENT="120">
<HTTP-EQUIV="Content-Language" CONTENT="xb,xvv,x,">
<HTTP-EQUIV="Pragma" CONTENT="no-cache">
<style>
   body { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt; color: #000000;}
   table { font-size: 10pt; color: #000000 }
   A:link { text-decoration: none;color=#000000} A:visited { text-decoration: none;color:darkgoldenrod}A:hover {  text-decoration: none ;color:#FF6600}
</style>
</HEAD>

<BODY BGCOLOR="RED" ONBLUR="javascript:this.window.docuement.focus();">
	<CENTER>
	<TABLE BORDER="0">
	<TR><TD>
	<IMG SRC="/mail.gif" border="0">
	</td>
	<td>
	-&nbsp;<font color=WHITE><b>Vous avez du courrier ! ! !</b></font>
	</td>
	</tr>
	</table>
	</CENTER>
<script>

height=90;
width=30;
moveTo(width, height);
this.window.document.focus();


</script>

eof
}
else{
print <<"eof";
<HTML>
<HEAD>
<TITLE>$nbmessage Message(s) pour $user - MailAlert Intranet</TITLE>
<meta HTTP-EQUIV="Refresh" CONTENT="120">
<HTTP-EQUIV="Content-Language" CONTENT="xb,xvv,x,">
<HTTP-EQUIV="Pragma" CONTENT="no-cache">
<style>
   body { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt; color: #000000;}
   table { font-size: 10pt; color: #000000 }
   A:link { text-decoration: none;color=#000000} A:visited { text-decoration: none;color:darkgoldenrod}A:hover {  text-decoration: none ;color:#FF6600}
</style>
</HEAD>
eof
	print "<BODY>\n";
	print "<CENTER>Pas De Courrier Intranet.</CENTER>";
}
close(MAIL);




# -E Interface Intranet Perso