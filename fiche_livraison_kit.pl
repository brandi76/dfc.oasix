use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

$four=$html->param("four");
$date=$html->param("date");
$liv_id=$html->param("liv_id");
$base=$html->param("base");
$code=$html->param("code");
$qte=$html->param("qte");
$qte_fac=$html->param("qte_fac");
$qte_liv=$html->param("qte_liv");
$qte_ent=$html->param("qte_ent");
$qte=$html->param("qte");
$prix=$html->param("prix");
$option=$html->param("option");
$blabla=$html->param("blabla");
$lta=$html->param("lta");
$frais=$html->param("frais");
$frais_desi=$html->param("frais_desi");
$facture=$html->param("facture");

push(@bases_client,"formation");
if (grep /\//,$date){
  ($j,$m,$a)=split(/\//,$date);
  $date="$a-$m-$j";
}  
  

if ($action eq ""){
	&save("create temporary table four_tmp (code int(8),nom varchar(30),primary key (code))");
	foreach $base (@bases_client){
	  &save("insert ignore into four_tmp (select distinct pr_four,fo2_add from $base.entbody,$base.produit,$base.fournis where enb_cdpr=pr_cd_pr and fo2_cd_fo=pr_four)","af"); 
	}
	print "<div style=position:absolute;margin:20px>";
	print "<div class=titre>Documents de livraison</div><br>";
	print "Recherche<br>";
	print "<form name=maform>";
	&form_hidden();
	if ($base_dbh eq "dfc"){
	  print "<select name=base>";
	  foreach $base (@bases_client){
	    if ($base eq "dfc"){next;}
	    print "<option value=$base>$base</option>";
	  }
	  print "</select>";
	}
	else {print "<input type=hidden name=base value='$base_dbh'>";}
	print "Fournisseur <select name=four><option value=Tous>Tous</option>";
	$query="select code,nom from four_tmp order by nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$nom)=$sth->fetchrow_array){
		  ($nom)=split(/\*/,$nom);
	      print "<option value=$code>$nom</code>";
	}
	print "</select>";
	print "<br>";
	print "premiere date <br>";
	print "derniere date <br> ";
	print "<br><br><input type=hidden name=action value=go>";
	print "<br><br><input type=submit></form>"; 
	print "<br><br> Liste des 20 dernieres bons de livraisons <br>";
	print "<table border=1 cellsapcing=0><tr><th>Base</th><th>User</th><th>No</th><th>Date</th><th>Fournisseur</th><th>Montant</th><th>Facture</th><th>LTA</th><th colspan=4>Action</th></tr>";
	$query="select * from dfc.livraison_h order by livh_id desc limit 20";
	if ($base_dbh ne "dfc"){
	  $query="select * from dfc.livraison_h where livh_base='$base_dbh' order by livh_id desc limit 20";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user)=$sth->fetchrow_array){
	  print "<tr>";
	  $fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	  ($fo_nom)=split(/\*/,$fo_add);
	  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	  $montant=int($montant*100)/100;
	  if ($livh_facture eq ""){$livh_facture="&nbsp;";}
	  if ($livh_lta eq ""){$livh_lta="&nbsp;";}
	  print "<td>$livh_base</td><td>$livh_user</td><td>$livh_id</td><td>$livh_date</td><td>$livh_four $fo_nom</td><td>$montant</td><td>$livh_facture</td><td>$livh_lta</td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&liv_id=$livh_id><img src=/images/b_edit.png border=0 title=\"Modifier\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=voir&liv_id=$livh_id><img src=/images/b_voir.png border=0 title=\"Voir\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=entree&liv_id=$livh_id><img src=/images/b_in.png border=0 title=\"Faire l'entrée\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&liv_id=$livh_id><img src=/images/b_drop.png border=0 title=\"Supprimer\" onclick=\"return confirm('Etes vous sur de vouloir supprimer ?')\"></a></td>";
	 print "</tr>";
	}
	print "</table>";
	print "</div>";
}


if (($action eq "voir")){
   $query="select livh_base,livh_four,livh_cout,livh_cout_desi,livh_date,livh_blabla,livh_four,livh_facture,livh_lta from dfc.livraison_h where livh_id='$liv_id'";
   $sth2=$dbh->prepare($query);
   $sth2->execute();
   ($base,$livh_four,$livh_cout,$livh_cout_desi,$livh_date,$livh_blabla,$four,$livh_facture,$livh_lta)=$sth2->fetchrow_array;
   $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
   ($fo_nom)=split(/\*/,$fo_add);
   print "<div class=titre>$base $four $fo_nom</div>";
   print "<strong>Livraison no:$liv_id du $livh_date </strong><br>";
   
   $query="select pr_cd_pr,pr_desi,livb_qte_fac,livb_qte_liv,livb_qte_ent,livb_prix from dfc.livraison_b,$base.produit where pr_cd_pr=livb_code and livb_id='$liv_id'"; 
   $sth=$dbh->prepare($query);
   $sth->execute();
   print "<table border=1 cellspacing=0>";
   print "<tr><th colspan=2>Produit</th><th>Qté sur Facture</th><th>Qté sur bon Livraison</th><th>Qté livrée</th><th>Prix</th><th>Valeur facture</th></tr>";

   while (($prod,$pr_desi,$qte_fac,$qte_liv,$qte_ent,$prix)=$sth->fetchrow_array){
	 $qte_liv+=0;
	 $qte_fac+=0;
	 $qte_ent+=0;
	 
	 $valeur=$qte_liv*$prix;
	 $color="white";
	 if ($prod==$code){$color="yellow";}
	 print "<tr><td>$prod</td><td bgcolor=$color>$pr_desi</td>";
	  $color="white";
	  if ($qte_fac!=$qte_liv){$color="pink";}
	  print "<td align=right bgcolor=$color>$qte_fac</td>";
	  print "<td align=right>$qte_liv</td>";
	  $color="white";
	  if ($qte_ent!=$qte_liv){$color="pink";}
	  print "<td align=right bgcolor=$color>$qte_ent</td>";
	  print "<td align=right>$prix</td>";
	  print "<td align=right>$valeur</td>";
	 print "</tr>"; 
	 $nb_ligne++;
	 $total_fac+=$qte_fac;
	 $total_liv+=$qte_liv;
	 $total_ent+=$qte_ent;
	 $total+=$valeur;
   }
    print "<tr><td colspan=2>Nombre de ligne:$nb_ligne</td>";
    $color="white";
    if ($total_fac!=$total_liv){$color="pink";}
    print "<td align=right bgcolor=$color>$total_fac</td><td align=right>$total_liv</td>";
    $color="white";
    if ($total_ent!=$total_liv){$color="pink";}
    print "<td align=right bgcolor=$color>$total_ent</td><td>&nbsp;</td><td align=right><strong>$total</td></tr>";
    print "</table>";
    if ($livh_cout+0!=0){
     print "Frais:$livh_cout<br>";
     $total+=$livh_cout;
     print " Total avec frais:$total";
    }
    print "<br>";
    print "<a href=/doc/liv_$liv_id.pdf><img src=../../images/pdf.jpg></a><br />";
    print "<br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
}

sub liv_etat{
  my($mess)="";
  $check=&get("select sum(livb_qte_ent) from dfc.livraison_b where livb_id='$liv_id'")+0;
  if ($check!=0){$mess="entree";}
  return($mess);
} 


;1