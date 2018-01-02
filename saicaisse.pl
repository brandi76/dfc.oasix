#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";

$border=$html->param("border");
$appro=$html->param("appro");
$rotation=$html->param("rotation");

#$client=substr($border,0,3);
$client=$base_client;
$query="select cl_cd_cl,cl_nom from client where cl_cd_cl='$client'";
$sth=$dbh->prepare($query);
$sth->execute();
if (! (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array)){$client="___";}
$vol=$html->param("vol");
$vol_force=$html->param("vol_force");
$action=$html->param("action");
$date=$html->param("date");
$cc=$html->param("cc");
for ($i=1;$i<9;$i++){
	$par="pnc".$i;
	$pnc=$html->param($par);
	if ($pnc ne ""){push (@pnc,$pnc);}
}

for ($i=0;$i<11;$i++){
	$par1="montant".$i;
	$$par1=0;
}

$date_du_jour=`/bin/date '+%d/%m/%y'`;

$justificatif=$html->param("justificatif");
$annonce=$html->param("annonce");
# $bordereau_force=&get("select DAYOFYEAR(curdate())")+200000;
$bordereau_force=&get("select no from bordereau where date_creation=curdate()");
if ($bordereau_force eq ""){$bordereau_force=&get("select max(no) from bordereau")+1;}
if ($bordereau_force<2015001){$bordereau_force=2015001;}

$devise_id=&get("select dt_no from atadsql where dt_cd_dt=20");
$devise_tri=&get("select trigramme from devise where id='$devise_id'");
# ###############

if ($action eq ""){&page1();}
if ($action eq "Envoyer"){
#   $dernier_traitement=&get("select max(date_creation) from bordereau where date_creation!=curdate()");
#   $dernier_coffre=&get("select max(date) from coffre");
#   if ($dernier_coffre eq ""){$dernier_coffre="1970-01-01";}
#   # print "**",&get("select datediff('$dernier_coffre','$dernier_traitement')","aff");
#   if (&get("select datediff('$dernier_coffre','$dernier_traitement')")+0<0){
#     print "L'inventaire du coffre n'a pas été fait après le dernier traitement de caisse<br>";
#      print "<form action=kit.pl>";
#      print "<input type=hidden name=onglet value=0>";
#      print "<input type=hidden name=sous_onglet value=2>";
#      print "<input type=hidden name=sous_sous_onglet value=14>";
#      print "<input type=submit value='Comptage Coffre'></form>";		
#   }
#   else
#   {
    &verif();
#   }
}
if ($action eq "ok"){&saicaisse();}
# if ($action eq "Forcage"){&saicaisse();}
if ($action eq "valider"){&enregistre();}
if ($action eq "Bordereau"){&bordereau();}
if ($action eq "Relevé d'espece"){&espece();}

#### PREMIERE PAGE
sub page1{
print << "eof"
<html>
<body >
<h1> SAISIE DES CAISSES</h1>
<form>
<table border=0 width=50%>
<tr><td align=center >Bordereau <mark> Nouvelle numerotation 2015 commence par 2015xxx</mark></td><td align=center ><input type=text name=border size=8 value=\"$bordereau_force\"></td></tr>
<tr><td align=center >Appro </td><td align=center ><input type=text name=appro size=8 ></td></tr>
<tr><td align=center >Rotation </td><td align=center ><input type=text name=rotation value=1 size=2 ></td></tr>
<tr><td align=center >Chef de cabine </td><td align=center ><input type=text name=cc size=3 ></td></tr>
<tr><td align=center >Equipage</td><td align=center >
<input type=text name=pnc1 size=3 >
<input type=text name=pnc2 size=3 >
<input type=text name=pnc3 size=3 >
<input type=text name=pnc4 size=3 >
<input type=text name=pnc5 size=3 >
<input type=text name=pnc6 size=3 >
<input type=text name=pnc7 size=3 >
<input type=text name=pnc8 size=3 ></td></tr>
</table><br>
<input type=submit name=action value=Envoyer >
<input type=submit name=action value=Bordereau> 
<input type=submit name=action value="Relevé d'espece"> 
<input type=submit name=action value="Forcage">
</form>
eof
;
$pass=0;
$query="select * from bordereau where date_remise='0000-00-00' and date_creation>'2015-01-01' order by no";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no,$devise,$date)=$sth->fetchrow_array){
	if ($pass==0) { print "<div style=background-color:pink;>Bordereau en attente de saisie<br>";}
	$pass=1;
	print "Bordereau no:$no du $date devise:$devise<br>";
}
print "</div></body> </html>";

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
			&saicaisse();
			exit;
		}
	}	
	if ($border eq ""){
		$message="<font color=red size=+2>No Bordereau invalide</font>";
		$ok=0;
		}
	if (($border <1000)||($border >9999999)){
		$message="<font color=red size=+2><b>No Bordereau invalide</b></font>";
		$ok=0;
		}
	$check=&get("select max(no) from bordereau")+1;
	if ($border>$check){
		$message="<font color=red size=+2>No Bordereau invalide</font>";
		$ok=0;
	}
	if ($ok==0){
	print "<html>
	<body alink=white vlink=white link=white>
	<h1>VERIFICATION</h1>
	<form method=get  name=verif>
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
		if (($cc ne "")&&($cc ne "___")){
			$equipe="";
			foreach (@pnc){
				$equipe.=";".$_;
			}
			$query="replace into equipagesql values ('$appro','$rotation','$cc','$equipe')";
			$dbh->do($query);
		}
		saicaisse();
	}
}


