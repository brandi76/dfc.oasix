#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$user = &user(); 
require "./src/connect.src";

$devise_id=&get("select dt_no from atadsql where dt_cd_dt=20");
$devise_tri=&get("select trigramme from devise where id='$devise_id'");
print $html->header;

# Gestion des commandes -->  creation 	--> confirmer 	--> saisie
#			-->  edition  	--> facture
#					--> notededetail
#					--> article 111


$date = `/bin/date '+%d%m%y'`;    
chop($date);   


$action=$html->param("action");
$commande=$html->param("commande");
if (($action ne "edi_facture")&&($action ne "note")){
	print "<html><body>";
	&tete("Gestion des Commandes","");
} 

if ($action eq ""){
	&premiere_page();
}

if ($action eq "premiere_page"){
	$commande=&plus1("/home/sylvain/ibs/atad.txt","commande");
	&creation();
}
	
if ($action eq "creation"){
	&confirmer();
}

if ($action eq "confirmer"){
	$ligne=$commande.";".$html->param("client").";".$html->param("nom").";".$html->param("createur").";".$date.";";
	&ajoute_n("/home/sylvain/ibs/commande.dsc","$ligne",0);
	&entete();
	&saisie();
	print "</body></html>";

}

if ($action eq "saisie"){
	&maj();
	&entete();
	print "<table border=1><tr><td>";
	print "<font  face=\"Courier\">";
	&edition();
	print "</font>";
	print "</td></tr></table>";
	if ($erreur eq "oui"){print "<br><font color=red>Commande protégée , votre mise à jour ne sera pas prise en compte</font></br>";}
	&saisie();
	print "<br>";
	print "<a href=saisie.pl?action=facture&commande=$commande>Facture</a>",&espace(2);
	print "<a href=saisie.pl?action=note&commande=$commande>Notededetail</a>",&espace(2);
	print "<a href=saisie.pl?action=a111&commande=$commande>Article 111</a>",&espace(2);
}	

if ($action eq "voir"){
	&voir();
}
if ($action eq "edition"){
	&entete();
	print "<table border=1><tr><td>";
	print "<font  face=\"Courier\">";
	&edition();
	print "</font>";
	print "</td></tr></table>";
	print "<br>";
	print "<a href=saisie.pl?action=facture&commande=$commande>Facture</a>",&espace(2);
	print "<a href=saisie.pl?action=saisie&commande=$commande>Modification</a>",&espace(2);
	print "<a href=saisie.pl?action=note&commande=$commande>Notededetail</a>",&espace(2);
	print "<a href=saisie.pl?action=a111&commande=$commande>Article 111</a>",&espace(2);
}


if ($action eq "facture"){
	&in_facture();
}

if ($action eq "edi_facture"){
	&facture();
}
if ($action eq "note"){
	&note();
}


print "</body></html>";


sub facture {
	$facture=$html->param(facture);
        print "<html><body><br><BR><BR><br><br><br><br><br>";
	print "<font  face=\"Courier\">";
	print &espace(56),date($date)."<br>";
	print &espace(56),"Facture N°:$facture<br><br>";
	$query="select cl_cd_cl,cl_nom from client where cl_cd_cl='$code_client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_cd_cl,$cl_nom)=$sth->fetchrow_array;
	if ($code_client eq ""){print "<font color=red size=+1>* Commande $commande inconnu</font><br>";}
	if (($code_client ne "")&&($cl_cd_cl eq "")){print "<font color=red size=+1>Client $code_client inconnu</font><br>";}
	print &espace(56),"Commande N°:$commande<br>";
	print &espace(56),"$cl_cd_cl<br>",&espace(56),"$cl_nom<br>",&espace(56),"$nom<br>",&espace(56),"$cl_rue<br>",&espace(56),"$cl_ville<br><br><br><br><BR><BR><BR><BR><BR><BR>";
	&edition();
	for ($i=$nbligne;$i<20;$i++){print "<br>";}
	print &espace(50),"TOTAL HT :";
	print &taillefixe(&deci2($total),10);
	print " $devise_tri<br>";
	if ($html->param("tva") eq "oui" ){
		print &espace(50),"TVA 19.6 :";
		$tva=$total*19.6/100;
		print &taillefixe(&deci2($tva),10);
		print "<br>",&espace(50),"TOTAL TTC:";
		$total+=$tva;
		print &taillefixe(&deci2($total),10);
		print " $devise_tri<br>";
	}
		
	open (FILE,">>/home/sylvain/ibs/facture.txt");
	print FILE "$facture;$commande;$date;$user;$total;\n";
	close (FILE);
	`chmod 444 /home/sylvain/ibs/$commande.txt`;
	
}

