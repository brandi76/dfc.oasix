$pr_cd_pr=$html->param("pr_cd_pr");
print <<EOF;
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	<style>
            
            /* Position et couleur bulle */
            a span{ 
                position:absolute;
                margin-top:25px; 
                margin-left:-25px;
                color:#fff; 
                background:rgba(0, 0, 0, 0.5); 
                padding:25px; 
                border-radius:3px; 
                
                /* Faire disparaire infobulle par défaut */
                /* On determine l'origine de la rotation */ 
                transform:scale(0) rotate(-180deg);
                /* Faire durer l'effet */
                transition:all .25s;
                /* Effet sur la transparence */ 
                opacity:0;
            }
            
            /* Apparition de la bulle avec le scale à 1 */ 
            a:hover span, a:focus span{ 
                transform:scale(1) rotate(0);
                /* Effet sur la transparence */ 
                opacity:1;
            }
        
        </style>  
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

@base_client=("dfc","camairco","togo","aircotedivoire");
$action=$html->param("action");
$code=$html->param("code");	
$client_bon=$html->param("client");


if (($action eq "go")&&($pr_cd_pr eq "")){$action="liste";}


if (($action eq "go")&&($pr_cd_pr ne "")){
	$query="select pr_cd_pr,pr_desi,pr_prac from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array;
	if ($pr_cd_pr eq ""){	
		print "<div class=alert>Produit Inconnu</div>";
		$action="";
	}
	else {
		$pr_prac/=100;
		print "$pr_cd_pr $pr_desi Prix achat:$pr_prac<br>";
		print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
		print "<thead>";
		print "<tr style=font-size:0.8em class=\"info\">";
		print "<th>Base</th><th>Date</th><th>No facture</th><th>Prix factur�</th></tr>";

		$query="select livh_base,livh_date,livb_prix,livh_facture from livraison_b,livraison_h where livb_code='$pr_cd_pr' and livb_id=livh_id order by livh_id desc";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($livh_base,$livh_date,$livb_prix,$livh_facture )=$sth->fetchrow_array){
			print "<tr><td>$livh_base</td><td>$livh_date</td><td>$livh_facture</td><td>$livb_prix</td><td></tr>";
		}
		print "</table>";
	}
}
if ($action eq ""){
	
	print "<form>";
	&form_hidden();
	print "(laisser vide pour avoir la liste) Produit <input name=pr_cd_pr>";
	print "<input type=submit><input type=hidden name=action value=go>";
	print "</form>";
}

if ($action eq "liste"){
$query="select pr_cd_pr,pr_desi,pr_prac from produit order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
  print "<table><tr><td>&nbsp;</td>";
  foreach $client (@base_client){
    print "<th>$client</th>";
  }
  print "</tr>";
    
  while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array){
    $pr_prac/=100;
    print "<tr><td>$pr_cd_pr $pr_desi</td><td align=right>$pr_prac</td>";
    $prix_ref=$pr_prac;
    $date_ref=0;
    $ko=0;
    foreach $client (@base_client){
      if ($client eq "dfc"){next;}
      $color="white";
      $prac=&get("select pr_prac from  $client.produit where pr_cd_pr='$pr_cd_pr'","af");
      $prac/=100;
      $date=&get("select max(es_dt) from  $client.enso where es_cd_pr='$pr_cd_pr' and es_qte_en>0","af");
      if (($date ne "")&&($date >$date_ref)&&($prac>0)){$prix_ref=$prac;}
      if ($prac != $pr_prac){$color="pink";$ko=1;}
      print "<td bgcolor=$color align=right>$prac</td>";
#          if ($prac>0){
# 	foreach $client2 (@bases_client) {
#  		&save("update $client2.produit set pr_prac='$prac' where pr_cd_pr='$pr_cd_pr'","aff");
# 	  }
#       }
    }
    print "</tr>";
    $prix_ref*=100;
    # if ($ko==1){&save("update dfc.produit set pr_prac='$prix_ref' where pr_cd_pr='$pr_cd_pr'","aff");}
  }
print "</table>";
}
if ($action eq "zero"){
  $query="select pr_cd_pr,pr_desi,pr_prac from produit where pr_prac=0 and pr_cd_pr<9000000 order by pr_cd_pr";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
    print "$pr_cd_pr $pr_desi<br>";
  } 
}

if ($action eq "fourchette"){
  $query="select pr_cd_pr,pr_desi,pr_prac from produit where pr_prac!=0 and pr_cd_pr<9000000 order by pr_cd_pr";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array){
	$pr_prac/=100;
	 $err=0;
        foreach $client (@base_client){
	  if ($client eq "dfc"){next;}
	  $color="white";
	  $prix_mini=&get("select min(tr_prix) from  $client.trolley,$client.lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1","af")+0;
	  $prix_maxi=&get("select max(tr_prix) from  $client.trolley,$client.lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1","af")+0;
	  $prix_mini/=100;
	  $prix_maxi/=100;
	  if (($prix_mini!=0)&&($prix_maxi!=0)){
	  if (($prix_mini<$pr_prac*2)||($prix_maxi>$pr_prac*3)){
		  $coef=int($prix_mini*100/$pr_prac)/100;
	  	  print "$pr_cd_pr;$pr_desi;$client;$pr_prac;$prix_mini;$coef<br>";
	  }
	  }
	}
  } 
}

print "		
		</div>
	</div>
</div>";


;1
