$com_no=$html->param("com_no");
$com2_no_liv=$html->param("com2_no_liv");
$client=$html->param("client");
$option=$html->param("option");
$param=$html->param("param");
push(@bases_client,"corsica");
push(@bases_client,"cameshop");
if ((grep /\//,$param)&&(grep /date/,$option)){
  ($j,$m,$a)=split(/\//,$param);
  $param="$a-$m-$j";
}

@etat_desi=("0 état de base","1 proforma verifiée","2 commande expédiée par le fournisseur","3 commande chez transitaire","4 commande expédiée sur base","5 entrée faite");
if ($action eq "sup"){
	$check=&get("select com2_no_liv from $client.commande where com2_no='$com_no'")+0;
	if ($check!=0){
		print "<span style=background:pink>Impossible elle est sur le bl $check</span><br>";
		$action="visu"
	}
	elsif (&get("select etat from $client.commande_info where com_no='$com2_no'")+0>3)
		{
		print "<span style=background:pink>Impossible elle est en cours de traitement</span><br>";
		$action="visu";
		}
	else{
		&save("delete from $client.commande where com2_no=$com_no");
		print "<p style=background:pink>Commande $com_no supprimée</p>";
		&save("update $client.commande_info set etat=-1 where com_no=$com_no");
		$action="";
	}
}

if ($action eq "creer"){
  $four=&get("select com2_cd_fo from $client.commande where com2_no='$com_no' limit 1");
  &save("insert into dfc.livraison_h (livh_base,livh_date,livh_four,livh_user,livh_date_facture) values ('$client',curdate(),'$four','$user',curdate())","af");
  $liv_id=&get("SELECT LAST_INSERT_ID() FROM dfc.livraison_h");
  $query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $client.commande where com2_no='$com_no' and com2_no_liv=0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
      &save("insert into dfc.livraison_b values ('$liv_id','$com2_cd_pr','$com2_qte','$com2_qte','0','$com2_prac')");
      &save("update $client.commande set com2_no_liv='$liv_id' where com2_no='$com2_no' and com2_cd_pr='$com2_cd_pr'");
  }
  &save("insert ignore into dfc.traceur values (now(),\"action=creer_commande_kit_dfc liv_no=$liv_id \",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
  &save("insert ignore into dfc.livraison values ('$liv_id','$com2_no')");
 $action="visu";
}

if ($action eq "upload"){
  $no_liv=&get("select com2_no_liv from $client.commande where com2_no='$com_no' limit 1","af")+0;
  if ($no_liv==0){
    $no_liv=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no' limit 1","af")+0;
  }
  $fic=$html->param("fichier");
  $ext=substr($fic,length($fic)-3,3);
  $file="/var/www/dfc.oasix/doc/fac_$no_liv".".".$ext;
  open(FILE,">$file");
  print "$file enregistré<br>";
  while (read($fic, $data, 2096)){
	  print FILE $texte.$data;
  }
  close(FILE);
  &save("update livraison_h set livh_nom_facture='fac_$no_liv.$ext' where livh_id='$no_liv'");
  $action="visu";
}

if ($action eq "maj"){
  &save("insert ignore into $client.commande_info (com_no) value ('$com_no')");
  if ($option eq "user_cde"){
    &save("update $client.commande_info set user='$param' where com_no='$com_no'","af");
  }
  if ($option eq "date_cde"){
    &save("update $client.commande_info set date='$param' where com_no='$com_no'");
  }
  if ($option eq "date_accuse"){
    &save("update $client.commande_info set accuse='$param' where com_no='$com_no'","af");
  }
  if ($option eq "blabla_cde"){
    &save("update $client.commande_info set blabla=\"$param\" where com_no='$com_no'");
  }
  if ($option eq "poids"){
    &save("update $client.commande_info set poids=\"$param\" where com_no='$com_no'");
  }
  if ($option eq "volume"){
    &save("update $client.commande_info set volume=\"$param\" where com_no='$com_no'");
  }
  if ($option eq "etat"){
    &save("update $client.commande_info set etat=\"$param\" where com_no='$com_no'","af");
  }
  if ($option eq "livh_user"){
    &save("update livraison_h set livh_user=\"$param\" where livh_id='$com2_no_liv'","af");
  }
  if ($option eq "livh_date"){
    &save("update livraison_h set livh_date=\"$param\" where livh_id='$com2_no_liv'","af");
  }
  if ($option eq "livh_lta"){
    &save("update livraison_h set livh_lta=\"$param\" where livh_id='$com2_no_liv'","af");
  }
 if ($option eq "livh_facture"){
    &save("update livraison_h set livh_facture=\"$param\" where livh_id='$com2_no_liv'","af");
    &save("update $client.commande_info set etat=2 where com_no=$com2_no and etat<=2","af");
  }
  if ($option eq "livh_date_facture"){
    &save("update livraison_h set livh_date_facture=\"$param\" where livh_id='$com2_no_liv'","af");
  }
 if ($option eq "livh_date_reglement"){
    &save("update livraison_h set livh_date_reglement=\"$param\" where livh_id='$com2_no_liv'","af");
  }
 
  $action="visu";
  $option="";
}

if ($action eq "send_pdf"){
  $four=&get("select com2_cd_fo from $client.commande where com2_no='$com_no'");
  $fich=$four."_".$com_no.".pdf";
  $mail=$html->param('mail');
  $copie=$html->param('copie');
  $client_rep=$client;
  if ($client eq "corsica"){$client_rep="dfca";}
  $mail=~s/@/\@/g;
  $copie=~s/@/\@/g;
  system("/var/www/cgi-bin/dfc.oasix/sendpdf_relcde.pl '$mail' $fich $com_no $client_rep '$copie' &");
  print "<div class=titre>Mail envoyé</div>";
  &save("update $client.commande_info set relance=curdate() where com_no=$com_no");
  $action="visu";
}
if ($action eq "send_accuse_prof"){
  $mail=$html->param('mail');
  $copie=$html->param('copie');
  $no_prof=$html->param('no_prof');
  if ($no_prof eq ""){
	print "<p style=background:red>No de proforma vide</p>";
	}
	else {
	  $mail=~s/@/\@/g;
	  $copie=~s/@/\@/g;
	  system("/var/www/cgi-bin/dfc.oasix/send_accuse_prof.pl '$mail' $no_prof '$copie' &");
	  print "<div class=titre>Mail envoyé</div>";
		&save("update $client.commande_info set etat=1  where com_no=$com_no and etat=0");
	}
  $action="visu";
}


if ($action eq ""){
  print "<form>";
  &form_hidden();
  foreach $client (@bases_client){
    if ($client ne "dfc"){
      print "$client <input type=checkbox name=$client ><br>";
    }
   }
  print "Tous <input type=checkbox name=tous><br>";
  print "Y compris cdes livrées <input type=checkbox name=etat5><br>";
  
  #   print "Commencer la recherche à <input type=date name=datepicker value=Indefini><br>";
  #   print "Avec une Facture oui non Indéfini<br>";
  #   print "Commande en attente d'entrée oui non Indéfini<br>";
#   print "<input type=hidden name=action value=go>";
  print "<input type=submit>";
  print "</form>";
  foreach (@etat_desi){print "$_<br>";}
  $pass=0;
  &save("create temporary table cde_tmp (base varchar(20),cde int(8),four int(8),four_desi varchar(80),date_cde date,date_echeance date,montant decimal (8,2),etat int(2),facture varchar(30),livh_date_reglement date,accuse date,primary key (base,cde))");
  foreach $client (@bases_client){
      if ($client eq "dfc"){next;}
      if (($html->param("$client") eq "on")||($html->param("tous") eq "on")){
	&save_liste();
	$pass=1;
      }
  }
  if ($pass==0){
   foreach $client (@bases_client){
    if ($client ne "dfc"){
      &save_liste();
    }
   }
  }
  print "<style>";
  print "#com tr:nth-child(even){background:lavender;}";
  print "#com a{color:black;text-decoration:none;}";
  print "</style>";
  $tri=$html->param("tri");
  if ($tri eq ""){$tri="base,etat";}
  print "Trié par $tri<br>";
  print "<table cellspacing=0 border=1 id=com><tr>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=base&$query_string>Base</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=cde&$query_string>No cde</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=four&$query_string>Fournisseur</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=date_cde&$query_string>Date cde</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=date_echeance&$query_string>Echeance</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=montant&$query_string>Montant</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=etat&$query_string>Etat</a></th>";
  print "<th onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background='#5580AB'><a href=?tri=facture&$query_string>Fact</a></th>";
  print "</tr>";
  $query="select * from cde_tmp order by $tri";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $client_ref="aircotedivoire";
  $mois_run=&get("select month(curdate())");
 $an_run=&get("select year(curdate())");
		
  while (($client,$com2_no,$fo_cd_fo,$fo_nom,$com2_date,$date_echeance,$montant,$etat,$livh_facture,$livh_date_reglement,$accuse)=$sth->fetchrow_array){
	  if (($etat==5)&&($html->param("etat5") ne "on")){next;}
# 	  if ($com2_no != $no_ref){
# 		  if ($color eq "#FFFFFF"){$color="#dcdcdc";}else{$color="#FFFFFF";}
# 		  $no_ref=$com2_no;
# 	  }
		if (($tri eq "base,etat")&&($client ne $client_ref)){
			print "<tr><td colspan=8><strong>mois M:</strong>$total_mois <strong>mois M+1:</strong>$total_moisP1 <strong>mois M++:</strong>$total_moisPP</td></tr>";

			$client_ref=$client;
			$total_mois=$total_moisP1=$total_moisPP=0;
		}
 	  print "<tr><td>$client</td><td onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background=''>";
	  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&com_no=$com2_no&client=$client style=color:black;text-decoration:none >$com2_no</a>";
	  print "</td>";
	  print "<td style=font-size:0.7em;>$fo_cd_fo $fo_nom";
	  print "</td>";
	  print "<td";
	  if (($etat==0)&&($accuse eq "0000-00-00")){print " bgcolor=pink";}
	  print ">";
	  $com2_date=&get("select com2_date from $client.commande where com2_no='$com2_no'","af");
	  if ($com2_date eq ""){ $com2_date=&get("select com2_date from $client.commandearch where com2_no='$com2_no'");}
	  # mail daniel du 30/04/2015
	  print $com2_date;
	  if ($accuse ne "0000-00-00"){print " <img src=/images/check.png width=10>";}
	  print "</td>";
	  $color="white";
	  if (&get("select datediff(curdate(),'$date_echeance')")>0){$color="pink";}
	  print "<td bgcolor=$color>";
	  print "$date_echeance";
	  print "</td>";
	  print "<td align=right>";
	  print $montant;
	  print "</td>";
	  $mois=&get("select month('$date_echeance')");
	  $an=&get("select year('$date_echeance')");
	  if ($an >$an_run){$mois=100;}
	  if ($mois==$mois_run){ $total_mois+=$montant;$totalg_mois+=$montant;}
	  if ($mois==$mois_run+1){ $total_moisP1+=$montant;$totalg_moisP1+=$montant;}
	  if ($mois>$mois_run+1){ $total_moisPP+=$montant;$totalg_moisPP+=$montant;}
	  print "<td align=center>";
	  print $etat;
	  if ($etat==0){
	    $relance=&get("select relance from $client.commande_info where com_no='$com2_no'");
	    $color2="black";
	    if ((&get("select datediff(curdate(),'$com2_date')","af")>7)&&(($relance eq "0000-00-00")||(&get("select datediff(curdate(),'$relance')","af")>7))){$color2="red";}
	    
	    print "<bR><span style=font-size:0.5em;color:$color2>$relance</span>";
	  }
 	  print "</td>";
	  print "<td align=center>";
	  if ($livh_facture ne ""){
	    if ($livh_date_reglement ne "0000-00-00"){print "$livh_date_reglement<img src=/images/check.png>";}
	    elsif($etat>=5){
	      print "<img src=/images/check.png>";
	    }
	    else{
	      print "<img src=/images/checkr.png>";
	    }
	      
#  	    &save("update $client.commande_info set etat=1 where com_no=$com2_no","aff");
	  }
	  else{print "&nbsp;"}
	  print "</td>";
	  print "</tr>";
	  $total+=$montant
  }
	if ($tri eq "base,etat"){
		print "<tr><td colspan=8><strong>mois M:</strong>$total_mois <strong>mois M+1:</strong>$total_moisP1 <strong>mois M++:</strong>$total_moisPP</td></tr>";
	}

  print "</table>";
 print "<strong>mois M:</strong>$totalg_mois <strong>mois M+1:</strong>$totalg_moisP1 <strong>mois M++:</strong>$totalg_moisPP<br>";

  print "Total:$total<br>";
}

if ($action eq "visu"){
  $query="select date,user,etat,blabla,poids,volume,relance,accuse from $client.commande_info where com_no=$com_no";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($date_cde,$user_cde,$etat,$blabla_cde,$poids,$volume,$relance,$accuse)=$sth->fetchrow_array;
 
  print "$client<p style=font-size:1.2em;font-weight:bold>Commande no:$com_no ";
  if ($etat <4){
  ($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis,$client.commande where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'","af"));
   $fo_cd_fo=&get("select fo2_cd_fo from $client.fournis,$client.commande where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'","af");
  }
  else
  {
  ($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis,$client.commandearch where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'","af"));
   $fo_cd_fo=&get("select fo2_cd_fo from $client.fournis,$client.commandearch where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'","af");
  }
  print " <a href=?onglet=0&sous_onglet=1&sous_sous_onglet=&fo2_cd_fo=$fo_cd_fo&action=visu>$fo_cd_fo</a> $fo_nom</p>";
  
  print "<div style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black;margin-left:20px\";>";
	$check_ar=&get("select count(*) from $client.commandearch where com2_no='$com_no'")+0;
	if ($check_ar>0){print "<p style=background:pink>Commande archivée</p>";}
 	$check=&get("select count(*) from $client.commande where com2_no='$com_no'")+0;
	if (($check>0)&&($check_ar>0)){print "<p style=background:pink>PB Commande archivée et en cours prevenir l'admin</p>";}
 	if (($check==0)&&($check_ar==0)){print "<p style=background:pink>PB Commande disparue prevenir l'admin</p>";}
  
  print "Commande Créée par:";
  $param=$user_cde;
  $champ="user_cde";
  &input_param();
  
  print " le:";
  $param=$date_cde;
  $champ="date_cde";
  &input_param();
  
  print " accusé de reception le:";
  $param=$accuse;
  $champ="date_accuse";
  &input_param();
  
  print "<br>Info cde:";
  $param=$blabla_cde;
  $champ="blabla_cde";
  &input_param();
  
  print "<br>Poids:";
  $param=$poids;
  $champ="poids";
  &input_param();
  
  print " Volume:";
  $param=$volume;
  $champ="volume";
  &input_param();
  print "<br>";
  $champ="etat";
  print " Etat:";
  $com2_no_liv=&get("select com2_no_liv from $client.commande where com2_no='$com_no'","af");
  if ($com2_no_liv==0){ $com2_no_liv=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'","af");}
  
 
  if ($option eq $champ){
    print "<form style=display:inline>";
    &form_hidden();
    print "<input type=hidden name=action value=maj>";
    print "<input type=hidden name=option value=$option>";
    print "<input type=hidden name=client value=$client>";
    print "<input type=hidden name=com_no value=$com_no>";
    print "<select name=param>";
    for($i=0;$i<=$#etat_desi-1;$i++){
	print "<option value=$i>$etat_desi[$i]</option>";
    }	  
    print "</select> ";
    print "<input type=submit value=maj></form>";
  }
  else {
    print $etat_desi[$etat],'-';
    if ($etat==5){
      $enh_no=&get("select enh_no from $client.enthead where enh_document=$com2_no_liv");
      print " No:$enh_no";
    }  
    &lien("$champ");
	if ($etat<5){print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&client=$client&com_no=$com_no><img src=/images/b_drop.png border=0 title=\"Supprimer\" onclick=\"return confirm('Etes vous sur de vouloir supprimer ?')\"></a>";}
  }
  print "<br>";
  if ($etat==0){
    print "<form>";
    &form_hidden();
    ($fo2_email)=&get("select fo2_email from $client.fournis,$client.commande where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'");
    
    print "Accepter la proforma no <input type=text name=no_prof><br>";
    print "Email:<input type=text name=mail size=50 value='$fo2_email' > <br />";
    print "Envoyer une copie à:<input type=text name=copie size=50 value=supply_dfc\@dutyfreeconcept.com> <br />";
    print "<input type=hidden name=com_no value=$com_no>";
    print "<input type=hidden name=client value=$client>";
    print "<input type=hidden name=action value=send_accuse_prof>";
    print "<br><input type=submit value=envoyer>";
    print "</form><br />";
  }
  
  print "</div>";
  print "<div style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black;margin-left:20px\";>";
  if ($com2_no_liv==0){
    print "Pas de bon de livraison pour cette commande";
    print "<form>";
    &form_hidden();
    print "<input type=hidden name=action value=creer>";
    print "<input type=hidden name=client value=$client>";
    print "<input type=hidden name=com_no value=$com_no>";
    print "<input type=submit value=creer onclick=\"return confirm('Etes vous sur de vouloir creer un bon de livraison pour cette commande')\"></form>";
    print "<br>";
    }
  else{
    $query="select livh_facture,livh_date,livh_date_facture,livh_nom_facture,livh_lta,livh_user,livh_date_reglement from livraison_h where livh_id='$com2_no_liv'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($livh_facture,$livh_date,$livh_date_facture,$livh_nom_facture,$livh_lta,$livh_user,$livh_date_reglement)=$sth->fetchrow_array;
    print "Bon de livraison no:$com2_no_liv ";
    print "<a href=?onglet=1&sous_onglet=0&action=modifier&liv_id=$com2_no_liv><img src=/images/b_edit.png border=0 title=\"Modifier\"></a> ";
    print "<a href=?onglet=1&sous_onglet=0&action=voir&liv_id=$com2_no_liv><img src=/images/b_voir.png border=0 title=\"Voir\"></a> ";
    print "<a href=?onglet=1&sous_onglet=0&action=entree&liv_id=$com2_no_liv><img src=/images/b_in.png border=0 title=\"Faire l'entrée\"></a> ";
    print "<a href=?onglet=1&sous_onglet=0&action=sup&liv_id=$com2_no_liv><img src=/images/b_drop.png border=0 title=\"Supprimer\" onclick=\"return confirm('Etes vous sur de vouloir supprimer ?')\"></a>";
    print " créé par:";
    $param=$livh_user;
    $champ="livh_user";
    &input_param();
    print "le:";
    $param=$livh_date;
    $champ="livh_date";
    &input_param();
    print "<br>Lta:";
    $param=$livh_lta;
    $champ="livh_lta";
    &input_param();
    print "<br>";
    $montant_fac=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$com2_no_liv'");
    $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
    $montant_fac+=$frais;
    $montant_fac=int($montant_fac*100)/100;
    print "No Facture:";
    $param=$livh_facture;
    $champ="livh_facture";
    &input_param();
    print " Date:";
    $param=$livh_date_facture;
    $champ="livh_date_facture";
    &input_param();
    print " Montant:$montant_fac <br>";
    print " Reglement:";
    $param=$livh_date_reglement;
    $champ="livh_date_reglement";
    &input_param();
    print "<br>";
	($livx_date,$info)=&get("select livx_date,livx_blabla from livraison_x where livx_id='$com2_no_liv'","af");
	if ($info ne ""){print "<mark>$livx_date $info</mark><br>";}
	
	
	
    $fichier_facture=&get("select livh_nom_facture from livraison_h where livh_id='$com2_no_liv'","af");
    if ($fichier_facture ne ""){
      print "$fichier_facture <a href=http://dfc.oasix.fr/doc/$fichier_facture><img src=/images/file.png></a><br>";
    }
    if ($livh_facture ne ""){
      print "<form  method=POST enctype=multipart/form-data>";
      &form_hidden();
      print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
      print " Download facture <input type=file name=fichier accept=text/* maxlength=2097152>";
      print " <input type=hidden name=client value=$client>";
      print " <input type=hidden name=com_no value=$com_no>";
      print " <input type=hidden name=action value=upload>";
      print " <input type=submit></form>";
      }
    }
  print "</div>";
  print "<div style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black;margin-left:20px\";>";
  print "Détail de la commande <table border=0 style=font-size:0.8em>";
  $pass=0;
  $query="select com2_cd_pr,pr_desi,com2_qte/100,com2_prac from $client.commande,$client.produit where com2_no='$com_no' and com2_cd_pr=pr_cd_pr";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($com2_cd_pr,$pr_desi,$com2_qte,$com2_prac)=$sth->fetchrow_array){
    $com2_qte=int($com2_qte);
    print "<tr><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_prac</td></tr>";
    $montant_cde+=$com2_qte*$com2_prac;
    $pass=1;
  }
  $query="select com2_cd_pr,pr_desi,com2_qte/100,com2_prac from $client.commandearch,$client.produit where com2_no='$com_no' and com2_cd_pr=pr_cd_pr";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($com2_cd_pr,$pr_desi,$com2_qte,$com2_prac)=$sth->fetchrow_array){
    $com2_qte=int($com2_qte);
    print "<tr><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_prac</td></tr>";
    $montant_cde+=$com2_qte*$com2_prac;
  }
  if (($pass==0)&&($com2_no_liv !=0)){
    print "</table>";
    print "Montant:$montant_cde<br>";
    $montant_cde=0;
	############ Détail de l'entrée ######################
    print "Détail de l'entrée <table border=0 style=font-size:0.8em>";
    $query="select es_cd_pr,pr_desi,es_qte_en,livb_prix from livraison_b,$client.produit,$client.enso,$client.enthead where livb_id='$com2_no_liv' and enh_document=livb_id and es_no_do=enh_no and livb_code=pr_cd_pr and es_cd_pr=pr_cd_pr";
#     print $query;
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($com2_cd_pr,$pr_desi,$com2_qte,$com2_prac)=$sth->fetchrow_array){
		$com2_qte/=100;
      print "<tr><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_prac</td></tr>";
      $montant_cde+=$com2_qte*$com2_prac;
    }
  }
  print "</table>";
  print "Montant:$montant_cde<br>";
  $client_rep=$client;
  if ($client eq "corsica"){$client_rep="dfca";}
  $four=&get("select com2_cd_fo from $client.commande where com2_no='$com_no' limit 1","af");
  if ($four eq ""){
    $four=&get("select com2_cd_fo from $client.commandearch where com2_no='$com_no' limit 1","af");
  }
  if (-f "/var/www/$client_rep.oasix/doc/$com_no.pdf"){
    print "<a href=http://$client.oasix.fr/doc/$com_no.pdf><img src=/images/pdf.jpg></a>";
  }
  if (-f "/var/www/$client_rep.oasix/doc/${four}_$com_no.pdf"){
    print " <a href=http://$client_rep.oasix.fr/doc/${four}_$com_no.pdf><img src=/images/pdf.jpg></a>";
  }
  if ($etat==0){
    print "<br><form>";
    &form_hidden();
    ($fo2_email)=&get("select fo2_email from $client.fournis,$client.commande where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'");
    
    print "Renvoyer la commande &nbsp;&nbsp;&nbsp;&nbsp;derniere relance:$relance<br>";
    print "Email:<input type=text name=mail size=50 value='$fo2_email' > <br />";
    print "Envoyer une copie à:<input type=text name=copie size=50 value=supply_dfc\@dutyfreeconcept.com> <br />";
    print "<input type=hidden name=com_no value=$com_no>";
	print "<input type=hidden name=client value=$client>";
    print "<input type=hidden name=action value=send_pdf>";
    print "<br><input type=submit value=envoyer>";
    print "</form><br />";
  }
  print "</div>";
  print "<form>";
  &form_hidden();
  print "<br> <input type=submit value=retour>";
  print "</form>";
  
}

sub save_liste(){
	$query="select distinct com2_no,com2_cd_fo,com2_date,com2_no_liv from $client.commande order by com2_no";
# 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_date,$com2_no_liv)=$sth->fetchrow_array){
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo'"));
		$query="select livh_facture,livh_lta,livh_date_facture,livh_date_reglement from livraison_h where livh_id='$com2_no_liv'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($livh_facture,$livh_lta,$livh_date_facture,$livh_date_reglement)=$sth2->fetchrow_array;
# 		if (($livh_facture ne "")&&($livh_date_facture ne "0000-00-00")){$com2_date=$livh_date_facture;}
 		if (($livh_date_facture ne "0000-00-00")&&($livh_date_facture ne "")){$com2_date=$livh_date_facture;}
		if ($com2_no_liv ==0){
		  $montant=&get("select sum(com2_qte*com2_prac)/100 from $client.commande where com2_no='$com2_no'")+0;
		  $montant=int($montant*100)/100;
		}
		else
		{
		  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$com2_no_liv'");
		  $montant=int($montant*100)/100;
		  $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$com2_no_liv'")+0;
		  $montant+=$frais;
		}
 		$fo_delai_pai=&get("select fo_delai_pai from fournis where fo2_cd_fo='$com2_cd_fo'","af")+0;
 		$date_echeance=&get("select '$com2_date' + interval $fo_delai_pai day","af");
 		$etat=&get("select etat from $client.commande_info where com_no='$com2_no'")+0;
 		if (($etat>=5)&&($livh_facture ne "")&&($livh_date_facture ne "0000-00-00")&&($etat5 ne "on")){next;}
 		$accuse=&get("select accuse from $client.commande_info where com_no='$com2_no'");
		&save("insert ignore into cde_tmp values('$client','$com2_no','$com2_cd_fo','$fo_nom','$com2_date','$date_echeance','$montant','$etat','$livh_facture','$livh_date_reglement','$accuse')","af");
	}
	
	$query="select distinct com2_no,com2_cd_fo,com2_date,com2_no_liv from $client.commandearch where com2_no_liv!=0";
# 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_date,$com2_no_liv)=$sth->fetchrow_array){
# 		print "$com2_no<br>";
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo'"));
		$query="select livh_facture,livh_lta,livh_date_facture,livh_date_reglement,livh_date from livraison_h where livh_id='$com2_no_liv'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($livh_facture,$livh_lta,$livh_date_facture,$livh_date_reglement,$livh_date)=$sth2->fetchrow_array;
# 		if (($livh_facture ne "")&&($livh_date_facture ne "0000-00-00")){$com2_date=$livh_date_facture;}
 		if (($livh_date_facture ne "0000-00-00")&&($livh_date_facture ne "")){$com2_date=$livh_date_facture;}
 		if ($com2_date eq "0000-00-00"){$com2_date=$livh_date;}
		  
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$com2_no_liv'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$com2_no_liv'")+0;
		$montant+=$frais;
		$fo_delai_pai=&get("select fo_delai_pai from fournis where fo2_cd_fo='$com2_cd_fo'","af")+0;
		$date_echeance=&get("select '$com2_date' + interval $fo_delai_pai day","af");
#  		&save("update $client.commande_info set etat=4 where com_no=$com2_no","af");
#   		&save("insert ignore into $client.commande_info (com_no,etat) values ('$com2_no','4')");

		$etat=&get("select etat from $client.commande_info where com_no='$com2_no'");
		if ($etat eq ""){$etat=-1;}
		
 		# if (($etat>=5)&&($livh_facture ne "")&&($livh_date_reglement ne "0000-00-00")){next;}
		
 		$accuse=&get("select accuse from $client.commande_info where com_no='$com2_no'");
 		&save("insert ignore into cde_tmp values('$client','$com2_no','$com2_cd_fo','$fo_nom','$com2_date','$date_echeance','$montant','$etat','$livh_facture','$livh_date_reglement','$accuse')");
	}
	
	$query="select distinct com2_no,com2_cd_fo,com2_date,com2_no_liv from $client.commandearch where com2_date>'2015-03-01' and com2_no_liv=0";
# 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_date,$com2_no_liv)=$sth->fetchrow_array){
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo'"));
		$montant=&get("select sum(com2_qte*com2_prac)/100 from $client.commandearch where com2_no='$com2_no'")+0;
		$montant=int($montant*100)/100;
 		$fo_delai_pai=&get("select fo_delai_pai from fournis where fo2_cd_fo='$com2_cd_fo'","af")+0;
		$date_echeance=&get("select '$com2_date' + interval $fo_delai_pai day","af");
#  		&save("update $client.commande_info set etat=4 where com_no=$com2_no","af");
# 		&save("insert ignore into $client.commande_info (com_no,etat) values ('$com2_no','4')");

 		$etat=&get("select etat from $client.commande_info where com_no='$com2_no'")+0;
 		$accuse=&get("select accuse from $client.commande_info where com_no='$com2_no'");
 		&save("insert ignore into cde_tmp values('$client','$com2_no','$com2_cd_fo','$fo_nom','$com2_date','$date_echeance','$montant','$etat','$livh_facture','$livh_date_reglement','$accuse')");
	}
}


sub lien{
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&client=$client&com_no=$com_no&option=".$_[0]."><img src=/images/b_edit.png border=0 title=\"Modifier\"></a>";
}
sub input_param{
 if ($option eq $champ){
  print "<form style=display:inline>";
  &form_hidden();
  print "<input type=hidden name=action value=maj>";
  print "<input type=hidden name=option value=$option>";
  print "<input type=hidden name=client value=$client>";
  print "<input type=hidden name=com_no value=$com_no>";
  print "<input type=hidden name=com2_no_liv value=$com2_no_liv>";
  if (grep /date/,$champ){
    print "<input type=texte name=param id=datepicker value=$param>";
  }
  else {print "<input type=texte name=param value=$param>";}
  print "<input type=submit value=maj></form>";
 }
 else {print $param;&lien("$champ");}
}
;1