sub saicaisse{
	$cours_ref=&get("select cours from devise where id='$devise_id'");
	$cours_xof=&get("select cours from devise where trigramme='XOF'")/$cours_ref;
	$cours_xaf=&get("select cours from devise where trigramme='XAF'")/$cours_ref;
	$cours_usd=&get("select cours from devise where trigramme='USD'")/$cours_ref;
	$cours_eur=&get("select cours from devise where trigramme='EUR'")/$cours_ref;
	
	$query="select ca_total,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_nbcb,ca_papi from caissesql where ca_code='$appro' and ca_rot='$rotation'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($total,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$total_cb,$nbcb,$stim)=$sth->fetchrow_array;
	$transfert="";
	if (&get("select tra_total from transfertcb where tra_code='$appro' and tra_rot='$rotation'")>0){$transfert="checked";}
	($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
	($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
	($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
	($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
	$xof_1+=0;
	$xof_2+=0;
	$xof_3+=0;
	$xof_4+=0;
	$xof_5+=0;
	$xaf_1+=0;
	$xaf_2+=0;
	$xaf_3+=0;
	$xaf_4+=0;
	$xaf_5+=0;
	$dol_1+=0;
	$dol_2+=0;
	$dol_3+=0;
	$dol_4+=0;
	$dol_5+=0;
	$dol_6+=0;
	$eur_1+=0;
	$eur_2+=0;
	$eur_3+=0;
	$eur_4+=0;
	$eur_5+=0;
	$eur_6+=0;
	$nbcb+=0;
	$total_cb+=0;
	$stim+=0;
	
	print "
	<html>
	<script>

	function cal_tot()
	{
		totala.innerHTML=Math.round(eval(xof.innerHTML)/".$cours_xof."+eval(xaf.innerHTML)/".$cours_xaf."+eval(eur.innerHTML)/".$cours_eur."+eval(dol.innerHTML)/".$cours_usd."+eval(document.fiche.total_cb.value)/".$cours_eur."+eval(document.fiche.stim.value));
		// totala.innerHTML=Math.round(eval(eur.innerHTML)+eval(dol.innerHTML)/1.35+document.fiche.total_cb.value);
		//alert(eur.innerHTML);
		//alert(totala.innerHTML);
	
	}
	function total_xof()
	{
		xof.innerHTML=eval(l_xof_1.innerHTML)+eval(l_xof_2.innerHTML)+eval(l_xof_3.innerHTML)+eval(l_xof_4.innerHTML)+eval(l_xof_5.innerHTML)+0;
		cal_tot();
	}
	function total_xaf()
	{
		xaf.innerHTML=eval(l_xaf_1.innerHTML)+eval(l_xaf_2.innerHTML)+eval(l_xaf_3.innerHTML)+eval(l_xaf_4.innerHTML)+eval(l_xaf_5.innerHTML)+0;
		cal_tot();
	}
	function total_dol()
	{
		dol.innerHTML=eval(l_dol_1.innerHTML)+eval(l_dol_2.innerHTML)+eval(l_dol_3.innerHTML)+eval(l_dol_4.innerHTML)+eval(l_dol_5.innerHTML)+eval(l_dol_6.innerHTML)+0;
		cal_tot();
	}
	function total_eur()
	{
		eur.innerHTML=eval(l_eur_1.innerHTML)+eval(l_eur_2.innerHTML)+eval(l_eur_3.innerHTML)+eval(l_eur_4.innerHTML)+eval(l_eur_5.innerHTML)+eval(l_eur_6.innerHTML)+0;
		cal_tot();
	}

	function recalcul()
	{
			l_xof_1.innerHTML=eval(document.fiche.xof_1.value)*10000+0;
			l_xof_2.innerHTML=eval(document.fiche.xof_2.value)*5000+0;
			l_xof_3.innerHTML=eval(document.fiche.xof_3.value)*2000+0;
			l_xof_4.innerHTML=eval(document.fiche.xof_4.value)*1000+0;
			l_xof_5.innerHTML=eval(document.fiche.xof_5.value)*500+0;
		
			l_xaf_1.innerHTML=eval(document.fiche.xaf_1.value)*10000;
			l_xaf_2.innerHTML=eval(document.fiche.xaf_2.value)*5000;
			l_xaf_3.innerHTML=eval(document.fiche.xaf_3.value)*2000;
			l_xaf_4.innerHTML=eval(document.fiche.xaf_4.value)*1000;
			l_xaf_5.innerHTML=eval(document.fiche.xaf_5.value)*500+0;
		
			l_dol_1.innerHTML=eval(document.fiche.dol_1.value)*50;
			l_dol_2.innerHTML=eval(document.fiche.dol_2.value)*20;
			l_dol_3.innerHTML=eval(document.fiche.dol_3.value)*10;
			l_dol_4.innerHTML=eval(document.fiche.dol_4.value)*5;
			l_dol_5.innerHTML=eval(document.fiche.dol_5.value)*2;
			l_dol_6.innerHTML=eval(document.fiche.dol_6.value)*1;
			
			l_eur_1.innerHTML=eval(document.fiche.eur_1.value)*100;
			l_eur_2.innerHTML=eval(document.fiche.eur_2.value)*50;
			l_eur_3.innerHTML=eval(document.fiche.eur_3.value)*20;
			l_eur_4.innerHTML=eval(document.fiche.eur_4.value)*10;
			l_eur_5.innerHTML=eval(document.fiche.eur_5.value)*5;
			l_eur_6.innerHTML=eval(document.fiche.eur_6.value)*1;
			
			cal_tot();
	}		
	function init()
	{
		recalcul();
		total_xof();
		total_xaf();
		total_dol();
		total_eur();
		cal_tot();
	}
	function setvar()
	{
		document.fiche.total.value=totala.innerHTML;
	}
	function confirmation()
	{
	resultat=confirm('Enregistrer les valeurs saisies ?');
	if(resultat !=\"1\") {return(false);} else {return(true);}
	}

	</script>
	<body onLoad=init()>
	<center>
	<h1> Saisie caisse </h1><br>

	<h3>$cl_nom Code appro:$appro  rotation:$rotation  $vol $cc @pnc</b></h3><br>
	Pour passer d'une case à l'autre utilisez la touche tab ou la souris<br>
	<form method=get  name=fiche Onsubmit=\"return confirmation()\">
	<table width=80%>
	<tr><td align=center >
		<table border=1>
			<caption><b>Francs UEMOA (XOF)</capion>
			<tr><th>Nombre</th><th>Monnaie</th><th>Total</th></tr>
			<tr><td align=center ><input type=text name=xof_1 size=4 value=\"$xof_1\" Onchange=\"recalcul();total_xof();\"></td><td align=center >10000 XOF </td> <td align=center ><div id=l_xof_1>0</div></td></tr>
			<tr><td align=center ><input type=text name=xof_2 size=4 value=\"$xof_2\" Onchange=\"recalcul();total_xof();\"></td><td align=center >5000 XOF </td> <td align=center ><div id=l_xof_2>0</div></td></tr>
			<tr><td align=center ><input type=text name=xof_3 size=4 value=\"$xof_3\" Onchange=\"recalcul();total_xof();\"></td><td align=center >2000 XOF </td> <td align=center ><div id=l_xof_3>0</div></td></tr>
			<tr><td align=center ><input type=text name=xof_4 size=4 value=\"$xof_4\" Onchange=\"recalcul();total_xof();\"></td><td align=center >1000 XOF </td> <td align=center ><div id=l_xof_4>0</div></td></tr>
			<tr><td align=center ><input type=text name=xof_5 size=4 value=\"$xof_5\" Onchange=\"recalcul();total_xof();\"></td><td align=center >500 XOF </td> <td align=center ><div id=l_xof_5>0</div></td></tr>
			<tr><td colspan=2 ><b>Total</b><td><div id='xof'>0</div></td></tr>

			</table>	
		</td><td align=center >
		<table border=1>
			<caption><b>Francs Afrique Central (XAF)</capion>
			<tr><th>Nombre</th><th>Monnaie</th><th>Total</th></tr>
			<tr><td align=center ><input type=text name=xaf_1 size=4 value=\"$xaf_1\" Onchange=\"recalcul();total_xaf();\"></td><td align=center >10000 xaf </td> <td align=center ><div id=l_xaf_1>0</div></td></tr>
			<tr><td align=center ><input type=text name=xaf_2 size=4 value=\"$xaf_2\" Onchange=\"recalcul();total_xaf();\"></td><td align=center >5000 xaf </td> <td align=center ><div id=l_xaf_2>0</div></td></tr>
			<tr><td align=center ><input type=text name=xaf_3 size=4 value=\"$xaf_3\" Onchange=\"recalcul();total_xaf();\"></td><td align=center >2000 xaf </td> <td align=center ><div id=l_xaf_3>0</div></td></tr>
			<tr><td align=center ><input type=text name=xaf_4 size=4 value=\"$xaf_4\" Onchange=\"recalcul();total_xaf();\"></td><td align=center >1000 xaf </td> <td align=center ><div id=l_xaf_4>0</div></td></tr>
			<tr><td align=center ><input type=text name=xaf_5 size=4 value=\"$xaf_5\" Onchange=\"recalcul();total_xaf();\"></td><td align=center >500 xaf </td> <td align=center ><div id=l_xaf_5>0</div></td></tr>
			<tr><td colspan=2 ><b>Total</b><td><div id='xaf'>0</div></td></tr>
	</table>
	</td></tr>
	<tr><td align=center >	
		<table border=1>
			<caption><b>Dollars américains USD</capion>
			<tr><th>Nombre</th><th>Monnaie</th><th>Total</th></tr>
			<tr><td align=center ><input type=text name=dol_1 size=4 value=\"$dol_1\" Onchange=\"recalcul();total_dol();\"></td><td align=center >50\$</td> <td align=center ><div id=l_dol_1>0</div></td></tr>
			<tr><td align=center ><input type=text name=dol_2 size=4 value=\"$dol_2\" Onchange=\"recalcul();total_dol();\"></td><td align=center >20\$</td> <td align=center ><div id=l_dol_2>0</div></td></tr>
			<tr><td align=center ><input type=text name=dol_3 size=4 value=\"$dol_3\" Onchange=\"recalcul();total_dol();\"></td><td align=center >10\$</td> <td align=center ><div id=l_dol_3>0</div></td></tr>
			<tr><td align=center ><input type=text name=dol_4 size=4 value=\"$dol_4\" Onchange=\"recalcul();total_dol();\"></td><td align=center >5\$</td> <td align=center ><div id=l_dol_4>0</div></td></tr>
			<tr><td align=center ><input type=text name=dol_5 size=4 value=\"$dol_5\" Onchange=\"recalcul();total_dol();\"></td><td align=center >2\$</td> <td align=center ><div id=l_dol_5>0</div></td></tr>
			<tr><td align=center ><input type=text name=dol_6 size=4 value=\"$dol_6\" Onchange=\"recalcul();total_dol();\"></td><td align=center >1\$</td> <td align=center ><div id=l_dol_6>0</div></td></tr>
			<tr><td colspan=2 ><b>Total</b><td><div id='dol'>0</div></td></tr>

		</table>	
		</td><td align=center >
		<table border=1>
			<caption><b>Euros</capion>
			<tr><th>Nombre</th><th>Monnaie</th><th>Total</th></tr>
			<tr><td align=center ><input type=text name=eur_1 size=4 value=\"$eur_1\" Onchange=\"recalcul();total_eur();\"></td><td align=center >100€</td> <td align=center ><div id=l_eur_1>0</div></td></tr>
			<tr><td align=center ><input type=text name=eur_2 size=4 value=\"$eur_2\" Onchange=\"recalcul();total_eur();\"></td><td align=center >50€</td> <td align=center ><div id=l_eur_2>0</div></td></tr>
			<tr><td align=center ><input type=text name=eur_3 size=4 value=\"$eur_3\" Onchange=\"recalcul();total_eur();\"></td><td align=center >20€</td> <td align=center ><div id=l_eur_3>0</div></td></tr>
			<tr><td align=center ><input type=text name=eur_4 size=4 value=\"$eur_4\" Onchange=\"recalcul();total_eur();\"></td><td align=center >10€</td> <td align=center ><div id=l_eur_4>0</div></td></tr>
			<tr><td align=center ><input type=text name=eur_5 size=4 value=\"$eur_5\" Onchange=\"recalcul();total_eur();\"></td><td align=center >5€</td> <td align=center ><div id=l_eur_5>0</div></td></tr>
			<tr><td align=center ><input type=text name=eur_6 size=4 value=\"$eur_6\" Onchange=\"recalcul();total_eur();\"></td><td align=center >1€</td> <td align=center ><div id=l_eur_6>0</div></td></tr>
			<tr><td colspan=2 ><b>Total</b><td><div id='eur'>0</div></td></tr>

		</table>	
	</td></tr>
	</table>		
	<table>
	<tr><th>Nombre Carte bancaire</th><th>Total</th></tr>
	<tr><td align=center ><input type=text name=nbcb size=4 value=\"$nbcb\" ></td><td align=center ><input type=text name=total_cb value=\"$total_cb\" Onchange=\"cal_tot()\"></td><td>Tranfert ok <input type=checkbox name=transfert $transfert></td></tr>
	<tr><td align=center colspan=2 >Stimulation $devise_tri<input type=text name=stim size=4 value=\"$stim\"  Onchange=\"cal_tot()\"></td></tr>
	
	</table>	
	<font size=+2> TOTAL: <span id=totala style=font-size:large>0</span> $devise_tri<br>";
	$check=&get("select max(montant) from bordereau where no='$border'","af")+0;
	if ($check>0){print "<span style=color:red>Caisse Remise en banque, modification non autorisée</span><br>";}
	else{
	print "<input type=submit value=valider Onclick=setvar()>";
	}
	print "<input type=hidden name=total value=0>
	";

	print "	<input type=hidden name=border value=$border>";
	print "	<input type=hidden name=appro value=$appro>";
	print "	<input type=hidden name=action value=valider>";
	print "<h2>Ecart de caisse </h2><br>";
	print "Montant indiqué par le PNC:<input type=texte name=annonce size=8><br>Justificatif<br> <textarea name=justificatif rows=4 cols=40></textarea>";
	print "<input type=hidden name=rotation value=$rotation>";
	print "</form></body></html>";
}

		
sub enregistre{
	&save("insert ignore into traceur value (now(),'saicaisse $appro',\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	$xof_1=$html->param("xof_1")+0;
	$xof_2=$html->param("xof_2")+0;
	$xof_3=$html->param("xof_3")+0;
	$xof_4=$html->param("xof_4")+0;
	$xof_5=$html->param("xof_5")+0;

	$xaf_1=$html->param("xaf_1")+0;
	$xaf_2=$html->param("xaf_2")+0;
	$xaf_3=$html->param("xaf_3")+0;
	$xaf_4=$html->param("xaf_4")+0;
	$xaf_5=$html->param("xaf_5")+0;
	
	$dol_1=$html->param("dol_1")+0;
	$dol_2=$html->param("dol_2")+0;
	$dol_3=$html->param("dol_3")+0;
	$dol_4=$html->param("dol_4")+0;
	$dol_5=$html->param("dol_5")+0;
	$dol_6=$html->param("dol_6")+0;

	$eur_1=$html->param("eur_1")+0;
	$eur_2=$html->param("eur_2")+0;
	$eur_3=$html->param("eur_3")+0;
	$eur_4=$html->param("eur_4")+0;
	$eur_5=$html->param("eur_5")+0;
	$eur_6=$html->param("eur_6")+0;

	
	$xof="$xof_1:$xof_2:$xof_3:$xof_4:$xof_5:";
	$xaf="$xaf_1:$xaf_2:$xaf_3:$xaf_4:$xaf_5:";
	$dol="$dol_1:$dol_2:$dol_3:$dol_4:$dol_5:$dol_6:";
	$eur="$eur_1:$eur_2:$eur_3:$eur_4:$eur_5:$eur_6:";

	$total=$html->param("total")+0;
	$total_cb=$html->param("total_cb")+0;
	$stim=$html->param("stim")+0;
	
	$nbcb=$html->param("nbcb")+0;
	
# 	 if ($xof!=":::::") {
		$sth=$dbh->prepare("insert ignore into bordereau values ('$border','XOF',curdate(),'','','','')");
		$sth->execute();
# 	}
# 	if ($xaf!="::::") {
		$sth=$dbh->prepare("insert ignore into bordereau values ('$border','XAF',curdate(),'','','','')");
		$sth->execute();
# 	}
# 	if ($dol!="::::::") {
		$sth=$dbh->prepare("insert ignore into bordereau values ('$border','USD',curdate(),'','','','')");
		$sth->execute();
# 	}
# 	if ($eur!="::::::") {
		$sth=$dbh->prepare("insert ignore into bordereau values ('$border','EUR',curdate(),'','','','')");
		$sth->execute();
# 	}
	
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	
	$query="replace into caissesql values ('$appro','$rotation','$border','$total','$xof','$xaf','$dol','$eur','$total_cb','$nbcb','$stim')";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	if ($html->param("transfert") eq "on"){
	  &save("replace into transfertcb value ('$appro','$rotation','$total_cb')");
	  }
	else
	  {
	  &save("delete from transfertcb  where tra_code='$appro' and tra_rot='$rotation'");
	}
	
	# ecart
	if ($justificatif ne ""){
		$query="replace into ecart_caisse values ('$appro','$rotation','$annonce','$justificatif')";
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	&page1();
}

sub entete {
	$t_total=0;
	$t_totalxof=0;
	$t_totalxaf=0;
	$t_totaldol=0;
	$t_totaleur=0;
	$t_total_cb=0;
	$t_stim=0;

	print "
	<h3>$cl_nom $client</h3>
	<br>
	<br>
	Saisie du <B>$date_du_jour</B><BR>
	BORDEREAU <b>$border</b><br>

	<table border=1 cellspacing=0 cellpadding=5>
	<tr><th>APPRO</th><th>DATE</th><th>ROT</th><th>C/C PNC</th><th>RECETTE</th><th>XOF</th><th>XAF</th><th>DOLLAR</th><th>EURO</th><th>CARTE</th><th>STIM</th></tr>";
}

sub bordereau{
	print "
	<html>
	<body>";
	&entete();
	$query="select ca_code,ca_rot,ca_total,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_nbcb,ca_papi from caissesql where ca_border='$border' order by ca_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$pass=0;
	while (($appro,$rotation,$total,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$total_cb,$nbcb,$stim)=$sth->fetchrow_array){
		($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
		($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
		($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
		($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
		$xof_1+=0;
		$xof_2+=0;
		$xof_3+=0;
		$xof_4+=0;
		$xof_5+=0;
		$xaf_1+=0;
		$xaf_2+=0;
		$xaf_3+=0;
		$xaf_4+=0;
		$xaf_5+=0;
		$dol_1+=0;
		$dol_2+=0;
		$dol_3+=0;
		$dol_4+=0;
		$dol_5+=0;
		$dol_6+=0;
		$eur_1+=0;
		$eur_2+=0;
		$eur_3+=0;
		$eur_4+=0;
		$eur_5+=0;
		$eur_6+=0;
		$nbcb+=0;
		$total_cb+=0;
		$stim+=0;

		$query="select v_vol,v_date,v_dest from vol where v_code='$appro' and v_rot='$rotation'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		if (! (($v_vol,$v_date,$v_dest)=$sth2->fetchrow_array)){$v_vol="vol inconnu";}
		$query="select eq_cc,eq_equipage from equipagesql where eq_code='$appro' and eq_rot='$rotation'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($eq_cc,$eq_equipage)=$sth2->fetchrow_array;
		if ($v_date%1000 != $mois_verif){
			if ($pass != 0){
				&total();
				&entete();

			}
		$pass=1;
		$mois_verif=$v_date%1000;
		}
		print "<tr><td align=center  align=right>$appro</td><td align=center  align=right>$v_date</td><td align=center  align=right>$rotation</td><td align=center >";
		
		print $eq_cc." ".$eq_equipage;
		print "</td><td align=center  align=right>";
		print &deci($total,2);
		print "</td><td align=center  align=right>";
		$total_xof=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
		$billetxof{"xof_1"}+=$xof_1;
		$billetxof{"xof_2"}+=$xof_2;
		$billetxof{"xof_3"}+=$xof_3;
		$billetxof{"xof_4"}+=$xof_4;
		$billetxof{"xof_5"}+=$xof_5;
		$total_xaf=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
		$billetxaf{"xaf_1"}+=$xaf_1;
		$billetxaf{"xaf_2"}+=$xaf_2;
		$billetxaf{"xaf_3"}+=$xaf_3;
		$billetxaf{"xaf_4"}+=$xaf_4;
		$billetxaf{"xaf_5"}+=$xaf_5;
		$total_dol=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
		$total_eur=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
		print &deci($total_xof,2);
		print "</td><td align=center  align=right>";
		print &deci($total_xaf,2);
		print "</td><td align=center  align=right>";
		print &deci($total_dol,2);
		print "</td><td align=center  align=right>";
		print &deci($total_eur,2);
		print "</td><td align=center  align=right>";
		print &deci($total_cb,2);
		print "</td><td align=center  align=right>";
		print &deci($stim,2);
		print "</td></tr>";
		$t_total+=$total;
		$t_totalxof+=$total_xof;
		$t_totalxaf+=$total_xaf;
		$t_totaldol+=$total_dol;
		$t_totaleur+=$total_eur;
		$t_total_cb+=$total_cb;
		$t_stim+=$stim;
	
	}
	&total();
	print "<br><br>Recap hors stim/cb<br>";
	$total=0;
	if ($t_totalxof>0){print "$t_totalxof XOF <bR>";$total+=$t_totalxof;}
	if ($t_totalxaf>0){print "$t_totalxaf XAF <bR>";$total+=$t_totalxaf;}
	if ($t_totaldol>0){
		$contre=int($t_totaldol*480);
		print "$t_totaldol USD  Contre valeur :$contre<bR>";
		$total+=$contre;
	}
	if ($t_totaleur>0){
		$contre=int($t_totaleur*655.957);
		print "$t_totaleur EUR  Contre valeur :$contre<bR>";
		$total+=$contre;
	}	
	print "Total:$total XOF/XAF";
	print "<br><br>Billeterie";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Valeur billet</th><th>Xof</th></tr>";
	print "<tr><td align=right>10000</td><td align=right>";
	print $billetxof{"xof_1"};
	print "</td></tr>";
	print "<tr><td align=right>5000</td><td align=right>";
	print $billetxof{"xof_2"};
	print "</td></tr>";
	print "<tr><td align=right>2000</td><td align=right>";
	print $billetxof{"xof_3"};
	print "</td></tr>";
	print "<tr><td align=right>1000</td><td align=right>";
	print $billetxof{"xof_4"};
	print "</td></tr>";
	print "<tr><td align=right>500</td><td align=right>";
	print $billetxof{"xof_5"};
	print "</td></tr>";
	print "<tr><th>Total</th><td align=right><b>$t_totalxof</b></td></tr>";
	print "</table>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Valeur billet</th><th>Xaf</th></tr>";
	print "<tr><td align=right>10000</td><td align=right>";
	print $billetxaf{"xaf_1"};
	print "</td></tr>";
	print "<tr><td align=right>5000</td><td align=right>";
	print $billetxaf{"xaf_2"};
	print "</td></tr>";
	print "<tr><td align=right>2000</td><td align=right>";
	print $billetxaf{"xaf_3"};
	print "</td></tr>";
	print "<tr><td align=right>1000</td><td align=right>";
	print $billetxaf{"xaf_4"};
	print "</td></tr>";
	print "<tr><td align=right>500</td><td align=right>";
	print $billetxaf{"xaf_5"};
	print "</td></tr>";
	print "<tr><th>Total</th><td align=right><b>$t_totalxaf</b></td></tr>";
	print "</table>";
	print "<form action=kit.pl>";
	print "<input type=hidden name=onglet value=0>";
	print "<input type=hidden name=sous_onglet value=2>";
	print "<input type=hidden name=sous_sous_onglet value=14>";
  	print "<br>Dernier traitement de la journée ?<input type=submit value=oui> <input type=button value=non onclick=self.close()></form>";		
			
	print "</body></html>";
}
	
sub total{
	$t_total+=0;
	$t_totalxof+=0;
	$t_totalxaf+=0;
	$t_totaldol+=0;
	$t_totaleur+=0;
	$t_total_cb+=0;
	$t_stim+=0;

	print "<tr><td align=center  align=right><b>TOTAL</td><td align=center  align=right>&nbsp;</td><td align=center  align=right>&nbsp;</td><td align=center >";
	print "&nbsp;</td><td align=center  align=right><b>";
	print &deci($t_total,2);
	print "</td><td align=center  align=right><b>";
	print &deci($t_totalxof,2);
	print " xof</td><td align=center  align=right><b>";
	print &deci($t_totalxaf,2);
	print " xaf</td><td align=center  align=right><b>";
	print &deci($t_totaldol,2);
	if ($t_totaldol!=0){print " \$";}
	print " </td><td align=center  align=right><b>";
	print &deci($t_totaleur,2);
	if ($t_totaleur!=0){print " €";}
	print " </td><td align=center  align=right><b>";
	print &deci($t_total_cb,2);
	print " </td><td align=center  align=right><b>";
	print &deci($t_stim,2);
	print "</td></tr>";
	print "</table>";
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
	Remettant:<br><br>";
	$query="select ca_xof,ca_xaf,ca_dol,ca_eur from caissesql where ca_border='$border'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ca_xof,$ca_xaf,$ca_dol,$ca_eur)=$sth->fetchrow_array){
		($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
		($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
		($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
		($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
		$t_xof_1+=$xof_1;
		$t_xof_2+=$xof_2;
		$t_xof_3+=$xof_3;
		$t_xof_4+=$xof_4;
		$t_xof_5+=$xof_5;

		$t_xaf_1+=$xaf_1;
		$t_xaf_2+=$xaf_2;
		$t_xaf_3+=$xaf_3;
		$t_xaf_4+=$xaf_4;
		$t_xaf_5+=$xaf_5;

		$t_dol_1+=$dol_1;
		$t_dol_2+=$dol_2;
		$t_dol_3+=$dol_3;
		$t_dol_4+=$dol_4;
		$t_dol_5+=$dol_5;
		$t_dol_6+=$dol_6;

		$t_eur_1+=$eur_1;
		$t_eur_2+=$eur_2;
		$t_eur_3+=$eur_3;
		$t_eur_4+=$eur_4;
		$t_eur_5+=$eur_5;
		$t_eur_6+=$eur_6;
	}
			
	print "<table border=1 cellspacing=0 cellpadding=0 width=400>
	<caption><b>DETAIL XOF</caption>
	<tr><th>Nb</th><th>Valeur</th><th>Total</th></tr>";
	$total=0;
	
	$nb=$t_xof_1+0;
	$billet=10000;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_xof_2+0;
	$billet=5000;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$billet=2000;
	$nb=$t_xof_3+0;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_xof_4+0;
	$billet=1000;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	$nb=$t_xof_5+0;
	$billet=500;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	print "<tr><td align=center  align=right>&nbsp;</td><td align=center  align=right><b>TOTAL</td><td align=right><b>";
	print &deci($total,2);
	print "</td></tr>";

	print "</table>";
	print "<div style=page-break-after:right;></div>";
	print "<br>
	Saisie du <B>$date_du_jour</B><BR>
	BORDEREAU <b>$border</b><br>
	Compte _____ ______ ___ __<br>
	Remettant:<br><br>";
	
	print "<table border=1 cellspacing=0 cellpadding=0 width=400>
	<caption><b>DETAIL XAF</caption>
	<tr><th>Nb</th><th>Valeur</th><th>Total</th></tr>";
	$total=0;
	
	$nb=$t_xaf_1+0;
	$billet=10000;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_xaf_2+0;
	$billet=5000;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$billet=2000;
	$nb=$t_xaf_3+0;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_xaf_4+0;
	$billet=1000;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_xaf_5+0;
	$billet=500;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	print "<tr><td align=center  align=right>&nbsp;</td><td align=center  align=right><b>TOTAL</td><td align=right><b>";
	print &deci($total,2);
	print "</td></tr>";

	
	print "</table>";
	print "<div style=page-break-after:right;></div>";
	
	print "<br>
	Saisie du <B>$date_du_jour</B><BR>
	BORDEREAU <b>$border</b><br>
	Compte _____ ______ ___ __<br>
	Remettant:<br><br>";

	print "<table border=1 cellspacing=0 cellpadding=0 width=400>
	<caption><b>DETAIL DOLLARS</caption>
	<tr><th>Nb</th><th>Valeur</th><th>Total</th></tr>";
	$total=0;
	
	$nb=$t_dol_1+0;
	$billet=50;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_dol_2+0;
	$billet=20;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$billet=10;
	$nb=$t_dol_3+0;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_dol_4+0;
	$billet=5;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	$nb=$t_dol_5+0;
	$billet=2;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	$nb=$t_dol_6+0;
	$billet=1;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	print "<tr><td align=center  align=right>&nbsp;</td><td align=center  align=right><b>TOTAL</td><td align=right><b>";
	print &deci($total,2);
	print "</td></tr>";

	print "</table>";
	print "<div style=page-break-after:right;></div>";
	print "<br>
	Saisie du <B>$date_du_jour</B><BR>
	BORDEREAU <b>$border</b><br>
	Compte _____ ______ ___ __<br>
	Remettant:<br><br>";
	
	print "<table border=1 cellspacing=0 cellpadding=0 width=400>
	<caption><b>DETAIL EUROS</caption>
	<tr><th>Nb</th><th>Valeur</th><th>Total</th></tr>";
	$total=0;
	
	$nb=$t_eur_1+0;
	$billet=100;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_eur_2+0;
	$billet=50;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$billet=20;
	$nb=$t_eur_3+0;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";
	
	$nb=$t_eur_4+0;
	$billet=10;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	$nb=$t_eur_5+0;
	$billet=5;
	$val=$nb*$billet;
	$total+=$val;
	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	$nb=$t_eur_6+0;
	$billet=1;
	$val=$nb*$billet;
	$total+=$val;

	print "<tr><td align=right>$nb</td><td align=center>$billet</td><td align=right>";
	print &deci($val,2);
	print "</td></tr>";

	print "<tr><td align=center  align=right>&nbsp;</td><td align=center  align=right><b>TOTAL</td><td align=right><b>";
	print &deci($total,2);
	print "</td></tr>";

	print "</table>";
	
	print "</body></html>";
}

# -E saisie des caisses fly
