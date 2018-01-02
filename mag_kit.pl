#### VERSION FACTURE PAR MARQUE  """""""""""""""""

#### a faire mettre un flag à mag_info et gerer valide/lock *******
#### a faire deplacement par block *******

use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
# use OpenOffice::OOCBuilder;
 use Spreadsheet::WriteExcel;

use File::Copy qw(copy);
# use Text::Levenshtein qw(distance);
use String::Similarity;
use LWP::UserAgent;
use PDF::Reuse;

$mag=$html->param("mag");	
$code=$html->param("code");	
$code_pub=$html->param("code_pub");	
$cases=$html->param("cases");	
$page=$html->param("page");
$info=$html->param("info");
$contact=$html->param("contact");
$prix=$html->param("prix");
$prix_xof=$html->param("prix_xof");
$prix_strike=$html->param("prix_strike");
$prix_strike_xof=$html->param("prix_strike_xof");
$desi=$html->param("desi");
$action_prev=$html->param("action_prev");	
$option=$html->param("option");	
$four=$html->param("four");
$focus=$html->param("focus");
$sous_tot=$html->param("sous_tot");
$sendpdf=$html->param("sendpdf");


# $mag_texte=$html->param("mag_texte");
 
#  print "<div style=background-color:pink> Developpement en cours ne pas utiliser</div>"; 
$desi=~s/'/ /g;
$info=~s/'/ /g;
$contact=~s/'/ /g;

$query="select cl_nom,cl_magazine from client where cl_cd_cl='$base_client_code'";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom,$cl_magazine)=$sth->fetchrow_array;
	
$pub=$new;$texte=$visuel=0;
if ($html->param("pub") eq "on"){$pub=1;$pubcheck="checked";}
if ($html->param("new") eq "on"){$new=1;$newcheck="checked";}
if ($html->param("texte") eq "on"){$texte=1;$textecheck="checked";}
if ($html->param("visuel") eq "on"){$visuel=1;$visuelcheck="checked";}
if ($html->param("presentation") eq "on"){$visuel=-1;$presentationcheck="checked";}
$visuelprix=$html->param("visuelprix");
$pubprix=$html->param("pubprix");
$desi_pub=$html->param("desi_pub");
$desi_pub=~s/'/ /g;
$marque=$html->param("marque");
$marque=~s/'/ /g;
@liste_fragrance=("EDT","EDP","eau de cologne","parfum","eau fraiche","soie de parfum","eau tonique","coffret");

print "<style>";
print "li:nth-child(odd) { background-color:#efefef;width:600px;}";
print "li {list-style-type:none;}";
print "a.textemag span{display:none;}";
print "a.textemag:hover span{display:inline;position:relative;top:-20px;left:20px;background-color:yellow;}";
print "a.nodeco {text-decoration:none;color:black;}";
print "a.nodeco:hover {background-color:orange;}";
 
print ".cache{display:none;}";
print "</style>";

# if ($action eq "maj"){
#   $query = "select * from mag_import";
#   $sth=$dbh->prepare($query);
#   $sth->execute();
#   while (($code,$prix,$prix_xof,$texte,$visuel,$pub,$info,$contact)=$sth->fetchrow_array){
#     &save("update mag set prix='$prix',prix_xof='$prix_xof',visuel='$visuel',texte='$texte',pub='$pub',info='$info',contact='$contact' where code='$code'","aff");
#   }
# }

print "<div style=\"width:670px;height:6000px;position:absolute;background-color:white;\">";  # debut de la boite cellule principale

if ($action eq "supmag"){
  &save("delete from mag where mag='$mag'");
  $action="";
}  
if ($action eq "majdate"){
  $date_debut=$html->param("date_debut");
  if (grep(/\//,$date_debut)) {
	  ($jj,$mm,$aa)=split(/\//,$date_debut);
	  $date_debut=$aa."-".$mm."-".$jj;
  }
  $date_fin=$html->param("date_fin");
  if (grep(/\//,$date_fin)) {
	  ($jj,$mm,$aa)=split(/\//,$date_fin);
	  $date_fin=$aa."-".$mm."-".$jj;
  }
  &save("insert ignore into mag_info (mag) values ('$mag')");
  &save("update mag_info set debut='$date_debut',fin='$date_fin' where mag='$mag'","af");
  if ($html->param("mail") eq "on"){
	&save("update mag_info set mail=1 where mag='$mag'","af");
  }
  else{
	&save("update mag_info set mail=0 where mag='$mag'","af");
  }
  $action="go";
}
  

if ($action eq "cre_trol"){
  $lot_desi=$html->param("lot_desi");
  $lot_conteneur=$html->param("lot_conteneur");
  $lot_nbcont=$html->param("lot_nbcont");
  $lot_nbplomb=$html->param("lot_nbplomb");
  $lot_poids=$html->param("lot_poids");
  $lot_flag=$html->param("lot_flag");
  $lot_cout=$html->param("lot_cout");
  $lot_nolot=$html->param("lot_nolot");
  $lot_inspire=$html->param("lot_inspire");
  
  $ok=1;
  $check=&get("select count(*) from lot where lot_nolot=$lot_nolot")+0;
  $check+=&get("select count(*) from trolley where tr_code=$lot_nolot");
  if ($check >0){
    print "<p class=erreur>Trolley $lot_nolot existant</p>";
    $ok=0;
  }
  if ($lot_inspire ne ""){
    $check=&get("select count(*) from trolley where tr_code=$lot_inspire")+0;
    if ($check ==0){
      print "<p class=erreur>Trolley à s'inspirer $lot_inspire inexistant</p>";
      $ok=0;
    }  
  }
  
  $check=&get("select count(*) from trolley where tr_code=$lot_nolot*10")+0;
  $check+=&get("select count(*) from lot where lot_nolot=$lot_nolot*10")+0;
  if ($check >0){
    print "<p class=erreur>Trolley $lot_nolot"."0 (en $base_dev1) existant</p>";
    $ok=0;
  }
  if ($ok){
    &maj_code_court();
    $lot_nolotx=$lot_nolot*10;
    &save("create temporary table ordre_temp (famille int(3),desi varchar(40),code int(10))"); 
    $query = "select code from mag where mag='$mag' and code>0 and visuel>0";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code)=$sth->fetchrow_array){
      &famille($code);
      &desi_court($code);
      &save ("insert into ordre_temp values ('$pr_famille','$desi_court','$code')");
      $nb++;
    }
    $query="select code from ordre_temp,dfc.ordre_famille where ord_famille=famille  order by ord_ordre,desi ";
    $sth=$dbh->prepare($query);
    $sth->execute();
    $ordre=2;
    while (($code)=$sth->fetchrow_array){
      $query="select prix,prix_xof from mag where mag='$mag' and code>=0  and visuel>0 and code='$code'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($prix,$prix_xof)=$sth2->fetchrow_array;
      $prix*=100;
      $prix_xof*=100;
      $tr_qte=100;
      $tr_tiroir=0;
      if ($lot_inspire ne ""){
	$query="select tr_qte,tr_tiroir from trolley where tr_code='$lot_inspire' and tr_cd_pr='$code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($tr_qte,$tr_tiroir)=$sth2->fetchrow_array;
	if ($tr_qte==0){$tr_qte=100;}
      }
      &save ("insert ignore into trolley value ('$lot_nolot','$ordre','$code','$tr_qte','$prix','$tr_tiroir','')");
      &save ("insert ignore into trolley value ('$lot_nolotx','$ordre','$code','$tr_qte','$prix_xof','$tr_tiroir','')");
      $ordre+=5;
    }  
    &save ("insert ignore into lot values ('$lot_nolot','$lot_desi','$lot_conteneur','$lot_nbplomb','$lot_nbplomb','0','1','$lot_cout','$mag',curdate(),'')","af");
    $lot_desi.="_$base_dev1";
    &save ("insert ignore into lot values ('$lot_nolotx','$lot_desi','$lot_conteneur','$lot_nbplomb','$lot_nbplomb','0','0','$lot_cout','$mag',curdate(),'')","af");
    print "<p >Lot $lot_nolot et $lot_nolotx créés <a href=?onglet=0&sous_onglet=4>Voir les trolleys</a></p>";
	$mess="creation_du_${lo_nolot}_${base_dbh}";
	system("/var/www/cgi-bin/dfc.oasix/send_bug $mess &");
  }
  print "<input type=button value=retour onclick=history.back()>";
} 

if ($action eq "trol"){
  print "Controle ...<br>";
  $ok=1;
  print "Code ..";
  $query="select page from mag where mag='$mag' and code>=0 and  visuel>0 and code not in (select pr_cd_pr from produit)";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($page)=$sth->fetchrow_array){
    print "<p>Page $page produit inconnu</p>";
    $ok=0;
  }
  if ($ok){print "ok<br>";}
  print "Prix ..";
  $query="select code,page,prix,prix_xof from mag where mag='$mag' and code>=0  and (prix=0 or prix_xof=0) and visuel>0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code,$page,$prix,$prix_xof)=$sth->fetchrow_array){
    $desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    print "<p>page:$page $code $desi Prix Euro:$prix Prix $base_dev1:$prix_xof </p>";
    $ok=0;
  }
  if ($ok){print "ok<br>";}

#   print "Ordre ..";
#   $query="select code,page from mag where mag='$mag' and code>=0  and visuel>0 and code not in (select ord_cd_pr from ordre)";
#   $sth=$dbh->prepare($query);
#   $sth->execute();
#   while (($code,$page)=$sth->fetchrow_array){
#     $desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
#     print "<p >page:$page $code $desi non ordonné </p>";
#     $ok=0;
#   }
#   if ($ok){print "ok<br>";}
#   
  print "Ordre ..."; 
  $query = "select code from mag where mag='$mag' and code>0 and visuel>=0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    &famille($code);
    $check=&get("select count(*) from dfc.ordre_famille where ord_famille='$pr_famille'")+0;
    if ($check==0){
      print "$code $desi_court famille:$pr_famille non ordonnée<br>";
      $ok=0;
    }
    
  }
  if ($ok){print "ok<br>";}
   
   
   if ($ok){
	$nolot=&get("select max(lot_nolot) from lot where lot_nolot<10000");
	$nolot++;
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
	&form_hidden();
	print "<div style=float:left;width:200px;>No </div> <input type=text size=5 name=lot_nolot><br />";
	print "<div style=float:left;width:200px;>Pour les tiroirs et les quantités s'inspirer du trolley (facultatif)</div><br><input type=text size=5 name=lot_inspire><br />";
	print "<div style=float:left;width:200px;>Libellé </div> $mag <input type=hidden name=lot_desi value=\"$mag\"><br />";
	print "<div style=float:left;width:200px;>Conteneur ex:1T+A</div> <input type=text  size=20 name=lot_conteneur value=\"$lot_conteneur\"><br />";
	print "<div style=float:left;width:200px;>Nombre de plomb</div> <input type=text size=3 name=lot_nbplomb value=$lot_nbplomb><br />";
	print "<div style=float:left;width:200px;>Cout de traitement</div> <input type=text size=3 name=lot_cout value=$lot_cout><br />";
	print "<input type=hidden name=action value=cre_trol>";
	print "<input type=hidden name=mag value=$mag>";
	print "<input type=submit value=submit> (le trolley en prix $base_dev1 sera automatiquement créé)</form>";
   }			  
   else {
    print "<input type=button value=retour onclick=history.back()>";
   }
}   


