#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
# initialisation des variables
print "En maintenance merci de reessayer plus tard";
exit;
$border=$html->param("border");
$client=substr($border,0,3);
$query="select cl_cd_cl,cl_nom from client where cl_cd_cl='$client'";
$sth=$dbh->prepare($query);
$sth->execute();
if (! (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array)){$client="___";}

$appro=$html->param("appro");
$vol=$html->param("vol");
$vol_force=$html->param("vol_force");
$action=$html->param("action");
$date=$html->param("date");
$rotation=$html->param("rotation");
$cc=$html->param("cc");
for ($i=1;$i<9;$i++){
	$par="pnc".$i;
	$pnc=$html->param($par);
	if ($pnc ne ""){push (@pnc,$pnc);}
}
$total=$html->param("total")+0;
$totalmo=$html->param("totalmo")+0;
$totalch=$html->param("totalch")+0;
$totalcb=$html->param("totalcb")+0;
$papi=$html->param("papi")+0;
$devise=$html->param("devise")+0;
$coma=$html->param("coma")+0;
$comp=$html->param("comp")+0;

@chequier=();
for ($i=0;$i<11;$i++){
	$par1="banque".$i;
	$par1b="ville".$i;
	$par2="nom".$i;
	$par3="montant".$i;
	$montant=$html->param($par3)+0;
	$cheque=$html->param($par1).":".$html->param($par1b).":".$html->param($par2).":".$montant;
	if ($montant != 0){
		# print "sylvain $cheque ".$html->param($par1),"*",$i,$par1;
		push (@chequier,$cheque);}
}
for ($i=0;$i<11;$i++){
	$par1="montant".$i;
	$$par1=0;
}

$monnaie=$html->param("monnaie")+0;
$monnaie5=$html->param("monnaie5")+0;
$monnaie10=$html->param("monnaie10")+0;
$monnaie20=$html->param("monnaie20")+0;
$monnaie50=$html->param("monnaie50")+0;
$monnaie100=$html->param("monnaie100")+0;
$monnaie200=$html->param("monnaie200")+0;
$monnaie500=$html->param("monnaie500")+0;

$ingenico=$html->param("ingenico")+0;
$sabot=$html->param("sabot")+0;
$am=$html->param("am")+0;
$diners=$html->param("diners")+0;
$date_du_jour=`/bin/date '+%d/%m/%y'`;

$justificatif=$html->param("justificatif");
$annonce=$html->param("annonce");

# ###############

if ($action eq ""){&page1();}
if ($action eq "verif"){&verif();}
if ($action eq "ok"){&saicaisse();}
if ($action eq "forcage"){&saicaisse();}
if ($action eq "valid"){&enregistre();}
if ($action eq "bordereau"){&bordereau();}
if ($action eq "cheque"){&cheque();}
if ($action eq "espece"){&espece();}

