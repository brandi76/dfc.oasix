sub select_navire(){
	$navire=$_[0];
	print "<br> Choix d'un navire<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		if ($tables[0] eq $navire){ print " selected";}
		print ">$tables[0]\n";
	}
    	print "</select><br>\n";
}

sub select_produit(){
	my $produit,$desi;
	print "<br> Choix d'un produit<br>";
	$sth = $dbh->prepare("select nav_cd_pr,pr_desi from navire2,produit where nav_cd_pr=pr_cd_pr group by pr_cd_pr order by pr_cd_pr ");
    	$sth->execute;
   	print "<br><select name=produit>\n";
    	while (($produit,$desi)= $sth->fetchrow_array) {
       		print "<option value=$produit";
       		print ">$produit $desi\n";
	}
    	print "</select><br>\n";
}



# entree  nom du navire, code produit 
# sortie %calcul
# date_mini 		date du dernier inventaire
# nofact_mini 		premier numero de facture apres le dernier inventaire
# inv 			valeur de l'inventaire
# liv 			quantite livre
# vendu			quantite vendu	
# max			quantite maximum vendu sur une semaine
# stock navire  	quantite a bord
# stock mini 		stock alerte
# alivre 		quantite a livrer
# stock_minisuiv 	quantite pour la semaine apres
 
