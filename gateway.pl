#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;

require 'outils_perl2.lib';
$ip=$html->param("user");
#if($ip eq ""){
#	$ip = $ENV{"REMOTE_ADDR"};
#}
$user = &user($ip);
# <!--A:link, A:visited { text-decoration: none;}A:hover {  text-decoration: none ;color:#FF6600}-->

print <<"eof";
<HTML>
<HEAD>
<TITLE>INTRANET :: Menu :: B.I.S. FRANCE</TITLE>
	<META HTTP-EQUIV="Pragma"  CONTENT="no-cache">
	<META HTTP-EQUIV="Cache-Control"  CONTENT="no-cache">
	<META HTTP-EQUIV="Expires"  CONTENT="Mon, 06 May 1996 04:57:00 GMT">
	<META NAME="classification" CONTENT="Global">
	<META NAME="robots" CONTENT="ALL">
	<META NAME="distribution" CONTENT="Global">
	<META NAME="rating" CONTENT="General">
	<META NAME="copyright" CONTENT="Copyright 1998-2000 - Nicolaas Goardraad Holding">
	<META NAME="author" CONTENT="N.G.H. Création 2001">
	<META NAME="language" CONTENT="fr">
	<META NAME="resource-type" CONTENT="document">
	<META NAME="revisit-after" CONTENT="9 days">
	<META NAME="description" CONTENT="-">
	<META NAME="bulletin-date" CONTENT="02/07/2000">
	<META NAME="bulletin-text" CONTENT="-">
	<META NAME="keywords" CONTENT="-">


<style>
   body { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt; color: #000000;}
   table { font-size: 10pt; color: #000000 }
   A:link { text-decoration: none;color=#000000} A:visited { text-decoration: none;color:darkgoldenrod}A:hover {  text-decoration: none ;color:#FF6600}
</style>
</HEAD>
<body background=/fond-papi.gif topmargin=5 alink=red vlink=black link=black onLoad='window.defaultStatus = "B.I.S. FRANCE by copyright NGH Création 2000-2001"; return true;'>
<SCRIPT LANGUAGE="JavaScript 1.2">

self.locationbar.visible=true
</SCRIPT>
<!-- <center><img src=http://ibs.oasix.fr/allez.jpg></center> -->
<table border=1 width=100% cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod  rules=none><tr>
<td align=left width=10%>&nbsp;</td><td align=center><font size=4><b>
Menu Intranet $user </td><td width=10% align=right>
&nbsp;</td>
</tr></table>
<br>
eof
open(LISTECATEGORIE,"< /home/var/spool/uucppublic/CATEGORIES.txt");
@categorie = <LISTECATEGORIE>;
close(LISTECATEGORIE);


# recuperation de la liste des programme trié par categorie dans un tableau
@prog = `sort -t';' +1 +3 /home/var/spool/uucppublic/prog.txt`;

$nbcat = 0;


print "<p align=right>";


print "<table border=0 width=75% cellpadding=0 cellspacing=0>";
# chop($user);
foreach(@categorie){
	($ID,$DESIGN,$DECRIP,$BACK,$COLOR) = split(/;/,$_);
	$affichecat = 0;
	foreach $prog_tmp(@prog){
			if( (grep /$ID/,$prog_tmp) && (grep /$user/,$prog_tmp) ){
				$affichecat = 1;
			}	
	}
	if( $nbcat%2 eq 0){
		print "<tr>";
	}
	if($affichecat == 1){
	print "<td valign=top>";
	print "<table border=0 width=100% cellpadding=0 cellspacing=0>";	
	print "<tr><td bgcolor=$BACK align=center><font color=$COLOR><b>$DESIGN</b></font></td></tr>";
	foreach(@prog){
		$autorisation = 0;
		@tampon = split(/;/,$_);
		for($i=0;$i<=$#tampon;$i++){
			if($user eq $tampon[$i]){
				$autorisation = 1;
			}
		}
		if($tampon[3] eq $ID && $autorisation eq 1){
			print "<tr><td><a href=$tampon[2] onMouseOut=\"window.status=window.defaultStatus;return true\" onMouseMove=\"window.status='$tampon[$#tampon-1]';return true\">$tampon[1]</a>";
			if($tampon[0] eq "new"){
				print " - <img src=/new.gif>";
			}
			if($tampon[0] eq "maj"){
				#print "&nbsp;-&nbsp;<font color=green><b><i>MAJ</i></b></font>";
				print " - <img src=/maj.gif>";
			}

			print "</td></tr>";
		}
	}
	print "</table>";
	print "</td>";
	if($nbcat%2 ne 0){
		print "</tr>";
	}
	$nbcat += 1;
	}
}

print "</table>";
# print "<p><CENTER><IMG SRC=\"http://intranet.dom/bannernoel.gif\"></CENTER>\n";
print "<p><HR COLOR='darkgoldenrod'>";
print "<font size=-2><i>Pour toutes informations utiliser le <a href=\"mailto:alex\@ibs.dom;sylvain\@ibs.dom;\">Mail</a></i></font><img src=http://intranet.dom/images/creation2001.jpg align=right width=50>";
print "<p>&nbsp;</p>\n";

# -E Interface Intranet Perso
