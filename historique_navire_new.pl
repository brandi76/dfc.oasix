#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

# $perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$option=$html->param("option");
$prodet=$html->param("produit");
$maj=$html->param("maj");
require "./src/connect.src";
@liste=("MEGA 1","MEGA 2","MEGA 4","SERENA II");
print "<title>Historique navire </title>";
if ($action eq ""){
	print "<body><center><h1>Historique navire<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
    	print "<br></h1>Mise à jour du fichier pour la creation de la commande ? <input type=checkbox name=maj checked><br><input type=hidden name=action value=visu><br><input type=submit value=voir></form></body>";
}
	

if ($action eq "visu"){
	&save("create temporary table liste1 (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
	$liste_nav="and (nav_nom='MEGA 1' or nav_nom='MEGA 2' or nav_nom='MEGA 4') ";
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_nav group by nav_cd_pr order by qte desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$i=0;
	while (($nav_cd_pr,$null)=$sth->fetchrow_array){
		&save("insert into liste1 values ('$nav_cd_pr','$i')","af");
		$i++;
	}
	&save("create temporary table liste2 (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
	$liste_nav="and (nav_nom!='MEGA 1' and nav_nom!='MEGA 2' and nav_nom!='MEGA 4') ";
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_nav group by nav_cd_pr order by qte desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$i=0;
	while (($nav_cd_pr,$null)=$sth->fetchrow_array){
		&save("insert into liste2 values ('$nav_cd_pr','$i')","af");
		$i++;
	}
	if ($maj eq "on"){
		print "<font color=red>mise à jour de importcsv<br></font><br>";
		$query = "delete from corsica ";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$query = "replace into corsica values (10001,'2000469',0,'500')";
		if ($navire eq "EXPRESS 2") 
		{
			$query = "replace into corsica values (10001,'2001841',0,'800')";
		}
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	&table($navire);
	print "</body></html>";
}

if ($action eq "detail"){
	&table($navire);
	print "</body></html>";
}


sub table(){
	my $navire=$_[0];
	print "<h1>$navire</h1>";
	print "<table border=1 cellspacing=0><tr bgcolor=yellow><th><font size=-2>";
	print "Code produit</th><th><font size=-2>désignation</th><th ><font size=-2>Info</th>";
 	print "<th><font size=-2>stock navire</th><th><font size=-2>a livrer</th></tr>";
	$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup,nav_pos from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and pr_sup!=5 and (pr_type=1 or pr_type=5) and nav_cd_pr>100000000 group by nav_cd_pr order by nav_cd_pr ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_sup,$nav_pos)=$sth->fetchrow_array){
	       	$rank_fam1=&get("select tmp_rank from liste1 where tmp_cd_pr=$pr_cd_pr");
		$rank_fam2=&get("select tmp_rank from liste2 where tmp_cd_pr=$pr_cd_pr");
		
	       	################ RECUPERATION DU STOCK (outils_corsica.pl) ############
	       	$stock_navire=&stock_navire($pr_cd_pr,"$navire","$option")+0;
	       	######################################################################
               	
               	################# CALCUL DU BESOIN  (outils_corsica).pl################
               	%res=&tablenew_navire($pr_cd_pr,$rank_fam1,$rank_fam2,"$navire");
               	##############################################
               	
             	%stock=&stock($pr_cd_pr,'','quick','');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
                if ($pr_stre<=0 && (($pr_sup==7)||($pr_sup==1))){next; } # produit deliste
		print "<tr><td>$pr_cd_pr</a></td>";
		print "<td><font size=-2>";
		if ($pr_sup==0 || $pr_sup==3){print "<b>";}
		print "$pr_desi</td>";
		if (grep /$navire/,@liste){$info=$rank_fam1;}else{$info=$rank_fam2;}
                if ($pr_sup==3){$info="new";}
		print "<td><font size=-3>$info</td>";
 		# stock navire 
		print "<td align=right><b>";
		if (($stock_navire==0)&& ($info<50) && ($pr_sup==0 || $pr_sup==3)){print "<font color=red>";}
		print "$stock_navire</b></td>";
		$total_stock+=$stock_navire;
        	$color="black";
		 $alivrer=$res{"s+0"}+$res{"s+1"}-$stock_navire;
# 		 print  "$pr_cd_pr ".$res{"s+0"}." ".$stock_navire."<br>";
# 		if (grep /$navire/,@liste){
# 			$alivrer=$res{"s+0"}-$stock_navire;
# 		}
# 		else
# 		{
			# 1 mois
# 	        	$alivrer=$res{"s+3"}+$res{"s+2"}+$res{"s+1"}+$res{"s+0"}-$stock_navire;
# 	
# 	        }
	
		$pr_four=&get("select pr_four from produit where pr_cd_pr='$pr_cd_pr'");
# 		if (($pr_four==2250)&&($pr_sup==0)){$alivrer+=2;}
# 		if (($info <50)&&($navire eq "MEGA 2")&&($pr_four!=2250)){$alivrer+=2;}		
# 		if (($info <50)&&($navire eq "MEGA 1")&&($pr_four!=2250)){$alivrer+=2;}		

		if ($alivrer<0){$alivrer=0;}
	
		# concours kenzo
# 		if (($info>100)&&($stock_navire>=3)&&($pr_four!=2250)){$alivrer=0;}
		if (($info eq "new")&&($stock_navire<=6)){$alivrer=6-$stock_navire;}
# 		print "<td>*$alivrer* </td>";
		if ($alivrer + $stock_navire <3){$alivrer=3-$stock_navire;}
		if (($stock_navire==0)&&($pr_sup==0)){
		$manquant++;
# 		print "$pr_cd_pr $pr_desi<br>";
		}
		if (($stock_navire>0)&&($pr_sup==0)){
		$nb++;                          }
		
		
		if (($alivrer>0)&&($maj eq "on")){
			$query = "replace into corsica values (10001,'$pr_cd_pr',0,'".$alivrer."')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
		}
		
		if ($alivrer>0){
				$total_stock_alivrer+=$alivrer;
		}
		print "<td align=right><font color=$color>".$alivrer;
		if ($alivrer > $pr_stre)
		{
			if ($pr_sup==0 || $pr_sup==3){
				print ";<font color=red>$pr_stre</font>";
                        }
                        else
                        {
				print ";<font color=green>$pr_stre</font>";
			}
			$total_alivrerm+=$pr_stre;
		}
		else {
			
			$total_alivrerm+=&max($alivrer,0);
		}
		
		print "</td></tr>";
  	}
	print "</tr><th colspan=3>Total</th>";
        print "<th align=right>$total_stock</th>";
	print "<th align=right><nobr><font color=red>$total_stock_alivrer /</font><font color=green>$total_alivrerm</th>";
	print "</tr></table><br>";
	print "Nombre de manquant:$manquant $nb top60:$manquant_top surstock:$surstock<br>";


}