sub table_navire(){
	my $navire=$_[0];
	my $pr_cd_pr=$_[1];
	my $option=$_[2];
	my(@liste_date_liv)=(); 
	my(@liste_date_ven)=();
	my(%calcul);
	my($date_mini,$nb);
	my (@top60)={};
	my (@top120)={};
	
	# verification si le produits est liste Ã  bord
	my($existe)=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr='$pr_cd_pr'","af")+0;
	if (! $existe){
		if ($option eq "debug"){ 
			print "$navire produit non liste a bord<br>";
		}
		return(%calcul);
	}
	# optimisation
   	$query="select ta_cd_pr,stockmini_suivsuiv,date_mini,stockmini_suiv,prev,coef1,coef2,vs,coef3,coef4,max,vsp1,nofact_mini,vsp2,stockmini,ecart,liv,stock_plancher,inv,vendu,semaine,alivrer,stock_navire from table_navire where ta_cd_pr='$pr_cd_pr' and ta_navire='$navire' and date_modif=now()";
 	my($sth)=$dbh->prepare($query);
 	$sth->execute();
 	my($ta_cd_pr,$stockmini_suivsuiv,$date_mini,$stockmini_suiv,$prev,$coef1,$coef2,$vs,$coef3,$coef4,$max,$vsp1,$nofact_mini,$vsp2,$stockmini,$ecart,$liv,$stock_plancher,$inv,$vendu,$semaine,$alivrer,$stock_navire)=$sth->fetchrow_array;
 	if (($ta_cd_pr ne "")&&($option eq "quick")){
 		$calcul{"stockmini_suivsuiv"}=$stockmini_suivsuiv;
 		$calcul{"date_mini"}=$date_mini;
 		$calcul{"stockmini_suiv"}=$stockmini_suiv;
 		$calcul{"prev"}=$prev;
 		$calcul{"coef1"}=$coef1;
 		$calcul{"coef2"}=$coef2;
 		$calcul{"vs"}=$vs;
 		$calcul{"coef3"}=$coef3;
 		$calcul{"coef4"}=$coef4;
 		$calcul{"max"}=$max;
 		$calcul{"vsp1"}=$vsp1;
 		$calcul{"nofact_mini"}=$nofact_mini;
 		$calcul{"vsp2"}=$vsp2;
 		$calcul{"stockmini"}=$stockmini;
 		$calcul{"ecart"}=$ecart;
 		$calcul{"liv"}=$liv;
 		$calcul{"stock_plancher"}=$stock_plancher;
 		$calcul{"inv"}=$inv;
 		$calcul{"vendu"}=$vendu;
 		$calcul{"semaine"}=$semaine;
 		$calcul{"alivrer"}=$alivrer;
 		$calcul{"stock_navire"}=$stock_navire;
 	}
        else {
	
	
	
	
	# ajout le 16 novembre 2006 gestion du stock mini par topten
	
	######################
        ##### TOP TEN ########
        ######################
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 60";
	$sth_ou=$dbh->prepare($query);
	$sth_ou->execute();
	while (($top_cd_pr,$top_qte)=$sth_ou->fetchrow_array){
		push (@top60,$top_cd_pr);
	}

	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 120";
	$sth_ou=$dbh->prepare($query);
	$sth_ou->execute();
	while (($top_cd_pr,$top_qte)=$sth_ou->fetchrow_array){
		push (@top120,$top_cd_pr);
	}
	$existe=3;
	if (grep /$pr_cd_pr/,@top120){$existe=6;}
	my($pr_sup)=&get("select pr_sup from produit where pr_cd_pr='$pr_cd_pr'");
	if ($pr_sup!=0 && $pr_sup!=3){$existe=6;}
	
	
	# recuperation de la date la plus recentes d'inventaire
	$query="select count(*) from navire2 where nav_nom='$navire' and nav_type=1 and nav_cd_pr='$pr_cd_pr'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$nb=$sth->fetchrow_array;
# 	if ($nb==0){
# 		$calcul{'date_mini'}=&get("select nav_date from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr='$pr_cd_pr'","aff")+0;
# 	}
# 	else
# 	{
		$query="select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=1 ";
# 		print "$query";
		my($sth)=$dbh->prepare($query);
		$sth->execute();
		$calcul{'date_mini'}=$sth->fetchrow_array;
		if ($calcul{'date_mini'} eq ''){
			$query="select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=0 ";
	# 		print "$query";
			my($sth)=$dbh->prepare($query);
			$sth->execute();
			$calcul{'date_mini'}=$sth->fetchrow_array;
		}
# 	}	
	$date_mini=$calcul{'date_mini'};
	if ($option eq "debug"){print "$pr_cd_pr<br>date la plus recente d'inventaire:$date_mini<br>";}
	
	# recuperation du premier numero de facture apres le dernier inventaire
	my($date_mini_simple)=&datesimple($calcul{'date_mini'});	
	if ($calcul{'date_mini'}=="9999-99-99"){$date_mini_simple=99999999;}
	$query="select min(ic2_no) from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000 and ic2_fact>0 ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$calcul{'nofact_mini'}=$sth->fetchrow_array;
	if ($calcul{'nofact_mini'} eq "") {$calcul{'nofact_mini'}=99999999999;}

	if ($option eq "debug"){print "premier numero de facture apres inventaire:".$calcul{'nofact_mini'}."<br>";}
	
	# recuperation de la liste des factures  apres le dernier inventaire
	$query="select ic2_no,ic2_date from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000 and ic2_fact>0 group by ic2_date order by ic2_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((my($no),my($datef))=$sth->fetchrow_array){
		if ($option eq "debug"){print "factures prisent en compte:$no $datef<br>";}
		push (@liste_date_liv , $datef);
	}

	# recuperation des dates de ventes  apres le dernier inventaire
	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>'$date_mini' and nav_cd_pr='$pr_cd_pr' group by nav_date order by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		if ($option eq "debug"){print "date des vendus pris en compte:$no<br>";}
		push (@liste_date_ven , $no);
	}
        
        # recuperation des date de vente <-> no semaine
	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_date > DATE_SUB(curdate(),INTERVAL 6 MONTH) group by nav_date order by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_date)=$sth->fetchrow_array){
		$no_semaine{&semaine($nav_date)}=$nav_date;
		# print &semaine($nav_date)."<br>";
	}
=pod	
	$max_date_vendu=&get("select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>'$date_mini'");
	$max_date_vendu=&get("select count(*) from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>'$date_mini'");
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$nb=$sth->fetchrow_array;
	if ($nb==0){$max_date_vendu="9999-99-99";}
