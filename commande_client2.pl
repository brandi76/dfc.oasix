#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client2.pl";
$html=new CGI;
print $html->header;
$no_cde=$html->param("no_cde");
$action=$html->param("action");
$client=$html->param("client");
$produit=$html->param("produit");
if ($html->param("produit2") ne ""){$produit=$html->param("produit2");}
$comment=$html->param("comment");

$qte=$html->param("qte");

require "./src/connect.src";

if (($action eq "creation")&&($comment eq "")){
	$moncomment="<font color=red size=+5>Merci de saisir un commentaire</font>";
	$action="";
}

if ($action eq ""){
	&tetehtml();
	$query="select ic2_no,ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact from infococ2 order by ic2_no desc limit 10";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0><tr><th>Numero de commande</th><th>code client</th><th>Commentaire</th><th>Facture</th></tr>";
	while (($ic2_no,$ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_fact)=$sth->fetchrow_array){
		print "<tr><td>$ic2_no</td><td>$ic2_cd_cl</td><td>$ic2_com1</td><td>$ic2_fact</td><td><a href=?action=validation&no_cde=$ic2_no>edite</a></td></tr>";
	}
	print "<tr><td colspan=3><a href=$perl?action=nouveau>Nouveau</a></td></tr>";
	print "<table></body></html>";
}

if ($action eq "bon_de_livraison"){
	$no_cde=$html->param("no_cde");
	&bon_de_livraison();
}	

if ($action eq "nouveau"){
	$sth=$dbh->prepare("select dt_no from atadsql where dt_cd_dt=120");
	$sth->execute;
	($no_cde)= $sth->fetchrow_array;
	$no_cde++;
	&tetehtml();
	print "<font size=+2><b>Numéro de commande $no_cde</font><br>";
	print "<form>";
	$sth = $dbh->prepare("select cl_cd_cl,cl_nom from client order by cl_nom");
    	$sth->execute;
   	print "Client<br><select name=client>\n";
    	while (my @tables = $sth->fetchrow_array) {
      		next if $table eq $tables[0];
       		print "<option value=\"$tables[0]\"";
       		if ($tables[0]==420){ print " selected ";}
    		print ">$tables[1]\n";
       	
    	}
    	print "</select><br>\n";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=no_cde value=$no_cde>";
	print "<br><br>Commentaire<br><input type=texte size=120 name=comment><br><br>";
	print "<input type=submit class=bouton value=creation>";
	print "</form></body></html>";
}

