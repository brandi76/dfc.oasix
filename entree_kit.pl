$ok=0;
if ($user eq "sylvain"){$ok=1;}
if ($user eq "philippe"){$ok=1;}
if ($user eq "daniel"){$ok=1;}
if ($user eq "pierette"){$ok=1;}
if ($user eq "isabelle"){$ok=1;}
if ($user eq "mireille"){$ok=1;}
if ($user eq "edwige"){$ok=1;}
if (($base_dbh eq "aircotedivoire")&&($ok!=1)){
	print "Vous n'êtes pas autorisé à utiliser cette fonctionnalité";
	exit;
}
$ok=0;
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
$date_facture=$html->param("date_facture");
$date_reglement=$html->param("date_reglement");
$limit=$html->param("limit");
$no_cde=$html->param("no_cde");
$no_entree=$html->param("no_entree");

if ($base eq ""){$base=$base_dbh;}
push(@bases_client,"corsica");
$limit+=0;
if ($limit==0){$limit=20;}

push(@bases_client,"formation");
push(@bases_client,"cameshop");

if (grep /\//,$date){
  ($j,$m,$a)=split(/\//,$date);
  $date="$a-$m-$j";
}
if (grep /\//,$date_facture){
  ($j,$m,$a)=split(/\//,$date_facture);
  $date_facture="$a-$m-$j";
}  
if (grep /\//,$date_reglement){
  ($j,$m,$a)=split(/\//,$date_reglement);
  $date_reglement="$a-$m-$j";
}  

if ($action eq "sup"){
  $base=&get("select livh_base from dfc.livraison_h where livh_id='$liv_id'");
  &save("delete from dfc.livraison_h where livh_id='$liv_id' limit 1");
  &save("update $base.commande set com2_no_liv=0 where com2_no_liv='$liv_id'");
  print "<p style=backgroundcolor:pink> $liv_id supprimé</p>";
  $action="";
}

if ($action eq "modif_cde"){
	$prix_avant=&get("select livb_prix from dfc.livraison_b where livb_id='$liv_id' and livb_code='$code'");
	if ($prix_avant!=$prix){
		$base=&get("select livh_base from dfc.livraison_h where livh_id='$liv_id'");
		if (&get("select base_type from dfc.base where base_lib='$base'") eq "aerien"){
			my($prix_achat_avant)=&get("select pr_prac/100 from $base.produit where pr_cd_pr='$code'","af")+0;
			# print "*$prix_achat_avant*";
			if ($prix_achat_avant!=$prix){
				print "<form>";
				# print "$prix_achat_avant $prix";
				&form_hidden;
				print "<input type=hidden name=action value=modif_prix>";
				print "<input type=hidden name=code value=$code>";
				print "<input type=hidden name=liv_id value=$liv_id>";
				print "<input type=hidden name=prix value=$prix>";
				print "<input type=hidden name=prix_achat_avant value=$prix_achat_avant>";
				print "<mark>Modifier le prix d'achat dans la base produit ?</mark> <input type=submit value=modifier>";
				print "</form>";
			}
		}
	}
	&save("update dfc.livraison_b set livb_qte_fac='$qte_fac',livb_qte_liv='$qte_liv',livb_qte_ent='$qte_ent',livb_prix='$prix' where livb_id='$liv_id' and livb_code='$code'");
	if (($qte_fac==0)&&($qte_liv==0)&&($qte_ent==0)){
		&save("delete from dfc.livraison_b where livb_id='$liv_id' and livb_code='$code'");
		&save("update $base.commande set com2_no_liv=0 where com2_no_liv='$liv_id' and com2_cd_pr='$code'");
	} 
	if (($base_dbh eq "dfc")&&(&liv_etat() eq "")){
		&save("update dfc.livraison_b set livb_qte_liv=livb_qte_fac where livb_id='$liv_id' and livb_code='$code'");
	}
	# if ($base_dbh eq "dfc"){&majprac($prix);}
	$action="modifier";
}


if ($action eq "modif_prix"){
	$prix_achat_avant=$html->param("prix_achat_avant");
	if ($base_dbh eq "dfc"){&majprac($prix);}
	$action="modifier";
}

# if ($action eq "special"){
  # $query="select livb_code,livb_prix FROM `livraison_b` where livb_prix!=0 order by livb_id ";
  # $sth=$dbh->prepare($query);
  # $sth->execute();
    # while (($code,$prix)=$sth->fetchrow_array){
      # &majprac($prix);
    # }
# }

if ($action eq "ajout_cde"){
  $check=&get("select count(*)  from $base.produit where pr_cd_pr='$code'")+0;
  if ($check==0){
	print "<font color=red>CODE INEXISTANT</font>";
 }	
else {	
  if ($prix eq ""){$prix=&get("select pr_prac/100 from $base.produit where pr_cd_pr='$code'");}
  &save("insert ignore into dfc.livraison_b values ('$liv_id','$code','$qte','$qte','0','$prix')");
  $com2_qte=$qte*100;
  $query="select com2_no,com2_cd_fo,com2_date,com2_liv from $base.commande where com2_no_liv='$liv_id' limit 1";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($com2_no,$com2_cd_fo,$com2_date,$com2_liv)=$sth->fetchrow_array;
  &save("insert ignore into $base.commande values ('$com2_no','$com2_cd_fo','$code','0','$prix','0','$com2_date','$liv_id','$com2_liv','')","af");
  &save("insert ignore into dfc.livraison values ('$liv_id','$com2_no')");
  # if ($base_dbh eq "dfc"){&majprac($prix);}
  }
  $action="modifier";
}      
if ($action eq "modif_h"){
  &save("update dfc.livraison_h set livh_blabla=\"$blabla\",livh_cout='$frais',livh_cout_desi=\"$frais_desi\",livh_facture=\"$facture\",livh_lta=\"$lta\",livh_date_facture=\"$date_facture\",livh_date_reglement=\"$date_reglement\" where livh_id='$liv_id'");
  if ($facture ne ""){
       &save("update $base.commande_info,$base.commande set etat=2 where com_no=com2_no and etat<=2 and com2_no_liv='$liv_id'","af");
  }
  $action="modifier";
}      
if ($action eq "fac_liv"){
  &save("update dfc.livraison_b set livb_qte_liv=livb_qte_fac where livb_id='$liv_id' ");
  $action="modifier";
}      
if ($action eq "qte_liv"){
  &save("update dfc.livraison_b set livb_qte_ent=livb_qte_liv where livb_id='$liv_id' ");
  $action="modifier";
}      

if ($action eq "ent_0"){
  &save("update dfc.livraison_b set livb_qte_ent=0 where livb_id='$liv_id' ");
  $action="modifier";
}      

if ($action eq "creer") {
  $ok=0;
  $query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$four' and com2_no_liv=0 order by com2_no,com2_cd_pr"; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
      $ref=$com2_no.":".$com2_cd_pr;
      if ($html->param("$ref") eq "on"){$ok++;}
  }    
  if ($ok==0){
    print "<p style=background:pink>Aucun produit selectionné</p>";
    $action="go";
  }
  else {
    if ($date eq ""){$date=&get("select curdate()");}
	$fo_local=&get("select fo2_identification from $base.fournis where fo2_cd_fo='$four' ");
    &save("insert into dfc.livraison_h (livh_base,livh_date,livh_four,livh_user,livh_date_facture) values ('$base','$date','$four','$user','$date')","af");
    $liv_id=&get("SELECT LAST_INSERT_ID() FROM dfc.livraison_h");
    if ($fo_local==1){&save("update dfc.livraison_h set livh_lta='$livh_id' where livh_id='$liv_id'");}  	
	&save("insert ignore into traceur values (now(),\"action=creer liv_no=$liv_id ok=$ok\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
    $query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$four' and com2_no_liv=0 order by com2_no,com2_cd_pr";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
	$ref=$com2_no.":".$com2_cd_pr;
	if ($html->param("$ref") eq "on"){
	    $check=&get("select count(*) from dfc.livraison_b where livb_id=$liv_id and livb_code=$com2_cd_pr")+0;
	    if ($check==0){
	      &save("insert into dfc.livraison_b values ('$liv_id','$com2_cd_pr','$com2_qte','$com2_qte','0','$com2_prac')");
		  &save("insert ignore into dfc.livraison values ('$liv_id','$com2_no')");
	    }
	    else
	    {
	      &save("update dfc.livraison_b set livb_qte_liv=livb_qte_liv+$com2_qte,livb_qte_fac=livb_qte_fac+$com2_qte where livb_id='$liv_id' and livb_code='$com2_cd_pr'");
		  &save("insert ignore into dfc.livraison values ('$liv_id','$com2_no')");
	    }
	    &save("update $base.commande set com2_no_liv='$liv_id' where com2_no='$com2_no' and com2_cd_pr='$com2_cd_pr'");
	}
    }
     print "<h3 style=background:lavender>Document de livraison no $liv_id créé</h3>";
    $action="";
 }   
}

if ($action eq "gocde"){
    $cde=$html->param("cde");
    ($base,$com2_no)=split(/:/,$cde);
	if ($base eq ""){$base=$base_dbh;}
    $four=&get("select com2_cd_fo from $base.commande where com2_no='$com2_no' limit 1");
    &save("insert into dfc.livraison_h (livh_base,livh_date,livh_four,livh_user,livh_date_facture) values ('$base',curdate(),'$four','$user',curdate())","af");
    $liv_id=&get("SELECT LAST_INSERT_ID() FROM dfc.livraison_h");
	&save("insert ignore into traceur values (now(),\"action=gocde liv_no=$liv_id com_no=$com2_no\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	&save("insert ignore into dfc.livraison values ('$liv_id','$com2_no')");
    $query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_no='$com2_no' and com2_no_liv=0";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
		&save("insert into dfc.livraison_b values ('$liv_id','$com2_cd_pr','$com2_qte','$com2_qte','0','$com2_prac')");
		&save("update $base.commande set com2_no_liv='$liv_id' where com2_no='$com2_no' and com2_cd_pr='$com2_cd_pr'");
    }
    print "<h3 style=background:lavender>Document de livraison no $liv_id créé</h3>";
    $action="";
 }

if (($action eq "go")||($action eq "refresh")) {
	$ok=0;
	&save("replace into retour value('$ENV{\"REMOTE_USER\"}','$ENV{\"QUERY_STRING\"}')");
	$fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
	($fo_nom)=split(/\*/,$fo_add);
	print "Base:$base fournisseur:$four $fo_nom <br>";
	$color="lavender";
	print "<form>";
	&form_hidden();
	$query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$four' and com2_no_liv=0 order by com2_no,com2_cd_pr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	 if ($sth->rows){
	  print "<table border=1 cellspacing=0><tr><th>No cde</th><th>Code</th><th>Produit</th><th>Qte</th><th>Prix<th>Valeur</th><th>Action</th></tr>";
	  while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
	    if ($com2_no ne $com2_no_tamp){if ($color eq "lavender"){$color="white";}else{$color="lavender";}$com2_no_tamp=$com2_no;}
	    $com2_qte+=0;
	    $valeur=$com2_qte*$com2_prac;
	    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$com2_cd_pr'");
	    $ref=$com2_no.":".$com2_cd_pr;
	    $pr_refour=&get("select pr_refour from $base.produit where pr_cd_pr=$com2_cd_pr");
	    print "<tr bgcolor=$color><td>$com2_no</td><td>$com2_cd_pr ";
	    print "<span style=font-size:0.8em;font-weight:bold>$pr_refour</span>";
	    print "</td><td>$pr_desi</td><td align=right>$com2_qte</td><td align=right>$com2_prac</td><td align=right>$valeur</td><td><input type=checkbox name=$ref ";
	    $check="";
	    if ($html->param("$ref") eq "on"){$ref="checked";}
	    if ($html->param("coche$com2_no") eq "on"){$ref="checked";}
	    if ($html->param("decoche$com2_o") eq "on"){$ref="";}
	    print "$ref></td></tr>";
	  }
	  print "</table>";
	  $query="select distinct(com2_no) from $base.commande where com2_cd_fo='$four' order by com2_no"; 
	  $sth=$dbh->prepare($query);
	  $sth->execute();
	  while (($com2_no)=$sth->fetchrow_array){
	    print "Tout Cocher $com2_no <input type=checkbox name=coche$com2_no> Tout Decocher $com2_no <input type=checkbox name=decoche$com2_no><br>";
	  }
	  print "<input type=hidden name=base value=$base>";
	  print "<input type=hidden name=four value=$four>";
	  print "<input type=submit name=action value='refresh'>";
	  print "<br><br><input type=hidden name=action value=creer>";
	  print "<br>Date de livraison (JJ/MM/AA) <input type=texte id=datepicker name=date size=8> ";
	  print "<input type=submit value='Creer le document de livraison'>";
	  print "</form>";
	}
	else
	{
	  print "<div style=background:lavender>Aucun resultat à votre demande</div>";
	}
	print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
}