=cut	
	# recuperation de l'inventaire
	$query="select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr='$pr_cd_pr'";
	my($sth2)=$dbh->prepare($query);
	$sth2->execute();
	$calcul{"inv"}=$sth2->fetchrow_array+0;
	if ($option eq "debug"){print "Inventaire:".$calcul{"inv"}."<br>";}
	
	# quantite livre
	my($liv_d)=0;
	$calcul{"liv"}=0;
	foreach (@liste_date_liv){
		$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr='$pr_cd_pr' and ic2_no>='$icc_mini' and ic2_date='$_' group by coc_cd_pr"; 
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$liv_d=$sth2->fetchrow_array+0;
		$calcul{"liv"}+=$liv_d;
		if (($option eq "debug")&&($liv_d>0)){print "$_ livre:$liv_d<br>"; }
	}
	if ($option eq "debug"){print "Qte livree:".$calcul{"liv"}."<br>";}
	
	# quantite vendu
	my($vendu_d)=0;
	my($date);
	my($semaine);
	my($max);
	$calcul{"vendu"}=0;
	foreach (@liste_date_ven){
		$query="select sum(nav_qte),nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date='$_' group by nav_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($vendu_d,$date)=$sth2->fetchrow_array;
		$vendu_d+=0;
		$calcul{"vendu"}+=$vendu_d;
		if (($option eq "debug")&&($vendu_d>0)){print "$_ vendu:$vendu_d<br>"; }

	}
	if ($option eq "debug"){print "Qte vendu:".$calcul{"vendu"}."<br>";}
	
	# ecart de stock
	$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr='$pr_cd_pr' and nav_date>'$date_mini'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$calcul{"ecart"}=$sth->fetchrow_array+0;
	
	if ($option eq "debug"){
		print "Ecart constate:".$calcul{"ecart"}."<br>";
		$query="select nav_qte,nav_date from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr='$pr_cd_pr' and nav_date>'$date_mini'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($nav_qte,$nav_date)=$sth->fetchrow_array){
			if ($nav_qte!=0){print "$nav_qte $nav_date <br>";}
		}
	
	}

	
	############## stock navire ##############################
	$calcul{"stock_navire"}=$calcul{'inv'}+$calcul{'liv'}-$calcul{'vendu'}+$calcul{"ecart"}+0;
	  
	if ($option eq "debug"){print "Stock navire:".$calcul{"stock_navire"}."<br>";}
	if ($calcul{"stock_navire"}<0){$calcul{"stock_navire"}=0;}

	
	
	#####################  Calcul du a livrer  #####################
	
	$semaine=&semaine("");
	$semaine_p_4=$semaine+4;
	$check=&get("select sum(se_coef) from semaine2 where se_no>='$semaine' and se_no<='$semaine_p_4' and se_navire='$navire'");
	if ($check ==0){$existe=0;} # navire arrete
	
	$total_vendu_s=0;
	$significatif=0;
	# $sign_ref=(&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr='$pr_cd_pr'")+0)/4;
	# pour etre significatif il faut que les ventes soient superieur Ã  un quart du stock mini
	
	# calcul des vendus de s-1 à s-4 dernieres semaines
	for ($t=$semaine-1;$t>$semaine-4;$t--){
		$i=$t;
		if ($i <= 0){$i=$i+52;}		
		$date_s=$no_semaine{$i};
		$vendu_s=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date='$date_s' group by nav_cd_pr")+0;
	 	# if ($vendu_s>$sign_ref) {$significatif=1;}
	 	$coef=&get("select se_coef from semaine2 where se_no='$i' and se_navire='$navire'");
		if ($coef){
			$total_vendu_s+=$vendu_s/$coef;
		}
	}
	
	# les vendus en reference est egale à la moyenne
	$calcul{"max"}=0;
       	$calcul{"max"}=$total_vendu_s/3;
    	if ($option eq "debug"){
		print "vendu ref".$calcul{"max"}."<br>";
	}

       	
       	
       	# }
	if ($calcul{"stock_navire"}==0){
	# manquant dans ce cas on prendre le max des 3 derniers mois	
# 		 $max=&get("select max(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date>DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr")+0;
       	 
#         	 if ($max>6){
#         	 	$max=6;
#         	 	if (grep /$pr_cd_pr/,@top120){$existe=6;}
#         	 } # ajouter le 228/08/07 pour palier a des extremes
        	 
#         	 $date_max=&get("select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_qte='$max'");
# 		 $i=&semaine($date_max);
# 		 $coef=&get("select se_coef from semaine2 where se_no='$i' and se_navire='$navire'");
#         	 if ($coef){
# 			 $calcul{"max"}=$max/$coef;
# 		 }
		# modifie le 10/10/07
		$calcul{"max"}=0.3;
	 	if (grep /$pr_cd_pr/,@top120){$calcul{"max"}=1;}
	 	if (grep /$pr_cd_pr/,@top60){$calcul{"max"}=2;}
         
     		if ($option eq "debug"){
			print "manquant vendu ref modifie".$calcul{"max"}." $max <br>";
# 			$i $coef<br>";
		}
	}
	
	$calcul{"semaine"}=$semaine;
	my($coef1,$coef2);
	$coef1=&get("select se_coef from semaine2 where se_no='$semaine' and se_navire='$navire'","af");
	$semaine++;
	$coef2=&get("select se_coef from semaine2 where se_no='$semaine' and se_navire='$navire'");
	
	$calcul{"vs"}=int($calcul{"max"}*$coef1);
	$calcul{"vsp1"}=int($calcul{"max"}*$coef2);
	# print "<font color=red>$coef2:".$calcul{"vsp1"};
	$calcul{"stockmini"}=int(($calcul{"max"}*$coef1)+($calcul{"max"}*$coef2));
 	# print "max:".$calcul{"max"};                                             
 	                                             
	$calcul{"coef1"}=$coef1+0;
	$calcul{"coef2"}=$coef2+0;
	$calcul{"prev"}=$calcul{"stockmini"}+0;
	$calcul{"stock_plancher"}=$existe;
		
	# existe c est le stock plancher
	
	$calcul{'alivrer'}=$existe+$calcul{'stockmini'}-$calcul{'stock_navire'};
	if ($option eq "debug"){ 
	print "existe:$existe: stockmini:",$calcul{'stockmini'},"->semaine $semaine navire:",$calcul{'stock_navire'};
	print " alivrer:".$calcul{'alivrer'};
	print "<br>";}
	# si la quantite a livrer est negative c'est du sur_stock
	# if ($calcul{'alivrer'}<=0){
			#$calcul{'alivrer'}=0;
		#}
	if ($calcul{'alivrer'}>18){
		$calcul{'alivrer'}=18;  # limite a 18 ventes par semaine
	}
		
	my($suivant)=0;
	$semaine++;
	$coef1=&get("select se_coef from semaine2 where se_no='$semaine' and se_navire='$navire'");
	$calcul{"vsp2"}=int($calcul{"max"}*$coef1);
	
	# 2 semaine 
	$semaine++;
	$coef2=&get("select se_coef from semaine2 where se_no='$semaine' and se_navire='$navire'");
	$calcul{'stockmini_suiv'}=int(($calcul{"max"}*$coef1)+($calcul{"max"}*$coef2));
	if ($option eq "debug"){ print "max:",$calcul{'max'},"coef1:$coef1 coef2:$coef2<br>";}
	if ($calcul{'stockmini_suiv'}>36){$calcul{'stockmini_suiv'}=36;}
	# securite
	# $calcul{'alivrer'}+=$calcul{'stockmini_suiv'};
	# surstock;
	if ($calcul{'alivrer'}<=0){
			$calcul{'alivrer'}=0;
	}
	if ($option eq "debug"){ print "semaine suivante:".$calcul{'stockmini_suiv'}." alivrer:".$calcul{'alivrer'}."<br>"};
	
	$semaine++;
	$coef3=&get("select se_coef from semaine2 where se_no='$semaine' and se_navire='$navire'");
	$calcul{'stockmini_suivsuiv'}=int($calcul{"max"}*$coef3)+0;
	$calcul{"coef3"}=$coef1+0;
	$calcul{"coef4"}=$coef2+0;
	$query="replace into table_navire value ('$navire','$pr_cd_pr',";
	$query=$query.$calcul{"stockmini_suivsuiv"}.",'".$calcul{"date_mini"}."',".$calcul{"stockmini_suiv"}.",".$calcul{"prev"}.",".$calcul{"coef1"}.",".$calcul{"coef2"}.",".$calcul{"vs"}.",".$calcul{"coef3"}.",".$calcul{"coef4"}.",".$calcul{"max"}.",".$calcul{"vsp1"}.",".$calcul{"nofact_mini"}.",".$calcul{"vsp2"}.",".$calcul{"stockmini"}.",".$calcul{"ecart"}.",'".$calcul{"liv"}."','".$calcul{"stock_plancher"}."',".$calcul{"inv"}.",".$calcul{"vendu"}.",".$calcul{"semaine"}.",".$calcul{"alivrer"}.",".$calcul{"stock_navire"}.",now())";
	&save($query,"af");
	# print $query;
	# foreach $cle (keys(%calcul)){
	# print "\$calcul{\"$cle\"}=\$$cle;<br>";
	# print "$cle,";

 	}
	return(%calcul);
}