if ($action eq "copier"){
    $new_mag=$html->param('new_mag');;
    if (($new_mag ne "")&&($new_mag!~m/ /)){
      &save("insert ignore into mag select '$new_mag', `page`, `cases`, `code`, `prix`, `prix_xof`, `texte`, `visuel`, `pub`, `new`, `info`, `contact`, `desi`, `visuelprix`, `pubprix`, `desi_pub`, `marque`,`code_court`,'prix_strike','prix_xof_strike' from mag where mag='$mag'");
      &save("update mag,marque_gr set marque='ROBERTO CAVALLI DAVIDOFF OPI' where marque=marque_desi and marque_ind=2 and mag='$new_mag'");
      &save("update mag,marque_gr set marque='LACOSTE DOLCE&GABBANA GUCCI BOSS' where marque=marque_desi and marque_ind=1 and mag='$new_mag'");
      #suite mail pierette du 10 mars 2015
      $mag=$new_mag;
      &trace("$action");
      $action="go";
    }
    else {
    &houps("nom de magazine invalide");
    }
  
}  
if ($action eq "decaler+"){
  &save("create temporary table chemin_temp (page int(8),cases int(8))");
  &save("insert into chemin_temp select page,cases from mag where mag='$mag' and page>='$page'");
  $query="select * from chemin_temp order by cases,page desc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($page,$cases)=$sth->fetchrow_array){
    &save("update mag set page=page+1 where mag='$mag' and page='$page' and cases='$cases'","af");
  }
  &trace("$action");
  $action="go";
}  
if ($action eq "decaler-"){
  &save("create temporary table chemin_temp (page int(8),cases int(8))");
  &save("insert into chemin_temp select page,cases from mag where mag='$mag' and page>='$page'");
  $query="select * from chemin_temp order by cases,page asc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($page,$cases)=$sth->fetchrow_array){
    &save("update mag set page=page-1 where mag='$mag' and page='$page' and cases='$cases'","af");
  }
  &trace("$action");
  $action="go";
}  

if ($action eq "Deplacer"){
  $newpage=$html->param("newpage");
  $check=&get("select count(*) from mag where mag='$mag' and page='$newpage'")+0;
  $ajout=$html->param("ajout");
  if (($check!=0)&&($ajout ne "on")){
    &houps("Impossible page existante");
    $action="modif_page";
  }
  else
  {
    &save("update mag set page='$newpage' where page='$page' and mag='$mag'");
    &trace("$action");
    $action="go";
  }
}  
if ($action eq "Intervertir"){
  $newpage=$html->param("switch");
  $check=&get("select count(*) from mag where mag='$mag' and page='$newpage'")+0;
  if ($check==0){
    &houps("Impossible page inexistante");
    $action="modif_page";
  }
  else
  {
    &trace("$action");
    &save("delete from mag where page=-99 and mag='$mag'");
    &save("update mag set page=-99 where page='$newpage' and mag='$mag'");
    &save("update mag set page='$newpage' where page='$page' and mag='$mag'");
    &save("update mag set page='$page' where page=-99 and mag='$mag'");
    $action="go";
  }
    
}

if ($action eq "modif_page"){
    print "<form>";
    &form_hidden();
    print "Page:$page<br>";
    print "<input type=submit name=action value='decaler+'>Toutes les pages vont être incrémentées de 1 à partir de la page:$page jusqu'a la derniere page<br>";
    print "<input type=submit name=action value='decaler-'>Toutes les pages vont être décrémentées de 1 à partir de la page:$page jusqu'a la derniere page<br>";
    print "Deplacer la page $page vers la page <input type=text name=newpage size=3> <input type=submit name=action value='Deplacer'> Ajouter aux produits existants <input type=checkbox name=ajout><br>";
    print "Intervertir la page $page avec la page <input type=text name=switch size=3> <input type=submit name=action value='Intervertir'><br>";
    print "<input type=hidden name=mag value='$mag'>";
    print "<input type=hidden name=page value='$page'>";
    print "</form>";
}  
if ($action eq "modif_adresse"){
    print "<form>";
    &form_hidden();
    print "Mag:$mag<br>";
    $adresse=&get("select adresse from mag_info where mag='$mag'");
    if ($adresse eq ""){$adresse=$mag;}
    print "Lien: (mettre que la fin ex cc03i ou c15-i)<input type=text name=adresse value='$adresse' size=50>";
    print "<input type=hidden name=mag value='$mag'>";
    print "<input type=hidden name=action value=modif_adresse_save>";
    print "<input type=submit>";
    print "</form>";
}  
if ($action eq "modif_adresse_save"){
     $adresse=$html->param("adresse");
     $adresse=~s/'//g;
     $adresse=~s/ //g;
     &save("replace into mag_info (mag,adresse) values('$mag','$adresse')");
     &trace("$action");
     $action="go";
}   


if ($action eq "modif_import"){
  $nb_ligne=&get("select max(cases) from mag where mag='$mag'");
  for ($i=1;$i<=$nb_ligne;$i++){
    if ($html->param("$i") eq "on"){
      $desi=&get("select desi from mag where mag='$mag' and cases='$i'");
      print "$desi code 0<br>";
      &save("update mag set code=0 where mag='$mag' and cases='$i'");
    }
  }
  &trace("$action");
  $action="go";
}

if ($action eq "sup_l"){
	&save("update dfc.produit_mag set image_l='' where code='$code'");
	$action="ins";
}
if ($action eq "sup_s"){
	&save("update dfc.produit_mag set image_s='' where code='$code'");
	$action="ins";
}

if ($action eq "modif_save"){
	$newpage=$html->param("newpage");
	$newposition=$html->param("newposition");
	$check=&get("select code from mag where cases='$cases' and page='$page' and mag='$mag'","af");
	if ($check != $code){
		&save("update mag set code='$code' where cases='$cases' and page='$page' and mag='$mag'","af");
	}
	$pr_prac=$html->param("prix_achat");
	$check=&get("select pr_prac from produit where pr_cd_pr=$code")+0;
	$pr_prac*=100;
	if (($pr_prac!=$check)&&($code ne "")&&($pr_prac>0)){
	    # averifier à quoi ça correspond
		# system("/var/www/cgi-bin/dfc.oasix/maj_prac.pl $code $pr_prac"); 
		&save("update produit set pr_prac='$pr_prac' where pr_cd_pr='$code'","af");
	
	}
	&place();
	if (($newpage!=$page)||($newposition!=$position)){
		$index=0;
		$cases_tamp=$cases;
		$query="select cases from mag where mag='$mag' and page='$newpage' order by cases";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$newcases=-1;
		while (($mcases)=$sth->fetchrow_array){
			$index++;
			if ($index>=$newposition){$newcases=$mcases;last;}
		}
		if ($index==0){
			$newcases=10;#page inexistante
		} 
		else {
			if ($newcases==-1){$newcases=&get("select max(cases) from mag where mag='$mag' and page='$newpage'")+1;} # derniere position
			else {
				$query="select cases from mag where mag='$mag' and page='$newpage' and cases>='$newcases' order by cases desc";
				$sth=$dbh->prepare($query);
				$sth->execute();
				while (($mcases)=$sth->fetchrow_array){
					if (($mcases==$cases)&&($newpage==$page)){$cases_tamp=$cases+1;} # cas particulier
					&save("update mag set cases=cases+1 where mag='$mag' and page='$newpage' and cases='$mcases'","af");
				}
			}
		} 
		# newcases c'est la nouvelle cases
		$cases=$cases_tamp;
		&save("update mag set page='$newpage',cases='$newcases' where mag='$mag' and page='$page' and cases='$cases'","af");
		$page=$newpage;
		$cases=$newcases;
	}
	$pagepub=$html->param("pagepub");
	if (($pagepub==0)&&(length($desi_pub)<3)){$pagepub="";}
	if ($code !=0){
		if ($pagepub ne ""){
			$code_neg=$code*-1;
			$check=&get("select page from mag where code='$code_neg' and mag='$mag'");
			if ($check ne $pagepub){
				$casepub=&get("select max(cases) from mag where mag='$mag' and page='$pagepub'")+1;
				$textepub=&get("select pr_desi from produit where pr_cd_pr='$code'","af");
				$textepub=$desi_pub." ".$textepub;
				&save("insert ignore into mag values ('$mag','$pagepub','$casepub','$code_neg','','','','','','','','','','','','$textepub','','','','')","af");
				&save("delete from mag where code='$code_neg' and mag='$mag' and page='$check'");
				&pashoups("Page de pub $textepub inserée en page $pagepub"); 
			}
			else{
				$textepub=&get("select pr_desi from produit where pr_cd_pr='$code'","af");
				$textepub=$desi_pub." ".$textepub;
				&save("update mag set desi_pub='$textepub' where mag='$mag' and page='$pagepub' and code='$code_neg'","af");
			}
		}
		else{
			$code_neg=$code*-1;
			$pagepub=&get("select page from mag where code='$code_neg' and mag='$mag'");
			&save("delete from mag where code='$code_neg' and mag='$mag'");
			if ($pagepub ne ""){
				&pashoups("Page de pub $textepub supprimée de la page $pagepub"); 
			}
		}
	}
	$texte_f=$html->param("texte_f");
	$texte_f=~s/\"/\'/g;
	$texte_a=$html->param("texte_a");
	$texte_a=~s/\"/\'/g;
	&save("insert ignore into dfc.produit_mag value('$code',\"$texte_f\",\"$texte_a\",'','')"); 
	&save("update dfc.produit_mag set texte_f=\"$texte_f\",texte_a=\"$texte_a\" where code='$code'"); 
	&trace("$action");
}

if (($action eq "modif_save")||($action eq "modif_save_verif1")||($action eq "modif_save_verif2")||($action eq "modif_save_verif3")){
    if ($cases eq ""){
      $cases=&get("select max(cases) from mag where mag='$mag' and page='$page'")+1;
      &save("insert into mag values ('$mag','$page','$cases','$code','$prix','$prix_xof','$texte','$visuel','$pub','$new','$info','$contact','$desi','$visuelprix','$pubprix','$desi_pub','$marque','$code_court','$prix_strike','$prix_xof_strike')","af");
   	
    }
    else {
		$mail=&get("select mail from mag_info where mag='$mag'")+0;
		if ($mail){
			$query="select prix,prix_xof from mag where code='$code' and mag='$mag' and cases='$cases' and page='$page'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			($ancien_prix,$ancien_prix_xof)=$sth->fetchrow_array;
			$desi=&get("select pr_desi from produit where pr_cd_pr='$code'"); 
			if ($ancien_prix != $prix){
				$mess="\'Changement de prix euro sur le catalogue:$mag produit:$code $desi page no:$page ancien prix:$ancien_prix nouveau prix:$prix\'";
				system("/var/www/cgi-bin/dfc.oasix/send_modif_mag.pl $mess &");
				print "<p style=background:lightgreen>Mail envoyé à thomas </p>";
			}
			if ($ancien_prix_xof != $prix_xof){
				$mess="\'Changement de prix en devise sur le catalogue:$mag produit:$code $desi page no:$page ancien prix:$ancien_prix_xof nouveau prix:$prix_xof\'";
				system("/var/www/cgi-bin/dfc.oasix/send_modif_mag.pl $mess &");
				print "<p style=background:lightgreen>Mail envoyé à thomas</p>";
			}
		}
        &save("update mag set code='$code',prix='$prix',prix_xof='$prix_xof',texte='$texte',visuel='$visuel',pub='$pub',new='$new',info='$info',contact='$contact',desi='$desi',visuelprix='$visuelprix',pubprix='$pubprix',desi_pub='$desi_pub',marque='$marque',prix_strike='$prix_strike',prix_strike_xof='$prix_strike_xof' where mag='$mag' and cases='$cases' and page='$page'","af");
    }
    $focus=$code;
    &trace("$action");
    if ($action eq "modif_save") {$action="ins";}
    if ($action_prev ne "") {$action=$action_prev;}
    
}

