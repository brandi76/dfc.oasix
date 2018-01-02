#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\"
lang=\"fr\">
<head>
<meta http-equiv=\"content-Type\" content=\"text/html; charset=iso-8859-15\" />
<style type=\"text/css\" >
body
{
	font-family:'Times New Roman';
	font-size:12pt;
	margin:0px;
	padding:0px
	}
.page
{
	border: 0.05cm solid black;
	//background-color: #d0ac96;
	width:21.05cm;
	height:29.7cm;
	page-break-after:always;
	}
.cartouche
{
	clear:both;
	border:0.05cm solid black;
	//background-color:green;
	width:21cm;
	height:3.4cm;
	overflow:hidden;
}
.corps
{
	clear:both;
	border: 0.05cm solid black;
//	background-color: blue;
	width:21cm;
	height:23.9cm;
	overflow:hidden;
}
.pied
{
	clear:both;
	border: 0.05cm solid black;
	//background-color:yellow;
	width:21cm;
	height:1.8 cm;
	overflow:hidden;
	padding:10px 0px;
}
.car1_1
{
	clear:both;
	float: left;
	height:0.6cm;
	//background-color: #E6E2AF;
	overflow:hidden;
	margin-left:0.2cm;
	width:5.8cm;
	border-bottom:1px solid black;
}
.car1_2
{
	float: left;
	height:0.6cm;
	//background-color: #A7A37E;
	overflow:hidden;
	width:9cm;
	text-align:center;
	border-bottom:1px solid black;
}
.car1_3
{
	float: left;
	height:0.6cm;
	//background-color: #046380;
	overflow:hidden;
	width:5.8cm;
	text-align:right;
	border-bottom:1px solid black;
}
.car2_1
{
	clear:both;
	float: left;
	height:1.2cm;
	//background-color: #E6E2AF;
	overflow:hidden;
	margin-left:0.2cm;
	width:3.5cm;
	border-bottom:1px solid black;
}
.car2_2
{
	float: left;
	height:1.2cm;
	//background-color: #A7A37E;
	overflow:hidden;
	width:3.45cm;
	border-bottom:1px solid black;
}
.car2_3
{
	float: left;
	height:1.2cm;
	//background-color: #046380;
	overflow:hidden;
	width:5cm;
	border-bottom:1px solid black;
}
.car2_4
{
	float: left;
	height:1.2cm;
	//background-color: #002F2F;
	overflow:hidden;
	width:4.3cm;
	border-bottom:1px solid black;
}
.car2_5
{
	float: left;
	height:1.2cm;
	//background-color: red;
	overflow:hidden;
 	width:4.35cm;
	border-bottom:1px solid black;
}
.car3_1
{
	clear:both;
	float: left;
	height:1.6cm;
	//background-color: #002F2F;
	overflow:hidden;
 	width:3cm;
	margin-left:0.2cm;
}
.car3_x
{
	float: left;
	height:1.6cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:4.4cm;
}
.corps1_1
{
	clear: both;
	float: left;
	margin-left:0.2cm;
	height:0.4cm;
	//background-color: #yellow;
	overflow:hidden;
 	width:5.95cm;
	border-bottom:1px solid black;
	border-top:1px solid black;
	font-size: 10pt;
}
.corps1_2
{
	float: left;
	height:0.4cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:1.98cm;
	border-left:1px solid black;
	border-bottom:1px solid black;
	border-top:1px solid black;
	font-size: 10pt;
	text-align:center;
}
.corps1_3
{
	float: left;
	height:0.4cm;
	//background-color: #red;
	overflow:hidden;
 	width:2.3cm;
	border-left:1px solid black;
	border-bottom:1px solid black;
	border-top:1px solid black;
	font-size: 10pt;
}
.corpsx_1
{
	clear: both;
	float: left;
	margin-left:0.2cm;
	height:0.4cm;
	//background-color: #yellow;
	overflow:hidden;
 	width:5.95cm;
	border-bottom:1px solid black;
	font-size: 10pt;
}
.corpsx_2
{
	float: left;
	height:0.4cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:1.98cm;
	border-left:1px solid black;
	border-bottom:1px solid black;
	font-size: 10pt;
	text-align:center;
}
.corpsx_3
{
	float: left;
	height:0.4cm;
	//background-color: #red;
	overflow:hidden;
 	width:2.3cm;
	border-left:1px solid black;
	border-bottom:1px solid black;
	font-size: 8pt;
	text-align:center;
}