#### PREMIERE PAGE
sub page1{
print << "eof"
<script>
index=0;
i=0;
b=0;
h=0;
go=0;
function chop()
{
touche=window.event.keyCode; 		// recuperation du code de la touche pressée
if (touche==39){
index=i+1;
if (index>=document.forms[0].length-1){index=0;}
document.forms[0][index].focus();
}
if (touche==37){
index=i-1;
if (index==-1){index=0;}
document.forms[0][index].focus();
}
if (touche==40){
document.forms[0][b].focus();
}
if (touche==38){
document.forms[0][h].focus();
}
}

function fauxcus()
{
	if (document.appro.border.value!=""){
		document.appro.appro.focus();
	}
	else{
		document.appro.border.focus();
	}
}

function envoie()
{
	if (go==1){return true} 
	else {
		index=i+1;
		if (index>=document.forms[0].length){index=0;}
		document.forms[0][index].focus();
		return(false);
	}
}


</script>
<html>
<body bgcolor=navy text=white onLoad=fauxcus() onKeydown=chop()>
<h1> SAISIE DES CAISSES</h1>
<form method=POST  name=appro OnSubmit=\"return envoie()\">
<table border=0 width=50%>
<tr><td>Bordereau</td><td><input type=texte name=border size=8 value=\"$border\" onFocus=\"i=0;b=1;h=0\"></td></tr>
<tr><td>Appro </td><td><input type=texte name=appro size=8 onFocus=\"i=1;b=2;h=0\"></td></tr>
<tr><td>Rotation </td><td><input type=texte name=rotation value=1 size=2 onFocus=\"i=2;b=3;h=1\"></td></tr>
<tr><td>Chef de cabine </td><td><input type=texte name=cc size=3 onFocus=\"i=3;b=4;h=2\"></td></tr>
<tr><td>Equipage</td><td>
<input type=texte name=pnc1 size=3 onFocus=\"i=4;b=12;h=3\">
<input type=texte name=pnc2 size=3 onFocus=\"i=5;b=12;h=3\">
<input type=texte name=pnc3 size=3 onFocus=\"i=6;b=12;h=3\">
<input type=texte name=pnc4 size=3 onFocus=\"i=7;b=12;h=3\">
<input type=texte name=pnc5 size=3 onFocus=\"i=8;b=12;h=3\">
<input type=texte name=pnc6 size=3 onFocus=\"i=9;b=12;h=3\">
<input type=texte name=pnc7 size=3 onFocus=\"i=10;b=12;h=3\">
<input type=texte name=pnc8 size=3 onFocus=\"i=11;b=12;h=3\"></td></tr>
<tr><td>No de vol </td><td><input type=texte name=vol_force size=3 onFocus=\"i=12;b=13;h=4\"></td></tr>
</table><br>
<input type=submit value=Envoyer onclick=document.appro.action.value=\"verif\" onFocus=\"i=13;b=13;h=12;go=1\" OnBlur=\"go=0\">
 <input type=submit value=Bordereau onclick=document.appro.action.value=\"bordereau\" onFocus=\"i=14;b=14;h=12;go=1\" OnBlur=\"go=0\">
 <input type=submit value="Relevé de chèque" onclick=document.appro.action.value=\"cheque\" onFocus=\"i=15;b=15;h=12;go=1\" OnBlur=\"go=0\">
 <input type=submit value="Relevé d'espece" onclick=document.appro.action.value=\"espece\" onFocus=\"i=16;b=16;h=12;go=1\" OnBlur=\"go=0\">
 <input type=submit value="Forcage" onclick=document.appro.action.value=\"forcage\" onFocus=\"i=17;b=17;h=12;go=1\" OnBlur=\"go=0\">

<input type=hidden name=action value=verif>
</form>
</body>
</html>
eof
}