if ($action eq "importer"){
      print "<form>";
      &form_hidden();
      &save ("delete from mag where mag='$mag'");
      $fic=$html->param("fichier");
      while (read($fic, $data, 4192)){
	      $texte=$texte.$data;
      }
      while ($texte=~s/'//){};
      print "Cocher les lignes avec l'auto codification erroné<br>";
      print "<table cellspacing=0 border=1>";
      (@ligne)=split(/\n/,$texte);
      foreach $ligne (@ligne){
	   chop($ligne);
	   $cases++;
	   (@cell)=split(/\t/,$ligne);
	   if ($cell[4] eq ""){next;}
	   if ($cell[1] eq ""){next;}
	   if ($cell[5] eq ""){next;}
	   if (grep/[a-z,A-Z]/,$cell[1]){next;}
	   $chaine='%'.$cell[5].'%';
	   $chaine=~s/ /%/g;
	   # attention c'est transitoire
	   $code=&get("select code from camairco.mag where desi like '$chaine'","af");
	   $page=$cell[1];
	   $prix=$cell[9];
	   $prix_xof=$cell[11];
	   $desi=$cell[5];
	   $marque=$cell[4];
	   $prix_xof=~s/,//;
	   $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
	   ($marque_pr,$null)=split(/ /,$pr_desi);
	   $ecart=similarity $pr_desi,$desi;
	   $color="white";
	   if ($ecart <0.5){$color="pink";}
# 	   $ecart_marque=distance("$marque","$marque_pr");
	   $texte=0;
	   if (($cell[14] eq "OK")||($cell[14] eq "OUI")){$texte=1;}
	   $visuel=1;
	   $pub=0;
	   if (($cell[16] eq "OK")||($cell[14] eq "OUI")){$pub=1;}
	   $info=$cell[17];
	   $contact=$cell[18];
	   if (($marque ne $marque_pr)&&($code ne "")){$color="pink";}
 	   if (($ecart>20)&&($code ne "")){$color="pink";}
 	   $new=0;
 	   if (grep /nouveau/i,$info){$new=1;}
 	   if (grep /new/i,$info){$new=1;}
 	   print "<tr><td>$page</td><td>$code</td><td bgcolor=$color><span style=color:blue>$marque</span> $desi<br><span style=color:blue>$marque_pr</span> $pr_desi</td><td>$prix</td><td>$prix_xof</td><td><input type=checkbox name=$cases></tr>";
 	   &save("insert ignore into mag values ('$mag','$page','$cases','$code','$prix','$prix_xof','$texte','$visuel','$pub','$new','$info','$contact','$desi','$visuelprix','$pubprix','$desi_pub','$marque','$code_court','$prix_strike','$prix_xof_strike')","af");
#  	    &save("update mag set marque='$marque' where cases='$cases'");
         } 
      print "</table>";
      print "<input type=hidden name=action value=modif_import>";
      print "<input type=hidden name=mag value='$mag'>";
      print "<input type=submit>";
      print "</form>";
}

if (($action eq "ins")&&($code eq "")){
  print "<form name=maform>";
  print "Code produit ? (0 si c'est une creation) <input type=text name=code><br>";
  &form_hidden();
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=page value=$page>";
  print "<input type=hidden name=action value=insertion>";
  print "<input type=submit>";
  print "</form>";
  print "<form>";
  print "Recherche <input type=text name=recherche><br>";
  &form_hidden();
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=page value=$page>";
  print "<input type=hidden name=action value=ins>";
  print "<input type=submit>";
  print "</form>";
  $recherche=$html->param("recherche");
  if ($recherche ne ""){
    print "<table>";
    $query="select pr_cd_pr,pr_desi,pr_pdn from produit where pr_desi like '%$recherche%'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($pr_cd_pr,$pr_desi,$pr_pdn)=$sth->fetchrow_array){
	$pr_fragrance=&get("select pr_fragrance from produit_plus where pr_cd_pr='$pr_cd_pr'");
	$fragrance=$liste_fragrance[$pr_fragrance];
# 	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$fragrance</td><td>$pr_pdn ML</td></tr>";
 	print "<tr><td><a href=# onclick=document.maform.code.value=$pr_cd_pr>$pr_cd_pr</a></td><td>$pr_desi</td></tr>";
    }
    print "</table>";
   }
 print "produits nouveaux<br>";  
 $query="select produit.pr_cd_pr,pr_desi from produit,dfc.produit_plus where produit.pr_cd_pr=produit_plus.pr_cd_pr and datediff(curdate(),pr_date_creation)<60 order by pr_desi";   
 $sth=$dbh->prepare($query);
 $sth->execute();
 while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
  print "<a href=# onclick=document.maform.code.value=$pr_cd_pr>$pr_cd_pr</a> $pr_desi<br>";
 }
}

if (($action eq "insertion")&&($code eq "")){
    &houps("merci de mettre un code produit");
}    
if (($action eq "insertion")&&($code ne "")){
    &cree_produit_tmp();
    $cases=&get("select max(cases) from mag where mag='$mag' and page='$page'")+1;
    $marque=&get("select marque from dfc.produit_desi where code='$code'"); 
    $four=&get("select pr_four from produit where pr_cd_pr='$code'");
    $fa_id=&get("select pr_famille from produit_plus  where pr_cd_pr='$code'");
    $prixv=&get("select prix from mag_pub where famille='$fa_id' and type='V' and four='$four'")+0;
    $desi="";
    $contact="";
    $contact=&get("select contact from mag,produit_tmp where code=pr_cd_pr and pr_four='$four' and contact!='' limit 1");
    if ($code==0){
      $desi="Produit à creer";
      $marque="";
      $contact="";
      $prixv=0;
    }
    &save("insert into mag values ('$mag','$page','$cases','$code','','','','1','','','','$contact','$desi','$prixv','','','$marque','$code_court','$prix_strike','$prix_xof_strike')","af");
    $action="ins";
    $focus=$code;
    &pashoups("Le Produit a été créé page:$page en derniere position"); 
 }

if (($action eq "ins")&&($code ne "")){
    $query="select texte_f,texte_a,image_s,image_l from dfc.produit_mag where code='$code'";
	$sth=$dbh->prepare($query);
    $sth->execute();
    ($texte_f,$texte_a,$image_s,$image_l)=$sth->fetchrow_array;
   
	$query = "select prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,desi_pub,marque,prix_strike,prix_strike_xof from mag where mag='$mag' and cases='$cases' and code='$code' and page='$page'";
#     print "$query";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$desi_pub,$marque,$prix_strike,$prix_strike_xof)=$sth->fetchrow_array;
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    if ($pub){$pubcheck="checked";}
    if ($new){$newcheck="checked";}
    
    if ($texte){$textecheck="checked";}	
    if ($visuel==1){$visuelcheck="checked";}
    if ($visuel==-1){$presentationcheck="checked";}
    print "<form method=POST name=maform enctype=multipart/form-data style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
    print "<div class=titre><input type=text name=code value=\"$code\" size=6> $pr_desi</div>";
    &form_hidden();
      if ($code>10000){
	$pr_prac=&get("select pr_prac from produit where pr_cd_pr='$code'","af")+0;
	$pr_prac/=100;
      }  
      $lock=&get("select pr_remplace from produit_plus where pr_cd_pr='$code'");
      if ($lock ne "loc"){	
	print "Prix Achat<input type=text name=prix_achat value=\"$pr_prac\" size=4 style=position:absolute;left:300px;text-align:right><br />";
      }
      else
      {
	print "Prix Achat<span style=position:absolute;left:300px;>$pr_prac (produit non commun entre les bases)</span><br />";
      }
      $coef=0;
      $style=0;
      if ($pr_prac>0){$coef=$prix/$pr_prac;}
      $coef=int($coef*100)/100;
      if (($coef<2)||($coef>3)){$style="background-color:red;";}
      print "Prix Vente<input type=text name=prix value=\"$prix\" size=4 style=position:absolute;left:270px;text-align:right;$style> $coef";
	  print "<span style=position:absolute;left:350px;>Prix Vente (eur) barré <input type=text name=prix_strike value=\"$prix_strike\" size=4></span>";
	  print "<br />";
      $conv=$prix*655.957;
      if ($base_dev1 eq "CVE"){
	$conv=$prix*110;
      }
      $coef=0;
      $style=0;
      if ($prix>0){$coef=$prix_xof/$prix;}
      $coef=int($coef);
      if (($coef<600)||($coef>700)){$style="background-color:red;";}
      if ($base_dev1 eq "CVE"){
	$style=0;
	if (($coef<100)||($coef>130)){$style="background-color:red;";}
      }
      print "Prix $base_dev1 ($conv) <input type=text name=prix_xof value=\"$prix_xof\" size=4 style=position:absolute;left:270px;text-align:right;$style> $coef";
	  print "<span style=position:absolute;left:350px;>Prix Vente (xof) barré <input type=text name=prix_strike_xof value=\"$prix_strike_xof\" size=4></span>";
	  print "<br />";
      
    if ($code==0){
      print "Designation<br><input type=text name=desi value=\"$desi\"  size=50><br />";
    }
    print "Marque<br><input type=text name=marque value=\"$marque\" size=40><br/>";
    print "Texte <input type=checkbox name=texte $textecheck style=position:absolute;left:300px><br />";
    print "Visuel <input type=checkbox name=visuel $visuelcheck style=position:absolute;left:300px><span style=position:absolute;left:350px>Prix</span><input type=text name=visuelprix value='$visuelprix' style=position:absolute;left:400px size=5><br />";
    print "Présentation <input type=checkbox name=presentation $presentationcheck><br />";
    print "Pub <input type=checkbox name=pub $pubcheck style=position:absolute;left:300px><span style=position:absolute;left:350px>Prix</span><input type=text name=pubprix value='$pubprix' style=position:absolute;left:400px size=6><br />";
    print "Designation Pub (ex PLEINE PAGE) ne pas mettre le nom du produit <br><input type=text name=desi_pub value=\"$desi_pub\" size=40>";
    $code_neg=$code*-1;
    $pagepub=&get("select page from mag where code='$code_neg' and mag='$mag'","af");
    if ($code_neg==0){$pagepub=0;}
    print " Page <input type=text name=pagepub value='$pagepub' size=3>";
    print "<br>";
    print "Nouveau <input type=checkbox name=new $newcheck style=position:absolute;left:300px><br />";
    &place();
    print "Page:<input type=texte name=newpage value='$page' size=3> Position:<input type=texte name=newposition value='$position' size=3><br>";
    print "Info<br><input type=text name=info value=\"$info\"  size=50><br />";
    print "Contact<br><input type=text name=contact value=\"$contact\" size=50><br />";
    print "<input type=hidden name=mag value=$mag>";
    print "<input type=hidden name=cases value=$cases>";
    print "<input type=hidden name=page value=$page>";
    print "<input type=hidden name=action_prev value=$action_prev>";
    print "<input type=hidden name=action value=modif_save>";
    &save("create temporary table similarity (code bigint(20),rank decimal(4,2))");

    if (($code==0)&&($desi ne "")){
      print "<br>Proposition de produit<br>";
      $query="select pr_cd_pr,pr_desi from produit limit 1000";
      $sth=$dbh->prepare($query);
      $sth->execute();
      while (($code,$pr_desi)=$sth->fetchrow_array){
	  $ecart= similarity $pr_desi,$desi;
	  if ($ecart>=0.5){ 
	    &save("insert into similarity values ('$code','$ecart')");
	    
	  }
      }
    if ($marque ne ""){
	$query="select pr_cd_pr from produit where pr_desi like '%$marque%'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code)=$sth->fetchrow_array){
	    $check=&get("select count(*) from similarity where code='$code'")+0;
	    if ($check==0){
	      &save("insert into similarity values ('$code','0')");
	    }
	}
      }
      $query="select pr_cd_pr,pr_desi,rank*100 from produit,similarity where code=pr_cd_pr order by rank desc";
      $sth=$dbh->prepare($query);
      $sth->execute();
      while (($code,$pr_desi,$rank)=$sth->fetchrow_array){
	 $rank=int($rank);
         print "<a href=# onclick=document.maform.code.value=$code>$code</a> $pr_desi $rank%<br>";
     }
    }
	print "<textarea name=texte_f placeholder=\"Texte français\" style=width:100%;heigth:80px>$texte_f</textarea><br>";
	print "<textarea name=texte_a placeholder=\"Texte anglais\" style=width:100%;heigth:80px>$texte_a</textarea><br>";
	print "<input type=submit>";
	print "</form>";
	if ($image_l ne ""){print "<img src=/images/$image_l> <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup_l&mag=$mag&page=$page&code=$code&cases=$cases>Sup</a><br>";}
	if ($image_s ne ""){print "<img src=/images/$image_s>  <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup_s&mag=$mag&page=$page&code=$code&cases=$cases>Sup</a><br>";}
	print "<a href=# onclick=\"window.open('http://dfc.oasix.fr/cgi-bin/upload_image.pl?code=$code&action=select','','width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,adress=yess,scrollbars=yes,left=20,top=30')\">Upload image</a>";
	print "<form>";
    &form_hidden();
    print "<input type=hidden name=mag value='$mag'>";
    print "<input type=hidden name=focus value='$code'>";
    print "<input type=hidden name=action value=go>";
    print "<div style=margin:auto;><input type=submit value='Retour au magazine'></div>";
    print "</form>";
      
  }