if ($action eq ""){
	&save("create temporary table four_tmp (code int(8),nom varchar(30),fo_local tinyint(2),primary key (code))");
	foreach $base (@bases_client){
	  if (($base_dbh ne "dfc")&&($base eq "formation")){next;}
	  &save("insert ignore into four_tmp (select distinct pr_four,fo2_add,fo2_identification from $base.entbody,$base.produit,dfc.fournis where enb_cdpr=pr_cd_pr and fo2_cd_fo=pr_four)","af"); 
	}
	print "<div style=position:absolute;margin:20px>";
	print "<div class=titre>Creation des documents de livraison</div><br>";
	print "Selection par commande<br>";
	&save("create temporary table commande_tmp (nocde int(8),base varchar(30),nom varchar(30),fo_local tinyint(2))");
	print "<form> ";
	&form_hidden();
	
	if ($base_dbh eq "dfc"){
	  foreach $base (@bases_client){
	    if ($base eq "dfc"){next;}
 	    if ($base eq "formation"){next;}
	    $query="select distinct com2_no,com2_cd_fo from $base.commande where com2_no_liv=0";
	    $sth=$dbh->prepare($query);
	    $sth->execute();
	    while (($com2_no,$com2_cd_fo)=$sth->fetchrow_array){
	      $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$com2_cd_fo' ");
	      ($fo_nom)=split(/\*/,$fo_add);
	      $fo_local=&get("select fo2_identification from $base.fournis where fo2_cd_fo='$com2_cd_fo' ");
	         # print "insert into commande_tmp values ('$com2_no','$base','$fo_nom')<br>";

	      &save("insert into commande_tmp values ('$com2_no','$base','$fo_nom','$fo_local')","af");
	    }
	  }  
	}
	else
	{
	  $query="select distinct com2_no,com2_cd_fo from commande where com2_no_liv=0";
	  $sth=$dbh->prepare($query);
	  $sth->execute();
	  while (($com2_no,$com2_cd_fo)=$sth->fetchrow_array){
	    $fo_add=&get("select fo2_add from fournis where fo2_cd_fo='$com2_cd_fo' ");
	    ($fo_nom)=split(/\*/,$fo_add);
	    $fo_local=&get("select fo2_identification from dfc.fournis where fo2_cd_fo='$com2_cd_fo' ");
	    &save("insert into commande_tmp values ('$com2_no','$base_dbh','$fo_nom','$fo_local')","af");
	  }
	}
	print "<select name=cde>";
	$query="select * from commande_tmp order by nocde,base";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$base,$fo_nom,$fo_local)=$sth->fetchrow_array){
	    $color="black";
	    if (($fo_local!=1)&&($base_dbh ne "dfc")){next;}
	    print "<option value=$base:$com2_no style=color:$color>$com2_no $base $fo_nom</option>";
	}
	print "</select>";
	print "<input type=hidden name=action value=gocde>";
	print " <input type=submit></form>"; 
	print "<br>Ou selection par fournisseur<br>";
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
	print "Fournisseur <select name=four>";
	$query="select code,nom,fo_local from four_tmp order by nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$nom,$fo_local)=$sth->fetchrow_array){
	      ($nom)=split(/\*/,$nom);
	      $color="black";
		  if (($fo_local !=1)&&($base_dbh ne "dfc")){next;}
	      # if ($fo_local==1){$color="green";}
	      print "<option value=$code style=color:$color>$nom</code>";
	}
	print "</select>";
	print "<input type=hidden name=action value=go>";
	print " <input type=submit></form>"; 
	print "<br><br> Liste des bons de livraisons en cours <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=rechercher&base=$base>Archive</a> les numéros des commandes qui ont fait l'objet d'une entrée sont en verts<br>";
	print "<table border=1 cellspacing=0 cellpadding=0><tr>";
	if ($base_dbh eq "dfc"){print "<th>Base</th><th>User</th>";}
	print "<th>No</th><th>Date</th><th>Fournisseur</th><th>Montant</th><th>Facture</th><th>LTA</th><th>Cde</th><th colspan=4>Action</th></tr>";
	$query="select * from dfc.livraison_h order by livh_id desc limit 100";
	if ($base_dbh ne "dfc"){
	  $query="select * from dfc.livraison_h where livh_base='$base_dbh' order by livh_id desc";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_date_reglement)=$sth->fetchrow_array){
	  if ($base_dbh ne "dfc"){
	     $fo_local=&get("select fo2_identification from $base.fournis where fo2_cd_fo='$livh_four'")+0;
	     if (($livh_lta eq "")&&($fo_local==0)){next;}
	  }   
	  $check=&get("select enh_no from $base.enthead where enh_document='$livh_id'")+0;
	  if ($check >0){next;}
	  print "<tr>";
	  $fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	  ($fo_nom)=split(/\*/,$fo_add);
	  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	  $montant=int($montant*100)/100;
	  $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	  $montant+=$frais;
	  if ($livh_facture eq ""){$livh_facture="&nbsp;";}
	  if ($livh_lta eq ""){$livh_lta="&nbsp;";}
	  if ($base_dbh eq "dfc"){print "<td>$livh_base</td><td>$livh_user</td>";}
	  print "<td>$livh_id</td><td>$livh_date</td><td>$livh_four $fo_nom</td><td>$montant</td><td>$livh_facture</td><td>";
	  print "<a href=# onclick=\"window.open('lta.pl?lta=$livh_lta','wclose','width=580,height=350,toolbar=no,status=no,left=20,top=30')\" style=color:black>$livh_lta</a>";
	  print "</td>";
	  print "<td>";
	  $query="select distinct com2_no from $livh_base.commande where com2_no_liv='$livh_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  if ($sth2->rows){
	    while (($com2_no)=$sth2->fetchrow_array){print "$com2_no<br>";}
	  }
	  $query="select distinct com2_no from $livh_base.commandearch where com2_no_liv='$livh_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  if ($sth2->rows){
	    while (($com2_no)=$sth2->fetchrow_array){print "<span style=color:green>$com2_no</span><br>";}
	  }
	  print "</td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&liv_id=$livh_id><img src=/images/b_edit.png border=0 title=\"Modifier\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=voir&liv_id=$livh_id><img src=/images/b_voir.png border=0 title=\"Voir\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=entree&liv_id=$livh_id><img src=/images/b_in.png border=0 title=\"Faire l'entrée\"></a></td>";
	  if ($base_dbh eq "dfc") { print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&liv_id=$livh_id><img src=/images/b_drop.png border=0 title=\"Supprimer\" onclick=\"return confirm('Etes vous sur de vouloir supprimer ?')\"></a></td>";}
	 print "</tr>";
	}
	print "</table>";
	print "</div>";
}


