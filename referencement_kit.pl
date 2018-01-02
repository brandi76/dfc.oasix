print "<title>referencement produit</title>";
require "./src/connect.src";
print "<center><div class=titrefixe>Referencement produit <br></div>";
@base_client=("dfc","camairco","togo","aircotedivoire","tacv");
$base_dbh=$html->param("base");
$pr_cd_pr=$html->param("produit");
$option=$html->param("option");

if ($action eq "duplique"){
    foreach (@base_client){
      $query="select count(*) from $_.produit where pr_cd_pr='$pr_cd_pr'";
#       print "$query<br>";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($check)=$sth->fetchrow_array+0;
      if ($check==0){
 	&save("insert into $_.produit select * from $base_dbh.produit where pr_cd_pr='$pr_cd_pr'","af");
 	&save("update $_.produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0 where pr_cd_pr='$pr_cd_pr'","af");
 	&save("insert ignore into $_.carton select * from $base_dbh.carton where car_cd_pr='$pr_cd_pr'","af");

      }
    }
}


&save("CREATE TEMPORARY TABLE produit_tmp (pr_cd_pr int(10))");
foreach $client (@base_client){
	# &save("insert into dfc.produit_tmp (select distinct tr_cd_pr from $client.trolley,$client.lot where tr_code=lot_nolot and lot_flag=1)","af");
	&save("insert into produit_tmp (select pr_cd_pr from $client.produit)","af");
	
}
print "<table cellspacing=0 border=1><tr><th colspan=2>produit</th>";
foreach $client (@base_client){
	print "<th>$client</th>";
}
print "</tr>";
$query=("select distinct pr_cd_pr from produit_tmp order by pr_cd_pr ");
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr)=$sth->fetchrow_array){
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
	print "<tR><td><a href=?onglet='$onglet'&sous_onglet='$sous_onglet'&sous_sous_onglet='$sous_sous_onglet'&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td>";
	$ref=0;
	$new=0;
	foreach $client (@base_client){
		$nb=&get("select count(*) from $client.trolley,$client.lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr='$pr_cd_pr'","af")+0;
		$pr_sup=&get("select pr_sup from $client.produit where pr_cd_pr=$pr_cd_pr");
		if ($pr_sup==3){$new=1;}
		if ($nb >0) { 
		  print "<td align=center><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&base=$client&produit=$pr_cd_pr&action=duplique><img src=/images/check.png width=20px border=0></a>";
		  $ref=1;
		  }
		else{
		  $nb=&get("select count(*) from $client.produit where pr_cd_pr='$pr_cd_pr'","af")+0;
		  if ($nb==0){
		    print "<td align=center><img src=/images/exclamation.gif>";
		  }
		  else {
		    print "<td align=center><img src=/images/nocheck.png width=20px>";
		  }
		    
		}
		if ($option eq "val"){
		$val=&get("select pr_prac*pr_stre/10000 from $client.produit where pr_cd_pr='$pr_cd_pr'","af")+0;
		print "<br>$val";
		}
		print "</td>";
	}
	if ($ref==0){
	  if (! $new){

	    print "<td align=center><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=2&pr_cd_pr=$pr_cd_pr><img src=/images/exclamation.gif border=0></a></td>";
	  }
	  else
	  {
	     print "<td align=center><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=2&pr_cd_pr=$pr_cd_pr><img src=/images/new.png></a></td>";
	  }
	}
	else {
	  print "<td align=center> </td>";
	}
		  
	print "</tR>";
	$nbligne++;
}
print "</table>$nbligne";
;1