if ($action eq "modif_desi_pub"){
  $query = "select code from mag where mag='$mag' order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    $desi_pub=$html->param("desi_pub$code");  
    $desi_pub=~s/'//g;
    if ($desi_pub ne ""){
        $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
        $desi_pub.=" $pr_desi";
    	&save("update mag set desi_pub='$desi_pub' where mag='$mag' and code=$code","af");
     }
   }
   &trace("$action");
   $action="pub";
}

if ($action eq "modif"){
#   print $html->param("a220246");
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
#   print $query;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$visuelprix,$pubprix)=$sth->fetchrow_array){
    ($newpage,$newcases,$newcode)=split(/:/,$html->param("a$code"));  
#     print "$code $newcode<br>";
  
    if ($newcode!=$code){
      $query="select cases from mag where mag='$mag' and page='$newpage' and cases>='$newcases' order by cases desc";
#       print "$query";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      while (($mcases)=$sth2->fetchrow_array){
	&save("update mag set cases=cases+1 where mag='$mag' and page='$newpage' and cases='$mcases'","af");
      }
      if (($cases >$newcases)&&($page==$newpage)){$cases++;}
      &save("update mag set page='$newpage',cases='$newcases' where mag='$mag' and page='$page' and cases='$cases'","af");
	
      $focus=$code;
    }
  }
  &trace("$action");
  $action="go";
}

if ($action eq ""){
  print "<form style=margin-left:100px;>";
  print "Choisir un magazine<br>";
  &form_hidden();
  $query = "select distinct mag from mag order by mag desc ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($mag)=$sth->fetchrow_array){
    print "<input type=submit name=mag value=$mag>";
  }
  print "<input type=hidden name=action value=go>";
  print "</form>";
  print "<hr></ht>";
  print "Ou importation<br>";
  print "<form method=POST enctype=multipart/form-data style=margin-left:100px;>";
  print "Choisir un fichier csv<br>";
  &form_hidden();
  print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
  print "<input type=file name=fichier accept=text/* maxlength=2097152>";
  print "<br>Nom ? (sans espace ni accent) <input type=texte name=mag>";
  print "<input type=submit name=action value=importer>";
  print "</form>";
}
if ($action eq "sup"){
  &save("delete from mag where code='$code' and page='$page' and mag='$mag' limit 1","af");
  print "<div class=red>Supprimé<div>";
  &trace("$action");
  $action="go";

}

if ($action eq "verif1"){
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    
    print "<div $style>";
    print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif1&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
    
    if ($new){print " <img src=../../images/new.png>";}
    print "<span style=position:absolute;left:450px>$prix</span>";
    print "<span style=position:absolute;left:500px>$prix_xof</span>";
    if ($prix!=0){$ratio=int($prix_xof/$prix);}else{$ratio=999999;}
    print "<span style=position:absolute;left:550px;";
    $style="";
    if (($ratio>700)||($ratio<649)){$style="background-color:red;"}
    if ($base_dev1 eq "CVE"){
      $style="";
      if (($ratio>120)||($ratio<105)){$style="background-color:red;"}
    }
    print "$style>$ratio</span></div>";
  }
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
}

if ($action eq "verif2"){
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_prac=&get("select pr_prac/100 from produit where pr_cd_pr='$code'")+0;
    
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    print "<div $style>";
    print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif2&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
    
    if ($new){print " <img src=../../images/new.png>";}
    print "<span style=position:absolute;left:450px>$pr_prac</span>";
    print "<span style=position:absolute;left:500px>$prix</span>";
    if ($pr_prac!=0){$ratio=int($prix*100/$pr_prac)/100;}else{$ratio=999999;}
    print "<span style=position:absolute;left:550px;";
    if (($ratio>3)||($ratio<2)){print "background-color:red;"}
    print ">$ratio</span></div>";
  }
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
}

if ($action eq "verif3"){
  print "stock et commande en cours<br>";
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' and code>0 and visuel>=0 order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_stre=&get("select pr_stre/100 from produit where pr_cd_pr='$code'")+0;
    $cde=&get("select sum(com2_qte)/100 from commande where com2_cd_pr='$code'")+0;
    
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    $en_cours=$pr_stre+$cde;
    if ($en_cours<12){   $style=" style=color:red;";}
   
    print "<div $style>";
    print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif3&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
    
    if ($new){print " <img src=../../images/new.png>";}
    print "<span style=position:absolute;left:450px>$pr_stre</span>";
    print "<span style=position:absolute;left:500px>$cde</span>";
    print "</div>";
  }
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
}
if ($action eq "verif4"){
  print "Designations les produit en rouge sont des produits non harmonisés<br>";
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' and code>0 and visuel>=0 order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    $lock=&get("select pr_remplace from dfc.produit_plus where pr_cd_pr='$code'");
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    &desi_court($code);
    if ($color eq "white"){$color="#efefef";}else{$color="white";}
    if ($lock eq "loc"){$color="pink";}
    print "<div style=\"background-color:$color;border:1px solid black\"><a href=http://dfc.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$code&action=visu target=_blank>$code</a> $pr_desi<br>$desi_court<br>$desi_tpe</div>";
  }
}
if ($action eq "verif9"){
  &maj_code_court();
  
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,code_court,prix_strike,prix_xof_strike from mag where mag='$mag' and code>0 and visuel>=0 order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$code_court,$prix_strike,$prix_xof_strike)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $style="";
    print "<div style=\"border:1px solid black\"><a href=http://dfc.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$code&action=visu target=_blank>$code</a> $pr_desi <strong>$code_court</strong></div>";
  }
}
if ($action eq "verif10"){
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,code_court,prix_strike,prix_xof_strike from mag where mag='$mag' and code>0 and visuel>=0 order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$code_court,$prix_strike,$prix_xof_strike)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $style="";
	$note=&get("select note from dfc.sephora_ref,dfc.produit_inode,dfc.sephora where sephora_ref.code=sephora.code and sephora_ref.inode=produit_inode.inode and produit_inode.code='$code'");
    print "<div style=\"border:1px solid black\">$code  $pr_desi <br><strong>$note</strong></div>";
  }
}

if ($action eq "verif5_mod"){
  $page=$html->param("page");
  $pr_famille=$html->param("pr_famille");
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' and code>0 and visuel>=0 and page='$page' order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    $lock=&get("select pr_remplace from dfc.produit_plus where pr_cd_pr='$code'");
    if ($lock ne "loc"){
      &save("update dfc.produit_plus set pr_famille='$pr_famille' where pr_cd_pr='$code'","af");
    }
  }
  $action="verif5";
}


if ($action eq "verif5"){
  print "Famille un clic sur la famille met tous les produits de la page dans la même famille<br>";
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' and code>0 and visuel>=0  order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $lock=&get("select pr_remplace from dfc.produit_plus where pr_cd_pr='$code'");
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    &famille($code);
    if ($color eq "white"){$color="#efefef";}else{$color="white";}
    if ($lock eq "loc"){$color="pink";}
    print "<div style=\"background-color:$color;border:1px solid black\"><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif5_mod&mag=$mag&page=$page&pr_famille=$pr_famille style=color:navy>$fa_famille</a> <a href=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?onglet=''&sous_onglet=0&sous_sous_onglet=''&pr_cd_pr=$code&action=visu target=_blank>$code</a> $pr_desi";
	$query="select texte_f,texte_a,image_s,image_l from dfc.produit_mag where code='$code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($texte_f,$texte_a,$image_s,$image_l)=$sth2->fetchrow_array;
	print "<img src=/images/$image_s width=50px>";
	print "</div>";
  }
}
if ($action eq "verif6"){
  print "Ordre trolley<br>";
  &save("create temporary table ordre_temp (famille int(3),desi varchar(40),code int(10))"); 
  $query = "select code from mag where mag='$mag' and code>0 and visuel>=0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    &famille($code);
    &desi_court($code);
    &save ("insert into ordre_temp values ('$pr_famille','$desi_court','$code')");
    $nb++;
  }
  $query="select code,famille from ordre_temp,dfc.ordre_famille where ord_famille=famille  order by ord_ordre,desi ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code,$famille)=$sth->fetchrow_array){
    $fa_desi=&get("select fa_desi from dfc.famille where fa_id='$famille'");
    if ($fa_desi ne $fa_desi_tamp){
      print "<strong>$famille $fa_desi</strong><br>";
      $fa_desi_tamp=$fa_desi;
    }
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    print "$code $pr_desi <br>";
    $nb2++;
  }  
 if ($nb != $nb2){print "<p style=background-color:pink>Attention il y a des produits dont la famille n'a pas ete pride en compte</p>";} 
}

if ($action eq "verif7"){
  print "Tpe les produits en rouge sont des doublons<br>";
  &save("create temporary table ordre_temp (famille int(3),desi varchar(15),code int(10))"); 
  $query = "select code from mag where mag='$mag' and code>0 and visuel>=0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    &famille($code);
    &desi_court($code);
    $desi_tpe=lc($desi_tpe);
    $desi_tpe=ucfirst($desi_tpe);
    &save ("insert into ordre_temp values ('$fa_cat','$desi_tpe','$code')");
    $nb++;
  }
  $query="select famille,desi,code from ordre_temp order by famille,desi";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($famille,$desi,$code)=$sth->fetchrow_array){
    if ($famille ne $famille_tamp){
      print "<strong>";
      print &famille_tpe($famille);
      print "</strong><br>";
      $famille_tamp=$famille;
    }
    $check=&get("select count(*) from ordre_temp where desi='$desi'");
    if ($check==1){
      print "<a href=http://dfc.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$code&action=visu target=_blank>$code</a> $desi<bR>";
    }
    else
    {
      print "<span style=background-color:pink><a href=http://dfc.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$code&action=visu target=_blank>$code</a> $desi</span><br>";
    }
    
  }  
}
if ($action eq "verif8"){
  $query = "select code from mag where mag='$mag' and code>0 and visuel>=0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    $pr_sup=&get("select pr_sup from produit where pr_cd_pr='$code'");
    if ((($pr_sup==1)||($pr_sup==2)||($pr_sup==5))&&($option eq "maj")){
      &save("update produit set pr_sup=0 where pr_cd_pr='$code'");
      $pr_sup=0;
    }
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    @liste=("actif","supprimé","délisté","new","déstockage","délisté par le fournisseur");
    $etat=$liste[$pr_sup];
    @coulor=("black","red","red","blue","green","red");
    $color=$coulor[$pr_sup];
    print "<span style=color:$color>$code $pr_desi Etat $pr_sup $etat</span><br>";
  }
  print "<form>";
  &form_hidden();
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=action value=verif8>";
  print "<input type=hidden name=option value=maj>";
  print "<input type=submit value=\"activer tous les produits en rouge\">";
  print "</form>";
}