sub verif{
$ok=1;
$message="";
if ($client eq "___"){
	$cl_nom="<font size=+2 color=red><b>Client inconnu</b></font>";
	$ok=0;
	}
$query="select v_code,v_vol,v_date,v_dest from vol where v_code='$appro' and v_rot='$rotation' and v_cd_cl='$client'";
$sth=$dbh->prepare($query);
$sth->execute();
if (($null,$v_vol,$v_date,$v_dest)=$sth->fetchrow_array){
	if ($vol_force ne ""){$v_vol=$vol_force;}
	if ($v_vol eq "___"){
			$v_vol="<b><Font size=+2 color=red>Merci de saisir le numéro de vol</font></b>";
		$ok=0;
	}
}
else {
	$v_vol="<b><Font size=+2 color=red>Bon Appro inconnu</font></b>";
	$ok=0;
}
if ($cc eq "" ){$cc="___";}
$query="select hot_tri,hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$cc'";
$sth=$dbh->prepare($query);
$sth->execute();
if (($hot_tri,$nomcc)=$sth->fetchrow_array){}
else {
	$query="select hot_tri,hot_nom from hotesse where hot_cd_cl='$client' and hot_mat='$cc'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_tri,$nomcc)=$sth->fetchrow_array){}
	else {
		$nomcc="<b><Font size=+2 color=red>CC inconnu</font></b>";
		if ($cc ne "NULL"){$ok=0;}
	}
}
if (($#pnc==-1) && ( $client!=330) && ($cc ne "NULL")){	
	push (@equipage,";<font size=+2 color=red><b>Saisir l'equipage Merci</b></font>");
	$ok=0;
}
$index_pnc=-1;	
foreach (@pnc){
	$index_pnc++;
	$pnc=$_;
	if ($pnc eq ""){$pnc="___";}
	$query="select hot_tri,hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_tri,$hot_nom)=$sth->fetchrow_array){}
	else{
		$query="select hot_tri,hot_nom from hotesse where hot_cd_cl='$client' and hot_mat='$pnc'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		if (($hot_tri,$hot_nom)=$sth->fetchrow_array){
			@pnc[$index_pnc]=$hot_tri;
			}
		else{
			$hot_nom="<b><Font size=+2 color=red>PNC inconnu</font></b>";
		}
	}
	push (@equipage,"$pnc;$hot_nom");
}
$query="select ca_border from caissesql where ca_code='$appro' and ca_rot='$rotation'";
$sth=$dbh->prepare($query);
$sth->execute();



if (($ca_border)=$sth->fetchrow_array){
 	if ($ca_border != $border){
 		$message="<font color=red size=+2>Caisse deja saisie sur le bordereau $ca_border </font>";
 		$ok=0;
 	}
 	else {
		$query="select ca_code,ca_rot,ca_total,ca_totalmo,ca_detail_monnaie,ca_totalch,ca_totalcb,ca_devise,ca_papi,ca_ingenico,ca_am,ca_diners,ca_detail_cheque,ca_coma,ca_comp from caissesql where ca_code='$appro' and ca_rot='$rotation'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($appro,$rotation,$total,$totalmo,$detail_monnaie,$totalch,$totalcb,$devise,$papi,$ingenico,$am,$diners,$detail_cheque,$coma,$comp)=$sth->fetchrow_array;
		($monnaie,$monnaie5,$monnaie10,$monnaie20,$monnaie50,$monnaie100,$monnaie500,$monnaie200)=split(/:/,$detail_monnaie);
	 	($null,@chequier)=split(/;/,$detail_cheque);
	 	for ($i=0;$i<11;$i++){
	 		# $j=$i+1;
	 		$j=$i;
			$varbanque="banque".$j; #astuce
			$varville="ville".$j; #astuce
			$varnom="nom".$j; #astuce
			$varmontant="montant".$j; #astuce
			($$varbanque,$$varville,$$varnom,$$varmontant)=split(/:/,$chequier[$i]);
			$$varmontant+=0;
		}
 		print "***";
	
 		&saicaisse();
 		exit;
 	}
}	
if ($border eq ""){
	$message="<font color=red size=+2>No Bordereau invalide</font>";
	$ok=0;
	}
if (($border <1000)||($border >999999)){
	$message="<font color=red size=+2><b>No Bordereau invalide</b></font>";
	$ok=0;
	}
if ($ok==0){
print "<html>
<body bgcolor=navy text=white alink=white vlink=white link=white>
<h1>VERIFICATION</h1>
<form method=POST  name=verif>
$message <br>
Client: $client $cl_nom<br>
Appro: $appro<br>
Rotation: $rotation<br>
Vol: $v_vol<br>
Destination: $v_dest<br>
Date: $v_date<br>
Chef de cabine: <b>$cc-->$nomcc</b><br>
équipage<br>";
foreach (@equipage){
	($tri,$nom)=split(/;/,$_);
	 print "$tri-->$nom <br>";
	}
print "<br><br><input type=button value=retour name=retour onclick=javascript:history.back()>";
print "</form><script>document.verif.retour.focus()</script></body></html>";
}
else
{
$vol=$v_vol;
saicaisse();
}
}


