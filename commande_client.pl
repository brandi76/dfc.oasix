#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$no_cde=$html->param("no_cde");
$action=$html->param("action");
$option=$html->param("option");
$client=$html->param("client");
$produit=$html->param("produit");
if ($html->param("produit2") ne ""){$produit=$html->param("produit2");}
$comment=$html->param("comment");
$navire=$html->param("navire");
$corsica=$html->param("corsica");
$qte=$html->param("qte");
$cdeprec1=$html->param("cdeprec1");
$cdeprec2=$html->param("cdeprec2");
$retour=$html->param("retour");
$colis=$html->param("colis");
$iteration=$html->param("iteration");
$filtre=$html->param("filtre");
print "<title> Commande client</title>";
# print "*** $retour $action ****";
require "./src/connect.src";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
$today=&nb_jour($jour,$mois,$an);
$comment2='';
#if (($action eq "creation")&&($comment eq "")&&($client!=500)&&($client!=434)&&($client!=43)){
	#$moncomment="<font color=red size=+5>Merci de saisir un commentaire</font>";
	#$action="";
#}
if (($action eq "creation")&&($client==500)){
	$comment2=$comment;
	$comment=$navire;
}

$parnum=$html->param("parnum"); 

if (($action eq "")&&($parnum ne "")){
	$no_cde=$parnum;
	$action="validation";
}
if ($action eq "bonprepnew"){
	&bonprepnew();
	exit;
}
if ($action eq "suptout"){
	&save("delete from infococ2 where ic2_no='$no_cde' and ic2_fact=0");
	&save("delete from comcli where coc_no='$no_cde' and coc_in_pos!=5");
	$action="";
}
if ($action eq "supprod"){
	&save("delete from comcli where coc_no='$no_cde' and coc_in_pos!=5");
	$action="validation";
}
if ($action eq ""){
	&tetehtml();
	print "<form><table border=1 cellspacing=0><tr><th>Numero de commande<br><input type=text name=parnum size=4> <input type=submit class=bouton2 value=go></th><th>code client<br><input type text name=parclient size=4> <input type=submit class=bouton2 value=go></th><th>Commentaire</th><th>Date</th><th>Facture</th></tr>";
	$parclient=$html->param("parclient"); 
	if ($parclient eq ""){
		$query="select ic2_no,ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_fact=0 order by ic2_no limit 30";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($ic2_no,$ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_fact,$ic2_date)=$sth->fetchrow_array){
			if ($ic2_date<1000000){$ic2_date+=1000000;}
			if ($ic2_date>10000000){$ic2_date-=9000000;}
		
			$date=substr($ic2_date,5,2)."/".substr($ic2_date,3,2)."/".substr($ic2_date,1,2);
			$nbref=&get("select count(*) from comcli where coc_no='$ic2_no'");
			print "<tr><td>$ic2_no</td><td>$ic2_cd_cl</td><td>$ic2_com1 $ic2_com2</td><td>$date</td><td>$ic2_fact</td><td>$nbref</td><td><a href=?action=validation&no_cde=$ic2_no>edite</a></td></tr>";
		
		}
		$query="select ic2_no,ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_fact!=0  order by ic2_no desc limit 30";
   	}
	else {
		if ($filtre ne ""){
			$query="select ic2_no,ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_cd_cl='$parclient' and (ic2_com1 like \"%$filtre%\" or ic2_com2 like \"%$filtre%\") order by ic2_no desc limit 100";
		}
		else
		{
			$query="select ic2_no,ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_cd_cl='$parclient' order by ic2_no desc limit 500";
		}
	}
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ic2_no,$ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_fact,$ic2_date)=$sth->fetchrow_array){
		if ($ic2_date<1000000){$ic2_date+=1000000;}
		if ($ic2_date>10000000){$ic2_date-=9000000;}
	
		$date=substr($ic2_date,5,2)."/".substr($ic2_date,3,2)."/".substr($ic2_date,1,2);
		print "<tr><td>$ic2_no</td><td>$ic2_cd_cl</td><td>$ic2_com1 $ic2_com2</td><td>$date</td><td>$ic2_fact</td><td><a href=?action=validation&no_cde=$ic2_no>edite</a></td></tr>";
	}
	print "<tr><td colspan=3><a href=$perl?action=nouveau>Nouveau</a></td></tr>";
	print "</table></form></body></html>";
}

if ($action eq "bon_de_livraison"){
	$no_cde=$html->param("no_cde");
	if (&get("select ic2_cd_cl from infococ2 where ic2_no='$no_cde'")==500){
		&bon_de_livraison_cor();
	}
	else
	{
		&bon_de_livraison();
	}
}	

if (($action eq "etiquette")&&($iteration eq 'on')){
	
	&etiquette();
}	
if (($action eq "etiquette")&&($iteration ne 'on')){
	&etiquette2();
}	

if ($action eq "nouveau"){
	$sth=$dbh->prepare("select dt_no from atadsql where dt_cd_dt=120");
	$sth->execute;
	($no_cde)= $sth->fetchrow_array;
	$no_cde++;
	&tetehtml();
	print "<font size=+2><b>Numéro de commande $no_cde</font><br>";
	print "<form>";
	$sth = $dbh->prepare("select cl_cd_cl,cl_nom from client where cl_zatt='actif' order by cl_nom");
    	$sth->execute;
   	print "Client<br><select name=client>\n";
    	while (my @tables = $sth->fetchrow_array) {
      		next if $table eq $tables[0];
       		print "<option value=\"$tables[0]\"";
       		if ($tables[0]==500){ print " selected ";}
    		print ">$tables[1]\n";
       	}
    	print "</select><br>\n";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=no_cde value=$no_cde>";
	print "<br><br>Commentaire<br><input type=texte size=120 name=comment><br><br>";
	print "<input type=submit class=bouton value=creation>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	
	print "</form></body></html>";
}

if ($action eq "creation"){
	$datesimple="1".`/bin/date +%y%m%d`;
	$query="update atadsql set dt_no='$no_cde' where dt_cd_dt=120";
	$sth=$dbh->prepare($query);
	$sth->execute;
	if ($client!=500){$navire='';}
	$query="replace into infococ2 values('$no_cde','$client','0','$datesimple','0','0','$comment','$comment2','$navire','0','0','0','0','$datesimple','','','')";
	# print $query;
	$sth = $dbh->prepare($query);
    	$sth->execute;
	$action="validation";
}
=pod	
	if ($comment2 eq "inventaire"){
		 # if ($four eq ""){$four="pr_four";}
		 $query="select nav_cd_pr from navire2,produit where nav_nom='MEGA 2' and nav_type=0 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5)";
		 $sth=$dbh->prepare($query);
		 $sth->execute;
		 while (($produit)= $sth->fetchrow_array) {
			$qte=0;
			&save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
		}
		 $query="select pr_cd_pr from produit where pr_sup=3 and (pr_type=1 or pr_type=5) and pr_cd_pr>100000000";
		 $sth=$dbh->prepare($query);
		 $sth->execute;
		 while (($produit)= $sth->fetchrow_array) {
			$qte=0;
			&save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
		}

	}
	
}	