# if ($action eq "verif4"){
#   print "prix d'achat enregistré et prix d'achat ficher excel<br>";
#   
#   $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
#   $i=10;
#   $sth=$dbh->prepare($query);
#   $sth->execute();
#    $query="select prac from Feuille1 order by cases";
#   $sth2=$dbh->prepare($query);
#   $sth2->execute();
#    
#   
#   while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
#     if ($page ne $page_tamp){
#       print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
#       print "</div>";
#       $page_tamp=$page;
#     }
#     $style="";
#     if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
#     $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
#     $pr_prac=&get("select pr_prac/100 from produit where pr_cd_pr='$code'")+0;
#     ($pr_prac_new)=$sth2->fetchrow_array;  
#     $pr_prac_new=int($pr_prac_new*100)/100;
#     if (($pr_desi eq "")||($code==0)){
#       $pr_desi=$desi;
#       $style=" style=color:red;";
#     }
#     print "<div $style>";
#     print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif3&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
#     
#     if ($new){print " <img src=../../images/new.png>";}
#     print "<span style=position:absolute;left:450px>$pr_prac</span>";
#     print "<span style=position:absolute;left:500px>$pr_prac_new</span>";
#     if ($pr_prac!=0){$ratio=int($pr_prac_new*100/$pr_prac)/100;}else{$ratio=999999;}
#     print "<span style=position:absolute;left:550px;";
#     if ((($ratio>1.2)||($ratio<0.8))&&($pr_prac!=0)&&($pr_prac_new!=0)){print "background-color:red;"}
#     print ">$ratio</span>";
#      print "</div>";
#     $i++;
#   }
#    if ($focus ne ""){
#     print "<script>location.href='#$focus';</script>";
#    }
#   
# }
if ($action eq "majprix"){
    &cree_produit_tmp();
    $query = "select code from mag,produit_tmp where pr_cd_pr=code and mag='$mag' and pr_four='$four'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code)=$sth->fetchrow_array){
      $fa_id=&get("select pr_famille from produit_plus  where pr_cd_pr='$code'");
      $prixv=&get("select prix from mag_pub where famille='$fa_id' and type='V' and four='$four'")+0;
      $prixp=&get("select prix from mag_pub where famille='$fa_id' and type='P' and four='$four'")+0;
      if ($prixv!=0){
	  &save("update mag set visuelprix='$prixv' where mag='$mag' and code='$code'","af");
      }
      if ($prixv!=0){
	  &save("update mag set pubprix='$prixp' where mag='$mag' and code='$code'");
      }
    }
    &trace("$action");
    print "Mise à jour effectuée<br>";
    $action="pub";
}    
if ($action eq "modif_prix_pub"){
    &cree_produit_tmp();

    $query = "select code from mag,produit_tmp where pr_cd_pr=code and mag='$mag' and pr_four='$four'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code)=$sth->fetchrow_array){
      $prixv=$html->param("visuel$code")+0;
      $prixp=$html->param("pub$code")+0;
      &save("update mag set visuelprix='$prixv' where mag='$mag' and code='$code'","af");
      &save("update mag set pubprix='$prixp' where mag='$mag' and code='$code'","af");
    }
    print "Mise à jour effectuée<br>";
    &trace("$action");
    $action="pub";
}    

if ($action eq "pub"){
    &cree_produit_tmp();

    $marque_tamp="null";
    $last_facture=&get("select max(no_facture) from dfc.facture_pub")+1;
    print "Libelle:$cl_magazine<br>";
    print "<p style=color:blue>Les prix peuvent être mis à jour:<br>";
    print "-Individuellement en cliquant sur le code produit </br>";
    print "-Individuellement en modifiant le prix dans les cases ci-dessous (bouton modifier en bas du fournisseur)</br>";
    print "-En mettant à jour les prix par défaut (lien prix visuel dans le cadre gauche), puis le lien 'mise à jour des prix par defaut' en bas de chaque marque</br>";
    print "Les prix en négatif appraissent comme offerts dans la facture<br></p>";
    print "<form name=maform method=POST>";
    &form_hidden();
    print "Controle <input type=radio name=controle value=controle checked><br>";
    print "Factures définitives ";
    print "<input type=radio name=controle value=facture>";
    print "Prochain no de facture <input type=texte name=facture value=$last_facture size=6 disabled=\"disabled\"> Envoyer les mails <input type=checkbox name=sendpdf ><br>";
    print "<input type=hidden name=action value=facture_pub>";
    print "<input type=hidden name=mag value=$mag>";
    print "<input type=submit value=\"Documents Pdf\"><br>";
    print "<input type=hidden name=four value='nul'>";
    $query = "select code,pr_desi,pr_four,visuel,pub,visuelprix,pubprix,desi_pub,marque,cases,page from mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' order by pr_four,marque,pr_desi";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code,$pr_desi,$pr_four,$visuel,$pub,$visuelprix,$pubprix,$desi_pub,$marque,$cases,$page)=$sth->fetchrow_array){
#       if ($marque eq ""){
# 	($marque)=split(/ /,$pr_desi);
#         &save("update mag set marque='$marque' where code='$code'","aff");
#       }
#       if (($marque >0)&&($marque<15)){
# 	($marque)=split(/ /,$pr_desi);
#         &save("update mag set marque='$marque' where code='$code'","aff");
#       }
      if ($marque_tamp eq "null") {$marque_tamp=$marque;}
      if ($pr_four ne $fo2_cd_fo){
	  if ($fo2_cd_fo ne ""){
	  if ($afacture==1){
	    print "<input type=hidden name=afac_$fo2_cd_fo"."_"."$marqueindex value='on'>";
#  	    print "</br>$fo2_cd_fo **** on *****</br>";
	  }
	  $afacture=0;
	  $marqueindex=0;
# 	  print "<input type=submit value=modifier onclick=\"document.maform.four.value='$fo2_cd_fo';document.maform.action.value='modif_prix_pub'\">"; 	 
# 	  print "*$afacture*";
   
 	  print "<input type=submit value=modifier onclick=document.maform.action.value='modif_prix_pub';document.maform.four.value='$fo2_cd_fo'>"; 	    
	 
	  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";

# 	    print "No de facture <input type=texte name=facture> Sous_totaux <input type=checkbox name=sous_tot><br>";
# 	    print "<input type=hidden name=four value=$fo2_cd_fo>";
# 	    print "<input type=hidden name=action value=facture_pub>";
# 	    print "<input type=hidden name=mag value=$mag>";
#  	    print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";
#   	    print "</form>";
	  }
	  ($fo2_add)=split('\*',&get("select fo2_add from fournis where fo2_cd_fo='$pr_four'"));
	  $sous_tot=0;
	  if ($pr_four==1260){$sous_tot=1;} #distrimark
	  if ($pr_four==1290){$sous_tot=1;} #iom
	  print "<hr></hr><span style=font-size:1.1em;font-weight:bold;>$pr_four $fo2_add</span>";
	  if ($sous_tot){print " <span style=font-size:1.1em;color:blue;>$marque</span>";}
	  print "<br>";
	  $fo2_cd_fo=$pr_four;
	  $marque_tamp=$marque;
      } 
      if (($marque ne $marque_tamp)&&($sous_tot)){
# 	  print "No de facture <input type=texte name=facture> Sous_totaux <input type=checkbox name=sous_tot><br>";
# 	  print "<input type=hidden name=four value=$fo2_cd_fo>";
# 	  print "<input type=hidden name=marque value='$marque'>";
# 	  print "<input type=hidden name=action value=facture_pub>";
# 	  print "<input type=hidden name=mag value=$mag>";
# 	  print "<input type=submit>";
# 	  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";
# 	  print "</form>";
	  if ($afacture==1){
	    print "<input type=hidden name=afac_$fo2_cd_fo"."_"."$marqueindex value='on'>";
#  	    print "</br>****$pr_four on *****</br>";
	    $afacture=0;
	  }
  	  $marqueindex++;
 	  print "<br><span style=font-size:1.1em;font-weight:bold;>$pr_four $fo2_add</span>";
	  print " <span style=font-size:1.1em;color:blue;>$marque</span>";
	  print "<br>";
	   $marque_tamp=$marque;
	 
      } 
      
      if ($visuel==1) {
	  print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=pub&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a>";
          print " PACKSHOTS $pr_desi <input type=text name=visuel$code value='$visuelprix' size=3 style=position:absolute;left:500px><br>";
          if ($visuelprix>0){$afacture=1;}
      }
      if ($pub==1) {
	if ($desi_pub eq ""){
	  $desi_pub="PLEINE PAGE $pr_desi";
	}
	else {$desi_pub=$desi_pub." $pr_desi";}
	if (($option eq "modif_pub")&&($code==$code_pub)){
	  print "<select name=desi_pub$code>";
	  $query = "select produit.pr_cd_pr,pr_desi from produit,produit_plus where produit.pr_cd_pr=produit_plus.pr_cd_pr and produit_plus.pr_famille=99";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($code_pub,$pr_desi_pub)=$sth2->fetchrow_array){
	    print "<option value='$pr_desi_pub' ";
	    if ($pr_desi_pub eq $desi_pub) {print "selected";}
	    print ">$code_pub $pr_desi_pub</option>";
	  }
	  print "</select>";  
# 	  print "<input type=text name=desi_pub$code value='$desi_pub' size=60>"
	  print "<input type=submit onclick=document.form$pr_four.action.value='modif_desi_pub'>";
	}
	else {
	  print "<span style=color:blue>$desi_pub</span>";
	  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=pub&option=modif_pub&mag=$mag&page=$page&code_pub=$code><img border=0 src=../../images/b_edit.png title='Modifier'></a>";
	}
	print "<input type=text name=pub$code value='$pubprix' size=3 style=position:absolute;left:500px><br>";
	if ($pubprix>0){$afacture=1;}
      }
    }
    # sortie de boucle
    if ($afacture==1){
	    print "<input type=hidden name=afac_$fo2_cd_fo"."_"."$marqueindex value='on'>";
#  	    print "</br>****$pr_four on *****</br>";
	    $afacture=0;
    }
    print "<input type=submit value=modifier onclick=document.maform.action.value='modif_prix_pub';document.maform.four.value='$fo2_cd_fo'>"; 	    
    print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";
    print "</form>";
}