sub saicaisse{
$tpemontant="&nbsp;";
$query="select sum(tb_montant) from tpebqsql where tb_code='$appro'";
$sth=$dbh->prepare($query);
$sth->execute();
($tpe_montant)=$sth->fetchrow_array;

print "
<html>
<script>
function cal_tot_mo()
{
totalmo.innerHTML=eval(document.fiche.monnaie.value)+eval(document.fiche.monnaie5.value*5)+eval(document.fiche.monnaie10.value*10)+eval(document.fiche.monnaie20.value*20)+eval(document.fiche.monnaie50.value*50)+eval(document.fiche.monnaie100.value*100)+eval(document.fiche.monnaie200.value*200)+eval(document.fiche.monnaie500.value*500);
total.innerHTML=eval(document.fiche.papi.value)+eval(document.fiche.devise.value)+eval(totalmo.innerHTML)+eval(totalch.innerHTML)+eval(totalcb.innerHTML);
}
function cal_tot_ch()
{
totalch.innerHTML=eval(document.fiche.montant0.value)+eval(document.fiche.montant1.value)+eval(document.fiche.montant2.value)+eval(document.fiche.montant3.value)+eval(document.fiche.montant4.value)+eval(document.fiche.montant5.value)+eval(document.fiche.montant6.value)+eval(document.fiche.montant7.value)+eval(document.fiche.montant8.value)+eval(document.fiche.montant9.value)+eval(document.fiche.montant10.value);
total.innerHTML=eval(document.fiche.papi.value)+eval(document.fiche.devise.value)+eval(totalmo.innerHTML)+eval(totalch.innerHTML)+eval(totalcb.innerHTML);
}
function cal_tot_cb()
{
totalcb.innerHTML=eval(document.fiche.ingenico.value)+eval(document.fiche.sabot.value)+eval(document.fiche.am.value)+eval(document.fiche.diners.value);
total.innerHTML=eval(document.fiche.papi.value)+eval(document.fiche.devise.value)+eval(totalmo.innerHTML)+eval(totalch.innerHTML)+eval(totalcb.innerHTML);
}
function cal_tot()
{
total.innerHTML=eval(document.fiche.papi.value)+eval(document.fiche.devise.value)+eval(totalmo.innerHTML)+eval(totalch.innerHTML)+eval(totalcb.innerHTML);
}
function setvar()
{
document.fiche.totalmo.value=totalmo.innerHTML;
document.fiche.totalch.value=totalch.innerHTML;
document.fiche.totalcb.value=totalcb.innerHTML;
document.fiche.total.value=total.innerHTML;
}
function init()
{
document.fiche.monnaie.focus();
document.fiche.monnaie.select();
totalmo.innerHTML=$totalmo;
totalch.innerHTML=$totalch;
totalcb.innerHTML=$totalcb;
total.innerHTML=$total;
}
</script>
<body bgcolor=navy text=white onLoad=init()>
<b><font size=+1>$cl_nom</font> Code appro:$appro  rotation:$rotation  $vol $cc @pnc</b><br><br>
<form method=POST  name=fiche>
<table border=0 width=80%>
	<tr><td>
	<table border=1>
		<caption><b>EURO</capion>
		<tr><th>Monnaie</th><th>Billet de 5</th><th>Billet de 10</th><th>Billet de 20</th><th>Billet de 50</th><th>Billet de 100</th><th>Billet de 200</th><th>Billet de 500</th><th>Total</th></tr>
		<tr>
		<td><input type=text name=monnaie size=4 Onchange=cal_tot_mo() value=$monnaie></td>
		<td><input type=text name=monnaie5 size=4 Onchange=cal_tot_mo() value=$monnaie5></td>
		<td><input type=text name=monnaie10 size=4 Onchange=cal_tot_mo() value=$monnaie10></td>
		<td><input type=text name=monnaie20 size=4 Onchange=cal_tot_mo() value=$monnaie20></td>
		<td><input type=text name=monnaie50 size=4 Onchange=cal_tot_mo() value=$monnaie50></td>
		<td><input type=text name=monnaie100 size=4 Onchange=cal_tot_mo() value=$monnaie100></td>
		<td><input type=text name=monnaie200 size=4 Onchange=cal_tot_mo() value=$monnaie200></td>
		<td><input type=text name=monnaie500 size=4 Onchange=cal_tot_mo() value=$monnaie500></td>
		<td><div id=totalmo style=font-size:large>0</div></td>
		</tr>
	</table>
	</td>
	<td align=middle valign=top>
	<table border=1>
		<caption><b>DEVISE</capion>
		<tr><td>Montant <input type=text name=devise size=4 value=$devise Onchange=cal_tot()></td></tr>
	</table>
	</td></tr>
	<tr><td>
	<table border=1>
		<caption><b>CHEQUE</capion>
		<tr><th>Banque</th><th>Ville</th><th>Nom</th><th>Montant</th></tr>
		<tr><td><input type=text name=banque0 size=12 value=\"$banque0\"></td>
		<td><input type=text name=ville0 size=25 value=\"$ville0\"></td>
		<td><input type=text name=nom0 size=25 value=\"$nom0\"></td>
		<td><input type=text name=montant0 size=12 Onchange=cal_tot_ch() value=$montant0></td></tr>
		
		<tr><td><input type=text name=banque1 size=12 value=\"$banque1\"></td>
		<td><input type=text name=ville1 size=25 value=\"$ville1\"></td>
		<td><input type=text name=nom1 size=25 value=\"$nom1\"></td>
		<td><input type=text name=montant1 size=12 Onchange=cal_tot_ch() value=$montant1></td></tr>
		
		<tr><td><input type=text name=banque2 size=12 value=\"$banque2\"></td>
		<td><input type=text name=ville2 size=25 value=\"$ville2\"></td>
		<td><input type=text name=nom2 size=25 value=\"$nom2\"></td>
		<td><input type=text name=montant2 size=12 Onchange=cal_tot_ch() value=$montant2></td></tr>
		
		<tr><td><input type=text name=banque3 value=\"$banque3\" size=12></td>
		<td><input type=text name=ville3 value=\"$ville3\" size=25></td>
		<td><input type=text name=nom3 value=\"$nom3\" size=25></td>
		<td><input type=text name=montant3 size=12 Onchange=cal_tot_ch() value=$montant3></td></tr>
		
		<tr><td><input type=text name=banque4 size=12 value=\"$banque4\"></td>
		<td><input type=text name=ville4 size=25 value=\"$ville4\"></td>
		<td><input type=text name=nom4 size=25 value=\"$nom4\"></td>
		<td><input type=text name=montant4 size=12 Onchange=cal_tot_ch() value=$montant4></td></tr>
		
		<tr><td><input type=text name=banque5 size=12 value=\"$banque5\"></td>
		<td><input type=text name=ville5 size=25 value=\"$ville5\"></td>
		<td><input type=text name=nom5 size=25 value=\"$nom5\"></td>
		<td><input type=text name=montant5 size=12 Onchange=cal_tot_ch() value=$montant5></td></tr>
		
		<tr><td><input type=text name=banque6 size=12 value=\"$banque6\"></td>
		<td><input type=text name=ville6 size=25 value=\"$ville6\"></td>
		<td><input type=text name=nom6 size=25 value=\"$nom6\"></td>
		<td><input type=text name=montant6 size=12 Onchange=cal_tot_ch() value=$montant6></td></tr>
		
		<tr><td><input type=text name=banque7 size=12 value=\"$banque7\"></td>
		<td><input type=text name=ville7 size=25 value=\"$ville7\"></td>
		<td><input type=text name=nom7 size=25 value=\"$nom7\"></td>
		<td><input type=text name=montant7 size=12 Onchange=cal_tot_ch() value=$montant7></td></tr>
		
		<tr><td><input type=text name=banque8 size=12 value=\"$banque8\"></td>
		<td><input type=text name=ville8 size=25 value=\"$ville8\"></td>
		<td><input type=text name=nom8 size=25 value=\"$nom8\"></td>
		<td><input type=text name=montant8 size=12 Onchange=cal_tot_ch() value=$montant8></td></tr>
		
		<tr><td><input type=text name=banque9 size=12 value=\"$banque9\"></td>
		<td><input type=text name=ville9 size=25 value=\"$ville9\"></td>
		<td><input type=text name=nom9 size=25 value=\"$nom9\"></td>
		<td><input type=text name=montant9 size=12 Onchange=cal_tot_ch() value=$montant9></td></tr>
		
		<tr><td><input type=text name=banque10 size=12 value=\"$banque10\"></td>
		<td><input type=text name=ville10 size=25 value=\"$ville10\"></td>
		<td><input type=text name=nom10 size=25 value=\"$nom10\"></td>
		<td><input type=text name=montant10 size=12 Onchange=cal_tot_ch() value=$montant10></td></tr>
		<tr><td>&nbsp;</td><td>&nbsp;</td><td><b>Total</td>
	
		<td><div id=totalch style=font-size:large>0</div></td></tr>
	</table>
	</td>
	<td align=middle valign=top>
	<table border=1>
		<caption><b>CARTE BANCAIRE</caption>
		<tr><td align=right>Ingenico</td><td><input type=text size=5 name=ingenico Onchange=cal_tot_cb() value=$ingenico></td><td><b>$tpe_montant<b></td></tr>
		<tr><td align=right>Sabot</td><td><input type=text size=5 name=sabot Onchange=cal_tot_cb() value=$sabot></td><td>&nbsp;</td></tr>
		<tr><td align=right>American express</td><td><input type=text size=5 name=am Onchange=cal_tot_cb() value=$am></td><td>&nbsp;</td></tr>
		<tr><td align=right>Diners</td><td><input type=text size=5 name=diners Onchange=cal_tot_cb() value=$diners></td><td>&nbsp;</td></tr>
		<tr><td align=right><b>Total</td><td><div id=totalcb style=font-size:large>0</div></td><td>&nbsp;</td></tr>
	</table>
	<br>	
	<table border=1>
		<caption><b>PAPILLON</capion>
		<tr><td>Montant <input type=text name=papi size=4 value=$papi Onchange=cal_tot()></td></tr></table>
		</td>
	</table>
	<table border=1>
		<tr><th>Montant commission argent</th><th>Montant commission produit</th></tr>
		<tr><td>Montant <input type=text name=coma value=$coma size=4></td>
		<td>Montant <input type=text name=comp value=$comp  size=4></td>
		</tr></table>
		</td>
	</table>
    
	</td>
	</tr>
</td></tr>
</table>
<br><br>
<center>
<table><tr><td><font size=+2> TOTAL: </td><td><div id=total style=font-size:large>0</div></td><td> <input type=submit value=valider Onclick=setvar()></tr></table>
";

print "<input type=hidden name=totalmo>";
print "<input type=hidden name=totalch>";
print "<input type=hidden name=totalcb>";
print "<input type=hidden name=total>";
print "<input type=hidden name=action value=valid>";
print "	<input type=hidden name=border value=$border>";
print "	<input type=hidden name=appro value=$appro>";
print "	<input type=hidden name=vol value=$v_vol>";
print "	<input type=hidden name=rotation value=$rotation>";
print "	<input type=hidden name=action value=ok>";
print "	<input type=hidden name=cc value=$cc>";
print "	<input type=hidden name=pnc1 value=$pnc[0]>";
print "	<input type=hidden name=pnc2 value=$pnc[1]>";
print "	<input type=hidden name=pnc3 value=$pnc[2]>";
print "	<input type=hidden name=pnc4 value=$pnc[3]>";
print "	<input type=hidden name=pnc5 value=$pnc[4]>";
print "	<input type=hidden name=pnc6 value=$pnc[5]>";
print "	<input type=hidden name=pnc7 value=$pnc[6]>";
print "	<input type=hidden name=pnc8 value=$pnc[7]>";
print "<h2>Ecart de caisse </h2><br>";
print "Montant indiqué par le PNC:<input type=texte name=annonce size=8><br>Justificatif <textarea name=justificatif rows=4 cols=40></textarea>";
print "</form></body></html>";
}

		
sub enregistre{
	# caisse
	if ($border==0){exit;} # en cas de bug
	$detail_cheque="";
	foreach(@chequier){
		 $detail_cheque=$detail_cheque.";".$_;
	}
	 # print "+",$#chequier,"---",$detail_cheque,"---";
	 # exit;
	$detail_monnaie="$monnaie:$monnaie5:$monnaie10:$monnaie20:$monnaie50:$monnaie100:$monnaie500:$monnaie200";
	$query="replace into caissesql values ('$appro','$rotation','$border','$total','$totalmo','$detail_monnaie','$totalch','$totalcb','$devise','$papi','$ingenico','$am','$diners','$detail_cheque','$coma','$comp' )";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	# equipage
	if (($cc ne "")&&($cc ne "___")){
		$equipe="";
		foreach (@pnc){
			$equipe.=";".$_;
		}
		$query="replace into equipagesql values ('$appro','$rotation','$cc','$equipe')";
		$dbh->do($query);
	}
	
	# ecart
	if ($justificatif ne ""){
		$query="replace into ecart_caisse values ('$appro','$rotation','$annonce','$justificatif')";
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	&page1();
}

sub bordereau{

 print "
 <html>
 <body>
 <h3>$cl_nom $client</h3>
 <br>
 <br>
 Saisie du <B>$date_du_jour</B><BR>
 BORDEREAU <b>$border</b><br>

 <table border=1 cellspacing=0 cellpadding=5>
 <tr><th>APPRO</th><th>DATE</th><th>ROT</th><th>C/C PNC</th><th>RECETTE</th><th>éspeces</th><th>chèque</th><th>ingénico</th><th>a.m</th><th>diners</th><th>dev.</th><th>papillon</th></tr>";
 $query="select ca_code,ca_rot,ca_total,ca_totalmo,ca_totalch,ca_totalcb,ca_devise,ca_papi,ca_ingenico,ca_am,ca_diners,ca_coma,ca_comp from caissesql where ca_border='$border'";
 $sth=$dbh->prepare($query);
 $sth->execute();
while (($appro,$rotation,$total,$totalmo,$totalch,$totalcb,$devise,$papi,$ingenico,$am,$diners,$coma,$comp)=$sth->fetchrow_array){
	$query="select v_vol,v_date,v_dest from vol where v_code='$appro' and v_rot='$rotation'";

	$sth2=$dbh->prepare($query);
	$sth2->execute();
	if (! (($v_vol,$v_date,$v_dest)=$sth2->fetchrow_array)){$v_vol="vol inconnu";}
        $query="select eq_equipage from equipagesql where eq_code='$appro' and eq_rot='$rotation'";

	@equip=();
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	(@equip)=split(/;/,$sth2->fetchrow_array);
      	print "<tr><td align=right>$appro</td><td align=right>$v_date</td><td align=right>$rotation</td><td>";
	foreach (@equip){print "$_ ";}
	print "&nbsp;</td><td align=right>";
	print &deci($total,2);
	print "</td><td align=right>";
	($totalmo)=split(/:/,$totalmo);
	print &deci($totalmo,2);
	print "</td><td align=right>";
	print &deci($totalch,2);
	print "</td><td align=right>";
	print &deci($ingenico,2);
	print "</td><td align=right>";
	print &deci($am,2);
	print "</td><td align=right>";
	print &deci($diners,2);
	print "</td><td align=right>";
	print &deci($devise,2);
	print "</td><td align=right>";
	print &deci($papi,2);
	print "</td></tr>";
	$t_total+=$total;
	$t_totalmo+=$totalmo;
	$t_totalch+=$totalch;
	$t_ingenico+=$ingenico;
	$t_am+=$am;
	$t_diners+=$diners;
	$t_sabot+=$sabot;
	$t_devise+=$devise;
	$t_papi+=$papi;
}
print "<tr><td align=right><b>TOTAL</td><td align=right>&nbsp;</td><td align=right>&nbsp;</td><td>";
print "&nbsp;</td><td align=right><b>";
print &deci($t_total,2);
print "</td><td align=right><b>";
print &deci($t_totalmo,2);
print "</td><td align=right><b>";
print &deci($t_totalch,2);
print "</td><td align=right><b>";
print &deci($t_ingenico,2);
print "</td><td align=right><b>";
print &deci($t_am,2);
print "</td><td align=right><b>";
print &deci($t_diners,2);
print "</td><td align=right><b>";
print &deci($t_sabot,2);
print "</td><td align=right><b>";
print &deci($t_devise,2);
print "</td><td align=right><b>";
print &deci($t_papi,2);
print "</td></tr>";

print "</table></body></html>";
}
 
sub cheque{
print "
<html>
<body>
<br>
<br>
Saisie du <B>$date_du_jour</B><BR>
BORDEREAU <b>$border</b><br>

<table border=1 cellspacing=0 cellpadding=0 width=80%>
<tr><th>Nom</th><th>Banque</th><th>Ville</th><th>Montant</th></tr>";
$t_total=0;
$query="select ca_detail_cheque from caissesql where ca_border='$border'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($detail_cheque)=$sth->fetchrow_array){
	($null,@chequier)=split(/;/,$detail_cheque);
	foreach (@chequier){
		($banque,$ville,$nom,$montant)=split(/:/,$_);
		if ($montant>0){
			print "<tr><td>$nom</td><td>$banque</td><td>$ville</td><td align=right>";
			print &deci($montant,2);
			print "</td></tr>";
		}
		$t_total+=$montant;
	}
}
print "<tr><td align=right>&nbsp;</td><td align=right>&nbsp;</td><td align=right>&nbsp;</td><td align=right>";
print "<b>";
print &deci($t_total,2);
print "</td></tr>";

print "</table></body></html>";
}