if ($action eq "sup"){
	$coc_in_pos=&get("select coc_in_pos from comcli where coc_no='$no_cde' and coc_cd_pr='$produit'");
	if ($coc_in_pos==5){
		$su_qte=&qte("select es_qte from enso where es_cd_pr='$produit' and es_no_do='$no_cde'");
		&save("delete from enso where es_cd_pr='$produit' and es_no_do='$no_cde'");
		&save("update produit set pr_stre=pr_stre+$su_qte where pr_cd_pr='$produit'");
	}		
	$query="delete from comcli where coc_no='$no_cde' and coc_cd_pr='$produit'";
	$sth = $dbh->prepare($query);
	$sth->execute;
	$action="bon_de_preparation";
}
=cut
if ($action eq "validation"){
	 $query="select ic2_cd_cl,cl_nom,ic2_com1,ic2_fact from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	 $sth = $dbh->prepare($query);
    	 $sth->execute;
	 ($cl_cd_cl,$cl_nom,$comment,$ic2_fact)=$sth->fetchrow_array; 
	if ($ic2_fact!=0){
		$qte="";
		$corsica="";
		print "<h2><font color=red>Impossible la facture a été editée</font></h2>";
	}
	if (($qte ne "")&&($corsica eq "")){
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
			$prix_achat=&get("select pr_prac from produit where pr_cd_pr=$produit");
			if ($prix_achat ne ""){
				if ($cl_cd_cl==434){$prix=$prix_achat;}
				$query="replace into comcli values('$no_cde','$produit','$newqte','$prix','$casse','0','$newqte')";
				print $query;
				$sth = $dbh->prepare($query);
				$sth->execute;
	    		}
	    	}
	}
	else {
		if ($corsica ne ""){
			($tout,$toutqte)=split(/\*/,$corsica);
			$toutqte+=0;
			if (($tout eq "tout")&&($toutqte>0)){  # catalogue navire
				# $query="select ord_cd_pr from ordre,produit where pr_cd_pr=ord_cd_pr and pr_sup=0 and (pr_type=1 or pr_type=5) and pr_cd_pr!=220200 ";
				# $query="select pr_cd_pr from produit where pr_cd_pr>100000000 and pr_stre/100>='$toutqte' and pr_sup=0";
				$query="select nav_cd_pr from navire2 where nav_nom='$comment' and nav_type=0";
				print "$query<br>";
				$sth = $dbh->prepare($query);
			    	$sth->execute;
			    	$toutqte*=100;
				while (($produit)= $sth->fetchrow_array) {
					$query="replace into comcli values('$no_cde','$produit','$toutqte','0','0','0','$toutqte')";
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
				}
			}
			if ($tout eq "double"){  # double les produit en topten
				$query=" select * from topten where top_flag=1";
				$sth = $dbh->prepare($query);
			    	$sth->execute;
			    	while (($produit)= $sth->fetchrow_array) {
					$query="update comcli set coc_qte=coc_qte*2 where coc_cd_pr=$produit and coc_no='$no_cde'";
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
				}
			}
	
			if (($tout eq "new")&&($toutqte>0)){  # catalogue navire
				$query="select pr_cd_pr from produit where pr_cd_pr>100000000 and (pr_stre-pr_stvol)>'$toutqte' or (pr_cd_pr=2001859 or pr_cd_pr=2007406 or pr_cd_pr=2007534)";
				$sth = $dbh->prepare($query);
			    	$sth->execute;
			    	$toutqte*=100;
				$query="select ic2_nom from infococ2 where ic2_no='$no_cde'";
				$sth2=$dbh->prepare($query);
				$sth2->execute;
				$nav=$sth2->fetchrow_array;
				
				while (($produit)= $sth->fetchrow_array) {
					$query="select sum(coc_qte/100) from comcli,infococ2 where coc_no=ic2_no and ic2_nom='$nav' and coc_cd_pr='$produit' and coc_in_pos=5";
					$sth2=$dbh->prepare($query);
					$sth2->execute;
					$qte=$sth2->fetchrow_array;
					if ($qte>0){next;}
					if (($produit==2007406)||($produit==2007534))
					{
						$query="replace into comcli values('$no_cde','$produit','5000','0','0','0','5000')";
					}
					else 
					{
						$query="replace into comcli values('$no_cde','$produit','$toutqte','0','0','0','$toutqte')";
					}
				
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
				}
			}
		
			if (($tout eq "copie")&&($toutqte>0)){ # copie de commande
					$query="select coc_cd_pr,coc_qte from comcli where coc_no=$toutqte";
					$sth = $dbh->prepare($query);
				    	$sth->execute;
				   	while (($coc_cd_pr,$coc_qte)= $sth->fetchrow_array) {
						$query="replace into comcli values('$no_cde','$coc_cd_pr','$coc_qte','0','0','0','$coc_qte')";
						$sth2 = $dbh->prepare($query);
						$sth2->execute;
					}
			}
			if (($tout eq "copie_ex")&&($toutqte>0)){ # copie de commande
					$query="select coc_cd_pr,coc_qte from comcli where coc_no=$toutqte";
					$sth = $dbh->prepare($query);
				    	$sth->execute;
				   	while (($coc_cd_pr,$coc_qte)= $sth->fetchrow_array) {
						$query="select count(*) from trolley,produit,topten where (tr_cd_pr=pr_cd_pr and pr_codebarre='$coc_cd_pr' and tr_code=1) or (top_cd_pr='$coc_cd_pr' and top_flag=1)";
						# print $query;
						$sth2 = $dbh->prepare($query);
					    	$sth2->execute;
					   	($count)= $sth2->fetchrow_array;
					   	if ($count==0){next;}
					   	# si c'est un express ou ne prend que les references avion
						$query="replace into comcli values('$no_cde','$coc_cd_pr','$coc_qte','0','0','0','$coc_qte')";
						$sth2 = $dbh->prepare($query);
						$sth2->execute;
					}
			}


			if (($tout eq "chanel")&&($toutqte>0)){ # copie de commande
				$query="select pr_cd_pr from produit where pr_cd_pr>10000000 and pr_four=2070 and (pr_stre-pr_stvol)>'$toutqte'";
				$sth = $dbh->prepare($query);
			    	$sth->execute;
			    	$toutqte*=100;
				while (($produit)= $sth->fetchrow_array) {
					$query="replace into comcli values('$no_cde','$produit','$toutqte','0','0','0','$toutqte')";
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
				}
			}

			if (($tout>0)&&($tout<10000)&&($toutqte>0)){ 
				if ($tout>1000){ # fournisseur
					$query="select pr_cd_pr from produit where pr_four=$tout and pr_sup!=1 and pr_sup!=2 ";
				}
				else {  # entree
					$query="select es_cd_pr from enso where es_no_do=$tout";
				}
				$sth = $dbh->prepare($query);
			    	$sth->execute;
			    	$toutqte*=100;
				while (($produit)= $sth->fetchrow_array) {
					$query="replace into comcli values('$no_cde','$produit','$toutqte','0','0','0','$toutqte')";
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
				}
			}
			($corsica,$four)=split(/;/,$corsica);
			if ($corsica eq "inventaire"){
				&save("update infococ2 set ic2_cd_cl=240,ic2_com1='inventaire' where ic2_no='$no_cde'");
			  	if ($four eq ""){$four="pr_four";}
				# $query="select pr_cd_pr from navire2,produit where nav_nom='MEGA 2' and nav_type=0 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_four=$four";
				$query="select pr_cd_pr,pr_sup from produit where (pr_type=1 or pr_type=5) and pr_cd_pr>100000000 and pr_four=$four";
				$sth=$dbh->prepare($query);
				$sth->execute;
				while (($produit,$pr_sup)= $sth->fetchrow_array) {
					%stock=&stock($produit,$today);
					if (($stock{"stock"}==0)&&($pr_sup!=0 && $pr_sup!=3)){
						next;
					}
					$qte=0;
					&save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
				}
				$query="select pr_cd_pr,pr_sup from produit where (pr_four=2454 or pr_four=2453) and pr_cd_pr>100000000	";
				$sth=$dbh->prepare($query);
				$sth->execute;
				while (($produit,$pr_sup)= $sth->fetchrow_array) {
					%stock=&stock($produit,$today);
					if (($stock{"stock"}==0)&&($pr_sup!=0 && $pr_sup!=3)){
						next;
					}
					$qte=0;
					&save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
				}
				$query="select pr_cd_pr,pr_sup from produit where pr_four=1320 and pr_sup=0";
				$sth=$dbh->prepare($query);
				$sth->execute;
				while (($produit,$pr_sup)= $sth->fetchrow_array) {
					%stock=&stock($produit,$today);
					if (($stock{"stock"}==0)&&($pr_sup!=0 && $pr_sup!=3)){
						next;
					}
					$qte=0;
					&save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
				}

				$query="select pr_cd_pr,pr_sup from produit where pr_desi like 'TESTE%'";
				$sth=$dbh->prepare($query);
				$sth->execute;
				while (($produit,$pr_sup)= $sth->fetchrow_array) {
					%stock=&stock($produit,$today);
					if (($stock{"stock"}==0)&&($pr_sup!=0 && $pr_sup!=3)){
						next;
					}
					$qte=0;
					&save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
				}

				# $query="select pr_cd_pr from produit where pr_sup=3 and (pr_type=1 or pr_type=5) and pr_cd_pr>100000000 and pr_four=$four";
				# $sth=$dbh->prepare($query);
				# $sth->execute;
				# while (($produit)= $sth->fetchrow_array) {
					# $qte=0;
					# &save("insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')","af");
				# }
			}

			if ($corsica eq "importcsv"){   # importation corsica
				# creer un fichier avec cde,code prord,0,qte puiss import.sql ->
				# "load data infile '/tmp/extract.txt ' replace into table corsica fields TERMINATED BY ';' LINES TERMINATED BY '\n';"| mysql -u root FLY
				$query="select cor_cd_pr,cor_qte_pre from corsica where cor_no='10001' and cor_qte_pre>0 or cor_qte_com>0";
				$sth = $dbh->prepare($query);
			    	$sth->execute;
				while (($produit,$qte)= $sth->fetchrow_array) {
					$qte*=100;
					$query="select count(*) from produit where pr_cd_pr='$produit'"; 
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
					($reponse)=$sth2->fetchrow_array;
					# if ($reponse==0){$produit+=2000000;}# produit boutique corsica
					if ($reponse==1){
						$query="replace into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')";
						$sth2 = $dbh->prepare($query);
						$sth2->execute;
					}
					else {
						print "$produit inconnu<br>";
						}
				}
			&save("delete from corsica");
			}
			if ($corsica eq "testeur"){   
				$query="select pr_cd_pr,pr_desi,pr_four from produit where pr_desi like 'TESTEUR%'"; 
				$sth=$dbh->prepare($query);
				$sth->execute();
				while (($produit)=$sth->fetchrow_array)
				{	
					$qte=100;
					$query="insert ignore into comcli values('$no_cde','$produit','$qte','0','0','0','$qte')";
					$sth2 = $dbh->prepare($query);
					$sth2->execute;
				}
			}
		}
	}
	&tetehtml();
	print "<br>$moncomment<br>";
	print "<font size=+2><b>Numéro de commande $no_cde</font> <a href=?action=suptout&no_cde=$no_cde>suppression de la commande</a><br><a href=?action=supprod&no_cde=$no_cde>suppression des produits de la commande</a><form name=saisie><br>";
	# $query="select ic2_cd_cl,cl_nom,ic2_com1,ic2_fact from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	# $sth = $dbh->prepare($query);
    	# $sth->execute;
	# ($cl_cd_cl,$cl_nom,$comment,$ic2_fact)=$sth->fetchrow_array; 
	print "$cl_cd_cl $cl_nom  $comment <br><br>";	
	$query="select coc_cd_pr,pr_desi,coc_qte/100,coc_puni/100,coc_casse,pr_type,pr_prac/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr";
	$sth = $dbh->prepare($query);
    	$sth->execute;
    	print "<div class=ombre>";
    	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Casse</th></tr>";
	while (($pr_cd_pr,$pr_desi,$qte,$prix,$casse,$pr_type,$pr_prac)= $sth->fetchrow_array) {
		if ($casse==1){$casse="oui";}else{$casse="&nbsp;";}
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$qte</td><td>$prix</td><td>$casse</td><td><a href=?action=validation&produit=$pr_cd_pr&no_cde=$no_cde&qte=0>sup</a></td>";
		$nbligne++;
		if (($pr_type==1)||($pr_type==5)){
			$nbparfum+=$qte;
			$nbval+=($qte*$pr_prac);
		}             
		else
		{ print "<td>*</td>";
		}
		print "</tr>";
	}
	print "</table>$nbligne (lignes) $nbparfum (parfums) $nbval (achat)</div>";
	if ($ic2_fact==0){
		# $query="select pr_cd_pr,pr_desi from ordre,produit where pr_cd_pr=ord_cd_pr and (pr_type=1 or pr_type=5) order by ord_ordre";
		$query="select pr_cd_pr,pr_desi from produit where (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and pr_cd_pr >100000000 or (pr_cd_pr=8003080026221 or pr_cd_pr=8003080040135 or pr_cd_pr=2000469 or pr_cd_pr=4891199000058 or pr_cd_pr=4891199000034 or pr_cd_pr=2000470 or pr_cd_pr=2000471) order by pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
	    		print "<form><br><table border=1><tr><td>Creation automatique de commance<br>";
	    		print "importation liste founisseur mettre code fournisseur*qte <i>exemple</i> <font color=green>2250*12</font> <br>";
	    		print "Copier une commande mettre copie*numero de commande <i>exemple</i> <font color=green>copie*7885</font><br>";
			print "Importer une commande suite à un historique navire mettre importcsv<br>";
			print "Inventaire navire mettre inventaire <br>";
			print "Inventaire navire pour un fournisseur  mettre inventaire;four <i>exemple</i> <font color=green>inventaire;2180</font> <br>";
		
	    		print "<br><input type=text size=6 name=corsica></td></table><br>";
	      	print "<select name=produit>\n";
	       	while (my @tables = $sth2->fetchrow_array) {
	      		next if $table eq $tables[0];
	       		print "<option value=\"$tables[0]\">$tables[0] $tables[1]\n";
	    	}
	    	print "</select>&nbsp;";
	    	print "ou code produit <input type=text size=18 name=produit2>";
	    	print "<br>\n";
		print "<br>qte <input type=text name=qte size=3 value=1>&nbsp;prix <input type=text name=prix size=5 value=auto>&nbsp;casse<input type=checkbox name=casse><br><br><br><br>";
	
		print "<input class=bouton type=submit name=action value=validation><br><br>";
	}
	# print "<a href=$perl?action=bon_de_preparation&no_cde=$no_cde>Bon de preparation</a><br><br>";
	print "<a href=$perl?action=bonprepnew&no_cde=$no_cde>Bon de preparation </a><br><br>";
	print "<a href=$perl?action=bon_de_livraison&no_cde=$no_cde>Bon de livraison</a><br><br>";
	print "<a href=$perl?action=facture&no_cde=$no_cde>Facture</a><br><br><br>";
	print "<a href=$perl?action=note&no_cde=$no_cde>Note de detail</a><br><br><br>";
	print "<a href=$perl?>Debut</a><br><br><br>";
	print "<input type=hidden name=no_cde value=$no_cde>";
	print "</form><form>Nb de colis <input type=text name=colis size=3> </b>Iteration <input type=checkbox name=iteration checked> <input type=hidden name=no_cde value='$no_cde'><input type=hidden name=action value=etiquette><input type=submit value=etiquette></form>";
	print "</form></body></html>";
}
=pod
if ($action eq "bon_de_preparation"){
	print "<html><head><title> gestion des commandes</title></head><body><h1>Bon de preparation de Commande</h1><br><form>";
	print "<b>Numéro de commande $no_cde<br>";
	$query="select ic2_cd_cl,cl_nom,ic2_com1 from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($cl_cd_cl,$cl_nom,$comment)=$sth->fetchrow_array; 
	print "$cl_cd_cl $cl_nom $comment<br><br>";	
	$query="select coc_cd_pr,pr_desi,coc_qte/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and coc_qte!=0 order by pr_four,pr_cd_pr";
	$sth=$dbh->prepare($query);
    	$sth->execute;
    	print "<table border=1 cellspacing=0><tr><th>Code</th><th>Produit</th><th>Qte commandée</th><th>Stock entrepot</th><th colspan=2>Stock apres sortie</th></tr>";
	while (($pr_cd_pr,$pr_desi,$qte)= $sth->fetchrow_array) {
		%stock=&stocknull($pr_cd_pr);
		$stock=$stock{"stock"};
		if ($cdeprec1!=""){
			$query="select coc_qte/100 from comcli where coc_cd_pr='$pr_cd_pr' and coc_no='$cdeprec1'";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
			($adeduire)=$sth3->fetchrow_array+0;
			# print "$pr_cd_pr $adeduire<br>";
			$stock-=$adeduire;
		}			
		if ($cdeprec2!=""){
			$query="select coc_qte/100 from comcli where coc_cd_pr='$pr_cd_pr' and coc_no='$cdeprec2'";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
			($adeduire)=$sth3->fetchrow_array+0;
			$stock-=$adeduire;
		}		
		if ($retour eq "oui"){
			# print $stock{"retourdujour"};
			$stock-=$stock{"retourdujour"};
		}			
	
		$detail=$stock-$qte;
		$carton=0;
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
		if (($stock_restant<0)&&($option eq "sup")){
			if ((0-$stock_restant)>=$qte){
				$query="delete from comcli where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'"; 
			}
			else{
				$qte=$qte+$stock_restant;
				$query="update comcli set coc_qte=$qte*100 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'"; 
				print "<tr><td>$pr_cd_pr</td><td><font color=$color>$pr_desi</td><td align=right>$qte</td><td align=right>$stock</td><td align=right>$stock_restant</td><td align=right>($carton carton,$detail detail)</td><td><a href=?action=sup&produit=$pr_cd_pr&no_cde=$no_cde>sup</a></td></tr>";
			}
			print $query;
			$sth3=$dbh->prepare($query);
    			$sth3->execute;

    		}
    		else
    		{
			print "<tr><td>$pr_cd_pr</td><td><font color=$color>$pr_desi</td><td align=right>$qte</td><td align=right>$stock</td><td align=right>$stock_restant</td><td align=right>($carton carton,$detail detail)</td><td><a href=?action=sup&produit=$pr_cd_pr&no_cde=$no_cde>sup</a></td></tr>";
		}
	}
	print "</table><br>Même edition en tenant compte que les commandes suivantes non pas été préparées<br>Cde1 <input type=text name=cdeprec1 size=8> Cde2 <input type=text name=cdeprec2 size=8> <input type=submit value=envoie><br>";
	print "<a href=?no_cde=$no_cde&action=bon_de_preparation&retour=oui>Meme edition en tenant compte du retour</a>";
	print "<input type=hidden name=action value=bon_de_preparation>";
	print "<input type=hidden name=no_cde value=\"$no_cde\"><br>";
	print "<a href=?no_cde=$no_cde&action=validation>Modification</a>";
	print "<br><a href=?no_cde=$no_cde&action=bon_de_preparation&option=sup><font color=red>Suppression des manquants</font></a>";

	print "</body></html>";
}
=cut
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
if ($action eq "facture"){
	&facture();
}
if ($action eq "note"){
	&note();
}