if ($action eq "excel"){
  &cree_produit_tmp();
  $query = "select pr_four,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,marque,pr_prac/100 from mag,produit where mag='$mag' and code=pr_cd_pr order by pr_four,page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_four,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$marque,$prac)=$sth->fetchrow_array){
    if ($pr_four ne $run){
      if ($run ne ""){
		$workbook->close();
		print "<div >$nom <a href=http://$base_rep.fr/doc/${mag}_${run}.xls><img src=/images/excel.gif></a></div>";
      }
      $query="select * from fournis where fo2_cd_fo='$pr_four'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth2->fetchrow_array;
      ($nom,$rue,$ville)=split(/\*/,$fo2_add);
	  $mail_pub=&get("select email from dfc.contact where fo_id='$fo2_cd_fo' and pub='on'");
	  if ($mail_pub ne ""){$fo2_email=$mail_pub;}
	  ($fo2_email)=split(/\;/,fo2_email);
	  
      $workbook = Spreadsheet::WriteExcel->new("../../$base_rep/doc/${mag}_${pr_four}.xls");
      $sheet = $workbook->add_worksheet();
      $ligne=1;
      $col=1;
      $i=0;
      $sheet->write($ligne,$col, "pages");
      $col++;
      $sheet->write($ligne,$col, "code");
      $col++;
      $sheet->write($ligne,$col, "code four");
      $col++;
      $sheet->write($ligne,$col, "marque");
      $col++;
      $sheet->write($ligne,$col, "pr_desi");
      $col++;
      $sheet->write($ligne,$col, "prix");
      $col++;
      $sheet->write($ligne,$col, "prix_xof");
      $col++;
      $sheet->write($ligne,$col, "nom");
      $col++;
      $sheet->write($ligne,$col, "texte");
      $col++;
      $sheet->write($ligne,$col, "visuel");
      $col++;
      $sheet->write($ligne,$col, "contact");
	  $col++;
      $sheet->write($ligne,$col, "prix achat");
	  $col++;
      $sheet->write($ligne,$col, "stock");
      $ligne++;
      $col=1;
      $run=$pr_four;
    }
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_refour=&get("select pr_refour from produit where pr_cd_pr='$code'");
	$pr_stre=&get("select pr_stre/100 from produit where pr_cd_pr='$code'")+0;
    $sheet->write($ligne,$col, "$page");
    $col++;
    $sheet->write($ligne,$col, "$code");
    $col++;
    $sheet->write($ligne,$col, "$pr_refour");
    $col++;
    $sheet->write($ligne,$col, "$marque");
    $col++;
    $sheet->write($ligne,$col, "$pr_desi");
    $col++;
    $sheet->write($ligne,$col, "$prix");
    $col++;
    $sheet->write($ligne,$col, "$prix_xof");
    $col++;
    $sheet->write($ligne,$col, "$nom");
    $col++;
    $sheet->write($ligne,$col, "$texte");
    $col++;
    $sheet->write($ligne,$col, "$visuel");
    $col++;
    $sheet->write($ligne,$col, "$contact");
	$col++;
    $sheet->write($ligne,$col, "$prac");
	$col++;
    $sheet->write($ligne,$col, "$pr_stre");
    $ligne++;
    $col=1;
  }
  $workbook->close();
  print "<div >$nom <a href=http://$base_rep.fr/doc/${mag}_${run}.xls><img src=/images/excel.gif></a></div>";
  $workbook = Spreadsheet::WriteExcel->new("../../$base_rep/doc/${mag}.xls");
  $sheet = $workbook->add_worksheet();
  $ligne=1;
  $col=1;
  $i=0;
  $sheet->write($ligne,$col, "pages");
  $col++;
  $sheet->write($ligne,$col, "code");
  $col++;
  $sheet->write($ligne,$col, "code four");
  $col++;
  $sheet->write($ligne,$col, "marque");
  $col++;
  $sheet->write($ligne,$col, "pr_desi");
  $col++;
  $sheet->write($ligne,$col, "prix");
  $col++;
  $sheet->write($ligne,$col, "prix_xof");
  $col++;
  $sheet->write($ligne,$col, "nom");
  $col++;
  $sheet->write($ligne,$col, "texte");
  $col++;
  $sheet->write($ligne,$col, "visuel");
  $col++;
  $sheet->write($ligne,$col, "contact");
  $col++;
  $sheet->write($ligne,$col, "prix achat");
  $col++;
  $sheet->write($ligne,$col, "stock");
  $ligne++;
  $col=1;
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,marque,pr_prac/100 from mag,produit where mag='$mag' and code=pr_cd_pr order by page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$marque,$prac)=$sth->fetchrow_array){
    $pr_four=&get("select pr_four from produit where pr_cd_pr='$code'");
    $query="select * from fournis where fo2_cd_fo='$pr_four'";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth2->fetchrow_array;
    ($nom,$rue,$ville)=split(/\*/,$fo2_add);
	$mail_pub=&get("select email from dfc.contact where fo_id='$fo2_cd_fo' and pub='on'");
	if ($mail_pub ne ""){$fo2_email=$mail_pub;}
	($fo2_email)=split(/\;/,fo2_email);
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_refour=&get("select pr_refour from produit where pr_cd_pr='$code'");
	$pr_stre=&get("select pr_stre/100 from produit where pr_cd_pr='$code'")+0;
    $sheet->write($ligne,$col, "$page");
    $col++;
    $sheet->write($ligne,$col, "$code");
    $col++;
    $sheet->write($ligne,$col, "$pr_refour");
    $col++;
    $sheet->write($ligne,$col, "$marque");
    $col++;
    $sheet->write($ligne,$col, "$pr_desi");
    $col++;
    $sheet->write($ligne,$col, "$prix");
    $col++;
    $sheet->write($ligne,$col, "$prix_xof");
    $col++;
    $sheet->write($ligne,$col, "$nom");
    $col++;
    $sheet->write($ligne,$col, "$texte");
    $col++;
    $sheet->write($ligne,$col, "$visuel");
    $col++;
    $sheet->write($ligne,$col, "$contact");
	$col++;
    $sheet->write($ligne,$col, "$prac");
	$col++;
    $sheet->write($ligne,$col, "$pr_stre");
    $ligne++;
    $col=1;
  }
  $workbook->close();
  print "<div >$mag <a href=http://$base_rep.fr/doc/$mag.xls><img src=/images/excel.gif></a></div>";
}

if ($action eq "facture_pub"){
    print "<font style=color:red>Facturation en cours merci de bien attendre la fin du traitement</font><br>";
	&cree_produit_tmp();
	# $facture=$html->param("facture");
    $facture=&get("select max(no_facture) from dfc.facture_pub")+1;
	$controle=$html->param("controle");
	if (($facture eq "")&&($controle eq "facture")){print "merci de mettre un numero de facture<br>";$action="pub";}
	else {
		if ($controle eq "controle"){
			&save("delete from dfc.facture_pub where base='$base_dbh' and mag='$mag' and no_facture=0","af");
			#&save("update mag_info set flag=1 where mag='$mag'");
		}
		$query = "select distinct pr_four from mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' order by pr_four";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($four)=$sth->fetchrow_array){
			$check=&get("select no_facture from dfc.facture_pub where base='$base_dbh' and mag='$mag' and fournisseur='$four'")+0;
			if ($check!=0){next;} # facture deja faite
			$sous_tot=0;
			if ($four==1260){$sous_tot=1;} #distrimark
			if ($four==1290){$sous_tot=1;} #iom
			$ref="afac_".$four."_0";
			%tot=();
			if (($html->param("$ref") eq "on")||($sous_tot==1)){
				$total_fo=0;
				$debut="";
				&create_pdf();
				$fin=$facture-1;
				if ($sous_tot==1){
					if ($controle eq "facture"){
						$group=$debut."_".$fin.".pdf";
					}
					else
					{
						$group="group_$four.pdf";
					}
					prFile("../../dfc.oasix/doc/$group");
				}		  
				print "<div style=\"border:1px solid black;clear:both;background:$efefef\">";
				print "$nom <span ";
				if (&validemail($fo2_email)){
					print ">";
				}
				else {
					print " style=background-color:pink>mail invalide ";
					#  	  &save("update mag_info set flag=0 where mag='$mag'");
				}
				print "Email:$fo2_email</span><br>"; 
				print "<br>";
				$query="select pdf,marque,montant from dfc.facture_pub where base='$base_dbh' and mag='$mag' and fournisseur='$four' and date=curdate() order by marque";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				while (($pdf,$marque,$montant)=$sth2->fetchrow_array){
					if ($sous_tot==1){
						print "<div style=float:left;width:160;padding:20px;margin:10px;font-size:0.8em;background:lightgray><a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
						if ($controle eq "facture"){print "$pdf<br>";}
						print "$marque<br>$montant Euros";
						print "</div>";
						prDoc("../../dfc.oasix/doc/$pdf");
					}
					else {
						print "<div style=width:160;padding:20px;margin:10px;font-size:0.8em;background:lightgray><a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
						if ($controle eq "facture"){
							print "$pdf<br>";
							if (($sendpdf eq "on")&&(&validemail($fo2_email))){
								$mail=$fo2_email;
								$mail=~s/@/\@/;
								system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $pdf $mag &");
								print "Mail envoyé<br>";
								&save("update dfc.facture_pub set date_mail=curdate() where base='$base_dbh' and mag='$mag' and fournisseur='$four' and date=curdate() and pdf='$pdf'");
							}
						}
						print "$marque<br>$montant Euros</div>";
						# 	   if ($montant==0){&save("update mag_info set flag=0 where mag='$mag'");}
					} 
					$total_gen+=$montant;
				}
				if ($sous_tot==1){
					prEnd();
					print "<div style=clear:both;width:160;padding:20px;font-size:0.8em;background:white><a href=http://dfc.oasix.fr/doc/$group><img src=/images/pdf.jpg /></a><br>";
					if ($controle eq "facture"){
						print "$group<br>";
						if (($sendpdf eq "on")&&(&validemail($fo2_email))){
							$mail=$fo2_email;
							$mail=~s/@/\@/;
							system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $group $mag &");
							print "Mail envoyé<br>";
							&save("update dfc.facture_pub set date_mail=curdate() where base='$base_dbh' and mag='$mag' and fournisseur='$four' and date=curdate()");
						}
						&save("update dfc.facture_pub set groupement='$group' where base='$base_dbh' and mag='$mag' and fournisseur='$four' and date=curdate()");
					}
					else {print "Groupement<br>";}
					print "$total_gen Euros</div>";
					$total_gen=0;
				}
				print "</div>";
			}
		}
	}
	&trace("$action");
}

if ($action eq "reedition_facture_pub"){
# http://aircotedivoire.oasix.fr/cgi-bin/kit.pl?onglet=&sous_onglet=12&sous_sous_onglet=&action=reedition_facture_pub&mag=lemag14&four=2810&facture=140481&date=23/06/2015
  &cree_produit_tmp();
  $facture=$html->param("facture");
  
  if ($facture eq ""){print "merci de mettre un numero de facture<br>";$action="pub";}
  else {
	$four=$html->param("four");
	$sous_tot=0;
	if ($four==1260){$sous_tot=1;} #distrimark
	if ($four==1290){$sous_tot=1;} #iom
	$ref="afac_".$four."_0";
	%tot=();
	# ne marche pas pour le grouepement
    if (($html->param("$ref") eq "on")||($sous_tot==1)){
		$total_fo=0;
		$debut="";
		&re_create_pdf();
		$fin=$facture-1;
		if ($sous_tot==1){
			if ($controle eq "facture"){
			  $group=$debut."_".$fin.".pdf";
			}
			else
			{
			$group="group_$four.pdf";
			}
			prFile("../../dfc.oasix/doc/$group");
		}
	}	
	&re_create_pdf();
	print "<div style=\"border:1px solid black;clear:both;background:$efefef\">";
	$query="select pdf,marque,montant from dfc.facture_pub where base='$base_dbh' and mag='$mag' and fournisseur='$four' order by marque";
	# print $query;
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pdf,$marque,$montant)=$sth2->fetchrow_array){
	  if ($sous_tot==1){
		print "<div style=float:left;width:160;padding:20px;margin:10px;font-size:0.8em;background:lightgray><a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
		if ($controle eq "facture"){print "$pdf<br>";}
		print "$marque<br>$montant Euros";
		print "</div>";
		prDoc("../../dfc.oasix/doc/$pdf");
	  }
	  else {
	   print "<div style=width:160;padding:20px;margin:10px;font-size:0.8em;background:lightgray><a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
		print "$pdf<br>";
	   print "$marque<br>$montant Euros</div>";
	  } 
	  $total_gen+=$montant;
	}
	
	if ($sous_tot==1){
		prEnd();
		print "<div style=clear:both;width:160;padding:20px;font-size:0.8em;background:white><a href=http://dfc.oasix.fr/doc/$group><img src=/images/pdf.jpg /></a><br>";
		if ($controle eq "facture"){
			print "$group<br>";
			if (($sendpdf eq "on")&&(&validemail($fo2_email))){
			  $mail=$fo2_email;
			  $mail=~s/@/\@/;
			  system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $group $mag &");
			  print "Mail envoyé<br>";
			  &save("update dfc.facture_pub set date_mail=curdate() where base='$base_dbh' and mag='$mag' and fournisseur='$four' and date=curdate()");
			}
			&save("update dfc.facture_pub set groupement='$group' where base='$base_dbh' and mag='$mag' and fournisseur='$four' and date=curdate()");
		}
		else {print "Groupement<br>";}
		print "$total_gen Euros</div>";
		$total_gen=0;
	}
	print "</div>";
  }
}


