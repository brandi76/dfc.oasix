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
if (($maj ne "on")&&($option ne "debug")){$option="quick";}
require "./src/connect.src";
print "<title>Historique navire</title>";
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
	if ($maj eq "on"){
# 		foreach $cle (keys(%ENV)){
# 		print "$cle:$ENV{$cle}<br>";
# 		} 
# 		print "*".$ENV{'HTTP_REFERER'}."*";
		print "<font color=red>mise à jour de importcsv<br></font><br>";
		$query = "delete from corsica ";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$query = "replace into corsica values (10001,'2000469',0,'200')";
		# if (($navire eq "MEGA 1") || ($navire eq "MEGA 2")) 
		# {
			# $query = "replace into corsica values (10001,'2000469',0,'600')";
		# }
		# $sth=$dbh->prepare($query);
		# $sth->execute();
		if ($navire eq "EXPRESS 2") 
		{
			$query = "replace into corsica values (10001,'2001841',0,'800')";
		}
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	$stock_navire_gg=0;

	if ($navire ne "tout") {
		&table($navire);
	}
	else 
	{
		$sthg = $dbh->prepare("select nav_nom from navire");
		$sthg->execute;
		while (($navire) = $sthg->fetchrow_array) {
      			&table($navire);
		}
	}
      
	
	print "</body></html>";
}

if ($action eq "detail"){
	&table($navire);
	print "</body></html>";
}