if ($action eq "creation"){
	$datesimple="10".`/bin/date +%y%m%d`;
	$query="update atadsql set dt_no='$no_cde' where dt_cd_dt=120";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$query="replace into infococ2 values('$no_cde','$client','0','$datesimple','0','0','$comment','','','0','0','0','0','$datesimple','','','')";
	$sth = $dbh->prepare($query);
    	$sth->execute;
	$action="validation";
}	
if ($action eq "validation"){
	if ($qte ne ""){
		if ($qte==0){
			$query="delete from comcli where coc_no='$no_cde' and coc_cd_pr='$produit'";
			$sth = $dbh->prepare($query);
	    		$sth->execute;
	    	}
	    	else{	
			$newqte=$qte*100;
			$casse=0;
			if ($html->param("casse") eq "on"){$casse=1;}
			# prix
			$prix=$html->param("prix")*100;
			if ($prix eq "auto"){		
				$query="select ord_prix1 from ordre where ord_cd_pr=$produit";
			  	$sth=$dbh->prepare($query);
				$sth->execute();
				($prix)=$sth->fetchrow_array;
				if ($casse==1){$prix=$prix*70/100;}
				$prix=int($prix*100/119.6);
			}
			$query="replace into comcli values('$no_cde','$produit','$newqte','$prix','$casse','0','')";
			# print $query;
			$sth = $dbh->prepare($query);
	    		$sth->execute;
	    	}
	}
	&tetehtml();
	print "<br>$moncomment<br>";
	print "<font size=+2><b>Numéro de commande $no_cde</font><br>";
	$query="select ic2_cd_cl,cl_nom,ic2_com1,ic2_fact from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	$sth = $dbh->prepare($query);
    	$sth->execute;
	($cl_cd_cl,$cl_nom,$comment,$ic2_fact)=$sth->fetchrow_array; 
	print "$cl_cd_cl $cl_nom  $comment<br><br>";	
	$query="select coc_cd_pr,pr_desi,coc_qte/100,coc_puni/100,coc_casse from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr";
	$sth = $dbh->prepare($query);
    	$sth->execute;
    	print "<div class=ombre>";
    	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Casse</th></tr>";
	while (($pr_cd_pr,$pr_desi,$qte,$prix,$casse)= $sth->fetchrow_array) {
		if ($casse==1){$casse="oui";}else{$casse="&nbsp;";}
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$qte</td><td>$prix</td><td>$casse</td></tr>";
	}
	print "</table></div>";
	if ($ic2_fact==0){
		$query="select pr_cd_pr,pr_desi from ordre,produit where pr_cd_pr=ord_cd_pr and (pr_type=1 or pr_type=5) order by ord_ordre";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
	   	print "<form><select name=produit>\n";
	    	while (my @tables = $sth2->fetchrow_array) {
	      		next if $table eq $tables[0];
	       		print "<option value=\"$tables[0]\">$tables[0] $tables[1]\n";
	    	}
	    	print "</select>&nbsp;";
	    	print "ou code produit <input type=text size=6 name=produit2><br>\n";
		print "<br>qte <input type=text name=qte size=3 value=1>&nbsp;prix <input type=text name=prix size=5 value=auto>&nbsp;casse<input type=checkbox name=casse><br><br><br><br>";
	
		print "<input class=bouton type=submit name=action value=validation><br><br>";
	}
	print "<a href=$perl?action=bon_de_preparation&no_cde=$no_cde>Bon de preparation</a><br><br>";
	print "<a href=$perl?action=bon_de_livraison&no_cde=$no_cde>Bon de livraison</a><br><br>";
	print "<a href=$perl?action=facture&no_cde=$no_cde>Facture</a><br><br><br>";
	print "<a href=$perl?>Debut</a><br><br><br>";
	print "<input type=hidden name=no_cde value=$no_cde>";
	print "</form></body></html>";
}

if ($action eq "bon_de_preparation"){
	print "<html><body><h1>Bon de preparation de Commande</h1><br>";
	print "<b>Numéro de commande $no_cde<br>";
	$query="select ic2_cd_cl,cl_nom,ic2_com1 from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($cl_cd_cl,$cl_nom,$comment)=$sth->fetchrow_array; 
	print "$cl_cd_cl $cl_nom $comment<br><br>";	
	$query="select coc_cd_pr,pr_desi,coc_qte/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr";
	$sth=$dbh->prepare($query);
    	$sth->execute;
    	print "<table border=1 cellspacing=0><tr><th>Code</th><th>Produit</th><th>Qte commandée</th><th>Stock entrepot</th><th colspan=2>Stock apres sortie</th><th>check</th></tr>";
	while (($pr_cd_pr,$pr_desi,$qte)= $sth->fetchrow_array) {
		%stock=&stock($pr_cd_pr);
		$stock=$stock{"stock"};
		$detail=$stock-$qte;;
		$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query);
    		$sth3->execute;
		($car_carton)=$sth3->fetchrow_array;
		if ($car_carton>0){
			$carton=int((($stock)-$qte)/$car_carton);
			$detail=(($stock)-$qte)-($carton*$car_carton);
		}
		$stock_restant=$stock-$qte;
		$color="black";
		if ($stock_restant<0){$color=red;}
		print "<tr><td>$pr_cd_pr</td><td><font color=$color>$pr_desi</td><td align=right>$qte</td><td align=right>$stock</td><td align=right>$stock_restant</td><td align=right>($carton carton,$detail detail)</td><td><input type=checkbox></td></tr>";
	}
	print "</table>fin<br>";
	print "<a href=?no_cde=$no_cde&action=validation>Modification</a>";
	print "</body></html>";
}
if ($action eq "imputation_du_stock"){
	$query="select coc_cd_pr,pr_desi,coc_qte from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and coc_in_pos=0";
	$sth=$dbh->prepare($query);
    	$sth->execute;
	$datesimple=`/bin/date +%Y%m%d`;
	$i=0;
	while (($pr_cd_pr,$pr_desi,$qte)= $sth->fetchrow_array) {
		$query="update produit set pr_stre=pr_stre-$qte where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query);
    		$sth3->execute;
    		$query="replace into enso values('$pr_cd_pr','$no_cde','$datesimple','$qte','0','5')";
		$sth3=$dbh->prepare($query);
    		$sth3->execute;
    		$query="update comcli set coc_in_pos=5 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query);
    		$sth3->execute;
		$i++;
	}
	print "$i mises à jour du stock effectuées";
	print "</body></html>";
}