sub create_pdf{  
  $sous_total=0;
  $total=0;
  $en_cours=0;
  $date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
  $index=0;
  $query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque,desi_pub from mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four' order by pr_desi";
  $marqueindex=0;
  if ($sous_tot==1){
    $query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque,desi_pub from mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four'  order by marque,pr_desi ";
  }
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  $first=0;
  $marque_tamp="null";
  # print $query;
  while (($code,$pr_desi,$visuel,$pub,$prix,$pubprix,$marque,$desi_pub)=$sth->fetchrow_array){
    if ($marque_tamp eq "null"){$marque_tamp=$marque;}
    if ($marque ne $marque_tamp){$marqueindex++;$marque_tamp=$marque;}
    $ref="afac_".$four."_".$marqueindex;
    if (($sous_tot==1)&&($html->param("$ref") ne "on")){next;}
 	if ($prix!=0){
      $nb++;
      if ($first==0){
		$marque_facture=$marque;
		$index=0;
		&facture_suite();
	  }
      $first=1;
      if (($sous_tot==1)&&($marque ne $marque_facture)) {
		$nb=0;
		#print "la $marque_facture $marque-";
		&total();
		$index=0;
		$marque_facture=$marque;
		&facture_suite();
      }
      if ($prix <0){
			$prix=$prix*-1;
			$pr_desi="$pr_desi $prix Euros";
			$prix="Offert";
	  }
      $tete_text->translate( 20/mm, $ligne/mm );
      $tete_text->text("PACKSHOT $pr_desi");
      $tete_text->translate( 150/mm, $ligne/mm );
      $tete_text->text("$prix");
      
      if ($prix ne "Offert"){
	$total+=$prix;
	$sous_total+=$prix;
	$tete_text->translate( 170/mm, $ligne/mm );
	$tete_text->text("Euros");
      }
       $ligne-=5;
    
    }
    $prix=$html->param("pub$code");
    if ($prix!=0){
      if ($first==0){
	$marque_facture=$marque;
	$index=0;
	&facture_suite();
	}
      $first=1;
      $nb++;
      if ($nb>21) {
	      $nb=0;
	      $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
	      $tete_text->translate( 40/mm, $ligne/mm );
	      $tete_text->text("Suite .... ");
	      $index++;
	      &facture_suite();
      }
      $tete_text->translate( 20/mm, $ligne/mm );
      if ($desi_pub eq ""){
	  $desi_pub="PLEINE PAGE ".substr($pr_desi,0,25);
	}
      else {$desi_pub=$desi_pub." ".substr($pr_desi,0,25);}

      if ($prix <0){
	$prix=$prix*-1;
	$tete_text->text("$desi_pub $prix Euros");
	$prix="Offert";
      }
      else{
      	$tete_text->text("$desi_pub");
      }
      if ($prix >999){
      	$tete_text->translate( 146/mm, $ligne/mm );
      }
      else {
	if ($prix >100){
	  $tete_text->translate( 148/mm, $ligne/mm );
	}
	else {
	  $tete_text->translate( 150/mm, $ligne/mm );
	}
      }
      $tete_text->text("$prix");
      if ($prix ne "Offert"){
	$total+=$prix;
	$sous_total+=$prix;
	$tete_text->translate( 170/mm, $ligne/mm );
	$tete_text->text("Euros");
      }
      $ligne-=5;
    }
  }
  $marque=$marque_facture;
  &total();
  $pdf->save();
}

sub re_create_pdf{  
  $sous_total=0;
  $total=0;
  $en_cours=0;
  $date_du_jour=$html->param("date");
  $index=0;
  $query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque,desi_pub from mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four' order by pr_desi";
  $marqueindex=0;
  if ($sous_tot==1){
    $query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque,desi_pub from mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four'  order by marque,pr_desi ";
  }
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  $first=0;
  $marque_tamp="null";
  # print $query;
  while (($code,$pr_desi,$visuel,$pub,$prix,$pubprix,$marque,$desi_pub)=$sth->fetchrow_array){
    if ($marque_tamp eq "null"){$marque_tamp=$marque;}
    if ($marque ne $marque_tamp){$marqueindex++;$marque_tamp=$marque;}
    $ref="afac_".$four."_".$marqueindex;
    if (($sous_tot==1)&&($html->param("$ref") ne "on")){next;}
	if ($prix!=0){
      $nb++;
      if ($first==0){
		$marque_facture=$marque;
		$index=0;
		&facture_suite();
	  }
      $first=1;
      if (($sous_tot==1)&&($marque ne $marque_facture)) {
		$nb=0;
		#print "la $marque_facture $marque-";
		&total();
		$index=0;
		$marque_facture=$marque;
		&facture_suite();
      }
      if ($prix <0){
			$prix=$prix*-1;
			$pr_desi="$pr_desi $prix Euros";
			$prix="Offert";
	  }
      $tete_text->translate( 20/mm, $ligne/mm );
      $tete_text->text("PACKSHOT $pr_desi");
      $tete_text->translate( 150/mm, $ligne/mm );
      $tete_text->text("$prix");
      
      if ($prix ne "Offert"){
	$total+=$prix;
	$sous_total+=$prix;
	$tete_text->translate( 170/mm, $ligne/mm );
	$tete_text->text("Euros");
      }
       $ligne-=5;
    
    }
	# if ($pubprix==600){$pubprix+=200;}
    $prix=$pubprix;
    if ($prix!=0){
		if ($first==0){
			$marque_facture=$marque;
			$index=0;
			&facture_suite();
		}
		$first=1;
		$nb++;
		if ($nb>21) {
		  $nb=0;
		  $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
		  $tete_text->translate( 40/mm, $ligne/mm );
		  $tete_text->text("Suite .... ");
		  $index++;
		  &facture_suite();
		}
		$tete_text->translate( 20/mm, $ligne/mm );
		if ($desi_pub eq ""){
			$desi_pub="PLEINE PAGE ".substr($pr_desi,0,25);
		}
		else {$desi_pub=$desi_pub." ".substr($pr_desi,0,25);}
		if ($prix <0){
			$prix=$prix*-1;
			$tete_text->text("$desi_pub $prix Euros");
			$prix="Offert";
		}
		else{
			$tete_text->text("$desi_pub");
		}
		if ($prix >999){
			$tete_text->translate( 146/mm, $ligne/mm );
		}
		else {
			if ($prix >100){
			  $tete_text->translate( 148/mm, $ligne/mm );
			}
			else {
			  $tete_text->translate( 150/mm, $ligne/mm );
			}
		}
		$tete_text->text("$prix");
		if ($prix ne "Offert"){
			$total+=$prix;
			$sous_total+=$prix;
			$tete_text->translate( 170/mm, $ligne/mm );
			$tete_text->text("Euros");
		}
		$ligne-=5;
    }
  }
  $marque=$marque_facture;
  &total();
  $pdf->save();
}


if ($action eq "go"){
print <<EOF;

<script>
function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function drop(ev) {
    ev.preventDefault();
    var x=eval(ev.target.id);
    var cible='h'+ev.target.id;
    var source = ev.dataTransfer.getData("Text");
    var y=eval(source);
    document.getElementById(cible).innerHTML=document.getElementById(source).innerHTML;
    document.getElementById(source).innerHTML="";
    document.maform.elements[y].value=document.maform.elements[x].value;
    document.maform.submit();
 }
</script>
EOF

  print "<span style=\"font-size:1.1em;background-color:#56739A;color:white;border-radius:0px 0px 10px 00px;padding:5px;font-weight:bold;\">$mag</span>";
  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=supmag&mag=$mag onclick=\"return confirm('Etes vous sur de vouloir supprimer ce magazine ?')\"><img border=0 src=http://image.oasix.fr/poub.jpg title='Supprimer' width=18px></a>";
  
  $query="select trac_date,trac_url,trac_login from traceur where trac_url like 'mag%' order by trac_date desc limit 1";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($trac_date,$trac_url,$trac_login)=$sth->fetchrow_array;
  ($jour,$null)=split(/ /,$trac_date);
  $ecart=&get("select datediff(now(),'$jour')");
  print "<span style=position:relative;left:50px;";
  if ($ecart==0){print "background-color:pink";}
  print ">Dernière opération:$trac_url par <strong>$trac_login</strong> le $trac_date</span>";
  $query="select debut,fin,mail from mag_info where mag='$mag'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($date_debut,$date_fin,$mail)=$sth->fetchrow_array;
  $mail+=0;
  if ($date_debut eq ""){$date_debut="0000-00-00";};
  if ($date_fin eq ""){$date_fin="0000-00-00";};
  print "<div class=\"history_filter_date_from\">";
  print "<form name=\"date_from\">Valable Du&nbsp;&nbsp;&nbsp;&nbsp;";
  &form_hidden();
  print "<input type=text readonly=\"readonly\" value='$date_debut' style=\"width:100px;height:37px;border:none;background:none;cursor:pointer;background-image:url(../../images/b_calendar.png);background-repeat:no-repeat;background-position:right 5px;\" id=datepicker name=date_debut onchange=document.date_from.submit()> ";
  print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;au&nbsp;&nbsp;&nbsp;&nbsp;";
  print "<input type=text readonly=\"readonly\" value='$date_fin' style=\"width:100px;height:37px;border:none;background:none;cursor:pointer;background-image:url(../../images/b_calendar.png);background-repeat:no-repeat;background-position:right 5px;\" id=datepicker2 name=date_fin onchange=document.date_from.submit()>";
  print "<input type=hidden name=action value=majdate><input type=hidden name=mag value='$mag'>";
	print " Envoyez les mises à jour par mail <input type=checkbox name=mail";
	print " checked" if ($mail);
	print ">";
	print " <input type=submit value=maj>";
	print "</form>";
	print "</div>";
    print "<form style=margin-top:25px>";
  &form_hidden();
  print "<input type=hidden name=action value=copier>";
  print "<input type=hidden name=mag value=$mag>";
  print "Nom <input type=texte name=new_mag size=10>";
  print "<input type=submit value=copier><br>";
  $adresse=&get("select adresse from mag_info where mag='$mag'");
  if ($adresse eq ""){
      &save("replace into mag_info (mag,adresse) values('$mag','$mag')");
      $adresse=$mag;
      # au debut l'adresse n etait pas liee au nom mais j'ai laissé le fichier au cas ou
  }
  print "Lien web:";
  print "<a href=http://www.trcp.fr/$adresse style=color:blue;>http://www.trcp.fr/$adresse</a> ";
  if ($adresse ne ""){
    my $ua  = LWP::UserAgent->new();
    my $req = HTTP::Request->new( GET => "http://www.trcp.fr/$adresse" );
    my $res=$ua->request($req);
    if (! $res->is_success){print " <span style=background-color:red;color:white>Lien invalide !</span>";}
  }  
  else {
    print " <span style=background-color:red;color:white>Lien invalide !</span>";
  }
  
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modif_adresse&mag=$mag><img border=0 src=../../images/b_edit.png title='Modifier' width=18px></a>";
  print "</form>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif1&mag=$mag>Verifier prix $base_dev1</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif2&mag=$mag>Verifier prix EUR</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif3&mag=$mag>Verifier Stock</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif4&mag=$mag>Verifier les designations</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif5&mag=$mag>Verifier les familles</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif6&mag=$mag>Verifier l'ordre trolley<br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif7&mag=$mag>Verifier le fichier tpe<br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif8&mag=$mag>Verifier le code actif</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif9&mag=$mag>Afficher les codes courts</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif10&mag=$mag>Afficher les familles olfactives</a><br>";
  
#
# 
# 
# 
#   print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif4&mag=$mag>Verifier prix achat du ficher excel</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=excel&mag=$mag>Export fichier</a><br>";
  $check=&get("select count(*) from dfc.facture_pub where no_facture!=0 and mag='$mag'")+0;
  $check+=&get("select count(*) from dfc.facture_pubB where no_facture not like '0' and mag='$mag'")+0;
  if ($check==0){
	  print "<form>";
	  &form_hidden();
	  print "<input type=hidden name=action value=pub>";
	  print "<input type=hidden name=mag value=$mag>";
	  print "<input type=submit value=Facture></form>";
  }
  else {
	print "<mark>Magazine Facturée<br></mark>";
  }
  print "<form>";
  &form_hidden();
  print "<input type=hidden name=action value=trol>";
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=submit value='Création du trolley'></form>";
# 
#   print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=pub&mag=$mag>Facture pub</a><br>";
  
  print "<form name=maform id=maform>";
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,desi_pub,prix_strike,prix_strike_xof from mag where mag='$mag' order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $i=0;
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$desi_pub,$prix_strike,$prix_strike_xof)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&mag=$mag&page=$page><img border=0 src=../../images/pop.png title='Inserer' width=18px></a>";
      print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modif_page&mag=$mag&page=$page><img border=0 src=../../images/b_edit.png title='Modifier' width=18px></a>";
      
      # print "<span style=position:absolute;right:400px>Pv</span>";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    if ($code<0){
      $pr_desi=$desi_pub;
      $style=" style=background-color:greenyellow;";
    }
    if (($visuel==0)&&($code>0)){
      $style=" style=background-color:lightblue;";
    }
    
    print "<li id=\"h$i\" class=cache></li>";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    
    print "<li id=\"$i\" ondrop=\"drop(event)\" ondragover=\"allowDrop(event)\" draggable=\"true\" ondragstart=\"drag(event)\" $style>";
    if ($code<0){
      print "$pr_desi";
      print "<span style=position:absolute;left:450px>";
      $code_pos=$code*-1;
      print &get("select pubprix from mag where mag='$mag' and code='$code_pos'");
      print "</span>";
    }
    else{
       if ($visuel==-1){
 	print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi présentation";
       } 
       else {
	print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
	if ($new){print " <img src=../../images/new.png>";}
	if ($prix_strike>0){print "<img src=../../images/promo.png>";}
	print "<span style=position:absolute;left:450px>$prix</span>";
	print "<span style=position:absolute;left:500px>$prix_xof</span>";
	if ($texte==1){print "<a class=textemag style=position:absolute;left:550px;><span>Texte</span>T</a>";}
	$couleur="";
	$visuelprix+=0;
	if ($visuelprix==0){$couleur="color:red;";}
	if ($visuel==1){print "<a class=textemag style=position:absolute;left:570px;$couleur><span>Visuel</span>V</a>";}
	$couleur="";
	$pubprix+=0;
	if ($pubprix==0){$couleur="color:red;";}
	if ($pub==1){print "<a class=textemag style=position:absolute;left:590px;$couleur><span>Pub</span>P</a>";}
	$image_l=&get("select image_l from dfc.produit_mag where code='$code' ");
	if ($image_l ne ""){print "<a class=textemag style=position:absolute;left:600px;><img border=0 src=../../images/camera.jpg title='Image'></a>";}

	
       }
    }
    print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&mag=$mag&page=$page&code=$code  style=position:absolute;left:620px><img border=0 src=../../images/b_drop.png title='Supprimer'></a>";
    print "</span>";
    print "</li>";
    $value="$page:$cases:$code";
    print "<input type=hidden name=a$code value=$value>\n";
    $i++;
 
   }
   print "<input type=hidden name=action value=modif>";
   print "<input type=hidden name=mag value=$mag>";
   print "<input type=submit>";
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
   &form_hidden();
   print "</form>";
 
}
print "</div>"; # fin de la boite cellule principale