sub tablenew_navire()
{
	
	my($pr_cd_pr)=$_[0];
	my($rank_fam1)=$_[1];
       	my($rank_fam2)=$_[2];
        my($navire)=$_[3];
        my($rank);
        my($type);
        my($jour);
        my($mois);
        my($max);
        my ($semaine);
        my(%calcul);
        @liste=("MEGA 5","MEGA 2","MEGA 4");
	my($an)=&get("select year(now())")-1;
	if ($rank_fam1 eq ""){$rank_fam1=500;}
	if ($rank_fam2 eq ""){$rank_fam2=500;}
#  	print "*$rank_fam1 $rank_fam2 * $mois";
	if (grep /$navire/,@liste){
		$type=1;
		if ($rank_fam1<=10){$rank="0_10";}
		if (($rank_fam1>10)&&($rank_fam1<=20)){$rank="10_10";}
		if (($rank_fam1>20)&&($rank_fam1<=30)){$rank="20_10";}
		if (($rank_fam1>30)&&($rank_fam1<=60)){$rank="30_30";}
		if (($rank_fam1>60)&&($rank_fam1<=90)){$rank="60_30";}
		if (($rank_fam1>90)&&($rank_fam1<=120)){$rank="90_30";}
		if ($rank_fam1>120){$rank="120_500";}
	}
	else
	{
		$type=2;
		if ($rank_fam2<=30){$rank="0_30";}
		if (($rank_fam2>30)&&($rank_fam2<=60)){$rank="30_30";}
		if ($rank_fam2>60){$rank="60_500";}
	}
		
#  print "<font color=red> $pr_cd_pr $rank<br>";
	for ($i=0;$i<7;$i++){
		$jour=$i*7;
		$mois=&get("select month(date_add(now(),INTERVAL $jour DAY))");
		$mois=$mois+($an*100)-200000;
		$max=&get("select qte from maxmois where type=$type and rank='$rank' and mois=$mois","af");
		if (($max%4)!=0){$max=1+int($max/4);}else{$max=$max/4;}
# 		print "$i max: $max";
		$calcul{"s+$i"}=$max;
 		$semaine=&semaine(&get("select date_add(curdate(),INTERVAL $jour DAY)","af"));
 		# navire arrete
 		if (&get("select se_coef from semaine2 where se_navire='$navire' and se_no=$semaine","af")==0){
#  			print "$navire*";
			$calcul{"s+$i"}=0;
 		}
	}
# 	if ($pr_cd_pr==737052892412){print "$pr_cd_pr ".$calcul{"s+0"}."<br>";}
	
	$calcul{"type"}=$type;
	return(%calcul);
}