sub stock {
	$prod=$_[0];
	my($stock);
	my(%stock);
	$query = "select * from produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$produit= $sth->fetchrow_hashref;
	
	$query = "select sum(ret_retour)  from  non_sai,retoursql where ret_cd_pr=$prod and ns_code=ret_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$non_sai =$sth->fetchrow*100;
	$stock{"nonsai"}=$non_sai/100;
	
	$query = "select sum(ap_qte0)  from  appro,geslot where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$pastouch = $sth->fetchrow;
	
	$query = "select max(liv_dep)  from  geslot,listevol where gsl_nolot=liv_nolot and gsl_ind=11";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	$max = $sth->fetchrow;
	
	$query = "select sum(ap_qte0)  from  appro,listevol where ap_code=liv_aprec and ap_cd_pr=$prod and liv_dep='$max'";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	$pastouch2 = $sth->fetchrow;  # pas touche des pas touche dans le depart
	
	
	$stock{"pastouch"}=$pastouch+$pastouch2;
	$query = "select sum(ret_retour) from retoursql,retjour,geslot,etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$prod and rj_appro=ret_code and rj_date>='$today' and gsl_ind!=10 and gsl_ind!=11";
	$sth=$dbh->prepare($query);
	# print $query;
	$sth->execute();
	$retourdujour = $sth->fetchrow;
	$stock{"retourdujour"}=$retourdujour;

	# $query = "select sum(ap_qte0)  from  appro,geslot,retjour where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod and rj_appro=gsl_apcode and rj_date>=$today";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $pastouchdujour = $sth->fetchrow;
	# $stock{"pastouchdujour"}=$pastouchdujour/100;

	$query = "select sum(erdep_qte)  from  errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	$errdep = $sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"vol"}=$produit->{'$pr_vol'}/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	
	
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100;

	return(%stock);
}
sub tetehtml{
	print "<html><head><style type=\"text/css\">
	body {color=white;}
	td {font-weight:bold;text-align:center;}
	.gauche {
		td {font-weight:bold;text-align:left;}
	}
	
	<!--
	.ombre {
	filter:shadow(color=black, direction=120 , strength=3);
	width:800px;}
		
	.bouton {border-width=3pt;color:black;background-color:white;font-weight:bold;}
	-->
	</style></head>";

	print "<body background=../fond2.jpg link=white alink=white vlink=white><center><div class=ombre><font size=+5>Gestion des Commandes clients</font><br><br>";
}
sub bon_de_livraison(){
	$date=`/bin/date +%d/%m/%y`;
	print '<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body><div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy>email:ibsfrance@wanadoo.fr<br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>';

	print "<br><br><br><br><br><br><pre>";
	print "                                                  Dieppe le $date<br>";
	$query="select ic2_cd_cl,ic2_com1,ic2_com2 from infococ2 where ic2_no='$no_cde'";
	# print $query;

	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2)=$sth->fetchrow_array;

	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	print "                                                  <b>$cl_nom</b><br>";
        print "                                                  $rue<br>";
        print "                                                  $ville<br>";
        print "                                                  $pays<br>";
        print "$ic2_com1 $ic2com2 <br>";
	print "$ref                                        <b>BON DE LIVRAISON NO:$no_cde</b><br>";
	
	$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli where coc_no='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Montant</th></tr>";
	
	while (($coc_cd_pr,$coc_qte,$coc_puni)=$sth->fetchrow_array){
	
		$query="select pr_desi from produit where pr_cd_pr='$coc_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi)=$sth2->fetchrow_array;
		$montant=$coc_puni*$coc_qte;
		print "<tr><td>$coc_cd_pr</td><td>$pr_desi</td><td align=right>$coc_qte</td><td align=right>";
		print &deci2($coc_puni);
		print "</td><td align=right>";
		print &deci2($montant);
		$total+=$montant;
		print "</td></tr>";
	}
	print "<tr><td colspan=4><b>TOTAL HT</td><td align=right><b>";
	print &deci2($total);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TVA</td><td align=right><b>";
	print &deci2($total*19.6/100);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TOTAL TTC</td><td align=right><b>";
	print &deci2($total*1.196);
	print "</td></tr>";
	
	print "</table>";
	
}