sub voir{
print <<"eof";
		<center><h1>Voir une commande</h1>
		<form name=creation action=saisie.pl>
		<input type=hidden name=action value=edition>
		<br><br>Numero de commande 
		<input type=text name=commande size=8>

		<input type=submit value=voir>
		</form></body></html>
eof
}

sub in_facture{
print <<"eof";
		<center><h1>Creer une facture</h1>
eof
&entete();
print <<"eof";
		<br>		
		Commande $commande Facture crée par $user le $date <br>
		<form action=saisie.pl>
		<input type=hidden name=commande value=$commande>
		<input type=hidden name=action value=edi_facture>
		<br><br>Numero de facture 
		<input type=text name=facture size=8><br><br>
		avec tva <input type=radio name=tva value=\"oui\" checked>&nbsp;
		sans tva <input type=radio name=tva value=\"non\"><br><br>
		<input type=submit value=creer>
		</form></body></html>
eof
}
sub saisie{
	print "<br><br><table>";
	print "<tr><td><b>code</td><td><b>qte</b></td><td><b>prx</b></td></tr>";
	print "<form name=commande action=saisie.pl>";
	print "<input type=hidden name=action value=saisie>";
	print "<input type=hidden name=commande value=$commande>";
	for ($i=1;$i<=10;$i++){
		print "<tr><td><input type=text name=code$i size=6></td><td><input type=text name=qte$i size=8></td><td><input type=text name=prx$i size=8></td></tr>";
	}
	print "</table>";
	print "<input type=submit value=go>";
	print "</form>";
}

sub creation{
print <<"eof";
		<center><h1>Creation de la commande $commande</h1>
		<form name=creation action=saisie.pl>
		<input type=hidden name=action value=creation>
		<input type=hidden name=commande value=$commande>

		<br>
		<br>
		code client <input type=text size=8 name=client>
		<br><br>
		Nom (facultatif) <input type=text size=12 name=nom>
		<br><br>
		
		<input type=submit value=creation>
		</form></body></html>
eof
}

sub confirmer{
print <<"eof";
		<center><h1>Confirmation</h1>
		<form name=creation action=saisie.pl>
		<input type=hidden name=action value=confirmer>
		<input type=hidden name=commande value=$commande>

		<br>
		<br>
		code client:
eof
	print $html->param("client");
	$query="select cl_cd_cl,cl_nom from client where cl_cd_cl=".$html->param("client");
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_cd_cl,$cl_nom)=$sth->fetchrow_array;
	
	print " $cl_nom $cl_service $cl_rue $cl_ville<br><b>",$html->param("nom"),"</b><br>";
	print " creer par $user le $date<br>";
	print "<input type=hidden name=nom value=\"",$html->param("nom"),"\">";
	print "<input type=hidden name=createur value=$user>";
	print "<input type=hidden name=client value=$cl_cd_cl>";
	print "<input type=hidden name=date value=$date>";
	print "<br><input type=submit value=confirmer><br>";
	print "</form></body></html>";
}

sub premiere_page {
	print "
	<center><br><br><a href=saisie.pl?action=voir>voir une commande</a><br>
	<a href=saisie.pl?action=premiere_page>nouvelle commande</a><br>
	</body></html>";
}
 
sub entete{
	($null,$code_client,$nom,$createur,$dateco)=&selecte("/home/sylvain/ibs/commande.dsc",$commande,0);
	
	$query="select cl_cd_cl,cl_nom from client where cl_cd_cl='$code_client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_cd_cl,$cl_nom)=$sth->fetchrow_array;
	
	print "<center><br><br>";
	if ($code_client eq ""){print "<font color=red size=+1>- Commande $commande inconnu</font><br>";}
	if (($code_client ne "")&&($cl_cd_cl eq "")){print "<font color=red size=+1>Client $code_client inconnu</font><br>";}

	print "<table border=0>";
	print &ligne_tab("<b>","Cde: $commande",$cl_cd_cl,$cl_nom,$nom);
	print "</table><br><br>";
}