sub stocknull {
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
	.ombrenull {
	filter:shadow(color=black, direction=120 , strength=3);
	width:800px;}
		
	.bouton {border-width=3pt;color:black;background-color:white;font-weight:bold;}
	.bouton2 {border-width=1pt;color:black;background-color:#efefef;}
	
	-->
	</style><title>gestion des commandes</title></head>";

	print "<body background=../fond2.jpg link=white alink=white vlink=white onload=document.saisie.produit2.focus()><center><div class=ombre><font size=+5>Gestion des Commandes clients</font><br><br>";
}
sub bon_de_livraison(){
	$date=`/bin/date +%d/%m/%y`;
	$query="select ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_no='$no_cde'";
	# print $query;

	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_fact,$ic2_date)=$sth->fetchrow_array;


	print '<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body><div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy>email:ibsfrance@wanadoo.fr<br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>';
        
	print "<br><br><br><br><br><br><pre>";

	if ($ic2_date<1000000){$ic2_date+=1000000}
	$date=substr($ic2_date,5,2)."/".substr($ic2_date,3,2)."/".substr($ic2_date,1,2);
	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	print "                                                  Dieppe le $date<br>";
	print "                                                  <b>$cl_nom</b><br>";
        print "                                                  $rue<br>";
        print "                                                  $ville<br>";
        print "                                                  $pays<br>";
        print "<font size=+2><b>$ic2_com1</b></font> $ic2com2 <br>";
	print "$ref                                        <b>BON DE LIVRAISON NO:$no_cde</b><br>";
	$query="select coc_cd_pr,coc_qte/100,coc_puni/100,coc_qte_com/100 from comcli where coc_no='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Montant</th></tr>";
	
	while (($coc_cd_pr,$coc_qte,$coc_puni,$coc_qte_com)=$sth->fetchrow_array){
	
		$query="select pr_desi,pr_prac/100 from produit where pr_cd_pr='$coc_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi,$pr_prac)=$sth2->fetchrow_array;
		# $coc_puni=$pr_prac;
		$montant=$coc_puni*$coc_qte;
		$neptune=&get("select max(nep_cd_pr) from neptune where nep_codebarre=$coc_cd_pr");
		print "<tr><td>";
		if ($neptune ne ""){
			print "<b>$neptune </b>";
		}
		print "$coc_cd_pr</td><td>$pr_desi</td><td align=right>$coc_qte</td><td align=right>";
		print &deci($coc_puni);
		print "</td><td align=right>";
		print &deci($montant);
		$total+=$montant;
		print "</td></tr>";
	}
	print "<tr><td colspan=4><b>TOTAL HT</td><td align=right><b>";
	print &deci($total);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TVA</td><td align=right><b>";
	print &deci($total*19.6/100);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TOTAL TTC</td><td align=right><b>";
	print &deci($total*1.196);
	print "</td></tr>";
	print "</table>";

}
sub bon_de_livraison_cor(){
	$date=`/bin/date +%d/%m/%y`;
	$query="select ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_no='$no_cde'";
	# print $query;

	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_fact,$ic2_date)=$sth->fetchrow_array;

	open (FILE ,">/tmp/corsica.txt");
	print FILE "SUBJECT:Livraison $ic2_com1\n";
	print FILE "Content-type: text/html\n\n";

	print '<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body><div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy>email:ibsfrance@wanadoo.fr<br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>';
        
        print FILE '<html><body></div>';
	print "<br><br><br><br><br><br><pre>";
	print FILE "<br><br><br><br><br><br><pre>";

	if ($ic2_date<1000000){$ic2_date+=1000000}
	$date=substr($ic2_date,5,2)."/".substr($ic2_date,3,2)."/".substr($ic2_date,1,2);
	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	print "                                                  Dieppe le $date<br>";
	print FILE "                                                  Dieppe le $date<br>";
	print "                                                  <b>$cl_nom</b><br>";
       	print FILE "                                                  <b>$cl_nom</b><br>";
        print "                                                  $rue<br>";
        print FILE "                                                  $rue<br>";
        print "                                                  $ville<br>";
        print FILE "                                                  $ville<br>";
        print "                                                  $pays<br>";
        print "<font size=+2><b>$ic2_com1</b></font> $ic2com2 <br>";
	print FILE "<font size=+2><b>$ic2_com1</b></font> $ic2com2 <br>";
	print "$ref                                        <b>BON DE LIVRAISON NO:$no_cde</b><br>";
	print FILE "$ref                                        <b>BON DE LIVRAISON NO:$no_cde</b><br>";
	print "<b>Document à pointer et à rendre au chauffeur à la prochaine livraison</b><br>";
	print FILE "<b>Document à pointer et à rendre au chauffeur à la prochaine livraison</b><br>";
	$date_inv=&get("select MAX(nav_date) from navire2 where nav_nom='$ic2_com1' and nav_type=10","af");
	$query="select coc_cd_pr,coc_qte/100,coc_puni/100,coc_qte_com/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and (coc_qte !=0 or pr_sup=3 or pr_sup=0)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code</th><th>Désignation</th><th>Dernier inventaire $date_inv";
	print "</th><th>Qte calc</th><th>Qte liv</th></tr>";
	print FILE "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code</th><th>Désignation</th><th>Dernier inventaire";
	print FILE "</th><th>Qte calc</th><th>Qte liv</th></tr>\n";

	
	while (($coc_cd_pr,$coc_qte,$coc_puni,$coc_qte_com)=$sth->fetchrow_array){
	
		$query="select pr_desi,pr_prac/100,pr_type from produit where pr_cd_pr='$coc_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi,$pr_prac,$pr_type)=$sth2->fetchrow_array;
		# $coc_puni=$pr_prac;
		if ($pr_type==1){$poids+=$coc_qte*250;}
		if ($pr_type==5){$poids+=$coc_qte*100;}
		$montant=$coc_puni*$coc_qte;
		$neptune=&get("select max(nep_cd_pr) from neptune where nep_codebarre=$coc_cd_pr");
		print "<tr><td>";
		print FILE "<tr><td>";
		if ($neptune ne ""){
			print FILE "<b>$neptune </b>";
			print "<b>$neptune </b>";
		}
		print "$coc_cd_pr</td><td>$pr_desi</td><td align=right>";
		print FILE "$coc_cd_pr</td><td>$pr_desi</td><td align=right>";
		$inv=&get("select nav_qte from navire2 where nav_cd_pr=$coc_cd_pr and nav_nom='$ic2_com1' and nav_type=10 and nav_date='$date_inv'")+0;
		print "$inv</td><td align=right>$coc_qte_com</td><td align=right>$coc_qte</td></tr>";
		print FILE "$inv</td><td align=right>$coc_qte_com</td><td align=right>$coc_qte</td></tr>\n";
	}
	print "</table>";
	$poids/=1000;
	print "poids :$poids kg";
	print FILE "</table>";
	close (FILE);
	exec('rsh -l sylvain 192.168.1.4 /usr/sbin/sendmail -fibsfrance@wanadoo.fr giuliademarinis@wanadoo.fr</tmp/corsica.txt');
}

