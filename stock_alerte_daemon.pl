#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
use CGI;
$html=new CGI;
# print $html->header();

foreach $client (@bases_client){
  if ($client eq "dfc"){next;}
  if ($client eq "formation"){next;}
  @four=();
  @lot=();
  
  $mag=&get("select mag from alerte_daemon where client='$client'");
  $noratio=&get("select noratio from alerte_daemon where client='$client'");
  @liste_four=();
  &ratio();
  $query="select distinct pr_four from $client.produit order by pr_four";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($four)=$sth->fetchrow_array){
    $fo_delai=&get("select fo2_delai from fournis where fo2_cd_fo='$four'");
    if ($fo_delai<21){$fo_delai=21;}
	
    $pass=0;
    $query="select pr_cd_pr,pr_desi from $client.produit where pr_four like '$four' order by pr_desi";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array)
    {
	$actif=&get("select count(*) from $client.trolley,$client.lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1 and tr_qte>0")+0;
	if ($mag ne ""){
	  $actif=&get("select count(*) from $client.mag where code='$pr_cd_pr' and mag='$mag'")+0;
	}
	if (! $actif){next;}
	if ($pass==0){
	    $fo_nom=&get("select fo2_add from $client.fournis where fo2_cd_fo='$four'");
	    $fo_minicde=&get("select fo_minicde from $client.fournis where fo2_cd_fo='$four'");
	    ($fo_nom)=split(/\*/,$fo_nom);
	    $pass=1;
	}
	&algo();
	if (($rupture eq "oui")&&($encde==0)){
 	  # print "$client $pr_cd_pr $pr_desi Risque de rupture pick:$pick stock:$stock vendu:$vendu encde:$encde\n<br>";
	  # f (! grep /$four/,@liste_four){push (@liste_four,$four);}
	}
	if ($a_cde eq "oui"){
	  print "$client $pr_cd_pr $pr_desi Nouvelle commande à faire pick:$pick stock:$stock vendu:$vendu encde:$encde \n<br>";
	  if (! grep /$four/,@liste_four){push (@liste_four,$four);}
	}
    }
  }
  $first=1;
  foreach $four (@liste_four){
   if ($first){
    print "<strong> Liste des fournisseurs avec une commande à faire pour $client<br></strong>\n";
    print "mag:$mag<br>\n";
    print "ratio forcé:$noratio<br>\n";
    $first=0;
    }
   $fo_nom=&get("select fo2_add from $client.fournis where fo2_cd_fo='$four'");
  ($fo_nom)=split(/\*/,$fo_nom);
   print " <a href=http://$client.oasix.fr/cgi-bin/kit.pl?four=$four&mag=$mag&onglet=2&sous_onglet=2&sous_sous_onglet=1&action=phase1 target=_blank>$client $four $fo_nom</a><br>\n";
  } 
}
print "</html></body>";
sub algo{
	      $pick=$stock=$vendu=$ideal=$pick_sup_stck=$presence=$encde=$a_cde=$rupture=$sera_vendu=$arrive_dans=$proposition=$color=$color2=$color3="";
	      if ($fo_delai==0){$fo_delai=21;}
	      $freq=14;
	      $packing=&get("select car_carton from $client.carton where car_cd_pr='$pr_cd_pr'")+0;
	      $pick=&get("select max(pi_qte) from $client.pick where pi_cd_pr='$pr_cd_pr' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)")+0;
	      if ($avec_coef eq "on"){
		$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
		if ($coef ne ""){$pick=int($pick*$coef);}
	      }
	      $query="select pr_stre,pr_casse,pr_diff from $client.produit where pr_cd_pr='$pr_cd_pr'";
	      my($sth)=$dbh->prepare($query);
	      $sth->execute();
	      ($pr_stre,$pr_casse,$pr_diff)=$sth->fetchrow_array;
	      my($ecart)=&get("select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$pr_cd_pr")+0;
	      $stock=$pr_stre/100-$pr_casse/100+$pr_diff/100+$ecart;
	      $pick_sup_stck="non";
	      if ($stock<$pick){$pick_sup_stck="oui";;}
	      $vendu=0;
	      $sub=0;
	      %lot_vendu=();
	      foreach $lot_nolot (@lot){
		$lot_nolotm10=$lot_nolot-10;
		$qte=&get("select sum(ro_qte)/100 from $client.rotation,$client.vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;
		$qte+=&get("select sum(ret_qte-ret_retour) from $client.non_sai,$client.retoursql,$client.vol where ret_cd_pr=$pr_cd_pr and ret_code=v_code and ns_code=ret_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;

	      # si stock > pick -> qte = vente 21 jours 
	      # si stock < pick -> qte = MAX( vente  21 jours, vente 90 jours/4)
		if ($pick_sup_stck eq "oui") {
		  $qte2_sup_qte="non";
		  $qte2=&get("select sum(ro_qte)/100 from $client.rotation,$client.vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90")+0;
		  $qte2+=&get("select sum(ret_qte-ret_retour) from $client.non_sai,$client.retoursql,$client.vol where ret_cd_pr=$pr_cd_pr and ret_code=v_code and ns_code=ret_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90","af")+0;
# 		  print "qte2=$qte2*";
		  $qte2=$qte2*$fo_delai/90;
		  $qte2=int($qte2);
		  if ($qte2>$qte){$qte=$qte2;$qte2_sup_qte="oui";}
 		}
		$ratio=$ratiot{$lot_nolot};
		if ($ratio==0){$ratio=1;}
		if ($noratio eq "on"){$ratio=1;}
		$qtenew=int($qte*$ratio);
		$vendu+=$qtenew;
		$lot_vendu{$lot_nolot}="$qtenew:$qte2_sup_qte";
	      }
	      $presence=&get("select max(datediff (curdate(),pi_date)) from $client.pick where pi_cd_pr=$pr_cd_pr and datediff (curdate(),pi_date)<=30");
	      if ($presence==0){$presence=1}
	      if ($presence<21){
		$vendu=int($vendu*21/$presence);
	      }
	      if ($avec_coef eq "on"){
		$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
		if ($coef ne ""){$vendu=int($vendu+($vendu*$coef*15/100));}
	      }
# 	      $ideal=2*$vendu+$pick;
# 	      $ideal=int(5*$vendu/3)+$pick; # mail 31/03
	      $vendu_freq=$vendu*$freq/$fo_delai;
	      $ideal=int($vendu+$vendu_freq);
	      $encde=0;
	      $query="select com2_qte/100,com2_no_liv from $client.commande where com2_cd_pr='$pr_cd_pr'";
	      $sth4=$dbh->prepare($query);
	      $sth4->execute();
	      while (($com2_qte,$com2_no_liv)=$sth4->fetchrow_array){
		if ($com2_no_liv >0){
		  $com2_qte=&get("select livb_qte_liv from dfc.livraison_b where livb_id='$com2_no_liv' and livb_code='$pr_cd_pr'")+0;
		}
		$encde+=$com2_qte;
	      }
	      $arrive_dans="";
	      $sera_vendu=0;
	      $a_cde="non";
	      $rupture="non";
	      $la_plus_ancienne=&get("select min(date) from $client.commande_info,$client.commande where com_no=com2_no and com2_cd_pr='$pr_cd_pr'");
	      $arrive_dans=$fo_delai;
	      if ($la_plus_ancienne ne ""){
		$arrive_dans=$fo_delai-&get("select datediff(curdate(),'$la_plus_ancienne')");
		$livh_date_lta=&get("select livh_date_lta from $client.commande_info,$client.commande,dfc.livraison_h where date='$la_plus_ancienne' and com_no=com2_no and com2_cd_pr='$pr_cd_pr' and com2_no_liv=livh_id");
 	        if (($livh_date_lta ne "")&&($livh_date_lta ne "0000-00-00")){$arrive_dans=3-&get("select datediff(curdate(),'$livh_date_lta')");}
		if ($arrive_dans<0){$arrive_dans=0;}
	      }  
# 	      $sera_vendu=$vendu*$arrive_dans/$fo_delai;
# 	      $sera_vendu=int($sera_vendu);
# 	      if (($stock-$pick)<$sera_vendu){$rupture="oui";}
# 	      if ((($stock-$pick+$encde)<$sera_vendu)){$a_cde="oui";}
	      
	      
	      $sera_vendu=$vendu*($arrive_dans)/$fo_delai;
	      $sera_vendu_freq=$vendu*($arrive_dans+$freq)/$fo_delai;
	      $sera_vendu=int($sera_vendu);
	      $sera_vendu_freq=int($sera_vendu_freq);
	      if (($stock-$pick)<$sera_vendu){$rupture="oui";}
	      if ((($stock-$pick+$encde)<$sera_vendu_freq)){$a_cde="oui";}
	      if ((($stock-$pick+$encde)>=$sera_vendu)){$a_cde="non";}    
		  # modifier le 06/07/2017 remplace <$sera_vendu car ça ne me semble pas logique
	
	      
       	      $proposition=$ideal-$stock-$encde;
	      if (($packing >0)&&($proposition> $packing*70/100)){
		  $proposition2=int($proposition/$packing)*$packing;
		  if ($proposition%$packing!=0){$proposition2+=$packing;}
		  $proposition=$proposition2;
	      }
	      if ($proposition<0){$proposition=0;}
	      if (($proposition>0)&&($proposition<3)){$proposition=3;}
	    
}
  

sub ratio() {
  my ($passe)=0;
  my($avenir)=0;
  my ($aff)=$_[0];
  my(@ancien)=();
  $query="select lot_nolot from $client.lot where lot_flag=1 order by lot_nolot desc";
  my ($sth)=$dbh->prepare($query);
  $sth->execute();
  while (($lot_nolot)=$sth->fetchrow_array){
    if (grep /$lot_nolot/,@ancien){next;}
    push(@lot,$lot_nolot);
    $passe=&get("select count(*) from $client.vol where v_troltype=$lot_nolot  and v_rot=1 and datediff(curdate(),v_date_sql)<=35 and datediff(curdate(),v_date_sql)>0")+0;
    $avenir=&get("select count(*) from $client.flyhead where fl_troltype=$lot_nolot  and datediff(fl_date_sql,curdate())>0 and datediff(fl_date_sql,curdate())<=35")+0;
    $lot_nolotm10=$lot_nolot-10;
#     $check=&get("select count(*) from lot where lot_flag=1 and lot_nolot=$lot_nolotm10")+0;
#     if ($check){
      $passe+=&get("select count(*) from $client.vol where v_troltype=$lot_nolotm10  and v_rot=1 and datediff(curdate(),v_date_sql)<=35 and datediff(curdate(),v_date_sql)>0")+0;
      $avenir+=&get("select count(*) from $client.flyhead where fl_troltype=$lot_nolotm10  and datediff(fl_date_sql,curdate())>0 and datediff(fl_date_sql,curdate())<=35")+0;
      push (@ancien,$lot_nolotm10);
#     } 
    $ratio=0;
    if ($passe>0){$ratio=int($avenir*100/$passe)/100;}
    $ratiot{$lot_nolot}=$ratio;	
  }
}
;1