sub edition {
	$nbligne=0;

	open(FILE2,"/home/sylvain/ibs/$commande.txt");
	@commande_dat=<FILE2>;
	close(FILE2);
	$total=0;
	foreach (@commande_dat){
		($com_cd_pr,$com_qte,$com_puni)=split(/;/,$_);
		$pr_desi="";
		$query="select pr_desi,pr_type,pr_pdn,pr_pdb,pr_deg,prb_ndp_sh from produit,produit2 where pr_cd_pr='$com_cd_pr' and prb_cd_pr=pr_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($pr_desi,$pr_cd_fr,$pr_pdn,$pr_pdb,$pr_deg,$prb_ndp_sh)=$sth->fetchrow_array;

		$mont=$com_puni*$com_qte;
		$total+=$mont;
		$nbligne+1;
		print &taillefixe($com_cd_pr,6),&espace(1),&taillefixe($com_qte,8),&espace(5),&taillefixe($pr_desi,33),&espace(3);
		print &taillefixe(&deci2($com_puni),8),&espace(5);
		print &taillefixe(&deci2($mont),8);
		print "<br>";
	}
}

sub note {
	
	
	$nbligne=0;
	
	open(FILE2,"/home/sylvain/ibs/$commande.txt");
	@commande_dat=<FILE2>;
	close(FILE2);
	$total=0;
	($null,$code_client,$nom,$createur,$dateco)=&selecte("/home/sylvain/ibs/commande.dsc",$commande,0);

	print "<center><font size=+1><b>$nom</font></center><br>";
	print "<table border=0>";
	print &ligne_tab("<b>","ndp","code","designation","qte","poids net /litrage","poids brut","prix unitaire","montant €","degrée","alcool pur");
	$total_net=$total_pur=$total_brut=$total=$total_cnet=$total_cbrut=$totalc=0;
	foreach (@commande_dat){
		($com_cd_pr,$com_qte,$com_puni)=split(/;/,$_);
		$pr_desi="";
		$query="select pr_desi,pr_ventil,pr_pdn,pr_pdb,pr_deg/100,prb_ndp_sh from produit,produit2 where pr_cd_pr='$com_cd_pr' and prb_cd_pr=pr_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($pr_desi,$pr_cd_fr,$pr_pdn,$pr_pdb,$pr_deg,$prb_ndp_sh)=$sth->fetchrow_array;
		if ($com_cd_pr==120450){$pr_pdn=50;$pr_deg="19.50";}
		if ($com_cd_pr==120451){$pr_pdn=50;$pr_deg="19.50";}
		if ($com_cd_pr==120669){$pr_pdn=50;}
		if ($com_cd_pr==120693){$pr_deg="43.00";}
		if ($com_cd_pr==120325){$pr_deg="40.00";}
	
		$mont=&separateur($com_puni*$com_qte,2);
		$com_puni=&separateur($com_puni);
		$nbligne+1;
		# if (($pr_cd_fr == 2)||($pr_cd_fr == 14)||($pr_cd_fr == 15)){ # alcool pas fiable
		if ($pr_cd_fr == 6){ # alcool pas fiable

			$net=&separateur($pr_pdn*$com_qte/1000,2);
			$brut=&separateur($pr_pdb*$com_qte/1000,2);
			$pur=&separateur($net*$pr_deg/100,2);
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$pr_pdn,$brut,$com_puni,$mont,$pr_deg,$pur);
			$total_net+=$net;
			$total_brut+=$brut;
			$total_pur+=$pur;
			$total+=$mont;
		}
		if ($pr_cd_fr == 15){# cigarette
			$net=&separateur($pr_pdn*$com_qte/1000,2);
			$brut=&separateur($pr_pdb*$com_qte/1000,2);
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$net,$brut,$com_puni,$mont,"&nbsp;","&nbsp;");
			$total_cnet+=$net;
			$total_cbrut+=$brut;
			$totalc+=$mont;
		}
		
		$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$com_cd_pr'";
                $sth3=$dbh->prepare($query);
                $sth3->execute();
                ($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
                $info_entree="entree sous $fr8_doc le $fr8_date document precedent $fr8_info créé à $fr8_lieu";
                if ($fr8_doc eq ""){$info_entree="Information non disponible";}
           	print "<tR><td colspan=8>$info_entree</td></tr>";

               
		
		#if ($fr8_idx{$mini_prod}ne""){
		#	($fr_cd_pr,$fr_doc_ent,$fr_date,$fr_doc_prec,$fr_cre)=split(/;/,$fr8_dat[$fr8_idx{$mini_prod}]);
		#	$fr_date+=0;
		#	$fr_date=&date($fr_date);
		#	print &ligne_tab("","Document précédent:",$fr_doc_ent," du $fr_date");
		#}

	}
		$total_net+=$total_cnet;
		$total_brut+=$total_cbrut;
		$total+=$totalc;
	
		print &ligne_tab("<b>","","","","",$total_net,$total_brut,"",$total,"",$total_pur);
		print "</table>";
	
	
	if ($total_pur>0){
		#print &ligne_tab("<b>","","","","",$total_net,$total_brut,"",$total,"",$total_pur);
		print "</table>";
		
		print "<br><br><b>Calcul des Droits et taxes</b><br><table><tr><td>";
		print "Alcool pur $total_pur*14.50</td><td align=right>= ";
		print &separateur($total_pur*14.50,2);
		print " €</td></tr><tr><td>";
		print "Alcool  $total_net*1.30</td><td align=right>= ";
		print &separateur($total_net*1.30,2);
		print " €</td></tr><tr><td>";
		print "Total</td><td align=right>= ";
		print &separateur($total_net*1.30+$total_pur*14.50+$total,2);
		print " €</td></tr><tr><td>";
#	
		print "Tva 19.6</td><td align=right>= ";
		print &separateur((($total_net*1.30+$total_pur*14.50+$total)*19.6/100),2);
		print " €</td></tr><tr><td>";
		print "Total</td><td align=right><b>= ";
		print &separateur((($total_net*1.30+$total_pur*14.50+$total)*19.6/100)+($total_net*1.30+$total_pur*14.50),2);
		print " €</td></tr></table>";
	}
	if ($total_cnet>0){
		if ($total_pur==0){
			print &ligne_tab("<b>","","","","",$total_cnet,$total_cbrut,"",$totalc,"&nbsp;","&nbsp;");
			print "</table>";
		}
		print "<br><br><b>Calcul des Droits et taxes</b><br><table><tr><td>";
		#print "Valeur</td><td align=right>= ";
		#print &separateur($totalc,2);
		#print " €</td></tr><tr><td>";
#	
		print &separateur($total_cnet*10/2,2);
		print " cartouches = ";
		print &separateur($total_cnet*10/2,2);
		print "*200/1000";
		print "</td><td align=right>=";
		print &separateur($total_cnet,2);
		$base=int($total_cnet);
		print "</td></tr><tr><td>";
	
		print "P.V.:3.30*10*";
		print &separateur($total_cnet*10/2,2);
		$pv=int(3.30*10*$total_cnet*10/2);
		print " = ";
		print "</td><td align=right>=";
		print &separateur(3.30*10*$total_cnet*10/2,2);
		print "</td></tr><tr><td>";
		print "Droit à la consommation (A) $base*6.8391";
		print "</td><td align=right>=";
		$consoa=round(6.8391*$total_cnet);
		print &separateur($consoa,2);
		print "</td></tr><tr><td>";
		print "Droit à la consommation (B) $pv*55.19%";
		print "</td><td align=right>=";
		$consob=round($total_cnet*3.30*10*55.19*10/200);
		print &separateur($consob,2);
		print "</td></tr><tr><td>";
		print "Bapsa $pv*0.83*0.74%";
		print "</td><td align=right>=";
		$bapsa=round($total_cnet*3.30*10*0.83*0.74/20);
		print &separateur($bapsa,2);
		print "</td></tr><tr><td>";
		print "TVA 19.60 = ";
		print "</td><td align=right>=";
		$tva=round(($totalc+$bapsa+$consoa+$consob)*19.6/100) ;
		print &separateur($tva,2) ;
		print "</td></tr><tr><td>";
		print "Total</td><td align=right>= <b>";
		print &separateur(round($tva+$bapsa+$consoa+$consob),2);
		print "</td></tr></table>";
	}
	

}
sub maj {
	$erreur="non";
	close(FILE2);

	for ($i=1;$i<=10;$i++){
		$code=$html->param("code$i");
		if ($code>10000){
			if ($html->param("qte$i")!=0){
				$pr_prx_rev=0;
				print "$code<br>";
				$query="select pr_desi,pr_type,pr_pdn,pr_pdb,pr_deg,prb_ndp_sh from produit,produit2 where pr_cd_pr='$com_cd_pr' and prb_cd_pr=pr_cd_pr";
				$sth=$dbh->prepare($query);
				$sth->execute();
				($pr_desi,$pr_cd_fr,$pr_pdn,$pr_pdb,$pr_deg,$prb_ndp_sh)=$sth->fetchrow_array;
				$pr_prx_rev=&separateur($pr_prx_rev/6.55957,2);
				if($html->param("prx$i") ne ''){
					$pr_prx_rev = $html->param("prx$i");
				}
				$ligne=$html->param("code$i").";".$html->param("qte$i").";".$pr_prx_rev.";";
				if (&ajoute_n("/home/sylvain/ibs/$commande.txt",$ligne,0)==0){$erreur="oui";}
	
			}
			else
			{
				&supprime_n("/home/sylvain/ibs/$commande.txt",$html->param("code$i"),0);
			}
		}
	}
}

# -E saisie des commandes ibs