sub table(){
	my $navire=$_[0];
	$stock_navire_g=0;
	$trop=0;
	$pastrop=0;
	@liste_date_liv=(); 
	@liste_date_ven=();
	print "<h1>$navire</h1>";
	$s=&semaine("");
	$s_3=$s-3;
	$s_2=$s-2;
	$s_1=$s-1;
	$sp1=$s+1;
	$sp2=$s+2;
	
	$datesimple=&get("select date_sub(now(),interval 8 month)");
	($ans,$moiss,$jours)=split(/-/,$datesimple);
	$ans=substr($ans,2,2);
	$datesimple=1000000+$ans*10000+$moiss*100;
	$query="select ic2_no,ic2_date from infococ2 where ic2_com1='$navire' and ic2_date>$datesimple and ic2_fact>0" ;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ic2_no,$ic2_date)=$sth->fetchrow_array){
		$date="20".substr($ic2_date,1,2).'-'.substr($ic2_date,3,2).'-'.substr($ic2_date,5,2);
		# print "$date/".&semaine($date)."/$s_1<br>";
		if (&semaine($date)==$s_3) { push (@lsm3,$ic2_no);}
		if (&semaine($date)==$s_2) { push (@lsm2,$ic2_no);}
		if (&semaine($date)==$s_1) { push (@lsm1,$ic2_no);}
		# ajout de la semaine en cours a la semaine -1 pour pouvoir tenir comptes des livraisons récentes
		if (&semaine($date)==$s) { push (@lsm1,$ic2_no);}

	}
	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>date_sub(now(),interval 8 month) group by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_date)=$sth->fetchrow_array){
		if (&semaine($nav_date)==$s_3) { $vsm3=$nav_date;}
		if (&semaine($nav_date)==$s_2) { $vsm2=$nav_date;}
		if (&semaine($nav_date)==$s_1) { $vsm1=$nav_date;}
	}
	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=3 and nav_date>date_sub(now(),interval 8 month) group by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_date)=$sth->fetchrow_array){
		if (&semaine($nav_date)==$s_3) { $esm3=$nav_date;}
		if (&semaine($nav_date)==$s_2) { $esm2=$nav_date;}
		if (&semaine($nav_date)==$s_1) { $esm1=$nav_date;}
	}
	print "<table border=1 cellspacing=0><tr bgcolor=yellow><th rowspan=2><font size=-2>";
	print "Code produit</th><th rowspan=2><font size=-2>neptune</th><th rowspan=2><font size=-2>désignation</th><th rowspan=2><font size=-2>Info</th>";
	print "<th colspan=3 align=center bgcolor=#ffffcc><font size=-2>Semaine -3 (";
	print $s_3.") coef:";
	print &get("select se_coef from semaine2 where se_no='$s_3' and se_navire='$navire'");
	print "</th>";
	print "<th colspan=3 align=center><font size=-2>Semaine -2 (";
	print $s_2.") coef:";
	print &get("select se_coef from semaine2 where se_no='$s_2' and se_navire='$navire'");
	print "</th>";
	print "<th colspan=3 align=center bgcolor=#ffffcc><font size=-2>Semaine -1 (";
	print $s_1.") coef:";
	print &get("select se_coef from semaine2 where se_no='$s_1' and se_navire='$navire'");
	print "</th>";
 	print "<th rowspan=2><font size=-2>stock navire</th><th rowspan=2><font size=-2>stock plancher</th><th rowspan=2><font size=-2>Qte vendu ref</th><th rowspan=2><font size=-2>Semaine 0 (";
 	print $s.") coef:";
	print &get("select se_coef from semaine2 where se_no='$s' and se_navire='$navire'");
	print "<br>vente (Previson)</th>";
	print "<th rowspan=2><font size=-2>Semaine + 1 (";
	print $sp1.") coef:";
	print &get("select se_coef from semaine2 where se_no='$sp1' and se_navire='$navire'");
	print "<br>vente (Previson)</th>";
	# $nav_boutique=&get("select nav_boutique from navire where nav_nom='$navire'");
	# if ($nav_boutique==2){
	#	print "<th rowspan=2><font size=-2>Semaine + 2 (";
	#	print $sp2.") coef:";
	#	print &get("select se_coef from semaine2 where se_no='$sp2' and se_navire='$navire'");
	#	print "<br>vente (Previson)</th>";
	#	print "<th rowspan=2><font size=-2>A livrer<br>(v sem+0 +v sem+1)+max(v sem+2 , mini) - (stock navire)</th>";
	#}
	#else
	#{
		print "<th rowspan=2><font size=-2>A livrer<br>(v sem+0)+max(v sem+1 , mini) - (stock navire)</th>";
	
	#}
	print "</tr>";
	print "<tr bgcolor=yellow><th bgcolor=#ffffcc><font size=-2>Livraison<br>";
	foreach (@lsm3) {print "$_<br>";}
	print "</th>";
	print "<th bgcolor=#ffffcc><font size=-2>Vendus<br>$vsm3</th>";
	print "<th bgcolor=#ffffcc><font size=-2>Ecarts<br>$esm3</th>";
	print "<th><font size=-2> Livraison<br>";
	foreach (@lsm2) {print "$_<br>";}
	print "</th>";
	print "<th><font size=-2>Vendus<br>$vsm2</th>";
	print "<th><font size=-2>Ecarts<br>$esm2</th>";
	print "<th bgcolor=#ffffcc><font size=-2>Livraison<br>";
	foreach (@lsm1) {print "$_<br>";}
	print "</th>";
	print "<th bgcolor=#ffffcc><font size=-2>Vendus<br>$vsm1</th>";
	print "<th bgcolor=#ffffcc><font size=-2>Ecarts<br>$esm1</th>";
        
        ######################
        ##### TOP TEN ########
        ######################
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 30";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top30,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 0,10";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top10,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 10,10";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top11_20,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 20,10";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top21_30,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 30,30";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		# if ($pr_cd_pr==3760096760031){print "ok";}
		push (@top31_60,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 60,30";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top61_90,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 90,30";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top91_120,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 30,30";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top30_60,$pr_cd_pr);
	}
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 60";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		push (@top60,$pr_cd_pr);
		# if ($pr_cd_pr==3605530253338){print "ok";}
	}

	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 120";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		if (! (grep /$pr_cd_pr/,@top60)){
			push (@top120,$pr_cd_pr);}
	}
	
	#####################
	$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup,nav_pos from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and pr_sup!=5 and (pr_type=1 or pr_type=5) group by nav_cd_pr order by nav_cd_pr ";
	if ($prodet ne "")
	{
		$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup,nav_pos from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and pr_sup!=5 and (pr_type=1 or pr_type=5) and nav_cd_pr=$prodet group by nav_cd_pr order by nav_cd_pr ";
	
	}
	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_sup,$nav_pos)=$sth->fetchrow_array){
		if (($option eq "top60")&&(! (grep /$pr_cd_pr/,@top60))) {next;}
		# print "$pr_cd_pr<br>";
		%calcul=&table_navire($navire,$pr_cd_pr,$option);
                if ($calcul{'stock_entrepot'}<2 && (($pr_sup==7)||($pr_sup==1))){next; } # produit deliste
        	$color="white";
		$top=3;
		$stock_mini=3;
		$color=black;
		$info="flop";
		if ($pr_sup==3){$top=2;$stock_mini=6;$info="new";}
		if (($pr_sup!=0)&&($pr_sup!=3)&&($pr_sup!=5)){$stock_mini=20;$info="destockage";}

		if (grep /$pr_cd_pr/,@top60){$top=1;$stock_mini=12;$info="top 60";}
		if (grep /$pr_cd_pr/,@top120){$top=2;$stock_mini=6;$info="top 120";}
	
		# if ($nav_pos==1){$color="pink";}
		
		$vendu=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and (nav_date='$vsm3' or nav_date='$vsm2' or nav_date='$vsm1')")+0;
                # if ($vendu==0){$color="lightgreen";}
                $ligne_color=&inverse($ligne_color,"#efefef","white");
                $naviresql=$navire;
                while($naviresql=~s/ /+/){};
		print "<tr bgcolor=$ligne_color><td><font color=$color>";
		# <a href=?navire=$naviresql&produit=$pr_cd_pr&option=debug&action=visu>"
		# print "<a href=?";
		# print $ENV{"QUERY_STRING"};
		# print "&option=debug&produit=$pr_cd_pr>";
		print "$pr_cd_pr</a></td><td>";
		print "<a href=?";
		print $ENV{"QUERY_STRING"};
		print "&option=debug&produit=$pr_cd_pr>";
		print &get("select nep_cd_pr from neptune where nep_codebarre='$pr_cd_pr'");
		print "</a></td><td ";
		# if ($nav_pos==1){print " bgcolor=pink";}
		print "><font size=-2 color=$color>$pr_desi</td>";
		print "<td><font size=-3>$info</td>";
		$liv=0;
		foreach (@lsm3) {
			$liv+=&get("select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no='$_'")+0; 
   		}
   		print "<td bgcolor=#ffffcc align=right>$liv</td>";
		$total_livsm3+=$liv;
		$vendu=0;
		$vendu=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and nav_date='$vsm3' ")+0;
   		print "<td bgcolor=#ffffcc align=right>$vendu</td>";
		$total_vensm3+=$vendu;
	
		$ecart=0;
		$ecart=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr=$pr_cd_pr and nav_date='$esm3' ")+0;
   		print "<td bgcolor=#ffffcc align=right>$ecart</td>";
		$total_ecsm3+=$ecart;
		
		$liv=0;
		foreach (@lsm2) {
			$liv+=&get("select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no='$_'")+0; 
   		}
   		print "<td align=right>$liv</td>";
		$total_livsm2+=$liv;
		$vendu=0;
		$vendu=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and nav_date='$vsm2' ")+0;
   		print "<td align=right>$vendu</td>";
		$total_vensm2+=$vendu;
		$ecart=0;
		$ecart=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr=$pr_cd_pr and nav_date='$esm2' ")+0;
   		print "<td align=right>$ecart</td>";
		$total_ecsm2+=$ecart;
		
		$liv=0;
		foreach (@lsm1) {
			$liv+=&get("select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no='$_'")+0; 
   		}
   		print "<td bgcolor=#ffffcc align=right>$liv</td>";
		$total_livsm1+=$liv;
		$vendu=0;
		$vendu=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and nav_date='$vsm1' ")+0;
   		print "<td bgcolor=#ffffcc align=right>$vendu</td>";
		$total_vensm1+=$vendu;
		$ecart=0;
		$ecart=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr=$pr_cd_pr and nav_date='$esm1' ")+0;
   		print "<td bgcolor=#ffffcc align=right>$ecart</td>";
 		$total_ecsm1+=$ecart;
 		
 		# stock navire 
 		
 		if ($calcul{'stock_navire'}<0){$calcul{'stock_navire'}=0;}

 		if ($calcul{'stock_navire'}==0){
			print "<td align=right bgcolor=red><font color=white><b>$calcul{'stock_navire'}</b></td>";
			$manquant++;
			if ($top==1) {$manquant_top++;}
		}
		else {
			print "<td align=right><b>$calcul{'stock_navire'}</b></td>";
		}
		$total_stock+=$calcul{'stock_navire'};
        	$stockal=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr=$pr_cd_pr")+0;
		if ($stockal>100){	
			$calcul{'alivrer'}=$stockal;
			
			}
		# $calcul{'stock_plancher'}=$stock_mini;
		print "<td align=right>$calcul{'stock_plancher'}</td>";
		$total_stock_plancher+=$calcul{'stock_plancher'};
		$vendu_ref=int($calcul{'max'}*100)/100;
		print "<td align=right>$vendu_ref</td>";
		print "<td align=right>$calcul{'vs'}</td>";
		print "<td align=right>$calcul{'vsp1'}</td>";
		$total_vs+=$calcul{'vs'};
		$total_vsp1+=$calcul{'vsp1'};
		$total_vsp2+=$calcul{'vsp2'};

		
		# if ($nav_boutique==2){
                	# print "<td align=right>$calcul{'vsp2'}</td>";
                        # $calcul{'vsp2'}=&max($calcul{'vsp2'},$stock_mini);

                # }
	        # else
	        # {
	        	$calcul{'vsp2'}=0;
	                $calcul{'vsp1'}=&max($calcul{'vsp1'},$stock_mini);

	        # }
	
		$total_plancher+=$calcul{'stock_plancher'};
		$val_plancher+=$calcul{'stock_plancher'}*$pr_prac;
		$color="black";
		
		# $calcul{'alivrer'}=$calcul{'vs'}+$calcul{'vsp1'}+$calcul{'vsp2'}-$calcul{'stock_navire'};
		# $calcul{'alivrer'}-=$ecart;
		
		# print "<td>$calcul{'alivrer'}</td>";
		# if ($calcul{'alivrer'}<0){
			# $surstock-=$calcul{'alivrer'};
			# $calcul{'alivrer'}=0;
		# }
		 if ($calcul{'alivrer'}>18){$calcul{'alivrer'}=18;}
		 if (($calcul{'alivrer'}+$calcul{'stock_navire'})>27){$calcul{'alivrer'}=27-$calcul{'stock_navire'};}
		# modifier le 28/08/07 afin d'eviter d'avoir plus de 27 sur le navire 
                if (($navire eq "MEGA 3") or ($navire eq "REGINA") or ($navire eq "VICTORIA")){
                	if (grep /$pr_cd_pr/,@top30){
                		$calcul{'alivrer'}=15-$calcul{'stock_navire'};
                	}
                	else {
                		if (grep /$pr_cd_pr/,@top30_60){
                			$calcul{'alivrer'}=5-$calcul{'stock_navire'};
                		}
                		else  {
                			$calcul{'alivrer'}=3-$calcul{'stock_navire'};
                		} 
                	}
                }
                if (($navire eq "MEGA 1") or ($navire eq "MEGA 2") or ($navire eq "MEGA 4")){
                	if (grep /$pr_cd_pr/,@top10){
                	#23
                		$calcul{'alivrer'}=23-$calcul{'stock_navire'};
                	}
                	else {
                		if (grep /$pr_cd_pr/,@top11_20){
                			#18
                			$calcul{'alivrer'}=18-$calcul{'stock_navire'};
                		}
                                else {
					if (grep /$pr_cd_pr/,@top21_30){
					       #13
						$calcul{'alivrer'}=13-$calcul{'stock_navire'};
					}
					else  {
						if (grep /$pr_cd_pr/,@top31_60){
							$calcul{'alivrer'}=10-$calcul{'stock_navire'};
						}
						else  {
							if (grep /$pr_cd_pr/,@top61_90){
								$calcul{'alivrer'}=6-$calcul{'stock_navire'};
							}
							else  {
								if (grep /$pr_cd_pr/,@top91_120){
									$calcul{'alivrer'}=5-$calcul{'stock_navire'};
								}
								else {
									$calcul{'alivrer'}=3-$calcul{'stock_navire'};
								}
							}
						}
					} 
                		}
                	}
                }
		
		
		if (($calcul{'alivrer'}>0)&&($maj eq "on")){
			$query = "replace into corsica values (10001,'$pr_cd_pr',0,'".$calcul{'alivrer'}."')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$color="red";
		}
		
		if ($calcul{'alivrer'}>0){
				$total_stock_alivrer+=$calcul{'alivrer'};
		}
		print "<td align=right><font color=$color>".$calcul{'alivrer'};
	
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 

		if ($calcul{'alivrer'} > $pr_stre)
		{
			print ";<font color=green>$pr_stre</font>";
			$total_alivrerm+=$pr_stre;
		}
		else {
			
			$total_alivrerm+=&max($calcul{'alivrer'},0);
		}
		
		print "</td></tr>";
  	}
	print "</tr><th colspan=4>Total</th>";
	print "<th align=right>$total_livsm3</th>";
	print "<th align=right>$total_vensm3</th>";
	print "<th align=right>$total_ecsm3</th>";
	print "<th align=right>$total_livsm2</th>";
	print "<th align=right>$total_vensm2</th>";
	print "<th align=right>$total_ecsm2</th>";
	print "<th align=right>$total_livsm1</th>";
	print "<th align=right>$total_vensm1</th>";
	print "<th align=right>$total_ecsm1</th>";
        print "<th align=right>$total_stock</th>";
	print "<th align=right>$total_stock_plancher</th><th>&nbsp;</th>";
	print "<th align=right>$total_vs</th>";
        print "<th align=right>$total_vsp1</th>";
	# if ($nav_boutique==2){
	        # print "<th align=right>$total_vsp2</th>";
        # }
	print "<th align=right><nobr><font color=red>$total_stock_alivrer /</font><font color=green>$total_alivrerm</th>";
	print "</tr></table><br>";
	print "Nombre de manquant:$manquant top60:$manquant_top surstock:$surstock<br>";


}