if (($action eq "modifier")||($action eq "voir")){
   $query="select livh_base,livh_four,livh_cout,livh_cout_desi,livh_date,livh_blabla,livh_four,livh_facture,livh_lta,livh_date_facture,livh_date_reglement from dfc.livraison_h where livh_id='$liv_id'";
   $sth2=$dbh->prepare($query);
   $sth2->execute();
   ($base,$livh_four,$livh_cout,$livh_cout_desi,$livh_date,$livh_blabla,$four,$livh_facture,$livh_lta,$livh_date_facture,$livh_date_reglement)=$sth2->fetchrow_array;
   $checkfait=&get("select enh_no from $base.enthead where enh_document='$liv_id'","af");
   if ($checkfait ne ""){print "<mark>Entree faite sous le numero:$checkfait</mark><br>";}
   $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
   ($fo_nom)=split(/\*/,$fo_add);
   $fo_local=&get("select fo2_identification from $base.fournis where fo2_cd_fo='$four'");
   print "<div class=titre>$base $four $fo_nom</div>";
   print "<strong>Livraison no:$liv_id du ";
   print &date_iso($livh_date);
   print "</strong><br>";
   $query="select pr_cd_pr,pr_desi,livb_qte_fac,livb_qte_liv,livb_qte_ent,livb_prix from dfc.livraison_b,$base.produit where pr_cd_pr=livb_code and livb_id='$liv_id'"; 
   $sth=$dbh->prepare($query);
   $sth->execute();
   print "<table border=1 cellspacing=0>";
   print "<tr><th colspan=2>Produit</th><th>Qté sur Facture</th><th>Qté sur bon Livraison</th><th>Qté livrée</th><th>Prix</th><th>Valeur facture</th></tr>";
   &set_in();
   while (($prod,$pr_desi,$qte_fac,$qte_liv,$qte_ent,$prix)=$sth->fetchrow_array){
	 $qte_liv+=0;
	 $qte_fac+=0;
	 $qte_ent+=0;
	 $valeur=$qte_liv*$prix;
	 $color="white";
	 if ($prod==$code){$color="yellow";}
	 print "<tr><td>$prod ";
	 $pr_refour=&get("select pr_refour from $base.produit where pr_cd_pr=$prod");
	 print "<span style=font-size:0.8em;font-weight:bold>$pr_refour</span>";
	 print "</td><td bgcolor=$color>$pr_desi</td>";
	 if ($option eq $prod){
	      print "<form>";
	      &form_hidden();
	      if ($in_fac) {print "<td align=right><input type=text name=qte_fac value=$qte_fac size=3 style=background:yellow onchange=this.form.submit()></td>";}else{print "<td align=right ><input type=hidden name=qte_fac value=$qte_fac>$qte_fac</td>";} 
	      if ($in_liv) {print "<td align=right><input type=text name=qte_liv value=$qte_liv size=3 style=background:yellow onchange=this.form.submit()></td>";}else{print "<td align=right ><input type=hidden name=qte_liv value=$qte_liv>$qte_liv</td>";} 
	      if ($in_ent) {print "<td align=right><input type=text name=qte_ent value=$qte_fac size=3 style=background:yellow onchange=this.form.submit()></td>";}else{print "<td align=right ><input type=hidden name=qte_ent value=$qte_ent>$qte_ent</td>";} 
	      if ($in_prix) {print "<td align=right><input type=text name=prix value=$prix size=3 style=background:yellow onchange=this.form.submit()></td>";}else{print "<td align=right><input type=hidden name=prix value=$prix>$prix</td>";} 
	      print "<td><input type=submit value=maj></td>";
	      print "<input type=hidden name=action value=modif_cde>";
	      print "<input type=hidden name=liv_id value=$liv_id>";
	      print "<input type=hidden name=code value=$prod>";
	      print "</form>";
	 }
	 else{
	  $color="white";
	  if ($qte_fac!=$qte_liv){$color="pink";}
	  print "<td align=right bgcolor=$color>$qte_fac</td>";
	  print "<td align=right>$qte_liv</td>";
	  $color="white";
	  if ($qte_ent!=$qte_liv){$color="pink";}
	  print "<td align=right bgcolor=$color>$qte_ent</td>";
	  print "<td align=right>$prix</td>";
	  print "<td align=right>$valeur</td>";
	  if (($action eq "modifier")&&($checkfait eq "")){print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&option=$prod&liv_id=$liv_id&base=$base><img border=0 src=../../images/b_edit.png title='Modifier'></a></td>";}
	 }
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
    if ($action eq "modifier"){
      if ($in_ent) {print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=qte_liv&liv_id=$liv_id&base=$base>Quantités livrées = Quantités sur le bon de livraison</a>";}
      if ($base_dbh ne "dfc"){
		print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=entree&liv_id=$liv_id style=margin-left:200px;><img src=/images/b_in.png border=0 title=\"Faire l'entrée\"></a>";
      }
	  if ($in_liv) {print "<br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=fac_liv&liv_id=$liv_id&base=$base>Quantités facturées = Quantités sur le bon de livraison</a><br>";}
      if (($total_ent!=0)&&($checkfait eq "")){print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ent_0&liv_id=$liv_id&base=$base>Mettre à zéro les quantités livrées</a><br>";}
      print "<hr></hr><br>";
	  if ($in_fac){
		  print "<form>";
		  &form_hidden();
		  $query="select pr_cd_pr,pr_desi from $base.produit where pr_four='$four' and pr_cd_pr not in (select livb_code from dfc.livraison_b where livb_id='$liv_id') order by pr_desi";
	#       print $query;
		  print "<select name=code>";
		  print "<option></option>";
		  $sth=$dbh->prepare($query);
		  $sth->execute();
		  while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
				print "<option value=$pr_cd_pr>$pr_cd_pr $pr_desi</option>";
		  }
		  print "</select>";
		  print " Qte <input type=text name=qte size=3>";
		  print " Prix <input type=text name=prix size=3>";
		  print "<input type=hidden name=action value=ajout_cde>";
		  print "<input type=hidden name=base value=$base>";
		  print "<input type=hidden name=liv_id value=$liv_id>";
		  print " <input type=submit value='Ajouter un produit'></form>"; 
		  print "<form>";
		  &form_hidden();
		  print "Frais <input type=text size=4 name=frais value=$livh_cout>";
		  print "Libellé <input type=text name=frais_desi value='$livh_cout_desi'><br>";
		  print "<Textarea cols=\"160\" rows=\"3\" placeholder=commentaire name=blabla>$livh_blabla</textarea><br>";
		  $color="white";
		  if ($livh_facture eq ""){$color="pink";}
		  print "No Facture <input type=text name=facture value='$livh_facture' style=background:$color size=30><br>";
		  print "Date Facture <input type=text id=datepicker name=date_facture value='$livh_date_facture'> Date reglement <input type=text id=datepicker2 name=date_reglement value='$livh_date_reglement'><br> ";
		  $color="white";
		  if ($livh_lta eq ""){$color="pink";}
		  print "No LTA <input type=text name=lta value='$livh_lta' style=background:$color size=30><br>";
		  print "<input type=hidden name=action value=modif_h>";
		  print "<input type=hidden name=base value=$base>";
		  print "<input type=hidden name=liv_id value='$liv_id'>";
		  print "<input type=submit value=\"Mettre à jour\"></form>"; 
	  }
    }
    &doc_pdf();
    print "<a href=/doc/liv_$liv_id.pdf><img src=../../images/pdf.jpg></a><br />";
    print "<br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
}
if (($action eq "rechercher")||($action eq "rechercher_ok")){
    &save("create temporary table four_tmp (code int(8),nom varchar(30), fo_local tinyint(2), primary key (code))");
    foreach $base (@bases_client){
      &save("insert ignore into four_tmp (select distinct pr_four,fo2_add,fo2_identification from $base.entbody,$base.produit,dfc.fournis where enb_cdpr=pr_cd_pr and fo2_cd_fo=pr_four)","af"); 
    }
    print "<div style=position:absolute;margin:20px>";
    print "<div class=titre>Documents de livraison</div><br>";
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
    $query="select code,nom,fo_local from four_tmp order by nom";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code,$nom,$fo_local)=$sth->fetchrow_array){
	    ($nom)=split(/\*/,$nom);
		print "<option value=$code>$nom</code>";
    }
    print "</select>";
    print "<br>Ou no de commande <input type=texte name=no_cde><br>";
    print "<br>Ou no d' entrée <input type=texte name=no_entree>";
    print "<br>Limiter de le nombre de réponse à <input type=text name=limit size=3 value=$limit><br>";
    print "<br><br><input type=hidden name=action value=rechercher_ok>";
    print "<br><br><input type=submit></form>"; 
    if ($action eq "rechercher_ok"){
		print "<br><br>resultat de la recherche<br>";
		print "<table border=1 cellsapcing=0><tr>";
		if ($base_dbh eq "dfc"){print "<th>Base</th><th>User</th>";}
		print "<th>No</th><th>Date</th><th>Fournisseur</th><th>Montant</th><th>Facture</th><th>LTA</th><th>Cde</th><th>Entrée</th><th colspan=4>Action</th></tr>";
		$query="select * from dfc.livraison_h where livh_base='$base' order by livh_id ";
		if ($base_dbh eq "dfc"){
			$query="select * from dfc.livraison_h  order by livh_id desc ";
		}
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_date_reglement)=$sth->fetchrow_array){
			if (($four ne "Tous")&&($livh_four ne $four)){next;}
			# print "$four $livh_four $query<br>";
			if ($no_cde ne ""){
				$check=&get("select count(*) from $livh_base.commande where com2_no_liv='$livh_id' and com2_no='$no_cde'")+0;
				$check+=&get("select count(*) from $livh_base.commandearch where com2_no_liv='$livh_id' and com2_no='$no_cde'");
				if ($check==0){next;}
			}
			if ($no_entree ne ""){
				$check=&get("select count(*) from $livh_base.enthead where enh_document='$livh_id' and enh_no='$no_cde'")+0;
				if ($check==0){next;}
			}
			print "<tr>";
			$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
			($fo_nom)=split(/\*/,$fo_add);
			$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
			$montant=int($montant*100)/100;
			if ($livh_facture eq ""){$livh_facture="&nbsp;";}
			if ($livh_lta eq ""){$livh_lta="&nbsp;";}
			if ($base_dbh eq "dfc"){print "<td>$livh_base</td><td>$livh_user</td>";}
			print "<td>$livh_id</td><td>$livh_date</td><td>$livh_four $fo_nom</td><td>$montant</td><td>$livh_facture</td><td>";
			print "<a href=# onclick=\"window.open('lta.pl?lta=$livh_lta','wclose','width=580,height=350,toolbar=no,status=no,left=20,top=30')\" style=color:black>$livh_lta</a>";
			print "</td>";
			print "<td>";
			$query="select distinct com2_no from $livh_base.commande where com2_no_liv='$livh_id'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			if ($sth2->rows){
			  while (($com2_no)=$sth2->fetchrow_array){print "$com2_no<br>";}
			}
			$query="select distinct com2_no from $livh_base.commandearch where com2_no_liv='$livh_id'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			if ($sth2->rows){
			  while (($com2_no)=$sth2->fetchrow_array){print "$com2_no<br>";}
			}
			print "</td><td>";
			$livre=0;
			$query="select enh_no from $livh_base.enthead where enh_document='$livh_id'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			if ($sth2->rows){
			  ($enh_no)=$sth2->fetchrow_array;
			  print "$enh_no";
			  $livre=1;
			}
			else {print "<span style=background:pink>en cours</span>";}
			print "</td>";
			if ($action ne "rechercher_ok"){
				print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&liv_id=$livh_id><img src=/images/b_edit.png border=0 title=\"Modifier\"></a></td>";
				print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=voir&liv_id=$livh_id><img src=/images/b_voir.png border=0 title=\"Voir\"></a></td>";
				if ($livre){print "<td>&nbsp;</td>";}
				else{
				  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=entree&liv_id=$livh_id><img src=/images/b_in.png border=0 title=\"Faire l'entrée\"></a></td>";
				}
				print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&liv_id=$livh_id><img src=/images/b_drop.png border=0 title=\"Supprimer\" onclick=\"return confirm('Etes vous sur de vouloir supprimer ?')\"></a></td>";
			}
			print "</tr>";
		}
		print "</table>";
	}
    print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
    print "</div>";
}