sub facture(){
	$query="select ic2_fact,ic2_cd_cl from infococ2 where ic2_no='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($no_fact,$ic2_cd_cl)=$sth->fetchrow_array;
	$no_fact+=0;
	if ($no_fact==0){ 
		#############################
		#  CREATION DE LA FACTURE   #
		#############################
		$query="select coc_cd_pr,pr_desi,coc_qte,coc_casse from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and coc_in_pos=0";
			print "$query<br>";
		
		$sth=$dbh->prepare($query);
	    	$sth->execute;
		$datesimple=`/bin/date +%Y%m%d`;
		while (($pr_cd_pr,$pr_desi,$qte,$casse)= $sth->fetchrow_array) {
			if ($casse==1){$query="update produit set pr_casse=pr_casse-$qte where pr_cd_pr='$pr_cd_pr'";}
			$query="update produit set pr_stre=pr_stre-$qte where pr_cd_pr='$pr_cd_pr'";
			print "$query<br>";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
	    		$query="replace into enso values('$pr_cd_pr','$no_cde','$datesimple','$qte','0','5')";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
	    		$query="update comcli set coc_in_pos=5 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'";
			$sth3=$dbh->prepare($query);
	    		$sth3->execute;
	    		if ($ic2_cd_cl==500){
 	    			$query2="select prac,priv,flag from prix311208 where code='$pr_cd_pr'";
 				$sth3=$dbh->prepare($query2);
 				$sth3->execute();
 				($pr_puni,$pr_priv,$flag)=$sth3->fetchrow_array;
 				$pr_puni=$pr_prac*100;
 				if ($flag!=0){$pr_puni=int($pr_priv*100/2);}  
				if ($flag eq ""){$pr_puni=&get("select pr_prx_vte from produit where pr_cd_pr='$pr_cd_pr'");}	# ajoute le 2 sep 2009
				$pr_prac=&prac('$pr_cd_pr'); # remplace le 3 juin 2008
				$pr_prac*=100;
	    		    	&save("update comcli set coc_casse='$pr_prac',coc_puni='$pr_puni' where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'");
		    	}
		}
		if ($ic2_cd_cl==500){
 	    	    		$no_fact=&get("select dt_no from atadsql where dt_cd_dt=111")+1;
		    		&save("update atadsql set dt_no='$no_fact' where dt_cd_dt=111");
		}
		else {
			$sth=$dbh->prepare("select dt_no from atadsql where dt_cd_dt=110");
			$sth->execute;
			($no_fact)= $sth->fetchrow_array;
			$no_fact++;
			$query="update atadsql set dt_no='$no_fact' where dt_cd_dt=110";
			$sth=$dbh->prepare($query);
			$sth->execute;
		}
		$query="update infococ2 set ic2_fact='$no_fact' where ic2_no='$no_cde'";
		$sth=$dbh->prepare($query);
		$sth->execute;
		$creation=1
	}
	$no_fact=substr($no_fact,4,4);
	print "<a href=http://ibs.oasix.fr/html2pdf_v3.18/exemples/facture_corsica.php?no_cde=$no_cde&no_fact=$no_fact>Facture format pdf </a>";

=pod
	$date=`/bin/date +%d/%m/%y`;
	print '<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body><div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy>email:ibsfrance@wanadoo.fr<br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>';

	print "<br><br><br><br><br><br><pre>";
	$query="select ic2_cd_cl,ic2_com1,ic2_com2,ic2_fact,ic2_date from infococ2 where ic2_no='$no_cde'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2,$ic2_fact,$ic2_date)=$sth->fetchrow_array;
	if ($ic2_date<1000000){$ic2_date+=1000000}
	$date=substr($ic2_date,5,2)."/".substr($ic2_date,3,2)."/".substr($ic2_date,1,2);
	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	print "                                                  Dieppe le $date<br>";
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
		print &deci($coc_puni);
		print "</td><td align=right>";
		print &deci($montant);
		$total+=$montant;
		print "</td></tr>";
		if ($ligne++>32){&nextpage();}
	}
	print "<tr><td colspan=4><b>TOTAL HT</td><td align=right><b>";
	print &deci($total);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TVA</td><td align=right><b>";
	print &deci($total*19.6/100);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TOTAL TTC</td><td align=right><b>";
	print &deci($total*1.196);
	print "</td></tr>";
	
	print "</table>";