sub facture_suite{
  if (($index==0)&&($en_cours==0)){
    $debut=$facture;
  }  
  if (($index==0)&&($en_cours==1)){
    $pdf->save();
  }
  if ($index==0){
    $sous_total=0;
    $total=0;
    $fichier=&get("select pdf from dfc.facture_pub where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque'","af");
    if ($fichier ne ""){
      $file="/var/www/dfc.oasix/doc/".$fichier;
      &save("update dfc.facture_pub set date=curdate() where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque'","af");
      if (-f $file){unlink ($file);}
      # $facture=&get("select no_facture from dfc.facture_pub where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque'","af");
    }
    else
    {
      $fichier=&generate_random_string(8);
      $fichier.=".pdf";
      &save("replace into dfc.facture_pub values ('$base_dbh','$mag','$four','$marque','0',curdate(),'0','$fichier','','','')","af");
      $file="/var/www/dfc.oasix/doc/".$fichier;
    } 
    if ($controle eq "facture"){
      $file="/var/www/dfc.oasix/doc/pub_".$facture.".pdf";
      &save("replace into  dfc.facture_pub values ('$base_dbh','$mag','$four','$marque','$facture',curdate(),'0','pub_$facture.pdf','','','')","af");
     }
    if (-f $file){unlink ($file);}
    $pdf = PDF::API2->new(-file => $file);
      # $page->cropbox  (7.5/mm, 7.5/mm, 97.5/mm, 140.5/mm);
    %font = (
    Helvetica => {
    Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
    Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
    Italic => $pdf->corefont( 'Helvetica-Oblique', -encoding => 'latin1' ),
    },
    Times => {
	    Bold   => $pdf->corefont( 'Times-Bold',   -encoding => 'latin1' ),
	    Roman  => $pdf->corefont( 'Times',        -encoding => 'latin1' ),
	    Italic => $pdf->corefont( 'Times-Italic', -encoding => 'latin1' ),
    },
    );
    $en_cours=1;
  }  
  $nb=0;
  $page[$index] = $pdf->page();
  $page[$index]->mediabox('A4');
  $tete_text = $page[$index]->text;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->fillcolor('navy');
  
  my $logo1 = $page[$index]->gfx;
  my $logo1_file = $pdf->image_png('./logoDFC.png');
  $logo1->image( $logo1_file, 20/mm, 260/mm, 113, 88 );

  $query="select * from fournis where fo2_cd_fo='$four'";
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
  ($nom,$rue,$ville,$pays,$tva)=split(/\*/,$fo2_add);
  $mail_pub=&get("select email from dfc.contact where fo_id='$fo2_cd_fo' and pub='on'");
  if ($mail_pub ne ""){$fo2_email=$mail_pub;}
  $ligne=250;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$nom");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$rue");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$ville");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$pays");
  # $ligne-=5;
  # $tete_text->translate( 110/mm, $ligne/mm );
  # $tete_text->text("$tva");
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Bold'}, 14/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  if ($controle eq "facture"){
	$tete_text->text("FACTURE N° $facture");
	}
	else {
	$tete_text->text("PROFORMA N° $facture");
	}
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("$tva");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Le:$date_du_jour");
  $ligne-=10;
  $tete_text->translate( 20/mm, $ligne/mm );
  ($null,$mag_red)=split(/_/,$mag);
  $mag_red=$mag;
  $mag_red=~s/\D//g; #astuce regex nom numerique
  
  
	
	$query="select * from mag_info where mag='$mag'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$adresse,$debut_inf,$fin_inf,$null)=$sth->fetchrow_array;
	if (($debut_inf ne '0000-00-00')&&($fin_inf ne '0000-00-00')){$mag_red=$mag_red.=" $debut_inf $fin_inf";}
		
  if ($adresse ne ""){
    $tete_text->text("Magazine:$cl_magazine N°:$mag_red Lien web: http://issuu.com/renaut/docs/$adresse");
  }
  else {
     $tete_text->text("Magazine:$cl_magazine N°:$mag_red");
  }
  
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Compagnie $cl_nom");
  if ($sous_tot==1){
    $tete_text->translate( 100/mm, $ligne/mm );
    $tete_text->text("Marque $marque");
  }  
  $tete_text->fillcolor('navy');
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
  $ligne=60;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Coordonnées bancaires");
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Domiciliation:Bred Paris Opera Bic:BREDFRPPXXX Iban:FR76 1010 7001 7500 2150 4596 342");
  $ligne-=9;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Paiement à réception de facture");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("TVA payée sur les encaissements");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Tout litige ou contestation sont exclusivement du ressort du tribunal de commerce du siège de l'entreprise.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Aucun mode de règlement ou mode de livraison ne peuvent modifier cette clause.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("2 - Conformément à la loi du 12 mai 1980, nos produits restent notre propriété jusqu'à complet règlement.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("3 - Le non-retour de ccette facture dans un délai de huit jours implique acceptation de cette facturation. Toute somme");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("non réglée à la date d'échéance donnera lieu à la perception d'une indemnité de retard au taux minimum de 1,3%.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("DUTY FREE CONCEPT 7 passage du Ponceau  75002 PARIS");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("TVA intracommunautaire FR09 524 057 049 - RCS PARIS 524 057 049 00024");
  $tete_text->fillcolor('black');
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $ligne=195;
  &boite(15,203,200,65);
}
 

sub place{
  $page= &get("select page from mag where mag='$mag' and cases='$cases' and code='$code'","af");
  $position= &get("select count(*) from mag where mag='$mag' and page='$page' and cases<='$cases'");
}  

sub boite() {
	$a=$_[0];
	# x gauche
	$b=$_[1];
	# y haut
	$c=$_[2];
	# x droit
	$d=$_[3];
	# y bas
	# y bas
	my $line = $page[$index]->gfx;
	$line->strokecolor('black');

	# horizontale 
	$line->move( $a/mm, $b/mm );
	$line->line( $c/mm, $b/mm );
	$line->stroke;
	$line->move( $a/mm, $d/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;

	# verticale 	
	$line->move( $a/mm, $b/mm );
	$line->line( $a/mm, $d/mm );
	$line->stroke;
	$line->move( $c/mm, $b/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
}
sub total(){
 $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 100/mm, ($ligne-10)/mm );
  $tete_text->text("TOTAL HT:");
  $tete_text->translate( 148/mm, ($ligne-10)/mm );
  $tete_text->text("$total");
  $tete_text->translate( 170/mm, ($ligne-10)/mm );
  $tete_text->text("Euros");
  
  $tete_text->translate( 100/mm, ($ligne-15)/mm );
  $tete_text->text("TVA:");
  $tete_text->translate( 155/mm, ($ligne-15)/mm );
  $tete_text->text("0");
  $tete_text->translate( 170/mm, ($ligne-15)/mm );
  $tete_text->text("Euros");
  
  $tete_text->translate( 100/mm, ($ligne-20)/mm );
  $tete_text->text("TOTAL TTC:");
  $tete_text->translate( 148/mm, ($ligne-20)/mm );
  $tete_text->text("$total");
  $tete_text->translate( 170/mm, ($ligne-20)/mm );
  $tete_text->text("Euros");
#   $total_fo+=$total;
#   if ($sous_tot==1){$tot{"$marque_facture"}=$total;
#   }
  &save("update dfc.facture_pub set montant='$total' where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque_facture'","af");
  $total=0;
  $facture++;

}
sub trace() {
  my $texte="mag ".$_[0];
  &save("insert ignore into traceur values (now(),\"$texte\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
}
sub houps(){
  print "<div style=\"width:300px;height:80px;background-color:pink;border:1px solid red;margin:auto;padding:15px;border-radius:20px\"><img src=/images/exclamation.gif> $_[0]<br>";
  print "<input type=button value=retour onclick=history.back()></div>";
  print "";
  $action="houps";
}
sub pashoups(){
  print "<div style=\"width:300px;background-color:greenyellow;border:1px solid green;margin:auto;padding:15px;border-radius:20px\">$_[0]</div>";
}  

sub cree_produit_tmp(){
 if ($pass_cree_produit_tmp != 1){
  &save("create temporary table produit_tmp (pr_cd_pr bigint(16),pr_desi varchar(40),pr_four int(10), primary key (pr_cd_pr))"); 
  &save("insert into produit_tmp select pr_cd_pr,pr_desi,pr_four from produit");
  &save("update produit_tmp,produit_plus set pr_four=pr_four_pub where produit_tmp.pr_cd_pr=produit_plus.pr_cd_pr and pr_four_pub!=0");
 }
 $pass_cree_produit_tmp=1;
}

sub maj_code_court(){
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' and code>0 and visuel>=0 order by mag,page,cases";
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      $page_tamp=$page;
      $code_court=$page*10;
    }
    &save("update mag set code_court='$code_court' where mag='$mag' and page='$page' and cases='$cases'");
    $code_court++;
  }
}
;1 