sub stock_navire()
{
	
	my($pr_cd_pr)=$_[0];
	my($navire)=$_[1];
	my($option)=$_[2];
	# recuperation de la date la plus recentes d'inventaire
	my($date_mini)=0;
	$date_mini=&get("select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=1","af");
	if (($date_mini eq "")&&($option eq "debug")){print "<font color=red fonsize=+2>Pas de date d'inventaire '$navire' stop</font>";return();}
	if ($option eq "debug"){print "$pr_cd_pr<br>date la plus recente d'inventaire:$date_mini<br>";}
	my($date_mini_simple)=&datesimple($date_mini);	
	if ($calcul{'date_mini'}=="9999-99-99"){$date_mini_simple=99999999;}
	my($liv)=0;
	$liv=0+&get("select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr='$pr_cd_pr' and ic2_date>$date_mini_simple","af"); 
	my($vendu)=0;		
	$vendu=0+&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date>'$date_mini' group by nav_cd_pr","af");
	my($inv)=0;
	$inv=0+&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr='$pr_cd_pr'");
	if ($option eq "debug"){print "Inventaire:$inv Vendus:$vendu livré:$liv<br>";}
	$inv=$inv+$liv-$vendu;
	return($inv);	
}



sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}

sub max {
	if ($_[0]>$_[1]){return($_[0]);} else {return($_[1]);}
}
sub inverse {
	if ($_[0] eq $_[1]){return($_[2]);} else {return($_[1]);}
}

1;