if ($action eq "entree"){
  $query="select livh_base,livh_four,livh_cout,livh_cout_desi,livh_date,livh_blabla,livh_four,livh_facture,livh_date_facture,livh_date_reglement from dfc.livraison_h where livh_id='$liv_id'";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  ($base,$livh_four,$livh_cout,$livh_cout_desi,$livh_date,$livh_blabla,$four,$livh_facture,$livh_date_facture,$livh_date_reglement)=$sth2->fetchrow_array;
  $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
  ($fo_nom)=split(/\*/,$fo_add);
  print "<div class=titre>$base $four $fo_nom</div>";
  print "<strong>Livraison no:$liv_id du ";
  print &date_iso($livh_date);
  print "</strong><br>";
  $query="select pr_cd_pr,pr_desi,livb_qte_ent from dfc.livraison_b,$base.produit where pr_cd_pr=livb_code and livb_id='$liv_id' and livb_qte_ent!=0"; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  if ($sth->rows){
    print "<table border=1 cellspacing=0>";
    print "<tr><th colspan=2>Produit</th><th>Qté Livrée</th></tr>";
    $nb_ligne=0;
    $nb_prod=0;
    while (($prod,$pr_desi,$qte_ent)=$sth->fetchrow_array){
      $qte_ent+=0;
      print "<tr><td>$prod</td><td>$pr_desi</td>";
      print "<td align=right >$qte_ent</td>";
      print "</tr>"; 
      $nb_ligne++;
      $nb_prod+=$qte_ent;
    }
    print "</table>";
    print "<strong>Nb de ligne:$nb_ligne Nombre de produit:$nb_prod<br>";
    print "</strong><br>";
    if ($base_dbh ne "dfc"){
      print "<form>";
      &form_hidden();
      print "IM 7 <input type=text name=im7><br>";
      print "<input type=hidden name=action value=ok_entree>";
      print "<input type=hidden name=liv_id value='$liv_id'>";
      print "<input type=submit value=\"faire l'entrée\"></form>"; 
    }
    else
    {
      print "<p style=background:lavender>L' entrée doit se faire sur chaque base respective</p>";
    }
  }
  else
  {
    print "<p style=background:lavender>Aucun produit à entrer, la mise à jour des qtes livrées n'a peut être pas été faite</p>";
  }  
   print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
}

