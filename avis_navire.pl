#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

print $html->header;
$action=$html->param("action");
$rectif=$html->param("rectif");
$annul=$html->param("annul");
$urgent=$html->param("urgent");
$navire=$html->param("navire");
$chauffeur=$html->param("chauffeur");
# $passport=$html->param("passport");
$fourgon=$html->param("fourgon");
$immat=$html->param("immat");
$date=$html->param("date"); 
($date,$port)=split(/;/,$date);
if ($html->param("date2") ne ""){
	$date=$html->param("date2");
	$port=$html->param("port");
}
$liv=$html->param("liv");
require "./src/connect.src";
@port=("T","L","N","S","V");
print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
<HTML>
<HEAD>
	<META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=iso-8859-15\">
	<TITLE>Avis de livraison</TITLE>
	<STYLE>
	<!--
		\@page { size: 21cm 29.7cm; margin: 2.5cm }
		P { margin-bottom: 0.21cm; direction: ltr; color: #000000; text-align: left; widows: 2; orphans: 2 }
		P.western { font-family: \"Times New Roman\", serif; font-size: 10pt; so-language: en-GB }
		P.cjk { font-family: \"Times New Roman\", serif; font-size: 10pt }
		P.ctl { font-family: \"Times New Roman\", serif; font-size: 10pt; so-language: ar-SA }
	-->
	</STYLE>
</HEAD> 
<BODY LANG=\"fr-FR\" TEXT=\"#000000\" DIR=\"LTR\">
";
if ($action eq ""){
	print "<center><form><table>";
	print "<tr><td>navire</td><td>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option ";
      		if ($tables[0] eq $navire ){ print " selected";}

       		print " value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select></td></tr>\n";
	print "</table><input type=hidden name=action value=navire><input type=submit></form>";
}


if ($action eq "navire"){
	# $chauffeur="Remi GOEDRAAD";
	# $passport="7601013956 01DB66496 (Validité 14 octobre 2011)";
	$fourgon="Fourgon IVECO";
	$immat="1942 XY 76";
	$port="";
	$date="";
	print "<center><h3>$navire</h3><form><table>";
        print "<tr><td>Chauffeur</td><td>";
	print "<select name=chauffeur>\n";
	print "<option value=\"Alain BOUCHER\"";
	print " >alain\n";
    	print "<option value=\"Remi GOEDRAAD\"";
	print ">remi\n";
	print "<option value=\"Guilia\"";
	print ">Guilia\n";
	print "<option value=\"Bracconi\"";
	print ">Bracconi\n";
	print "</select></td></tr>\n";
 	# print "<tr><td>Passport</td><td><input type=text size=50 name=passport value='$passport'></td></tr>";
	print "<tr><td>Fourgon</td><td><input type=text size=50 name=fourgon value='$fourgon'</td></tr>";
	print "<tr><td>Immatriculation</td><td><input type=text size=50 name=immat value='$immat'</td></tr>";
	print "<tr><td>Livraison</td><td><input type=radio name=liv value='une palette de produits de boutique et materiel de vente' checked>une palette de produits de parfumerie et materiel de vente<br>";
	print "<input type=radio name=liv value='materiel de desarmement'>materiel de desarmement<br>";
  	print "<input type=radio name=liv value='enlevement boutique'>enlevement boutique<br>";
  	print "<input type=radio name=liv value='1 carton de parfum'>1 carton de parfum</td></tr>";

    	print "</select></td></tr>\n";
	print "<tr><td>Date </td><td><select name=date>\n";

	$query="select nav_date,nav_jour,nav_trajet,nav_hd,nav_ha from horaire where nav_date >=now() and nav_date<date_add(now(),interval 5 day) and nav_nom=\"$navire\"";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($date,$jour,$dest,$hd,$ha)=$sth->fetchrow_array){
		$hd=substr($hd,0,5);
		$ha=substr($ha,0,5);
		$dep=substr($dest,0,1);
		$ret=substr($dest,1,1);
		
		if (grep (/$dep/,@port)){
			$hd=&get("select date_sub(\"$date $hd\",INTERVAL 1 HOUR)");
			($null,$hd)=split(/ /,$hd);
			$hd=substr($hd,0,5);
			print "<option value=\"le $jour $date à $hd ;".&desiquai(substr($dest,0,1))."\">";
			print "le $jour $date à $hd ".&desiquai(substr($dest,0,1));
		}
		if (grep (/$ret/,@port)){
			$ha=&get("select date_add(\"$date $ha\",INTERVAL 15 MINUTE)");
			($null,$ha)=split(/ /,$ha);
			$ha=substr($ha,0,5);
			print "<option value=\"le $jour $date à $ha ;".&desiquai(substr($ret,0,1))."\">";
			print "le $jour $date à $ha ".&desiquai(substr($ret,0,1));
		}
	}
	print "</select><br>saisie manuel<br>date ";
	&select_date();
	print "<select name=port><option value=Toulon>Toulon</option><option value=Nice>Nice</option><option value=Vado>Vado</option><option value=Livourne>Livourne</option></select></td></tr>\n";
	print "<tr><td>Rectificatif <input type=checkbox name=rectif></td></tr>";	
	print "<tr><td>Annulation <input type=checkbox name=annul></td></tr>";	
	print "<tr><td>Urgent <input type=checkbox name=urgent></td></tr>";	
	print "</table><input type=hidden name=navire value=\"$navire\"><input type=hidden name=action value=go><input type=submit></form>";

}



if ($chauffeur eq "Remi GOEDRAAD"){
	$passport="7601013956 01DB66496 (Validité 14 octobre 2011)";
}
if ($chauffeur eq "Alain BOUCHER"){
	$passport="04FB17597 (Validité 26 juillet 2014)";
}

if ($action eq "go"){
	if ($navire eq "MEGA 2") {
	$liste="master.mega2\@corsicaferries.com info\@solas-security.com hotel.mega2\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "MEGA 1") {
	$liste="master.mega1\@corsicaferries.com info\@solas-security.com hotel.mega1\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "MEGA 3") {
	$liste="master.mega3\@corsicaferries.com info\@solas-security.com hotel.mega3\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "MEGA 4") {
	$liste="master.mega4\@corsicaferries.com info\@solas-security.com hotel.mega4\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}

	if ($navire eq "EXPRESS 3") {
	$liste="master.express3\@corsicaferries.com info\@solas-security.com hotel.express3\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "EXPRESS 2") {
	$liste="master.express2\@corsicaferries.com info\@solas-security.com hotel.express2\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	# $liste="sylvain.brandicourt\@wanadoo.fr";

	}
	if ($navire eq "SARDINIA EXPRESS") {
	$liste="master.express1\@corsicaferries.com info\@solas-security.com hotel.express1\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "MARINA") {
	$liste="master.marina\@corsicaferries.com info\@solas-security.com hotel.marina\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "VERA") {
	$liste="master.vera\@corsicaferries.com info\@solas-security.com hotel.vera\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "VICTORIA") {
	$liste="master.victoria\@corsicaferries.com info\@solas-security.com hotel.victoria\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "REGINA") {
	$liste="master.regina\@corsicaferries.com info\@solas-security.com hotel.regina\@corsicaferries.com vassel.regina\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	if ($navire eq "SERENA II") {
	$liste="master.serena\@corsicaferries.com info\@solas-security.com hotel.serena\@corsicaferries.com p.giafferi\@corsicaferries.com giuliademarinis\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr";
	}
	
	&save("update atad set dt_no=dt_no+1 where dt_cd_dt=181");
	$protocole=&get("select dt_no from atad where dt_cd_dt=181");
	open (FILE ,">/tmp/corsica.txt");
	print FILE "SUBJECT:prossima consegna boutique";
	if ($urgent eq "on") {print FILE " Procédure Urgente";}
	print FILE "\n";
	print FILE "Cc:$liste\n";
	print FILE "Content-type: text/html\n\n";

($part1,$part2,$part3)=split(/-/,$date);
($null,$null,$part1)=split(/ /,$part1);
($part3)=split(/ /,$part3);
$part1=substr($part1,2,2); 
$mab="IBS$part1$part2$part3";
if ($navire eq "EXPRESS 2"){$nav="C2";}
if ($navire eq "EXPRESS 3"){$nav="C3";}
if ($navire eq "MARINA"){$nav="CM";}
if ($navire eq "MEGA 1"){$nav="M1";}
if ($navire eq "MEGA 2"){$nav="M2";}
if ($navire eq "MEGA 3"){$nav="M3";}
if ($navire eq "MEGA 4"){$nav="M4";}
if ($navire eq "MEGA 5"){$nav="M5";}
if ($navire eq "REGINA"){$nav="SR";}
if ($navire eq "SARDINIA EXPRESS"){$nav="SE";}
if ($navire eq "SERENA II"){$nav="CS";}
if ($navire eq "VERA"){$nav="SV";}
if ($navire eq "VICTORIA"){$nav="CV";}
$mab=$mab.$nav;

print "<P STYLE=\"margin-bottom: 0cm\"><FONT FACE=\"Century Gothic, sans-serif\"><B>Objet:	Intervention
 de la soci&eacute;t&eacute; IBS FRANCE</B></FONT><SPAN ID=\"Cadre1\" DIR=\"LTR\" STYLE=\"position: absolute; top: 6.31cm; left: 0cm; width: 16.4cm; height: 0.04cm; border: none; padding: 0cm; background: #ffffff\">
	<TABLE DIR=\"LTR\" WIDTH=100% BORDER=1 BORDERCOLOR=\"#000000\" CELLPADDING=7 CELLSPACING=0>
		<COL WIDTH=62*>
		<COL WIDTH=85*>
		<COL WIDTH=47*>
		<COL WIDTH=61*>
		<TR>
			<TD WIDTH=24% HEIGHT=10>
				<P CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Jour
				et heure de l&rsquo;intervention :</FONT></P>
			</TD>
			<TD COLSPAN=3 WIDTH=76%>
				<P CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$date</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">A
				bord du navire:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$navire</FONT></P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"> <FONT FACE=\"Century Gothic, sans-serif\">port
				de</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$port</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Intervention
				de la soci&eacute;t&eacute;:</FONT></P>
			</TD>
			<TD WIDTH=76%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">IBS
				FRANCE</FONT></P>
			</TD>
			<TD >
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">No de protocole</FONT></P>
			</TD>
			<TD >
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$mab</FONT></P>
			</TD>
	
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Noms
				des personnes:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\"><FONT SIZE=2 STYLE=\"font-size: 9pt\">$chauffeur</FONT></FONT></P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Doc.Identit&eacute;</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"en-GB\" CLASS=\"western\"><SPAN LANG=\"fr-FR\"><FONT FACE=\"Century Gothic, sans-serif\">Passeport
				N&deg; <b>$passport</b></FONT></SPAN></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Noms
				des personnes:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><BR>
				</P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Doc.Identit&eacute;</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"en-GB\" CLASS=\"western\"><BR>
				</P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Noms
				des personnes:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><BR>
				</P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Doc.Identit&eacute;</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"en-GB\" CLASS=\"western\"><BR>
				</P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Type
				de  voiture:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$fourgon
				</FONT></P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">immatriculation</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$immat</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Motif
				de l&rsquo;Intervention:</FONT></P>
			</TD>
			<TD COLSPAN=3 WIDTH=76%>
				<P CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">LIVRAISON
				$liv</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=10>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Dur&eacute;e
				de l&rsquo;Intervention:</FONT></P>
			</TD>
			<TD COLSPAN=3 WIDTH=76%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">&frac12;
				heure </FONT>
				</P>
			</TD>
		</TR>
	</TABLE>
</SPAN>
</P>
<TABLE WIDTH=558 BORDER=1 BORDERCOLOR=\"#000000\" CELLPADDING=7 CELLSPACING=0 FRAME=ABOVE>
	<COL WIDTH=544>
	<TR>
		<TD WIDTH=544 VALIGN=TOP>
			<P LANG=\"en-GB\"><BR>
			</P>
		</TD>
	</TR>
</TABLE>
<P LANG=\"en-GB\" STYLE=\"margin-bottom: 0cm\"><BR>
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><BR>
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><FONT FACE=\"Century Gothic, sans-serif\" size=-1>";
if ($rectif eq "on") { print  "annule et remplace le mail précedent<br>";}
if ($annul eq "on") { print  "<b>DEMANDE ANNULE VEUILLEZ NE PAS TENIR COMPTES DE CET AVIS<b><br>";}
if ($urgent eq "on") { print  "<font size=+2><b>Procedure urgente</b></font><br>";}

print  "Je vous informe de l&rsquo;embarquement des personnes suivantes avec les
informations comme suit:</FONT></P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><BR>
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><BR>
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><BR>
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><BR>
</P>";
print FILE "<P STYLE=\"margin-bottom: 0cm\"><FONT FACE=\"Century Gothic, sans-serif\"><B>Objet:	Intervention
 de la soci&eacute;t&eacute; IBS FRANCE</B></FONT><SPAN ID=\"Cadre1\" DIR=\"LTR\" STYLE=\"position: absolute; top: 6.31cm; left: 0cm; width: 16.4cm; height: 0.04cm; border: none; padding: 0cm; background: #ffffff\">
	<TABLE DIR=\"LTR\" WIDTH=100% BORDER=1 BORDERCOLOR=\"#000000\" CELLPADDING=7 CELLSPACING=0>
		<COL WIDTH=62*>
		<COL WIDTH=85*>
		<COL WIDTH=47*>
		<COL WIDTH=61*>
		<TR>
			<TD WIDTH=24% HEIGHT=10>
				<P CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Jour
				et heure de l&rsquo;intervention :</FONT></P>
			</TD>
			<TD COLSPAN=3 WIDTH=76%>
				<P CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$date</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">A
				bord du navire:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$navire</FONT></P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"> <FONT FACE=\"Century Gothic, sans-serif\">port
				de</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$port</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Intervention
				de la soci&eacute;t&eacute;:</FONT></P>
			</TD>
			<TD WIDTH=76%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">IBS
				FRANCE</FONT></P>
			</TD>
			<TD >
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">No de protocole</FONT></P>
			</TD>
			<TD >
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$mab</FONT></P>
			</TD>
		
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Noms
				des personnes:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\"><FONT SIZE=2 STYLE=\"font-size: 9pt\">$chauffeur</FONT></FONT></P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Doc.Identit&eacute;</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"en-GB\" CLASS=\"western\"><SPAN LANG=\"fr-FR\"><FONT FACE=\"Century Gothic, sans-serif\">Passeport
				N&deg; <b>$passport</b></FONT></SPAN></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Noms
				des personnes:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><br>\n
				</P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Doc.Identit&eacute;</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"en-GB\" CLASS=\"western\"><br>\n
				</P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Noms
				des personnes:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><br>\n
				</P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Doc.Identit&eacute;</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"en-GB\" CLASS=\"western\"><br>\n
				</P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Type
				de  voiture:</FONT></P>
			</TD>
			<TD WIDTH=33%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$fourgon
				</FONT></P>
			</TD>
			<TD WIDTH=19%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">immatriculation</FONT></P>
			</TD>
			<TD WIDTH=24%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">$immat</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=11>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Motif
				de l&rsquo;Intervention:</FONT></P>
			</TD>
			<TD COLSPAN=3 WIDTH=76%>
				<P CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">LIVRAISON
				$liv</FONT></P>
			</TD>
		</TR>
		<TR>
			<TD WIDTH=24% HEIGHT=10>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">Dur&eacute;e
				de l&rsquo;Intervention:</FONT></P>
			</TD>
			<TD COLSPAN=3 WIDTH=76%>
				<P LANG=\"it-IT\" CLASS=\"western\"><FONT FACE=\"Century Gothic, sans-serif\">&frac12;
				heure </FONT>
				</P>
			</TD>
		</TR>
	</TABLE>
</SPAN>
</P>
<TABLE WIDTH=558 BORDER=1 BORDERCOLOR=\"#000000\" CELLPADDING=7 CELLSPACING=0 FRAME=ABOVE>
	<COL WIDTH=544>
	<TR>
		<TD WIDTH=544 VALIGN=TOP>
			<P LANG=\"en-GB\"><br>\n
			</P>
		</TD>
	</TR>
</TABLE>
<P LANG=\"en-GB\" STYLE=\"margin-bottom: 0cm\"><br>\n
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><br>\n
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><FONT FACE=\"Century Gothic, sans-serif\" size=-1>";
if ($rectif eq "on") { print FILE "annule et remplace le mail précedent<br>";}
if ($annul eq "on") { print  "<b>DEMANDE ANNULE VEUILLEZ NE PAS TENIR COMPTES DE CET AVIS<b><br>";}
if ($urgent eq "on") { print  "<font size=+2><b>Procedure urgente</b></font><br>";}

print FILE "Je vous informe de l&rsquo;embarquement des personnes suivantes avec les
informations comme suit:</FONT></P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><br>\n
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><br>\n
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><br>\n
</P>
<P CLASS=\"western\" STYLE=\"margin-bottom: 0cm\"><br>\n
</P>";
close (FILE);
  # system ("rsh -l sylvain 192.168.1.4 /usr/sbin/sendmail -fibsfrance\@wanadoo.fr $liste</tmp/corsica.txt");
 #  system ("rsh -l sylvain 192.168.1.4 (echo \"SUBJECT:newsletter le 3pieces\n\n \";uuencode /tmp/corsica.txt corsica.txt) | /usr/sbin/sendmail -fibsfrance\@wanadoo.fr sylvain.brandicourt\@wanadoo.fr");
}
print "</BODY> </HTML>";
sub desiquai()
{ 
 my $q=$_[0];
 if ($q eq "S"){return("Vado");}
 if ($q eq "T"){return("Toulon");}
 if ($q eq "L"){return("Livourne");}
 if ($q eq "N"){return("Nice");}
 if ($q eq "C"){return("Civitavecc");}
 return("<font color=red>Inconnu:$_[0]</font>");

}


# -E avis automatique par mail des livraisons navire 06/09 actif