.pied1_1
{
	clear: both;
	float: left;
	margin-left:0.2cm;
	height:0.4cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border-bottom:1px solid black;
	border-left:1px solid black;
	border-top:1px solid black;
	font-size: 10pt;
	text-align:center;

}
.pied1_2
{
	float: left;
	height:0.4cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:3.2cm;
	border-left:1px solid black;
	border-top:1px solid black;
	border-bottom:1px solid black;
	font-size: 10pt;
	text-align:center;
	text-align:center;

}
.pied1_3
{
	float: left;
	height:0.4cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:3.4cm;
	border-left:1px solid black;
	border-top:1px solid black;
	border-right:1px solid black;
	border-bottom:1px solid black;
	font-size: 10pt;
	text-align:center;
	text-align:center;

}

.piedx_1
{
	clear: both;
	float: left;
	margin-left:0.2cm;
	height:0.4cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border-bottom:1px solid black;
	border-left:1px solid black;
	font-size: 10pt;
	text-align:center;

}
.piedx_2
{
	float: left;
	height:0.4cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:3.2cm;
	border-left:1px solid black;
	border-bottom:1px solid black;
	font-size: 10pt;
	text-align:center;
	text-align:center;

}
.piedx_3
{
	float: left;
	height:0.4cm;
	//background-color: #efefef;
	overflow:hidden;
 	width:3.4cm;
	border-left:1px solid black;
	border-right:1px solid black;
	border-bottom:1px solid black;
	font-size: 10pt;
	text-align:center;
	text-align:center;

}
.mab1_1
{
	clear:both;
	float: left;
	height:1cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.mab1_x
{
	float: left;
	height:1cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}

.mab2_1
{
	clear:both;
	float: left;
	height:4cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.mab2_x
{
	float: left;
	height:4cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.rdc1_1
{
	clear:both;
	float: left;
	height:1cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.rdc1_x
{
	float: left;
	height:1cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}

.rdc2_1
{
	clear:both;
	float: left;
	height:4cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.rdc2_x
{
	float: left;
	height:4cm;
	//background-color: yellow;
	overflow:hidden;
 	width:4cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.caisse1_1
{
	clear:both;
	float: left;
	height:1cm;
	//background-color: yellow;
	overflow:hidden;
 	width:2cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
.caisse1_x
{
	float: left;
	height:1cm;
	//background-color: yellow;
	overflow:hidden;
 	width:2cm;
	border:1px solid black;
	font-size: 12pt;
	text-align:center;
}
	

</style></head>";
require "./src/connect.src";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);

$action=$html->param('action');
$nodepart=$html->param('nodepart');
print "<body>";
$nodepart=1547;
$query="select geslot.* from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot limit 1";
$sth=$dbh->prepare($query);
$sth->execute();
# boucle sur listevol
while (($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array)
	{
	$query="select cl_nom,cl_trilot from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";

	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_nom,$cl_trilot)=$sth2->fetchrow_array;
	$nolot=$gsl_nolot;
	$query="select vol.* from vol where v_code='$gsl_apcode' order by v_rot";
	$sth3=$dbh->prepare($query);
	$sth3->execute();

	########## BOUCLE SUR VOL #############

	while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=$sth3->fetchrow_array)
	{
		$query="select flb_depart from flybody,flyhead where fl_apcode='$gsl_apcode' and fl_vol=flb_vol and fl_date=flb_date and flb_rot=11";
		#print $query;
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($flb_depart)=$sth2->fetchrow_array;
		$depart=substr($flb_depart,0,2).'.'.substr($flb_depart,2,2);
		print "<div class=\"page\">";
		&cartouche_appro();
		&bon_appro();
		print "</div>";
		print "<div class=\"page\">";
		&cartouche_appro();
		&bon_appro();
		print "</div>";
		print "<div class=\"page\">";
		&mise_a_bord();
		&remise_de_caisse();
		print "</div>";
		print "<div class=\"page\">";
		&mise_a_bord();
		&remise_de_caisse();
		print "</div>";
		print "<div class=\"page\">";
		&fiche_de_caisse();
		print "</div>";
		print "<div class=\"page\">";
		&fiche_de_caisse();
		print "</div>";
	} # fin boucle vol
} # fin boucle listevol

print "</body></html>";

sub cartouche_appro {
	print "<div class=\"cartouche\">";
	print "
	<div class=car1_1>$cl_nom</div>
	<div class=car1_2>BON D'APPROVISIONNEMENT </div>
	<div class=car1_3>No <strong>$gsl_apcode</strong> du $jour/$mois/$an</div>
	<div class=car2_1>Lot no <br /><strong>$nolot</strong></div>
	<div class=car2_2>No vol <br />rot no:$v_rot :$v_vol</div>
	<div class=car2_3>DESTINATION<br />$v_dest</div>
	<div class=car2_4>DATE<br />";
	print &julian($v_date_jl,"DD/MM/YY");
	print "</div>
	<div class=car2_5>HEURE CHARG<br />$depart</div>
	<div class=car3_1>C/C:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	";
	print "</div>";

}
############### BON APPRO ########################
sub bon_appro{
	print "<div class=\"corps\">";
	print "
	<div class=corpsx_1>Designation</div>
	<div class=corpsx_2>Stock Départ</div>
	<div class=corpsx_2>Check PNC</div>
	<div class=corpsx_2>Stock Retour</div>
	<div class=corpsx_2>Vendus</div>
	<div class=corpsx_2>Prix</div>
	<div class=corpsx_2>Montant</div>
	<div class=corpsx_3>Stock ASKY/FNO</div>
	";

	
		$query="select appro.*,pr_desi,pr_type,tr_tiroir,pr_pdb from appro,produit,trolley where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr and tr_code='$v_troltype' and ap_cd_pr=tr_cd_pr order by tr_tiroir,ap_ordre";
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		# boucle sur appro
		$val=0;
		$total=0;
		$poids=690;
		while (($ap_code,$ap_ordre,$ap_cd_pr,$ap_prix,$ap_qte0,$ap_cd_pos,$ap_cd_cl,$pr_desi,$pr_type,$tr_tiroir,$pr_pdb)=$sth4->fetchrow_array)
		{
			$css="corpsx";
			if ($tr_tiroir != $tiroir){
			 	if ($total!=0){print "<div style=\"clear:both;\">Nombre de Produit tiroir $tiroir :$total $br</div>";}
			 	$css="corps1";
				$total=0;
			 	$poids=690;
			 	$tiroir=$tr_tiroir;
				
			}
			 
			$ap_qte0=$ap_qte0-$tr_qte;
			$total+=int($ap_qte0/100);
			$poids+=int($ap_qte0/100)*$pr_pdb;
			print "
			<div class=${css}_1>$pr_desi</div>
			<div class=${css}_2>";
			if ($v_rot==1){print int($ap_qte0/100);}
			print "</div>
			<div class=${css}_2></div>
			<div class=${css}_2></div>
			<div class=${css}_2></div>
			<div class=${css}_2> ";
			print int($ap_prix/100);
			print " E</div>
			<div class=${css}_2></div>
			<div class=${css}_3></div>
			";
			$val=$val+$ap_prix*$ap_qte0;
		} # fin boucle appro
 		if ($total!=0){print "<div style=\"clear:both;\">Nombre de Produit tiroir $tiroir :$total $br</div>";}
		print "<div style=\"position:relative;left:13cm;top:-0.4cm;\"><strong>TOTAL VENTES:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EU</strong></div>";
		print "</div>";
		print "<div class=pied>";
		print "<div class=pied1_1>No plomb depart</div>";
		print "<div class=pied1_2>Escale 1</div>";
		print "<div class=pied1_2>Escale 2</div>";
		print "<div class=pied1_2>Escale 3</div>";
		print "<div class=pied1_2>Escale 4</div>";
		print "<div class=pied1_3>Arrivée LFW asky/finaero</div>";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "<div class=piedx_1>${$var}</div>";
			print "<div class=piedx_2></div>";
			    print "<div class=piedx_2></div>";
			print "<div class=piedx_2></div>";
			print "<div class=piedx_2></div>";
			print "<div class=piedx_3></div>";
		}
		print "</div>";
}




sub mise_a_bord {
	print "<div class=\"cartouche\">";
	print "
	<div class=car1_1></div>
	<div class=car1_2><strong>$v_code</strong></div>
	<div class=car1_3></div>
	<div class=car2_1>Lot no <br /><strong>$nolot</strong></div>
	<div class=car2_2>No vol <br />rot no:$v_rot :$v_vol</div>
	<div class=car2_3>DESTINATION<br />$v_dest</div>
	<div class=car2_4>DATE<br />";
	print &julian($v_date_jl,"DD/MM/YY");
	print "</div>
	<div class=car2_5>HEURE CHARG<br />$depart</div>
	";
	print "</div>";
	
	print "<br>1ER EXEMPLAIRE POUR FINAERO / 2E EX C/C ASKY<br><br><br>";
	print "<center>MISE A BORD</center><br><br><br>";
	print "<div style=\"padding:10px;\">";
	print "<div class=\"mab1_1\" >VISA ASKY DEPART</div>";
	print "<div class=\"mab1_x\">VISA FINAERO DEPART</div>";
	print "<div class=\"mab1_x\">VISA RETOUR FINAERO</div>";
	print "<div class=\"mab1_x\">VISA ASKY  RETOUR</div>";
	print "<div class=\"mab2_1\" ></div>";
	print "<div class=\"mab2_x\"></div>";
	print "<div class=\"mab2_x\"></div>";
	print "<div class=\"mab2_x\"></div>";
	print "</div>";
	print "<div style=clear:both;><br>ECARTS OU SUGGESTION:</div>";

	}
sub remise_de_caisse {
	print "<br><br><center>REMISE DE CAISSE</center><br><br><br>";
	print "<div style=\"padding:10px;\">";
	print "<div class=\"rdc1_1\" >Num d.enve</div>";
	print "<div class=\"rdc1_x\">Num appro</div>";
	print "<div class=\"rdc1_x\">date des vols</div>";
	print "<div class=\"rdc1_x\"> NOM+TRIGRAM C/C</div>";
	print "<div class=\"rdc1_x\"> ASKY NOM AGENT FINAERO</div>";
	print "<div class=\"rdc2_1\" ></div>";
	print "<div class=\"rdc2_x\"></div>";
	print "<div class=\"rdc2_x\"></div>";
	print "<div class=\"rdc2_x\"></div>";
	print "<div class=\"rdc2_x\"></div>";
	print "</div>";
	print "<div style=clear:both;><br>DATE DE LA REMISE:</div>";

}

sub fiche_de_caisse {
	print "<div class=\"cartouche\">";
	print "
	<div class=car1_1>$cl_nom</div>
	<div class=car1_2>FICHE DE CAISSE</div>
	<div class=car1_3>No <strong>$gsl_apcode</strong> du $jour/$mois/$an</div>
	<div class=car2_1>Lot no <br /><strong>$nolot</strong></div>
	<div class=car2_2>No vol <br />rot no:$v_rot :$v_vol</div>
	<div class=car2_3>DESTINATION<br />$v_dest</div>
	<div class=car2_4>DATE<br />";
	print &julian($v_date_jl,"DD/MM/YY");
	print "</div>
	<div class=car2_5>HEURE CHARG<br />$depart</div>
	<div class=car3_1>C/C:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	<div class=car3_x>PNC:<br /><span style=\"position:relative;top:0.2cm;\">PNC:</span></div>
	";
	print "</div>";
	print "<div style=clear:both;><br>Le premier et le deuxieme exemplaire vont dans l'enveloppe de caisse.</div>";
	print "<div style=\"padding:10px;position:relative;top:2cm;left:2cm\">";
	print "<div class=\"caisse1_1\" ></div>";
	print "<div class=\"caisse1_x\">PIECES</div>";
	print "<div class=\"caisse1_x\">5e</div>";
	print "<div class=\"caisse1_x\">10e</div>";
	print "<div class=\"caisse1_x\">20e</div>";
	print "<div class=\"caisse1_x\">50e</div>";
	print "<div class=\"caisse1_x\">100e</div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_1\" >NB</div>";
	print "<div class=\"caisse1_x\">XXXXXXXX</div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\">TOTAL EUROS</div>";
	print "<div class=\"caisse1_1\" >TOTAL</div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "<div class=\"caisse1_x\"></div>";
	print "</div>";
	print "<div style=\"padding:10px;position:relative;top:3cm;left:2cm\">";
	print "<div class=\"rdc1_1\" >DEVISES</div>";
	print "<div class=\"rdc1_x\">TAUX</div>";
	print "<div class=\"rdc1_x\">NOMBRE</div>";
	print "<div class=\"rdc1_x\">VALEUR EU</div>";
	print "<div class=\"rdc1_1\" >USD</div>";
	print "<div class=\"rdc1_x\">0.740</div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_1\" >CFA XAF</div>";
	print "<div class=\"rdc1_x\">0.0015</div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_1\" >CFA XOF</div>";
	print "<div class=\"rdc1_x\">0.0015</div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_1\" ></div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_x\">TOTAL EUROS</div>";
	print "<div class=\"rdc1_x\"></div>";
	print "</div>";
	print "<div style=\"clear:both;padding:10px;position:relative;top:3.5cm;left:6cm\">";
	print "<div class=\"rdc1_1\" ></div>";
	print "<div class=\"rdc1_x\">CARTES BANCAIRES</div>";
	print "<div class=\"rdc1_1\" >NB</div>";
	print "<div class=\"rdc1_x\"></div>";
	print "<div class=\"rdc1_1\" >TOTAL</div>";
	print "<div class=\"rdc1_x\"></div>";
	print "</div>";
	print "<div style=clear:both;position:relative;top:5cm;>";
	print "MONTANT CAISSE    :<br>TOTAL VENTES      :<br>DIFFERENCE        :<br><br>";
	print "ENVELOPPE DE CAISSE No:<br>SIGNATURE DU CHEF DE CABINE:";
	print "</div>";
	}


