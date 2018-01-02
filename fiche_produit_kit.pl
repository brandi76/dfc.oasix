print "<title>fiche_produit</title>";
require "./src/connect.src";
print "<center><div class=titrefixe> Consultation du fichier produit <br></div>";
$action=$html->param("action");
$pr_cd_pr=$html->param("pr_cd_pr");
$recherche=$html->param("recherche");
$achat=$html->param("achat");
$logistique=$html->param("logistique");
$douane=$html->param("douane");
$stock=$html->param("stock");
$commercial=$html->param("commercial");
$tout=$html->param("tout");
$pr_desi=$html->param("pr_desi");
$pr_ventil=$html->param("pr_ventil"); 
$pr_sup=$html->param("pr_sup");
$pr_codebarre=$html->param("pr_codebarre");
$pr_refour=$html->param("pr_refour");
$pr_prac=$html->param("pr_prac");
$prixvauto=$html->param("prixvauto");
$pr_prx_rev=$html->param("pr_prx_rev");
$pr_four=$html->param("pr_four");
$pr_prx_vte=$html->param("pr_prx_vte");
$car_carton=$html->param("car_carton");
$car_pal=$html->param("car_pal");
$pr_douane=$html->param("pr_douane");
$pr_ventil=$html->param("pr_ventil");
$pr_type=$html->param("pr_type");
$pr_deg=$html->param("pr_deg");
$pr_pdn=$html->param("pr_pdn");
$pr_pdb=$html->param("pr_pdb");
$nouveau=$html->param("nouveau");
$pr_remise_com=$html->param("pr_remise_com");

$pr_newflag=$html->param("pr_newflag");
$pr_saison=$html->param("pr_saison");
$pr_impose=$html->param("pr_impose");
$pr_remplace=$html->param("pr_remplace");
$pr_date_deb=$html->param("pr_date_deb");
$pr_date_fin=$html->param("pr_date_fin");
$pr_fragrance=$html->param("pr_fragrance");
$pr_famille=$html->param("pr_famille");
$pr_vapo=$html->param("pr_vapo");
@liste_base=("formation","dfc","camairco","togo","aircotedivoire","dfc","tacv");

# $dbh_un = DBI->connect("DBI:mysql:host=195.114.27.208:database=camairco;","web","admin",{'RaiseError' => 1});
# $dbh_bis = DBI->connect("DBI:mysql:host=195.114.27.208:database=togo;","web","admin",{'RaiseError' => 1});
# $dbh_ter = DBI->connect("DBI:mysql:host=195.114.27.208:database=aircotedivoire;","web","admin",{'RaiseError' => 1});
# $dbh_quar = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});


if (($action eq "testeur")){
	$pr_four=&get("select pr_four from produit where pr_cd_pr='$pr_cd_pr'");
 	$modulo=$pr_cd_pr%10000;
        if ($pr_four==2070){$modulo=$pr_cd_pr%100000;$pr_four=207}
	$nouveau=$pr_four.$modulo;
	$nb=&get("select count(*) from produit where pr_cd_pr=$nouveau");
	if ($nb >0){
		print "<div class=erreur>Creation impossible produit existant</div>";
		$action=""; 
	}
	else
	{
       		$query="select * from produit where pr_cd_pr='$pr_cd_pr'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while ((@tab)=$sth->fetchrow_array)
		{
			$pr_desi=$tab[1];
			$desi="TESTEUR ".$pr_desi;
			$modulo=$pr_cd_pr%10000;
			$query="insert ignore into produit values (";
			$tab[0]=$nouveau;
			$tab[1]=$desi;
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			# print "$query<br>";
			&save_replique($query);
			&save_replique("update produit set pr_prac=0,pr_prx_vte=0,pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0,pr_sup=0 where pr_cd_pr='$nouveau'","af");
			&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");

		}
 		$pr_cd_pr=$nouveau;
 		$action="visu";
	}
}
if (($action eq "creation") or ($action eq "clone")){
	$nb=&get("select count(*) from produit where pr_cd_pr=$nouveau");
	if ($nb >0){
		print "<div class=erreur>Creation impossible produit existant</div>";
		$action=""; 
	}
	else
	{
		$query="select * from produit where pr_cd_pr='$pr_cd_pr'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while ((@tab)=$sth->fetchrow_array)
		{
			$query="replace into produit values (";
			$tab[0]=$nouveau;
			
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			# print "$query<br>";
			&save_replique($query);
# 			$sth2=$dbh->prepare($query);
# 			$sth2->execute();
		}
		if ($action eq "clone"){
 			&save_replique("update produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0 where pr_cd_pr='$nouveau'","af");
			&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
 		}
 		else
 		{
 			&save_replique("update produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0,pr_refour=0,pr_prac=0,pr_prx_rev=0,pr_prx_vte=0,pr_desi='Nouveau produit',pr_sup=3,pr_codebarre='' where pr_cd_pr='$nouveau'","af");
			&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
 		}
 		$query="select * from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
 		$sth2->execute();
         	($car_cd_pr,$car_carton,$car_pal)=$sth2->fetchrow_array;
 		&save_replique("replace into carton value ('$nouveau','$car_carton','$car_pal')","af");
 		$action="visu";
 		$pr_cd_pr=$nouveau;
	}
}
if ($action eq "duplique"){
    foreach (@liste_base){
      $query="select count(*) from $_.produit where pr_cd_pr='$pr_cd_pr'";
      print "$query<br>";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($check)=$sth->fetchrow_array+0;
      if ($check==0){
 	&save("insert into $_.produit select * from $base_dbh.produit where pr_cd_pr='$pr_cd_pr'","aff");
 	&save("update $_.produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0 where pr_cd_pr='$pr_cd_pr'","aff");
 	&save("insert ignore into $_.carton select * from $base_dbh.carton where car_cd_pr='$pr_cd_pr'","aff");
# 	print "insert into $_.produit select * from $base_dbh.produit where pr_cd_pr='$pr_cd_pr'<br>";
# 	print "update $_.produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0 where pr_cd_pr='$pr_cd_pr'<br>";
# 	print "insert ignore into $_.carton select * from $base_dbh.carton where car_cd_pr='$pr_cd_pr'<br>";

      }
    }
}

