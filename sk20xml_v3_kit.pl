$trolley=$html->param("trolley");
$trolley2=$html->param("trolley2");
$cours_dollars=&get("select cours from devise where id=840");
$cours_cve=&get("select cours from devise where id=132");
$cours_xaf=&get("select cours from devise where id=950");
$cours_xof=&get("select cours from devise where id=952");

# if ($cours_xaf!=0){$cours_xaf=659;}

$pays_ref="XOF";
if ($base_dbh eq "tacv") {
	$pays_ref="CVE";
}			
if ($trolley eq ""){
	print "<form>";
	&form_hidden();
	print "Trolley euro <input type=text name=trolley size=5> <br>Trolley cfa (optionnel)  <input type=text name=trolley2 size=5 ><br><input type=submit></form>";
}
else
{
  $ok=1;
  $mag=&get("select lot_mag from lot where lot_nolot='$trolley'");
  &save("create temporary table ordre_temp (famille int(3),desi varchar(15),code int(10),code_court int(5))"); 
  $query = "select tr_cd_pr from trolley where tr_code='$trolley'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    &famille($code);
    &desi_court($code);
    $code_court=&get("select code_court from mag where mag='$mag' and visuel>=0 and code='$code'")+0; 
    $desi_tpe=lc($desi_tpe);
    $desi_tpe=ucfirst($desi_tpe);
    if ($desi_tpe eq ""){
      print "<span background-color:pink>$code n a pas de designation tpe</span><br>";
      $ok=0;
    }  
    $desi_tpe=~s/\&//g;
    &save ("insert into ordre_temp values ('$fa_cat','$desi_tpe','$code','$code_court')");
  }
  if ($ok==0){print "merci de corrigé le probleme";exit;}
  $query="select famille,desi,code,code_court from ordre_temp order by famille,desi";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $ok=1;
  while (($famille,$desi,$code,$code_court)=$sth->fetchrow_array){
    $check=&get("select count(*) from ordre_temp where desi='$desi'");
    if ($check!=1){
      print "<span style=background-color:pink><a href=http://dfc.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$code&action=visu target=_blank>Doublon $code</a> $desi</span><br>";
      $ok=0;
    }
  }
  if ($ok==0){ print "<br>Il y a des doublons merci de corrigé le probleme</br>";}
  else {
  
    print "Fichier Tpe mis à jour, pret pour l'importation<br>";
    open (FILE,">/var/www/togo.oasix/sk20.xml");
	open (FILE2,">/var/www/togo.oasix/sk20_v2.xml");
    
    print FILE "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
	print FILE2 "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
	
    print FILE "<Sk20list>\n";
	print FILE2 "<Sk20list>\n";
	print FILE2 "<Version>\n";
	print FILE2 "$base_dbh $trolley\n";
	print FILE2 "</Version>\n";
	
    $query="select famille,desi,code,code_court from ordre_temp order by famille,desi";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($famille,$desi,$code,$code_court)=$sth->fetchrow_array){
		print FILE "<Prod>\n";
		print FILE2 "<Prod>\n";
		$pr_prix=&get("select tr_prix/100 from trolley where tr_code='$trolley' and tr_cd_pr='$code'")+0; 
		$pr_prix=int($pr_prix);
		$pr_prix0=$pr_prix;
		$pr_prix1=&get("select tr_prix/100 from trolley where tr_code='$trolley2' and tr_cd_pr='$code'")+0;
		$pr_prix1=int($pr_prix1);
		if ($pr_prix1==0){
			if ($base_dbh eq "tacv") {
				$pr_prix1=int($pr_prix*$cours_cve/100)*100;
				if (($pr_prix*$cours_cve%100)>=50){$pr_prix1+=50;}
			}
			else {
				$pr_prix1=int($pr_prix*$cours_xof/1000)*1000;
			}
		}	
		print  FILE "<Pr_cd_pr>$code</Pr_cd_pr>\n";
		print  FILE2 "<Pr_cd_pr>$code</Pr_cd_pr>\n";
		print FILE "<Pr_desi>$desi</Pr_desi>\n";
		print FILE2 "<Pr_desi>$desi</Pr_desi>\n";
		print FILE "<Pr_prix0>$pr_prix0</Pr_prix0>\n";
		print FILE2 "<Pr_prix0>$pr_prix0</Pr_prix0>\n";
		print  FILE "<Pr_prix1>$pr_prix1</Pr_prix1>\n";
		print  FILE2 "<Pr_prix1>$pr_prix1</Pr_prix1>\n";
		print  FILE "<Cat>$famille</Cat>\n";
		print  FILE2 "<Cat>$famille</Cat>\n";
		print  FILE "<Pr_barre>$code_court</Pr_barre>\n";
		print  FILE2 "<Pr_barre>$code_court</Pr_barre>\n";
		print FILE "</Prod>\n";
		print FILE2 "</Prod>\n";
	}
	
	print FILE2 "<Dev>\n";
    print FILE2 "<Dev_id>0</Dev_id>\n";
    print FILE2 "<Dev_desi>Euro</Dev_desi>\n";
    print FILE2 "<Dev_tri>EUR</Dev_tri>\n";
    print FILE2 "<Dev_cours>1</Dev_cours>\n";
    print FILE2 "<Dev_pays>0</Dev_pays>\n";
    print FILE2 "</Dev>\n";
    print FILE2 "<Dev>\n";
    print FILE2 "<Dev_id>1</Dev_id>\n";
    print FILE2 "<Dev_desi>XOF</Dev_desi>\n";
    print FILE2 "<Dev_tri>XOF</Dev_tri>\n";
    print FILE2 "<Dev_cours>$cours_xof</Dev_cours>\n";
	if ($pays_ref eq "XOF"){
		print FILE2 "<Dev_pays>1</Dev_pays>\n";
	}
	else {
		print FILE2 "<Dev_pays>0</Dev_pays>\n";
	}
    print FILE2 "</Dev>\n";
    print FILE2 "<Dev>\n";
    print FILE2 "<Dev_id>2</Dev_id>\n";
    print FILE2 "<Dev_desi>XAF</Dev_desi>\n";
    print FILE2 "<Dev_tri>XAF</Dev_tri>\n";
    print FILE2 "<Dev_cours>$cours_xaf</Dev_cours>\n";
    print FILE2 "<Dev_pays>0</Dev_pays>\n";
    print FILE2 "</Dev>\n";
    print FILE2 "<Dev>\n";
    print FILE2 "<Dev_id>3</Dev_id>\n";
    print FILE2 "<Dev_desi>Dollars</Dev_desi>\n";
    print FILE2 "<Dev_tri>USD</Dev_tri>\n";
    print FILE2 "<Dev_cours>$cours_dollars</Dev_cours>\n";
    print FILE2 "<Dev_pays>0</Dev_pays>\n";
    print FILE2 "</Dev>\n";
    print FILE2 "<Dev>\n";
    print FILE2 "<Dev_id>4</Dev_id>\n";
    print FILE2 "<Dev_desi>CVE</Dev_desi>\n";
    print FILE2 "<Dev_tri>CVE</Dev_tri>\n";
    print FILE2 "<Dev_cours>$cours_cve</Dev_cours>\n";
	if ($pays_ref eq "CVE"){
		print FILE2 "<Dev_pays>1</Dev_pays>\n";
	}
	else {
		print FILE2 "<Dev_pays>0</Dev_pays>\n";
	}
    print FILE2 "</Dev>\n";
 	
    print  FILE "</Sk20list>\n";
	print  FILE2 "</Sk20list>\n";
    close(FILE);
	close(FILE2);
	print "<a href=http://togo.oasix.fr/sk20.xml> fichier 1</a><br>";
	print "<a href=http://togo.oasix.fr/sk20_v2.xml> fichier 2</a><br>";
	}	
}  
;1