print "<title>referencement produit</title>";
require "./src/connect.src";
print "<center><div class=titrefixe>Referencement produit <br></div>";
@base_client=("dfc","camairco","togo","aircotedivoire","tacv");
$base_dbh=$html->param("base");
$pr_cd_pr=$html->param("produit");
$option=$html->param("option");

&save("CREATE TEMPORARY TABLE produit_tmp (pr_cd_pr int(10))");
foreach $client (@base_client){
	# &save("insert into dfc.produit_tmp (select distinct tr_cd_pr from $client.trolley,$client.lot where tr_code=lot_nolot and lot_flag=1)","af");
	&save("insert into produit_tmp (select pr_cd_pr from $client.produit)","af");
	
}
$query=("select distinct pr_cd_pr from produit_tmp order by pr_cd_pr ");
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr)=$sth->fetchrow_array){
	$ref=0;
	$new=0;
	foreach $client (@base_client){
	    if  ($client eq "dfc"){next;}
	 	$val{"$client"}=&get("select pr_prac*pr_stre/10000 from $client.produit where pr_cd_pr='$pr_cd_pr'","af")+0;
		$stock_base{"$client"}+=$val{"$client"};
		$nb=&get("select count(*) from $client.trolley,$client.lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr='$pr_cd_pr'","af")+0;
		$pr_sup=&get("select pr_sup from $client.produit where pr_cd_pr=$pr_cd_pr");
		if ($pr_sup==3){$new=1;}
		if ($nb >0) { 
		  #print "<td align=center><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&base=$client&produit=$pr_cd_pr&action=duplique><img src=/images/check.png width=20px border=0></a>";
		  $ref=1;
		  }
		else{
		  $stock_non_ref{"$client"}+=$val{"$client"};
		  $nb=&get("select count(*) from $client.produit where pr_cd_pr='$pr_cd_pr'","af")+0;
		  if ($nb==0){
# 		    print "<td align=center><img src=/images/exclamation.gif>";
		  }
		  else {
# 		    print "<td align=center><img src=/images/nocheck.png width=20px>";
		  }
		    
		}
	}
	if ($ref==0){
	  if (! $new){
	    foreach $client (@base_client){
		    $stock_mort{"$client"}+=$val{"$client"};
		    # print "$pr_cd_pr $client ".$val{"$client"}."<br>";
		    $stock_non_ref{"$client"}-=$val{"$client"};
	    }
	  }
	  else
	  {
	     #print "<td align=center><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=2&pr_cd_pr=$pr_cd_pr><img src=/images/new.png></a></td>";
	  }
	}
	else {
	  # print "<td align=center> </td>";
	}
		  
}
print "<table>";
print "<tr><th></th><th>Stock actif</th><th>Stock non actif referencé ailleurs</th><th>Stock non actif non referencé</th><th>Valeur du stock</th>";

foreach $client (@base_client){
  print "<tr><td>$client</td>";
  $stock=$stock_base{"$client"};
  $stock_mort=$stock_mort{"$client"};
  $stock_non_ref=$stock_non_ref{"$client"};
  $stock_actif=$stock-$stock_mort-$stock_non_ref;
  print "<td align=right>$stock_actif</td>";
  print "<td align=right>$stock_non_ref</td>";
  print "<td align=right>$stock_mort</td>";
  print "<td align=right>$stock</td>";
  print "</tr>";
}
 print "</table>"; 

;1