sub facture(){
	$query="select ic2_fact from infococ2 where ic2_no='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_fact)=$sth->fetchrow_array;
	$ic2_fact+=0;
	if ($ic2_fact==0){ 
		#############################
		#  CREATION DE LA FACTURE   #
		#############################
		$query="select coc_cd_pr,pr_desi,coc_qte,coc_casse from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and coc_in_pos=0";
		$sth=$dbh->prepare($query);
	    	$sth->execute;
		$datesimple=`/bin/date +%Y%m%d`;
		while (($pr_cd_pr,$pr_desi,$qte,$casse)= $sth->fetchrow_array) {
			if ($casse==1){$query="update produit set pr_casse=pr_casse-$qte where pr_cd_pr='$pr_cd_pr'";}
			else{$query="update produit set pr_stre=pr_stre-$qte where pr_cd_pr='$pr_cd_pr'";}
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
	    		$query="replace into enso values('$pr_cd_pr','$no_cde','$datesimple','$qte','0','5')";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
	    		$query="update comcli set coc_in_pos=5 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
		}
		$sth=$dbh->prepare("select dt_no from atadsql where dt_cd_dt=110");
		$sth->execute;
		($no_fact)= $sth->fetchrow_array;
		$no_fact++;
		$query="update atadsql set dt_no='$no_fact' where dt_cd_dt=110";
		$sth=$dbh->prepare($query);
		$sth->execute;
		$query="update infococ2 set ic2_no_fact='$no_fact' where ic2_no='$no_cde'";
		$sth=$dbh->prepare($query);
		$sth->execute;
		$creation=1
	}

	$date=`/bin/date +%d/%m/%y`;
	print '<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body><div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy>email:ibsfrance@wanadoo.fr<br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>';

	print "<br><br><br><br><br><br><pre>";
	print "                                                  Dieppe le $date<br>";
	$query="select ic2_cd_cl,ic2_com1,ic2_com2,ic2_no_fact from infococ2 where ic2_no='$no_cde'";
	# print $query;

	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_no_fact)=$sth->fetchrow_array;

	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	print "                                                  <b>$cl_nom</b><br>";
        print "                                                  $rue<br>";
        print "                                                  $ville<br>";
        print "                                                  $pays<br>";
        print "$ic2_com1 $ic2com2 <br>";
	print "bl:$ic2_no                                       <b>FACTURE NO:$ic2_no_fact</b><br>";
	if ($creation!=1){print " DUPLICATA<br>";}
	$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli where coc_no='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Montant</th></tr>";
	
	while (($coc_cd_pr,$coc_qte,$coc_puni)=$sth->fetchrow_array){
	
		$query="select pr_desi from produit where pr_cd_pr='$coc_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi)=$sth2->fetchrow_array;
		$montant=$coc_puni*$coc_qte;
		print "<tr><td>$coc_cd_pr</td><td>$pr_desi</td><td align=right>$coc_qte</td><td align=right>";
		print &deci2($coc_puni);
		print "</td><td align=right>";
		print &deci2($montant);
		$total+=$montant;
		print "</td></tr>";
	}
	print "<tr><td colspan=4><b>TOTAL HT</td><td align=right><b>";
	print &deci2($total);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TVA</td><td align=right><b>";
	print &deci2($total*19.6/100);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TOTAL TTC</td><td align=right><b>";
	print &deci2($total*1.196);
	print "</td></tr>";
	
	print "</table>";
	
}