sub espece{
print "
<html>
<body>
<br>
<br>
Saisie du <B>$date_du_jour</B><BR>
BORDEREAU <b>$border</b><br>
Compte _____ ______ ___ __<br>
Remettant:<br><br>
<table border=1 cellspacing=0 cellpadding=0 width=50%>
<caption><b>DETAIL ESPECES</caption>
<tr><th>Nb</th><th>Valeur</th><th>Total</th></tr>";
$t_monnaie,$t_monnaie5,$t_monnaie10,$t_monnaie20,$t_monnaie50,$t_monnaie100,$t_monnaie200,$t_monnaie500,$total=0;

$query="select ca_detail_monnaie from caissesql where ca_border='$border'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($detail_monnaie)=$sth->fetchrow_array){
		($monnaie,$monnaie5,$monnaie10,$monnaie20,$monnaie50,$monnaie100,$monnaie500,$monnaie200)=split(/:/,$detail_monnaie);
		$t_monnaie+=$monnaie;
		$t_monnaie5+=$monnaie5;
		$t_monnaie10+=$monnaie10;
		$t_monnaie20+=$monnaie20;
		$t_monnaie50+=$monnaie50;
		$t_monnaie100+=$monnaie100;
		$t_monnaie200+=$monnaie200;
		$t_monnaie500+=$monnaie500;
}
print "<tr><td align=right>$t_monnaie500</td><td align=right>500</td><td align=right>";
$total=$t_monnaie500*500;
$t_total=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>$t_monnaie200</td><td align=right>200</td><td align=right>";
$total=$t_monnaie200*200;
$t_total+=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>$t_monnaie100</td><td align=right>100</td><td align=right>";
$total=$t_monnaie100*100;
$t_total+=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>$t_monnaie50</td><td align=right>50</td><td align=right>";
$total=$t_monnaie50*50;
$t_total+=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>$t_monnaie20</td><td align=right>20</td><td align=right>";
$total=$t_monnaie20*20;
$t_total+=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>$t_monnaie10</td><td align=right>10</td><td align=right>";
$total=$t_monnaie10*10;
$t_total+=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>$t_monnaie5</td><td align=right>5</td><td align=right>";
$total=$t_monnaie5*5;
$t_total+=$total;
print &deci($total,2);
print "</td></tr>";
print "<tr><td align=right>&nbsp;</td><td align=right><b>TOTAL</td><td align=right><b>";
print &deci($t_total,2);
print "</td></tr>";
print "</table></body></html>";
}

# -E saisie des caisses fly