if ($action eq "versmodif"){
	$modif=1;
	$action="visu";
}
if ($action eq "modif"){
	if ($logistique eq "on"){
		&save_replique("update produit set pr_desi='$pr_desi',pr_sup='$pr_sup',pr_codebarre='$pr_codebarre',pr_type='$pr_type' where pr_cd_pr='$pr_cd_pr'");
		&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
		&save_replique("replace into carton value ('$pr_cd_pr','$car_carton','$car_pal')");

	}
	if ($achat eq "on"){
		$pr_prx_rev*=100;
		$pr_prx_vte*=100;
		$pr_prac*=100;
		&save_replique("update produit set pr_prac='$pr_prac',pr_prx_rev='$pr_prx_rev',pr_four='$pr_four',pr_refour='$pr_refour',pr_prx_vte='$pr_prx_vte' where pr_cd_pr='$pr_cd_pr'");
		&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
		&save_replique("insert ignore into prixachat value ('$pr_cd_pr',curdate(),'$pr_prac')");
		
		if ($prixvauto eq "on"){
			&save_replique ("update ordre set ord_prix1='$pr_prx_vte' where ord_cd_pr='$pr_cd_pr'","af");
			&save_replique ("update trolley,lot set tr_prix='$pr_prx_vte' where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1","af");
		}
	}
	if ($douane eq "on"){
		$pr_deg*=100;
		&save_replique("update produit set pr_douane='$pr_douane',pr_ventil='$pr_ventil',pr_deg='$pr_deg',pr_pdn='$pr_pdn',pr_pdb='$pr_pdb' where pr_cd_pr='$pr_cd_pr'");
		&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	}
	if ($commercial eq "on"){
		&save_replique("replace into produit_plus values('$pr_cd_pr','$pr_date_creation',now(),'$pr_nom','$pr_newflag','$pr_saison','$pr_impose','$pr_remplace','$pr_date_deb','$pr_date_fin','$pr_fragrance','$pr_vapo','$pr_remise_com','$pr_famille','$pr_four_pub')","af");
		&save_replique("update produit set pr_pdn='$pr_pdn' where pr_cd_pr='$pr_cd_pr'");
&save_replique("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	}
	$action="visu";
}
if ($tout eq "on"){
	$achat="on";
	$logistique="on";
	$douane="on";
	$stock="on";
}
if (($achat ne "on") && ($logistique ne "on") && ($stock ne "on") && ($douane ne "on") && ($commercial ne "on")){
	$logistique="on";
#	$achat="on";
}

if ($pr_cd_pr!=''){
	$query="select * from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$pr_desi,$pr_casse,$pr_prx_rev,$pr_stre,$pr_douane,$pr_ventil,$pr_stanc,$pr_type,$pr_prx_vte,$pr_stvol,$pr_sup,$pr_emb,$pr_prac,$pr_deg,$pr_pdn,$pr_diff,$pr_acquit,$pr_orig,$pr_pdb,$pr_qte_comp,$pr_cond,$pr_devac,$pr_four,$pr_refour,$pr_codebarre)=$sth->fetchrow_array;
	$pr_casse/=100;
	$pr_prx_rev/=100;
	$pr_stre/=100;
	$pr_stanc/=100;
	$pr_prx_vte/=100;
	$pr_stvol/=100;
	$pr_prac/=100;
	$pr_deg/=100;
	$pr_diff/=100;
	&save("replace into mouchard values ($pr_cd_pr,now())");
	$query="select * from produit_plus where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$pr_date_creation,$pr_date_modification,$pr_nom,$pr_newflag,$pr_saison,$pr_impose,$pr_remplace,$pr_date_deb,$pr_date_fin,$pr_fragrance,$pr_vapo,$pr_remise_com,$pr_famille,$pr_four_pub)=$sth->fetchrow_array;
}
if (($action eq "")||(($action eq "visu") && ($recherche ne ""))){
	print "</div><form name=prod>";
	require ("form_hidden.src");
	print "Code produit <input type=text name=pr_cd_pr size=16><br>";
	print "<br><img src=/kit/images/recherche.gif align=center> recherche <input type=text name=recherche size=16><br>";
	print "<input type=hidden name=action value=visu><br>";
	print "<input type=submit value=envoie><br><br>";
# 	print "<img src=/kit/images/couleur.gif align=center> <a href=\"/kit/code_couleur.html\" target=\"wclose\" onclick=\"window.open('popup.htm','wclose','width=380,height=350,toolbar=no,status=no,left=20,top=30')\">";
# 	print " Code couleur </a><br><br>";
	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>Désignation</th><th>Stock</th><th>Trolley</th><th>En cde</th><th>Vendu</th></tr>";
	if ($recherche ne ""){
		$query="select pr_cd_pr,pr_desi,pr_sup,pr_stre from produit where pr_desi like \"%$recherche%\" order by pr_cd_pr";
	}
	else
	{
		$query="select produit.pr_cd_pr,pr_desi,pr_sup,pr_stre from produit,mouchard where produit.pr_cd_pr=mouchard.pr_cd_pr group by mouchard.pr_cd_pr order by mouchard.date desc limit 10";
	}
	$action="";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_sup,$pr_stre)=$sth->fetchrow_array){
		$res=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1")+0;
		$cde=&get("select count(*) from commande where com2_cd_pr='$pr_cd_pr'")+0;	
		$vendu=&get("select count(*) from rotation where ro_cd_pr='$pr_cd_pr'")+0;

# 		if ($pr_sup==0 || $pr_sup==3){$color="black";}else{$color="#808080";}
# 		if ($pr_stre>0){$color="#5580ab";}

# 		if ($res!=0){$color="black";}
		print "<tR><td><a href=?onglet='$onglet'&sous_onglet='$sous_onglet'&sous_sous_onglet='$sous_sous_onglet'&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td>";
		print "<td>&nbsp;";
		if ($pr_stre >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "<td>&nbsp;";
		if ($res >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "<td>&nbsp;";
		if ($cde >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "<td>&nbsp;";
		if ($vendu >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "</tr>";
		
	}	
	print "</table><br></form></html>";
}		

if ($action eq "visu"){
	$query="select fo2_add from fournis where fo2_cd_fo='$pr_four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo_add)=$sth->fetchrow_array;
	($fo_add)=split(/\*/,$fo_add);
	if (length($pr_codebarre)==11){$pr_codebarre="00".$pr_codebarre;}
	if (length($pr_codebarre)==9){$pr_codebarre="000".$pr_codebarre;}
	$code_barre=substr($pr_codebarre,0,12);
	print "<center><div class=titre>$pr_cd_pr  $pr_desi ";
	if ((! &checkbarre($pr_codebarre))||(length($pr_codebarre)<10)){print "<img src=/kit/images/codebarre_errone.gif>";}
	else {
# print "<img src=\"http://ibs.oasix.fr/code_barre/html/image.php?code=ean13&o=1&t=30&r=1&text=$code_barre&f=2&a1=&a2\" align=middle>";
}
	print "</div>";
	&images_produit($pr_desi);
	print "<form>";
	require ("form_hidden.src");
	print "logistique<input type=checkbox name=logistique>
	&nbsp;&nbsp;&nbsp;achat<input type=checkbox name=achat>
	&nbsp;&nbsp;&nbsp;douane<input type=checkbox name=douane>
	&nbsp;&nbsp;&nbsp;stock<input type=checkbox name=stock>
	&nbsp;&nbsp;&nbsp;commercial<input type=checkbox name=commercial>
	&nbsp;&nbsp;&nbsp;tout<input type=checkbox name=tout>
	<input type=hidden name=action value=visu>
	<input type=hidden name=pr_cd_pr value=$pr_cd_pr>
	<input type=submit value=envoie>
	<br></form>";

	if ($logistique eq "on") { &table_logistique($modif);}
	if ($achat eq "on") { &table_achat($modif);}
	if ($douane eq "on") { &table_douane($modif);}
	if ($stock eq "on") { &table_stock();}
	if ($commercial eq "on") { &table_commer($modif);}

	print "<br><bR><form><input type=hidden name=onglet value=$onglet>"; 
        print "<input type=hidden name=sous_onglet value=$sous_onglet>";
        print "<input type=hidden name=sous_sous_onglet value=$sous_sous_onglet>";
	print "Creation d'un nouveau produit à partir de celui la<br>nouveau produit:<input type=text name=nouveau>";
	print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
	print "<input type=submit name=action value=creation> <input type=submit name=action value=clone> <input type=submit name=action value=testeur>";
	if ($user eq "sylvain"){
	  print "<input type=submit name=action value=duplique>";
	  }
	print "</form>";

}		
	

sub table_douane {
	my($option)=$_[0];
	if ($option == 1){&info("Désormais les modifications sont centralisées en france, merci d'envoyer votre besoin à info\@dutyfreeconcept.com");$option=0;}
  	if ($option==0){print "<div class=grise>";}
  	else{print "<div class=normal>";}
 	print "<form>";
 	require ("form_hidden2.src");
	print "<table cellspacing=0 cellpadding=0 border=0 width=500>";
	print "<tr bgcolor=white>";
	print "<td width=\"93\" height=\"25\" background=\"/kit/images/boutonActive_inv2.gif\" class=menu align=center>";
	print "Douane</td><td width=407>&nbsp;</td></tr>";
	print "<tr><td colspan=2><table cellspacing=0 border=0 bgcolor=#dcdcdc width=100%>";
	print "<tr><td>Code ventilation</td><td>";
	if ($option==0){
		my($query)="select type_desi from typedesi where type_code='$pr_ventil'";
		my($sth)=$dbh->prepare($query);
		$sth->execute();
		(my($type_desi))=$sth->fetchrow_array;
		&set_color($pr_ventil);
		print "<input readonly type=texte name=pr_ventil value=\"$pr_ventil $type_desi\" style=\"background-color:$color;\">";
	}
	else
	{
		print "<select name=pr_ventil>";
		my($query)="select type_code,type_desi from typedesi order by type_code";
		my($sth)=$dbh->prepare($query);
		$sth->execute();
		while (($type_code,$type_desi)=$sth->fetchrow_array)
  		{
			print "<option value=$type_code";
			if ($pr_ventil==$type_code){print " selected";}
			print ">$type_code $type_desi</option><br>";
		}
		print "</select>";
        }
	print "</td></tr>";
	&set_color($pr_douane,$option);
	print "<tr><td width=210 valign=top>Code ndp </td><td><input type=texte $readonly name=pr_douane value='$pr_douane' style=\"background-color:$color;\">";
	if ($option==0) {
			$nomenclature=substr($pr_douane,0,8);	
			print "<div class=petit style=text-align:justify;background-color:#ffffcc;>";
			print &get("select chap_desi from chapitre where chap_douane='$nomenclature'","af");
			print "</div>";
	}
	print "</td></tr>";
	if (substr($pr_douane,0,2)==22){
		&set_color(1,$option);
		print "<tr><td>Degrée %</td><td><input type=texte $readonly name=pr_deg value=$pr_deg  style=\"background-color:$color;\"></td></tr>";
	}
	&set_color($pr_pdn,$option);
	print "<tr><td>Poids net gr</td><td><input type=texte $readonly name=pr_pdn value=$pr_pdn  style=\"background-color:$color;\"></td></tr>";
	&set_color($pr_pdb,$option);
	print "<tr><td>Poids brut gr</td><td><input type=texte $readonly name=pr_pdb value=$pr_pdb  style=\"background-color:$color;\"></td></tr>";
	print "</td></tr><tr><td>";
        print "<input type=hidden name=douane value=on>";
       	print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
        if ($option==0){print "<input type=hidden name=action value=versmodif><input type=submit value=modif ";}	
        else{ print "<input type=hidden name=action value=modif><input type=submit value=validation ";}
        print "style=\"background-color:#dcdcdc\">";
	print "</td></tr></table>";
	print "</td></tr></table>";
	print "</div>";
	print "</form>";
}

sub set_color {
	$readonly="readonly";
	$color="white";
	my($val)=$_[0];
	if (grep (/[a-z]/,$val)){$val=1;}
	if ($val == 0){$color="#FFCC00";}else{$color="#dcdcdc";}
        if ($_[1]==1){$color="white";$readonly="";}
	# if (($_[0] eq "")||($_[0] == 0)){$color="#FFCC00";}else{$color="#dcdcdc";}
}
sub table_achat {
	my($option)=$_[0];
  	if ($option==0){print "<div class=grise>";}
  	else{print "<div class=normal>";}
 	print "<form>";
 	require ("form_hidden2.src");
	print "<table cellspacing=0 cellpadding=0 border=0 width=500>";
	print "<tr bgcolor=white>";
	print "<td width=\"93\" height=\"25\" background=\"/kit/images/boutonActive_inv2.gif\" class=menu align=center>";
	print "Achat</td><td width=407>&nbsp;</td></tr>";
	print "<tr><td colspan=2><table cellspacing=0 border=0 bgcolor=#dcdcdc width=100%>";
	&set_color($pr_four,$option);
	print "<tr><td width=210>Code fournisseur</td><td>";
	if ($option==0){
		print "<input readonly type=text name=pr_four value='$pr_four $fo_add' style=\"background-color:$color;\">";
	}
	else
	{
		print "<select name=pr_four>";
		my($query)="select fo2_cd_fo,fo2_add from fournis  order by fo2_cd_fo";
		my($sth)=$dbh->prepare($query);
		$sth->execute();
		while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array)
  		{
			$fo2_add=substr($fo2_add,0,25);
			print "<option value=$fo2_cd_fo";
			if ($pr_four==$fo2_cd_fo){print " selected";}
			print ">$fo2_cd_fo $fo2_add</option><br>";
		}
		print "</select>";
        }
	print "</td></tr>";
	&set_color($pr_refour,$option);
	print "<tr><td>Référence fournisseur</td><td><input type=text $readonly name=pr_refour value='$pr_refour' style=\"background-color:$color;\"></td></tr>";
	&set_color($pr_prac,$option);
	$vraiprac=&prac($pr_cd_pr);
	print "<tr><td>Prix d'achat</td><td><input type=text $readonly name=pr_prac value='$pr_prac' style=\"background-color:$color;\"> ($vraiprac)</td></tr>";
	&set_color(1,$option);

	print "<tr><td>Remise</td><td><input type=text $readonly name=pr_prx_rev value='$pr_prx_rev' style=\"background-color:$color;\"></td></tr>";
	&set_color($pr_prx_vte,$option);
	$marge=0;
	if ($pr_prac!=0){
	  # $marge=int(($pr_prx_vte-$pr_prac)*100/$pr_prac)/100;
	  $marge=int(($pr_prx_vte)*100/$pr_prac)/100;
	  }
	print "<tr><td>Prix de vente</td><td><input type=text $readonly name=pr_prx_vte value='$pr_prx_vte' style=\"background-color:$color;\"> ($marge)</td></tr>";
	print "<tr><td>Maj des prix de vente ordre et trolley ?</td><td><input type=checkbox $readonly name=prixvauto  style=\"background-color:$color;\"> </td></tr>";
	print "<tr><td>";
        print "<input type=hidden name=achat value=on>";
       	print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
        if ($option==0){print "<input type=hidden name=action value=versmodif><input type=submit value=modif ";}	
        else{ print "<input type=hidden name=action value=modif><input type=submit value=validation ";}
        print "style=\"background-color:#dcdcdc\">";
	print "</td></tr></table>";
	print "</td></tr></table>";
	print "</div>";
	print "</form>";
}

sub table_logistique {
	my($option)=$_[0];
	if ($option == 1){&info("Désormais les modifications sont centralisées en france, merci d'envoyer votre besoin à info\@dutyfreeconcept.com");$option=0;}
  	if ($option==0){print "<div class=grise>";}
  	else{print "<div class=normal>";}
  	print "<form>";
 	require ("form_hidden2.src");
  	print "<table cellspacing=0 cellpadding=0 border=0 width=500>";
	print "<tr bgcolor=white>";
	print "<td width=\"93\" height=\"25\" background=\"/kit/images/boutonActive_inv2.gif\" class=menu align=center>";
	print "Logistique</td><td width=407>&nbsp;</td></tr>";
	print "<tr><td colspan=2><table cellspacing=0 border=0 bgcolor=#dcdcdc width=100%>";
	$ventil="";
	my(@liste)=("null","Parfum","Alcool","Cigarette","Boutique","Cosmetique");
        $ventil=$liste[$pr_type];
	&set_color($ventil,$option);
	print "<tr><td width=210>Désignation</td>";
	print "<td><input type=text $readonly name=pr_desi value='$pr_desi' style=\"background-color:$color;\"></td></tr>";
	print "<tr><td width=210>Famille</td><td>";
	if ($option==0){
		print "<input type=text readonly name=pr_type value='$pr_type $ventil' style=\"background-color:$color;\">";
	}
	else {
		print "<select name=pr_type>";
		for (my($i)=0;$i<=$#liste;$i++){
			print "<option value=$i";
			if ($pr_type==$i){print " selected";}
			print ">$liste[$i] $i</option><br>";
		}
		print "</select>";
	}
	print "</td></tr>";
        @liste=("actif","supprimé","delisté","new","déstockage","suivi par paul","délisté par paul","délisté par le fournisseur");
        $etat=$liste[$pr_sup];
	&set_color(1);
	print "<tr><td>Etat</td><td>";
	if ($option==0){
		print "<input type=text readonly name=pr_sup value='$pr_sup $etat' style=\"background-color:$color;\"></td></tr>";
	}
	else {
		print "<select name=pr_sup>";
		for (my($i)=0;$i<=$#liste;$i++){
			print "<option value=$i";
			if ($pr_sup==$i){print " selected";}
			print ">$liste[$i] $i</option><br>";
		}
		print "</select>";
	}
	if ((! &checkbarre($pr_codebarre))||(length($pr_codebarre)<10)){&set_color("",$option);}
	else {&set_color($pr_codebarre,$option);}
	print "<tr><td>Code barre</td><td><input type=text $readonly name=pr_codebarre value='$pr_codebarre' style=\"background-color:$color;\"></td></tr>";
	print "<tr><td>Code neptune</td><td><textarea readonly>";
	$query="select nep_cd_pr,nep_desi from neptune where nep_codebarre='$pr_cd_pr'";
	my($sth2)=$dbh->prepare($query);
	$sth2->execute();
	while (($neptune,$desi)=$sth2->fetchrow_array){print "$neptune $desi\n";}
        print "</textarea>";
      	my($query)="select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	(my($car_carton),my($car_pal))=$sth->fetchrow_array;
	&set_color($car_carton,$option);
	print "<tr><td>Packing carton</td><td><input type=text $readonly name=car_carton value='$car_carton' style=\"background-color:$color;\"></td></tr>";
	&set_color(1,$option);
	print "<tr><td>Packing palette</td><td><input type=text $readonly name=car_pal value='$car_pal' style=\"background-color:$color;\"></td></tr>";
	print "</td></tr>";
       	print "<tr><td>";
        print "<input type=hidden name=logistique value=on>";
       	print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
        if ($option==0){print "<input type=hidden name=action value=versmodif><input type=submit value=modif ";}	
        else{ print "<input type=hidden name=action value=modif><input type=submit value=validation ";}
        print "style=\"background-color:#dcdcdc\">";
     	print "</td></tr></table>";
	print "</td></tr></table>";
	print "</div>";
	print "</form>";
}


sub table_commer {
	my($option)=$_[0];
	#if ($option == 1){&info("Désormais les modifications sont centralisées en france, merci d'envoyer votre besoin à info\@dutyfreeconcept.com");$option=0;}
  	if ($option==0){print "<div class=grise>";}
  	else{print "<div class=normal>";}
  	print "<form>";
 	require ("form_hidden2.src");
  	print "<table cellspacing=0 cellpadding=0 border=0 width=500>";
	print "<tr bgcolor=white>";
	print "<td width=\"93\" height=\"25\" background=\"/kit/images/boutonActive_inv2.gif\" class=menu align=center>";
	print "Commercial</td><td width=407>&nbsp;</td></tr>";
	print "<tr><td colspan=2><table cellspacing=0 border=0 bgcolor=#dcdcdc width=100%>";
	print "<tr><td width=210>Nouvelle fragrance</td>";
	if ($pr_newflag eq ""){$pr_newflag="non";}
	&set_color($pr_newflag,$option);
	# &set_color(1);
	print "<td><input type=text $readonly name=pr_newflag value='$pr_newflag' style=\"background-color:$color;\"></td></tr>";
	if ($pr_saison eq ""){$pr_saison="non";}
		print "<tr><td width=210>Produit saisonnier</td><td>";
	print "<input type=text $readonly name=pr_saison value='$pr_saison' style=\"background-color:$color;\">";
	print "</td></tr>";
	if ($pr_impose eq ""){$pr_impose="non";}
	print "<tr><td width=210>Imposé par le fournisseur</td><td>";
	print "<input type=text $readonly name=pr_impose value='$pr_impose' style=\"background-color:$color;\">";
	print "</td></tr>";
	if ($pr_remplace == 0){$pr_remplace="non";}
	print "<tr><td width=210>Remplacement d'un produit existant</td><td>";
	print "<input type=text $readonly name=pr_remplace value='$pr_remplace' style=\"background-color:$color;\">";
	print "</td></tr>";
        print "<tr><td width=210>Date de demarrage prevue</td><td>";
	print "<input type=text $readonly name=pr_date_deb value='$pr_date_deb' style=\"background-color:$color;\">";
	print "</td></tr>";
        print "<tr><td width=210>Date de fin (aaaa-mm-jj) </td><td>";
	print "<input type=text $readonly name=pr_date_fin value='$pr_date_fin' style=\"background-color:$color;\">";
	print "</td></tr>";
       	# &set_color(0,$option);
        print "<tr><td width=210>Remise commercial </td><td>";
	print "<input type=text $readonly name=pr_remise_com value='$pr_remise_com' style=\"background-color:$color;\">";
	# &set_color(1,$option);
	print "</td></tr>";
        print "<tr><td width=210>Famille</td><td>";
	$query="select fa_id,fa_desi from famille order by fa_id";
	$sth = $dbh->prepare($query);
    	$sth->execute;
	%table_famille=();
    	while (($fa_id,$famille) = $sth->fetchrow_array) {
       		$table_famille{$fa_id}="$famille";
       }
       if ($option==0){
	       
		print "<input type=text $readonly name=pr_famille value='$table_famille{$pr_famille}' style=\"background-color:$color;\">";
       }
	else {
 		print "<select name=pr_famille>";
		foreach $i (keys(%table_famille)){
 			print "<option value=$i";
 			if ($pr_famille==$i){print " selected";}
 			print ">$table_famille{$i}</option><br>";
 		}
 		print "</select>";
 	}
	print "</td></tr>";
	@liste=("eau de toilette","eau de parfum","eau de cologne","parfum","eau fraiche","soie de parfum","eau tonique");
        $etat=$liste[$pr_fragrance];
	# &set_color(1);
	print "<tr><td>Type de Fragrance</td><td>";
 	if ($option==0){
		print "<input type=text $readonly name=pr_fragrance value='$pr_fragrance $etat' style=\"background-color:$color;\">";
 	}
 	else {
 		print "<select name=pr_fragrance>";
 		for (my($i)=0;$i<=$#liste;$i++){
 			print "<option value=$i";
 			if ($pr_fragrance==$i){print " selected";}
 			print ">$liste[$i] $i</option><br>";
 		}
 		print "</select>";
 	}
	print "</td></tr>";
 	print "<tr><td>Contenance ml</td><td><input type=texte $readonly name=pr_pdn value=$pr_pdn  style=\"background-color:$color;\"></td></tr>";
      	print "<tr><td>";
       	print "</td></tr>";
 	if ($pr_vapo eq ""){$pr_vapo="oui";}
 	print "<tr><td>Vaporisateur</td><td><input type=texte $readonly name=pr_vapo value=$pr_vapo style=\"background-color:$color;\"></td></tr>";
      	print "<tr><td>";
        print "<input type=hidden name=commercial value=on>";
       	print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
        if ($option==0){print "<input type=hidden name=action value=versmodif><input type=submit value=modif ";}	
        else{ print "<input type=hidden name=action value=modif><input type=submit value=validation ";}
        print "style=\"background-color:#dcdcdc\">";
     	print "</td></tr></table>";
	print "</td></tr></table>";
	print "</div>";
	print "</form>";
}

sub table_stock {
  	print "<div class=grise>";
	print "<table cellspacing=0 cellpadding=0 border=0 width=500>";
	print "<tr bgcolor=white>";
	# print "<td width=\"93\" height=\"25\" background=\"/kit/images/boutonActive_inv2.gif\" class=menu align=center>";
	print "<td background=\"/kit/images/boutonActive_inv2.gif\" class=menu align=center>";
	print "Stock</td><td width=407>&nbsp;</td></tr>";
	print "<tr><td colspan=2><table cellspacing=0 border=0 bgcolor=#dcdcdc width=100%>";
	%stock=&stock($pr_cd_pr,"","","debu");
	$stock=$stock{"stock"};
	$pr_diff=$stock{"errdep"};
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
    	$stock_navire=0;
    	while (my $nom = $sth->fetchrow_array) {
       		$stock_navire+=&stock_navire("$pr_cd_pr","$nom","debu");
       }
       	$qte_commande=&get("select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'")+0;
      
	# $stock=($pr_stre-$pr_stvol-$pr_casse+$pr_diff)/100;
	&set_color($stock);
	print "<tr><td width=210>stock disponible</td><td><input type=text value='$stock' style=\"background-color:$color;\"></td></tr>";
	&set_color(1);
	print "<tr><td>stock debut de mois</td><td><input type=text value='$pr_stanc' style=\"background-color:$color;\"></td></tr>";
	&set_color(1);
	print "<tr><td>Stock casse</td><td><input type=text value='$pr_casse' style=\"background-color:$color;\"></td></tr>";
	&set_color(1);
	print "<tr><td><a href=inv_stockair.pl?produit=$pr_cd_pr&action=go target=_blank>Stock en vol</a></td><td><input type=text value='$pr_stvol' style=\"background-color:$color;\"></td></tr>";
	&set_color(1);
	# print "<tr><td><a href=inv_mer_new.pl?produit=$pr_cd_pr&action=go target=_blank>Stock en mer</a></td><td><input type=text name=pr_prac value='$stock_navire' style=\"background-color:$color;\"></td></tr>";
	# &set_color(1);
	print "<tr><td>En commande</a></td><td><input type=text value='$qte_commande' style=\"background-color:$color;\"></td></tr>";
	&set_color(1);
	print "<tr><td>Ecart</td><td><input type=text name=pr_prac value='$pr_diff' style=\"background-color:$color;\"></td></tr>";
	print "<tr><td>Dernière entrée</td><td>";
	$lastin=&get("select max(enh_date) from enthead,entbody where enh_no=enb_no and enb_cdpr=737052074443");
	if ($lastin ne ""){print &julian($lastin);}
	print "</td></tr>";
	print "</td></tr></table>";
	print "</td></tr></table>";
	print "</div>";
}
sub images_produit()
	{
	my ($desi)=$_[0];
	if ((grep /DIOR/,$desi)&&(grep /ADORE/,$desi)){print "<img src=/kit/images_produit/dior_jadore.jpg>";}
       	if ((grep /CHANEL/,$desi)&&(grep /5/,$desi)){print "<img src=/kit/images_produit/chanel5.gif>";}
       	if ((grep /GAULTIER/,$desi)&&(grep /MAL/,$desi)){print "<img src=/kit/images_produit/gaultier_lemale.jpg>";}
       	if (grep /ANAIS/,$desi){print "<img src=/kit/images_produit/anais_anais.jpg>";}
       	if ((grep /DIOR/,$desi)&&(grep /POISON/,$desi)){print "<img src=/kit/images_produit/dior_poison.jpg>";}
       	if ((grep /AQUA/,$desi)&&(grep /GIO/,$desi)){print "<img src=/kit/images_produit/armani_aqua.gif>";}
       	if (grep /^HUGO/,$desi){print "<img src=/kit/images_produit/hugoboss.jpg>";}
       	if (grep /LOLITA/,$desi){print "<img src=/kit/images_produit/lolita.jpg>";}
        if (grep /KENZO/,$desi){print "<img src=/kit/images_produit/kenzo.png>";}

        }
sub save_replique()
{
	my $query=$_[0];
	#my ($sth)=$dbh_un->prepare($_[0]);
	#$sth->execute() or die (print $query);
 	my ($sth)=$dbh->prepare($_[0]);
 	$sth->execute() or die (print $query);

	# 	my ($sth)=$dbh_bis->prepare($_[0]);
# 	$sth->execute() or die (print $query);
# 	$sth=$dbh_ter->prepare($_[0]);
# 	$sth->execute() or die (print $query);
# 	$sth=$dbh_quar->prepare($_[0]);
# 	$sth->execute() or die (print $query);

	
}
;1
