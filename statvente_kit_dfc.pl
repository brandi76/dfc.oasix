use OpenOffice::OOCBuilder;
use File::Copy qw(copy);
	
$form_four=$html->param("four");
$mois=$html->param("mois");
$an=$html->param("an");
$premiere=$html->param("premieredatean")."-".$html->param("premieredatemois")."-".$html->param("premieredatejour");
$derniere=$html->param("dernieredatean")."-".$html->param("dernieredatemois")."-".$html->param("dernieredatejour");
print "<center>";
if ($action eq ""){
    print "<div class=titre>Statistique des ventes</div><br>";
	print "<form>";
	require ("form_hidden.src");
        print "<p style=font-weight:bold>Fournisseur</p>";

	print "<select name=four><option value=tous>Tous</option>";  
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
	$sth2->execute;
	while (my @four = $sth2->fetchrow_array) {
		next if $four eq $four[0];
		($four[1])=split(/\*/,$four[1]);
		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
	}
	
	print "</select>";
	
        print "<p style=font-weight:bold>Famille</p>";
	$query="select fa_id,fa_desi from famille where fa_desi not like '' order by fa_id";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (($fa_id,$fa_desi) = $sth2->fetchrow_array) {
		print "<div style=float:left;width:200px;text-align:right>$fa_desi <input type=checkbox name=$fa_id ";
		if ($fa_id !=99) {print "checked";}
		print "></div>";
	}
 	print "<div style=clear:both> </div>";

	print "<br><br>Premiere date ";
	&select_date("premiere");
	print "<br><br>Derniere date ";
	&select_date("derniere");
	print "<br><br><input type=hidden name=action value=go><input type=submit value='Statistique'></form><br><br>"; 
}



if ($action eq "go")
{
  $sheet=new OpenOffice::OOCBuilder();
  $ligne=1;
  $col=1;
  $sheet->set_data_xy ($col, $ligne, "Periode du $premiere au $derniere");
  $ligne++;
  
  print "Periode du $premiere à $derniere<br>";
  $sheet->set_data_xy ($col, $ligne, "Famille");
  $col++;
  $sheet->set_data_xy ($col, $ligne, "Code");
  $col++;
  $sheet->set_data_xy ($col, $ligne, "Designation");
  $col++;
  
  # premier passage j'enregistre client qte pour la periode donnée
  &save("create temporary table liste_temp (client varchar(20),code int(8),qte int(8))");
  foreach $client (@bases_client) {
    if ($client eq "dfc"){next;}
    # if ($client eq "tacv"){next;}
    $sheet->set_data_xy ($col, $ligne, "$client");
    $col++;
    $query="select ro_cd_pr,floor(sum(ro_qte)/100) from $client.rotation,$client.vol where ro_code=v_code and v_date_sql>='$premiere' and v_date_sql<='$derniere' and v_rot=1 group by ro_cd_pr" ; 
#     print $query;
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
      &save("insert ignore into liste_temp value ('$client','$pr_cd_pr','$qte')");
    }
  }
  # deuxieme passage j'enregistre le detail par produit
  $sheet->set_data_xy ($col, $ligne, "Total");
  $ligne++;
  &save("create temporary table liste_temp2 (code int(8),qte int(8),four int(8),famille int(8),designation varchar(40))");
  $query="select code,pr_desi,pr_famille,pr_four,sum(qte) from liste_temp,produit,produit_plus where code=produit.pr_cd_pr and code=produit_plus.pr_cd_pr  group by code";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$famille,$pr_four,$qte)=$sth->fetchrow_array){
     &save("insert ignore into liste_temp2 value ('$pr_cd_pr','$qte','$pr_four','$famille','$pr_desi')");
  }
  # troisieme passage je trie et j'affiche
 
  $query="select code,designation,qte,four,famille from liste_temp2 order by famille,qte desc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$qte_tot,$four,$famille)=$sth->fetchrow_array){
    if (($form_four ne "tous")&&($four ne $form_four)){next;}
    if ($html->param("$famille") ne "on"){next;}
  
    if ($famille ne $famille_temp){
      if ($total_famille >0){ print "</table>Total $famille_desi:$total_famille<br>";}
      $famille_desi=&get("select fa_desi from famille where fa_id='$famille'");
      print "<hr></hr><h3>$famille_desi</h3><br><table><tr><th> </th>";
      foreach $client (@bases_client) {
	if ($client eq "dfc"){next;}
	# if ($client eq "tacv"){next;}
	 print "<th>$client</th>";
      }  
      print "<th>Total</th></tr>";
      $famille_temp=$famille;
      $total_famille=0;
    }
    
    $qte=&get("select sum(qte) from liste_temp where code='$pr_cd_pr'");
    print "<tr><td><a href=?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$pr_cd_pr&commercial=on&action=visu>$pr_cd_pr</a> $pr_desi</td>";
    $col=1;
    $sheet->set_data_xy ($col, $ligne, "$famille_desi");
    $col++;
    $sheet->set_data_xy ($col, $ligne, "$pr_cd_pr");
    $col++;
    $sheet->set_data_xy ($col, $ligne, "$pr_desi");
    $col++;
 
#     $qte_tot=0;
    foreach $client (@bases_client) {
      if ($client eq "dfc"){next;}
      # if ($client eq "tacv"){next;}
      $qte=&get("select sum(qte) from liste_temp where code='$pr_cd_pr' and client='$client'")+0;
      $sheet->set_data_xy ($col, $ligne,$qte,'float');
      $col++;
      print "<td  align=right>$qte</td>";
#       $qte_tot+=$qte;
    }
    print "<td align=right>$qte_tot</td></tr>";
    $sheet->set_data_xy ($col, $ligne, $qte_tot,'float');
    $ligne++;
    $total_famille+=$qte_tot;
  }
  if ($total_famille >0){ print "</table>Total $famille_desi:$total_famille<br>";}
  $sheet->generate("stat");
  copy "/var/www/cgi-bin/dfc.oasix/stat.sxc","/var/www/dfc.oasix/doc/stat.sxc";
  print "<br><a href=http://dfc.oasix.fr/doc/stat.sxc>Fichier Openoffice</a>";

}

;1