if ($action eq "ok_entree"){
  $im7=$html->param("im7");
  $check=&get("select enh_no from enthead where enh_document='$liv_id'");
  if ($check ne ""){
    print "<p style=background:pink>Ce bon de livraison à deja fait l'objet d'une entrée no:$check</p>";
  }
  else {
        &save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	$date=`/bin/date +%d/%m/%y`;
	$dateenso=`/bin/date +%Y%m%d`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	&save("update atadsql set dt_no=dt_no+1 where dt_cd_dt=207");
	$no=&get("select dt_no from atadsql where dt_cd_dt=207");
	print "Date d'entree:$date<br>";
	print "Numero d'entree:$no  Bon de livraison no:$liv_id Im7:$im7<br>";
	$four=&get("select livh_four from dfc.livraison_h where livh_id='$liv_id'");
	$fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
	($fo_nom)=split(/\*/,$fo_add);
	print "$four $fo_nom<br>";
	&save("replace into enthead values ('$no','$datejl','$scelle','$im7','$liv_id','$lieu')");
	$total=0;
	$query="select livb_code,livb_qte_ent,livb_prix from dfc.livraison_b where livb_id='$liv_id' and livb_qte_ent!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if ($sth->rows) {
	  print "<table cellspacing=0 border=1><tr><th>Code produit</th><th>Désignation</th><th>Qte à entrer</th><th>Stock nouveau</th><th>check</th></tr>";
	  while (($code,$qte,$prix)=$sth->fetchrow_array){
	    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
	    print "<tr><td>$code</td><td>$pr_desi</td>";
	    print "<td align=right>";
	    &carton($code,$qte);
	    print "</td>";
	    $qte*=100;
	    &save("replace into enso values ('$code','$no',now(),'0','$qte','10')");
	    &save("update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$code'");
	    # &save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	    &save("replace into entbody values ('$no','$code','$qte')");
# 	    &save("update dfc.livraison_b set livb_ent=livb_liv where livb_id=$liv_id and livb_code=$code");
	    %stock=&stock($code,"","");
	    $pr_stre=$stock{"stock"};
	    print "<td>";
	    &carton($code,$pr_stre);
	    print "</td><td>&nbsp;</td></tr>";
	   
	  }
	  print "</table><br>";
	  $query="select * from commande where com2_no_liv='$liv_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  $pass=0;
	  while (($com2_no,$com2_cd_fo,$com2_cd_pr,$com2_qte,$com2_prac,$com2_type,$com2_date,$com2_no_liv,$com2_liv)=$sth2->fetchrow_array){
	    $pass=1;
	    $delai=&get("select datediff(curdate(),'$com2_date')");
	    &save("replace into commandearch values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$com2_qte','$com2_prac','0','$com2_date','$delai','$liv_id')");
	  }
	  if ($pass==0){
			$mess="lien_blcde_no_de_bl:$liv_id";
			system("/var/www/cgi-bin/dfc.oasix/send_bug.pl $mess &");
	  }
	  $query="select distinct(com2_no) from commande where com2_no_liv='$liv_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($com2_no)=$sth2->fetchrow_array){
	  	  &save("delete from commande where com2_no='$com2_no'","af");
		  &save("update commande_info set etat=5 where com_no=$com2_no","af");
	  }
	  &doc_pdf_ent();
	  print "<a href=/doc/ent_$no.pdf><img src=../../images/pdf.jpg></a><br />";
  
	}
	else
	{ print "<p style=background:lavender>Aucun produit pour votre demande, certainement que l'entrée a déjà été faite";}
    }
    print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
    
}