=cut	
}



# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}
sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/mm/DD
# SORTIE : la date formatée

sub julian {
	my ($val)=$_[0];
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine)=(4,"Lundi",5,"mardi",6,"mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	return "$semaine{$var%7}";
}
sub select_date
{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	(@dates)=split(/;/, $date, 3); 
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	$firstyear=$dates[2];
  	print "<select name=datejour>"; 
 	for($i=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	@cal=("","Janvier","Février","mars","Avril","mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print "<select name=datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=datean>"; 
	for($i=$firstyear;$i<=($firstyear+1);$i++) { print "<option value=$i>$i</option> ";} 
 	print "</select>"; 
} 
sub etiquette{
	$query="select ic2_cd_cl,cl_nom,ic2_com1,ic2_fact from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	$sth = $dbh->prepare($query);
    	$sth->execute;
	($cl_cd_cl,$cl_nom,$comment,$ic2_fact)=$sth->fetchrow_array; 
	while ($date=~s/;/\//){}
	print "<html><head>
	<Meta http-equiv=\"Pragma\" content=\"no-cache\">
	<style type=\"text/css\">
	<!--
	#saut { page-break-after : right }         
	-->
	</style></head>";

	for ($j=1;$j<=$colis;$j++){
		print "<br>cde $no_cde du $date<br><font size=+5><br>$comment<br>$j/$colis<br></font>";
		print "<div id=saut></div>";
	}
}
sub etiquette2{
	$query="select ic2_cd_cl,cl_nom,ic2_com1,ic2_fact from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	$sth = $dbh->prepare($query);
    	$sth->execute;
	($cl_cd_cl,$cl_nom,$comment,$ic2_fact)=$sth->fetchrow_array; 
	while ($date=~s/;/\//){}
	print "<html><head>
	<Meta http-equiv=\"Pragma\" content=\"no-cache\">
	<style type=\"text/css\">
	<!--
	#saut { page-break-after : right }         
	-->
	</style></head>";

	for ($j=1;$j<=$colis;$j++){
		print "<br>$date<br><font size=+5><br>$comment<br>$j<br></font>";
		print "<div id=saut></div>";
	}
}


sub bonprepnew {
	$page=1;
	print "<html><head><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }         
	-->
	</style></head>";
	print "<body><h1>Bon de preparation de Commande</h1><br><form>";
	print "<b>Numéro de commande $no_cde<br>";
	&titre();
	$query="select ic2_cd_cl,cl_nom,ic2_com1 from infococ2,client where ic2_no='$no_cde' and cl_cd_cl=ic2_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($cl_cd_cl,$cl_nom,$comment)=$sth->fetchrow_array; 
	print "$cl_cd_cl $cl_nom $comment<br><br>";
		
	######################
        ##### TOP TEN ########
        ######################
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 60";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($top_cd_pr,$top_qte)=$sth->fetchrow_array){
		push (@top60,$top_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 120";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($top_cd_pr,$top_qte)=$sth->fetchrow_array){
		if (! (grep /$top_cd_pr/,@top60)){push (@top120,$top_cd_pr);}
	}
	
	
	##########  PRODUIT ACTIF ######
		
	
	$query="(select coc_cd_pr,pr_desi,coc_qte/100,pr_four,coc_casse,pr_sup,pr_cd_pr%10000 as modulo,pr_four from comcli,produit where coc_no='$no_cde' and pr_desi not like 'TESTE%' and coc_cd_pr=pr_cd_pr order by pr_four,pr_emb,modulo) ";
	$sth=$dbh->prepare($query);
    	$sth->execute;

	while (($pr_cd_pr,$pr_desi,$coc_qte,$pr_four,$coc_casse,$pr_sup,$modulo,$pr_four)=$sth->fetchrow_array){
		$info="flop";
		if ($pr_sup==3){$top=2;$stock_mini=6;$info="new";}
		if (($pr_sup!=0)&&($pr_sup!=3)&&($pr_sup!=5)){$info="destockage";}
       		if (grep /$pr_cd_pr/,@top60){$info="top 60";}
		if (grep /$pr_cd_pr/,@top120){$info="top 120";}

		$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
		$sth2->execute();
		($car_carton,$car_pal)=$sth2->fetchrow_array;
		%stock=&stock($pr_cd_pr,$today);
		$pr_stre=$stock{"stock"};
		$color="black";
		$nbligne++;
		# if ($nbligne>40){print "</table></b>page $page<div id=saut></div>";$page++;&titre();}

		
		if ($pr_sup!=0){$color="red";}
		$digit_f=$pr_cd_pr%10000+10000;
		$digit_f=substr($digit_f,1,4);
		$digit_p=int($pr_cd_pr/10000);
		$single="";
		if ($pr_four==2070){
			$digit_f=$pr_cd_pr%100000+100000;
			$digit_f=substr($digit_f,1,5);
			$digit_p=int($pr_cd_pr/100000);
		}
		# @decal=(737052460222,737052460055,737052460123,737052460130,737052460154,737052482101);
		# decale d'un chiffre pour les caracteres gras pour les produits de decal
		if (grep /$pr_cd_pr/,@decal){
			$digit_f=substr($digit_p,length($digit_p)-1,1).$digit_f;
			$single=" ".substr($digit_f,length($digit_f)-1,1);
			chop($digit_f);
			chop($digit_p);
		}
	
		$pr_stre+=0;
		$pr_stre-=$coc_qte;
		$color="";
		if (($pr_stre<0)||($coc_qte==0 && $pr_stre<=0)){$color="red";}
		if ((($pr_stre<0)||($coc_qte==0 && $pr_stre<=0))&&($option eq "sup")){
			
# 			 print "$pr_cd_pr $pr_stre $coc_qte <br>";
			$coc_qte+=$pr_stre;
			if ($coc_qte<0){$coc_qte=0;}
			$pr_stre=0;
			$color="black";
			if ($coc_qte==0){
			        $nonew=&get("select ic2_no from infococ2 where ic2_com1='$comment' and ic2_no>'$no_cde' and ic2_fact=0","af");
				if ($nonew eq ""){
					
					$datesimple="1".`/bin/date +%y%m%d`;
					$nonew=&get("select dt_no from atadsql where dt_cd_dt=120");
					$nonew++;
					&save("update atadsql set dt_no='$nonew' where dt_cd_dt=120","af");
					&save("replace into infococ2 values('$nonew','500','0','$datesimple','0','0','$comment','complement','$navire','0','0','0','0','$datesimple','','','')","af");
				}
				&save("update comcli set coc_no='$nonew' where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'","af");
				next;
			}
			else {
				&save("update comcli set coc_qte=$coc_qte*100 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'");
   			}
    		}
		# if ($coc_qte==0){next;}
# 		if ($pr_four ne $fourt) {
# 		 	 $sth3=$dbh->prepare("select fo2_cd_fo,fo2_add from fournis where fo2_cd_fo='$pr_four'");
# 			 $sth3->execute();
# 			 ($four,$fo_nom)=$sth3->fetchrow_array;
# 			 print "<tr><th colspan=8>$four $fo_nom </th></tr>";
# 			 $ngligne++;
# 			 $ngligne++;
		 	# print "<tr><td colspan=6><hr></td></tr>";
# 			$fourt=$pr_four;
# 		}
		if ($pr_cd_pr<100000000){
				print "<tr><td>$pr_cd_pr</td><td><font color=$color>$pr_desi </td>";
		}
		else
		{
			# print "<tr><td>$pr_four <b>$modulo</b></td><td><font color=$color>$pr_desi </td>";
			print "<tr><td>$digit_p <font size=+2><b>$digit_f</b></font>$single</td><td><font color=$color>$pr_desi </td>";
		}
		print "<td><font size=-2>$info</td>";
		print "<td align=right>";
		print "<font size=+1><b>".int($coc_qte)."</font>";
		# &carton($pr_cd_pr,$coc_qte);
		print "</td>";
		if ($coc_casse==1){print "<td>Casse</td>";}
		else {
			print "<td align=right> ";
			&carton($pr_cd_pr,$pr_stre);
			print "</td><td align=center>&nbsp;</td>";
		}
			print "</tr>";
	}
	
	
	
	$query= "select coc_cd_pr,pr_desi,coc_qte/100,pr_four,coc_casse,pr_sup,pr_cd_pr%10000 as modulo,pr_four from comcli,produit where coc_no='$no_cde' and pr_desi like 'TESTE%' and coc_cd_pr=pr_cd_pr order by pr_four,pr_emb,modulo";
	$sth=$dbh->prepare($query);
    	$sth->execute;

	while (($pr_cd_pr,$pr_desi,$coc_qte,$pr_four,$coc_casse,$pr_sup,$modulo,$pr_four)=$sth->fetchrow_array){
		$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
		$sth2->execute();
		($car_carton,$car_pal)=$sth2->fetchrow_array;
		%stock=&stock($pr_cd_pr,$today);
		$pr_stre=$stock{"stock"};
		$color="black";
		$nbligne++;
		$digit_f=$pr_cd_pr%10000+10000;
		$digit_f=substr($digit_f,1,4);
		$digit_p=int($pr_cd_pr/10000);
		$single="";
		$pr_stre+=0;
		$pr_stre-=$coc_qte;
		$color="";
		if (($pr_stre<0)||($coc_qte==0 && $pr_stre<=0)){$color="red";}
		if ((($pr_stre<0)||($coc_qte==0 && $pr_stre<=0))&&($option eq "sup")){
			# print "$pr_cd_pr $pr_stre $coc_qte <br>";
			$coc_qte+=$pr_stre;
			if ($coc_qte<0){$coc_qte=0;}
			$pr_stre=0;
			$color="black";
			if ($coc_qte==0){
			        $nonew=&get("select ic2_no from infococ2 where ic2_com1='$comment' and ic2_no>'$no_cde' and ic2_fact=0");
				if ($nonew eq ""){
					$datesimple="1".`/bin/date +%y%m%d`;
					$nonew=&get("select dt_no from atadsql where dt_cd_dt=120");
					$nonew++;
					&save("update atadsql set dt_no='$nonew' where dt_cd_dt=120","af");
					&save("replace into infococ2 values('$nonew','500','0','$datesimple','0','0','$comment','complement','$navire','0','0','0','0','$datesimple','','','')","af");
				}
				&save("update comcli set coc_no='$nonew' where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'","af");
			}
			else {
				&save("update comcli set coc_qte=$coc_qte*100 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'");
   			}
    		}
		if ($pr_cd_pr<100000000){
				print "<tr><td>$pr_cd_pr</td><td><font color=$color>$pr_desi </td>";
		}
		else
		{
			# print "<tr><td>$pr_four <b>$modulo</b></td><td><font color=$color>$pr_desi </td>";
			print "<tr><td>$digit_p <font size=+2><b>$digit_f</b></font>$single</td><td><font color=$color>$pr_desi </td>";
		}
		print "<td><font size=-2>$info</td>";
		print "<td align=right>";
		print "<font size=+1><b>".int($coc_qte)."</font>";
		# &carton($pr_cd_pr,$coc_qte);
		print "</td>";
		if ($coc_casse==1){print "<td>Casse</td>";}
		else {
			print "<td align=right> ";
			&carton($pr_cd_pr,$pr_stre);
			print "</td><td align=center>&nbsp;</td>";
		}
			print "</tr>";
	}
	
	
	
	
	
	
	
	#}
	##########  DESTOCKAGE ######

=pod
	$nbligne=40;
	$query="select coc_cd_pr,pr_desi,coc_qte/100,pr_four,coc_casse,pr_sup,pr_cd_pr%100000,pr_four as modulo from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and (pr_sup!=0 and pr_sup!=3) order by pr_cd_pr";
	$sth=$dbh->prepare($query);
    	$sth->execute;

	while (($pr_cd_pr,$pr_desi,$coc_qte,$pr_four,$coc_casse,$pr_sup,$modulo,$pr_four)=$sth->fetchrow_array){
		$info="flop";
		if ($pr_sup==3){$top=2;$stock_mini=6;$info="new";}
		if (($pr_sup!=0)&&($pr_sup!=3)&&($pr_sup!=5)){$info="destockage";}
       		if (grep /$pr_cd_pr/,@top60){$info="top 60";}
		if (grep /$pr_cd_pr/,@top120){$info="top 120";}

		$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
		$sth2->execute();
		($car_carton,$car_pal)=$sth2->fetchrow_array;
		%stock=&stock($pr_cd_pr,$today);
		$pr_stre=$stock{"stock"};
		$color="black";
		$nbligne++;
		if ($nbligne>40){print "</table></b>page $page<div id=saut></div>";$page++;&titre();}

		if ($pr_sup!=0){$color="red";}
		$digit_f=$pr_cd_pr%100000+100000;
		$digit_f=substr($digit_f,1,5);
		$digit_p=int($pr_cd_pr/100000);
		$single="";
		@decal=(737052460222,737052460055,737052460123,737052460130,737052460154,737052482101);
	
		# decale d'un chiffre pour les caracteres gras pour les produits de decal
		if (grep /$pr_cd_pr/,@decal){
			$digit_f=substr($digit_p,length($digit_p)-1,1).$digit_f;
			$single=" ".substr($digit_f,length($digit_f)-1,1);
			chop($digit_f);
			chop($digit_p);
	
		}
	
		$pr_stre+=0;
		$pr_stre-=$coc_qte;
		$color="";
		if ($pr_stre<0){$color="red";}
		if (($pr_stre<0)&&($option eq "sup")){
			# print "$pr_cd_pr $pr_stre $coc_qte <br>";
			$coc_qte+=$pr_stre;
			if ($coc_qte<0){$coc_qte=0;}
			$pr_stre=0;
			$color="black";
			$query="update comcli set coc_qte=$coc_qte*100 where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'";
			if ($coc_qte==0){
				 $query="delete from comcli where coc_no='$no_cde' and coc_cd_pr='$pr_cd_pr'";
			}
			# print "$query<br>";
			$sth3=$dbh->prepare($query);
    			$sth3->execute;
    	}
#    	if ($coc_qte!=0) {
			if ($pr_cd_pr<100000000){
				print "<tr><td>$pr_cd_pr</td><td><font color=$color>$pr_desi </td>";
			}
			else
			{
				# print "<tr><td>$pr_four <b>$modulo</b></td><td><font color=$color>$pr_desi </td>";
 				print "<tr><td>$digit_p <b>$digit_f</b>$single</td><td><font color=$color>$pr_desi </td>";
			}
			print "<td><font size=-2>$info</td>";
			print "<td align=right>";
			&carton($pr_cd_pr,$coc_qte);
			print "</td>";
			if ($coc_casse==1){print "<td>Casse</td>";}
			else {
				print "<td align=right> ";
				&carton($pr_cd_pr,$pr_stre);
				print "</td><td align=center>&nbsp;</td>";
			}
			print "</tr>";
		}
	
		
#	}
=cut
	print "</table></b>page $page dernière page";
	print "<br><a href=?no_cde=$no_cde&action=bonprepnew&option=sup><font color=red>Suppression des manquants</font></a>";
	print "<br><a href=http://ibs.oasix.fr/cgi-bin/commande_client.pl?action=validation&no_cde=$no_cde>retour</a>";

}
sub titre(){
	print `date`."<br>";;
	print "<table border=1 cellspacing=0>";
	print "<tr bgcolor=#FFFF66><td>&nbsp;</td><td>&nbsp;</td>";
	print "<th>info</th><th>Sortir</th><th>Reste</th><th>Check</th></tr>";
	$nbligne=0;
}

sub note {
	$nbligne=0;
	$ok=&get("select count(*) from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and pr_ventil=6");
        if ($ok>0){
		print "$no_cde <b>Alcool</b><table border=1 cellspacing=0>";
		print &ligne_tab("<b>","ndp","code","designation","qte","litrage","Volume litre","prix unitaire","montant ","degrée","alcool pur litre");
		$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and pr_ventil=6";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total_net=$total_pur=$total_brut=$total=$total_cnet=$total_cbrut=$totalc=0;
		while (($com_cd_pr,$com_qte,$com_puni)=$sth->fetchrow_array){
			$pr_desi="";
			$query="select pr_desi,pr_ventil,pr_pdn,pr_pdb,pr_deg/100,pr_douane from produit where pr_cd_pr='$com_cd_pr' ";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($pr_desi,$pr_cd_fr,$pr_pdn,$pr_pdb,$pr_deg,$prb_ndp_sh)=$sth2->fetchrow_array;
			$mont=&separateur($com_puni*$com_qte,2);
			$com_puni=&separateur($com_puni);
			$nbligne+1;
			$net=&separateur($pr_pdn*$com_qte/1000,2);
			$brut="-";
			$pur=&separateur($net*$pr_deg/100,2);
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$pr_pdn,$net,$com_puni,$mont,$pr_deg,$pur);
			$total_net+=$net;
			# $total_brut+=$brut;
			$total_pur+=$pur;
			$total+=$mont;
	
			$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$com_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
			$info_entree="entree sous $fr8_doc le $fr8_date document precedent $fr8_info créé à $fr8_lieu";
	#                 if ($fr8_doc ne ""){print "<tR><td colspan=8>$info_entree</td></tr>";}
	
	#                 {$info_entree="Information non disponible";}
			$total_net+=$total_cnet;
			$total_brut+=$total_cbrut;
			$total+=$totalc;
		}	
		print &ligne_tab("<b>","","","","","",$total_net,"",$total,"",$total_pur);
		print "</table>";                                             
		
		print "<b>Calcul des Droits et taxes alcool</b><br><table><tr><td>";
		print "Accises Alcool pur $total_pur*14.50</td><td align=right>= ";
		print &separateur($total_pur*14.50,2);
		print "</td></tr><tr><td>";
		print "Securité sociale  $total_net*1.30</td><td align=right>= ";
		print &separateur($total_net*1.30,2);
		print "</td></tr><tr><td>";
		print "Total</td><td align=right><b>= ";
		print &separateur($total_net*1.30+$total_pur*14.50,2);
		print "</td></tr><tr><td>";
		print "</table><br><br>";	
	}
	$nbligne=0;
	$ok=&get("select count(*) from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and pr_ventil=3");
        if ($ok>0){
		print "$no_cde <b>Produit intermediaire</b><table border=1 cellspacing=0>";
		print &ligne_tab("<b>","ndp","code","designation","qte","litrage","Volume litre","prix unitaire","montant");
		$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and pr_ventil=3";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total_net=$total_pur=$total_brut=$total=$total_cnet=$total_cbrut=$totalc=0;
		while (($com_cd_pr,$com_qte,$com_puni)=$sth->fetchrow_array){
			$pr_desi="";
			$query="select pr_desi,pr_ventil,pr_pdn,pr_pdb,pr_deg/100,pr_douane from produit where pr_cd_pr='$com_cd_pr' ";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($pr_desi,$pr_cd_fr,$pr_pdn,$pr_pdb,$pr_deg,$prb_ndp_sh)=$sth2->fetchrow_array;
			$mont=&separateur($com_puni*$com_qte,2);
			$com_puni=&separateur($com_puni);
			$nbligne+1;
			$net=&separateur($pr_pdn*$com_qte/1000,2);
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$pr_pdn,$net,$com_puni,$mont);
			$total_net+=$net;
			$total+=$mont;
	
			$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$com_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
			$info_entree="entree sous $fr8_doc le $fr8_date document precedent $fr8_info créé à $fr8_lieu";
	#                 if ($fr8_doc ne ""){print "<tR><td colspan=8>$info_entree</td></tr>";}
	
	#                 {$info_entree="Information non disponible";}
			$total_net+=$total_cnet;
			$total_brut+=$total_cbrut;
			$total+=$totalc;
		}	
		print &ligne_tab("<b>","","","","","",$total_net,"",$total);
		print "</table>";                                             
		
		print "<b>Calcul des Droits et taxes produit intermediaire</b><br><table>";
		print " <tr><td>";
		print "Accises  $total_net*2.14</td><td align=right>= ";
		print &separateur($total_net*2.14,2);
		print "</td></tr><tr><td>";
		print "Total</td><td align=right><b>= ";
		print &separateur($total_net*2.14,2);
		print "</td></tr><tr><td>";
		print "</table><br><br>";	
	}
	$nbligne=0;
	$ok=&get("select count(*) from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and pr_ventil=4");
        if ($ok>0){
		print "$no_cde <b>Vin doux naturel</b><table border=1 cellspacing=0>";
		print &ligne_tab("<b>","ndp","code","designation","qte","litrage","Volume litre","prix unitaire","montant");
		$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli,produit where coc_no='$no_cde' and coc_cd_pr=pr_cd_pr and pr_ventil=4";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total_net=$total_pur=$total_brut=$total=$total_cnet=$total_cbrut=$totalc=0;
		while (($com_cd_pr,$com_qte,$com_puni)=$sth->fetchrow_array){
			$pr_desi="";
			$query="select pr_desi,pr_ventil,pr_pdn,pr_pdb,pr_deg/100,pr_douane from produit where pr_cd_pr='$com_cd_pr' ";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($pr_desi,$pr_cd_fr,$pr_pdn,$pr_pdb,$pr_deg,$prb_ndp_sh)=$sth2->fetchrow_array;
			$mont=&separateur($com_puni*$com_qte,2);
			$com_puni=&separateur($com_puni);
			$nbligne+1;
			$net=&separateur($pr_pdn*$com_qte/1000,2);
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$pr_pdn,$net,$com_puni,$mont);
			$total_net+=$net;
			$total+=$mont;
	
			$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$com_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
			$info_entree="entree sous $fr8_doc le $fr8_date document precedent $fr8_info créé à $fr8_lieu";
	#                 if ($fr8_doc ne ""){print "<tR><td colspan=8>$info_entree</td></tr>";}
	
	#                 {$info_entree="Information non disponible";}
			$total_net+=$total_cnet;
			$total_brut+=$total_cbrut;
			$total+=$totalc;
		}	
		print &ligne_tab("<b>","","","","","",$total_net,"",$total);
		print "</table>";                                             
		
		print "<b>Calcul des Droits et taxes vins doux naturel</b><br><table>";
		print " <tr><td>";
		print "Accises  $total_net*0.54</td><td align=right>= ";
		print &separateur($total_net*0.54,2);
		print "</td></tr><tr><td>";
		print "Total</td><td align=right><b>= ";
		print &separateur($total_net*0.54,2);
		print "</td></tr><tr><td>";
		print "</table>";	
	}


=pod	
	if ($total_net3>0){
		print "<br><br><b>Calcul des Droits et taxes Produit intermediaire</b><br><table><tr><td>";
		print " €</td></tr><tr><td>";
		print "Litrage  $total_net*2.14</td><td align=right>= ";
		print &separateur($total_net*2.14,2);
		print " €</td></tr><tr><td>";
		print " €</td></tr><tr><td>";
#	
 	}
		
	print "Tva 19.6</td><td align=right>= ";
	print &separateur((($total_net*1.30+$total_pur*14.50+$total)*19.6/100),2);
	print " €</td></tr><tr><td>";
	print "Total</td><td align=right><b>= ";
	print &separateur((($total_net*1.30+$total_pur*14.50+$total)*19.6/100)+($total_net*1.30+$total_pur*14.50),2);
	print " €</td></tr></table>";
			if ($pr_cd_fr == 3){ 
			$net=&separateur($pr_pdn*$com_qte/1000,2);
			$brut="-";
			$pur="-";
			$pr_deg="-";
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$pr_pdn,$brut,$com_puni,$mont,$pr_deg,$pur);
			$total_net3+=$net;
			# $total_brut+=$brut;
			# $total_pur+=$pur;
			$total+=$mont;
		}

=cut	
	# $total_cnet=8;
	if ($total_cnet>0){
		if ($total_pur==0){
			print &ligne_tab("<b>","","","","",$total_cnet,$total_cbrut,"",$totalc,"&nbsp;","&nbsp;");
			print "</table>";
		}
		print "<br><br><b>Calcul des Droits et taxes</b><br><table><tr><td>";
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
=pod		
		if ($pr_cd_fr == 15){# cigarette
			$net=&separateur($pr_pdn*$com_qte/1000,2);
			$brut=&separateur($pr_pdb*$com_qte/1000,2);
			print &ligne_tab("",$prb_ndp_sh,$com_cd_pr,$pr_desi,$com_qte,$net,$brut,$com_puni,$mont,"&nbsp;","&nbsp;");
			$total_cnet+=$net;
			$total_cbrut+=$brut;
			$totalc+=$mont;
		}
		
=cut
}