sub set_in{
  $in_fac=0;
  $in_prix=0;
  $in_liv=0;
  $in_ent=0;
  if ($base_dbh eq "dfc"){
    $in_fac=1;
	$in_liv=1;
    $in_prix=1;
  }
  else
  {
	if ($fo_local){
		$in_fac=1;
		$in_liv=1;
		$in_ent=1;
		$in_prix=1;
	}
	else {
		$in_fac=0;
		$in_liv=0;
		$in_ent=1;
		$in_prix=0;
	}
  }
}

sub liv_etat{
  my($mess)="";
  $check=&get("select sum(livb_qte_ent) from dfc.livraison_b where livb_id='$liv_id'")+0;
  if ($check!=0){$mess="entree";}
  return($mess);
} 

sub doc_pdf {
  $total=$total_ent=$total_fac=$total_liv=0;
  $file="/var/www/$base_rep/doc/liv_$liv_id.pdf";
  if (-f $file){unlink ($file);}
  my $pdf = PDF::API2->new(-file => $file);
  my %font = (
	Helvetica => {
	Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
	Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
	}
    );
  $index=0;  
  $page[$index] = $pdf->page();
  $page[$index]->mediabox('A4');
  $text = $page[$index]->text;
  $text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
  $text->fillcolor('black');
  $ligne=220;
  $text->translate( 20/mm, $ligne/mm );
  $text->text("Base:$base_rep $four $fo_nom");
  $text->text("$texte");
  $ligne-=8;
  $text->translate( 20/mm, $ligne/mm );
  $date=&date_iso($livh_date);
  $text->text("Livraison no:$liv_id du $date édité par $user");
  $ligne=200;
  $text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
  $text->translate( 10/mm, $ligne/mm );
  $text->text("Produit");
  $text->translate( 30/mm, $ligne/mm );
  $text->text("Designation");
  $col=110;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Qté sur");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Qté sur");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Qté livrée");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("prix");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Valeur");
  $ligne-=5;
  $col=110;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Facture");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("bon Livraison");
  $col+=25;
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("facture");
  $ligne-=5;
  $text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
 
  $query="select pr_cd_pr,pr_desi,livb_qte_fac,livb_qte_liv,livb_qte_ent,livb_prix from dfc.livraison_b,$base.produit where pr_cd_pr=livb_code and livb_id='$liv_id'"; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($prod,$pr_desi,$qte_fac,$qte_liv,$qte_ent,$prix)=$sth->fetchrow_array){
    $qte_liv+=0;
    $qte_fac+=0;
    $qte_ent+=0;
    $valeur=$qte_liv*$prix;
    $text->translate( 10/mm, $ligne/mm );
    $text->text("$prod");
    $text->translate( 30/mm, $ligne/mm );
    $text->text("$pr_desi");
    $col=110;
    $text->translate( $col/mm, $ligne/mm );
    $text->text("$qte_fac");
    $col+=25;
    $text->translate( $col/mm, $ligne/mm );
    $text->text("$qte_liv");
    $col+=25;
    $text->translate( $col/mm, $ligne/mm );
    $text->text("$qte_ent");
    $col+=25;
    $text->translate( $col/mm, $ligne/mm );
    $text->text("$prix");
    $col+=25;
    $text->translate( $col/mm, $ligne/mm );
    $text->text("$valeur");
    $nb_ligne++;
    $total_fac+=$qte_fac;
    $total_liv+=$qte_liv;
    $total_ent+=$qte_ent;
    $total+=$valeur;
    $ligne-=5;
  }
  $text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
  $text->translate( 10/mm, $ligne/mm );
  $text->text("Nombre de ligne:$nb_ligne");
  $col=110;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("$total_fac");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("$total_liv");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("$total_ent");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("$total");
  $ligne-=5;
  if ($livh_cout+0!=0){
     $text->translate( 10/mm, $ligne/mm );
     $text->text("Frais:$livh_cout");
     $total+=$livh_cout;
     $ligne-=5;
     $text->translate( 10/mm, $ligne/mm );
     $text->text("Total avec frais:$total");
    }
  $ligne-=10;
  $text->translate( 10/mm, $ligne/mm );
  $text->text("Signature :$total");
  $pdf->save();
}
sub doc_pdf_ent {
  $total=$total_ent=$total_fac=$total_liv=0;
  $file="/var/www/$base_rep/doc/ent_$no.pdf";
  if (-f $file){unlink ($file);}
  my $pdf = PDF::API2->new(-file => $file);
  my %font = (
	Helvetica => {
	Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
	Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
	}
    );
  $index=0;  
  $page[$index] = $pdf->page();
  $page[$index]->mediabox('A4');
  $text = $page[$index]->text;
  $text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
  $text->fillcolor('black');
  $ligne=220;
  $text->translate( 20/mm, $ligne/mm );
  $text->text("Base:$base_rep $four $fo_nom");
  $text->text("$texte");
  $ligne-=8;
  $text->translate( 20/mm, $ligne/mm );
  $date=&date_iso($livh_date);
  $heure=`/bin/date +%H:%M`;
  $text->text("Entrée no:$no du $date $heure édité par $user");
  $ligne=200;
  $text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
  $text->translate( 10/mm, $ligne/mm );
  $text->text("Produit");
  $text->translate( 30/mm, $ligne/mm );
  $text->text("Designation");
  $col=110;
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Qté entrée");
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Stock nouveau");
  $col+=30;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("Check");
  $ligne-=5;
  $col=110;
  $col+=25;
  $col+=25;
  $col+=25;
  $ligne-=5;
  $text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
 
  $query="select pr_cd_pr,pr_desi,livb_qte_fac,livb_qte_liv,livb_qte_ent,livb_prix from dfc.livraison_b,produit where pr_cd_pr=livb_code and livb_id='$liv_id' and livb_qte_ent!=0"; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($prod,$pr_desi,$qte_fac,$qte_liv,$qte_ent,$prix)=$sth->fetchrow_array){
    $qte_liv+=0;
    $qte_fac+=0;
    $qte_ent+=0;
    $valeur=$qte_liv*$prix;
    $text->translate( 10/mm, $ligne/mm );
    $text->text("$prod");
    $text->translate( 30/mm, $ligne/mm );
    $text->text("$pr_desi");
    $col=110;
    $col+=25;
    $text->translate( $col/mm, $ligne/mm );
    $text->text("$qte_ent");
    $col+=35;
    $text->translate( $col/mm, $ligne/mm );
    %stock=&stock($prod,"","");
    $pr_stre=$stock{"stock"};
    $text->text("$pr_stre");
    $col+=25;
    $nb_ligne++;
    $total_ent+=$qte_ent;
    $ligne-=5;
  }
  $text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
  $text->translate( 10/mm, $ligne/mm );
  $text->text("Nombre de ligne:$nb_ligne");
  $col=110;
  $col+=25;
  $text->translate( $col/mm, $ligne/mm );
  $text->text("$total_ent");
  $col+=25;
  $ligne-=5;
  $ligne-=10;
  $text->translate( 10/mm, $ligne/mm );
  $pdf->save();
}

sub majprac(){
	my($prix100)=($_[0]+0)*100;
	my($prix_apres)=$_[0];
	
	# $check=&get("select pr_prac-$prix100 from produit where pr_cd_pr='$code'");
	#if ($check!=0){
	$query="select base_lib from base where base_type='aerien'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
    while (($client)=$sth->fetchrow_array){
		&save("update $client.produit set pr_prac='$prix100' where pr_cd_pr='$code'","af");
    }
	&save("update dfc.produit set pr_prac='$prix100' where pr_cd_pr='$code'","af");

	system("/var/www/cgi-bin/dfc.oasix/send_changement_prix.pl $code $prix_achat_avant $prix_apres aerien &");
}
;1