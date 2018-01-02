$appro=$html->param("appro");
$action=$html->param("action");
$index=$html->param("index");
$qte=$html->param("qte");
$retour=$html->param("retour");
$prix=$html->param("prix");
$retourpnc=$html->param("retourpnc");
$qtepnc=$html->param("qtepnc");
$nolot=$html->param("nolot");
$caisse1=$html->param("caisse1");
$caisse2=$html->param("caisse2");
$caisse3=$html->param("caisse3");
$caisse4=$html->param("caisse4");
$option=$html->param("option");
$qtepapi=$html->param("qtepapi");
$anomalie=$html->param("anomalie");
$papi=$html->param("papi");
$prixpapi=$html->param("prixpapi");
$comment=$html->param("comment");
$comment=~s/'//g;
$tpe1=$html->param("tpe1");
$montant1=$html->param("montant1");
$noremise1=$html->param("noremise1");
$tpe2=$html->param("tpe2");
$montant2=$html->param("montant2");
$noremise2=$html->param("noremise2");
$pastouche=$html->param("pastouche");

$vol=0;
if ($html->param("vol") eq "on"){$vol=1;}
if ($html->param("qu_plomb") eq "on"){$qu_plomb=1;};
if ($html->param("qu_plombt") eq "on"){$qu_plombt=1;};
if ($html->param("qu_plombc") eq "on"){$qu_plombc=1;};
if ($html->param("qu_cadena") eq "on"){$qu_cadena=1;};
if ($html->param("qu_caisse") eq "on"){$qu_caisse=1;};
$jour=`/bin/date '+%d'`;
$mois=`/bin/date '+%m'`;
$an=`/bin/date '+%Y'`;
chop($jour);
chop($mois);
chop($an);
$today=nb_jour($jour,$mois,$an);
	
if ($action eq ""){
  #### PREMIERE PAGE
  # en attente index de geslot � 5
  print "<span class=titre> SAISIE DES RETOURS</span><br>";
  print "Liste des bons en attente<br><table border=1 cellspacing=0 ><tr><th>Lot</th><th>Appro</th><th><vol</th><th>Type</th></tr>";
  $query = "select gsl_apcode,gsl_nolot,gsl_novol,gsl_troltype from geslot where gsl_ind=5";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($gsl_apcode,$gsl_nolot,$gsl_novol,$gsl_troltype)=$sth->fetchrow_array){
	  $gras="";
	  $check = &get("select count(*) from retoursql where ret_code='$gsl_apcode'")+0;
	  $gras="<span>";
	  if ($check==0){$gras="<span style=font-weight:bold;>";}
	  print "<tr><td>$gras $gsl_nolot<span></td><td>$gras $gsl_apcode</span></td><td>$gras $gsl_novol</span></td><td>$gsl_troltype</td></tr>";
  }
  print "</table><br>";
  print "<form name=appro>";
  &form_hidden();
  print "Bon d'appro: <input type=texte name=appro> <input type=submit value=go>
  <input type=hidden name=action value=go>
  <br><br>
  </form> ";
}

if ($action eq "majqualite"){
  &save("update inforetsql set infr_comment='$comment' where infr_code='$appro'");
  &save("replace into qualite values ('$appro','1','$qu_plomb')");
  &save("replace into qualite values ('$appro','2','$qu_cadena')");
  &save("replace into qualite values ('$appro','3','$qu_caisse')");
  &save("replace into qualite values ('$appro','4','$qu_plombt')");
  &save("replace into qualite values ('$appro','5','$qu_plombc')");
  $action="qualite";
}
 
if ($action eq "sairet"){
  $query = "select ret_cd_pr,ret_retour from retoursql where ret_code='$appro'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($ret_cd_pr,$ret_retour)=$sth->fetchrow_array){
	  $qte_retour=$html->param("$ret_cd_pr")+0;
	  if ($qte_retour!=$ret_retour){
		  &save("update retoursql set ret_retour='$qte_retour' where ret_code='$appro' and ret_cd_pr='$ret_cd_pr'");
	  }
  }
  $action="go";
  }		

if ($action eq "go"){
  $nolot = &get("select gsl_nolot from geslot where gsl_apcode='$appro' and (gsl_ind=5 or gsl_ind=3)")+0;
  if ($nolot==0){$action="saisie";}
  else {
    $message="";
    $query = "select v_code,v_vol,v_dest,v_date from vol where v_code='$appro' and v_rot=1";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($v_code,$v_vol,$v_dest,$v_date)=$sth->fetchrow_array;
    if ($v_vol eq ""){$message="Erreur: Information de vol inexistante";}
    $check = &get("select count(*) from retoursql where ret_code='$appro'")+0;
    if ($check) {$message="Houps saisie deja effectu�e veuillez contacter sylvain";}
    if ($message eq ""){
      &save("insert ignore into ventilcasql values ('$appro','','','','','','','','')");
      &save("insert ignore  into inforetsql values ('$appro',curdate(),'','','0','')");
      &save("insert ignore into non_sai values ('$appro')");
      &save("replace into retjour values ($today,$appro)");
      &save("update geslot set gsl_apcode='',gsl_pb1='',gsl_pb2='',gsl_pb3='',gsl_pb4='',gsl_pb5='',gsl_pb6='',gsl_pb7='',gsl_ind=0 where gsl_nolot='$nolot' and gsl_apcode='$appro'");
      &save("insert into retoursql select ap_code,ap_ordre,ap_cd_pr,ap_qte0/100,ap_qte0/100,ap_qte0/100,ap_qte0/100,ap_prix/100,0 from appro where ap_code='$appro'");
      $new=1;
      $action="qualite";
    }
    else {
      print "<div class=erreur>$message</div>";
      print "<form>";
      &form_hidden();
      print "<input type=submit value=retour></form>";
      print "</div>";
    }
   }
}

if ($action eq "qualite"){
  print "<div style=margin-left:20px;>";
  $query = "select v_code,v_vol,v_dest,v_date from vol where v_code='$appro' and v_rot=1";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($v_code,$v_vol,$v_dest,$v_date)=$sth->fetchrow_array;
  print "<h4>$appro $v_vol $v_dest $v_date</h4>";
  $vendutpe = &get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro='$appro'")+0;
  $comment=&get("select infr_comment from inforetsql where infr_code='$appro'");
  $qu_plomb=&get("select qu_flag from qualite where qu_appro='$appro' and qu_index=1");
  $qu_cadena=&get("select qu_flag from qualite where qu_appro='$appro' and qu_index=2");
  $qu_caisse=&get("select qu_flag from qualite where qu_appro='$appro' and qu_index=3");
  $qu_plombt=&get("select qu_flag from qualite where qu_appro='$appro' and qu_index=4");
  $qu_plombc=&get("select qu_flag from qualite where qu_appro='$appro' and qu_index=5");
  print "<br><br>";
  print "<form name=caisse>";
  &form_hidden();
  print "<b>Qualit� </b><br>";
  print "Plomb indiqu� sur le bon d'appro <input type=checkbox name=qu_plomb ";
  if ($qu_plomb==1) { print "checked";}
  print "><br>";
  print "Plomb sur le trolley <input type=checkbox name=qu_plombt";
  if ($qu_plombt==1) { print "checked";}
  print "><br>";
  print "Plomb conforme <input type=checkbox name=qu_plombc ";
  if ($qu_plombc==1) { print "checked";}
  print "><br>";
  print "Cadena en place <input type=checkbox name=qu_cadena ";
  if ($qu_cadena==1) { print "checked";}
  print "><br>";
  print "Proc�dure caisse conforme <input type=checkbox name=qu_caisse ";
  if ($qu_caisse==1) { print "checked";}
  print "><br>";
  print "<br><b>Commentaire</b><br><textarea rows=5 cols=80 name=comment>$comment</textarea><br>"; 
  print " <br><font size=+1>Montant tpe:$vendutpe </font><a href=cgi-bin/import_oasix.pl?appro=$appro>Maj</a><br><br>";
  print "
  <br>
  <input type=hidden name=action value=majqualite>
  <input type=hidden name=appro value=$appro>
  <br>
  <input type=submit value=validation>
  </form>
   <br>";
  if ($new !=1){ 
  print "<form>";
  &form_hidden();
  print "<input type=hidden name=appro value='$appro'>";
  print "<input type=hidden name=action value=go>";
  print "<input type=submit value='saisie des retours'>";
  print "</form>";
  }
}


if ($action eq "saisie"){
  # verification de la saisie
  print "<h4> SAISIE DES RETOUR $appro</h4>";
  $colorline="white";
  $totalpnc=0;
  print "<form>";
  &form_hidden();
  print "<table cellspacing=0 border=1><tr><th>Produit</th><th>D part</th></th><th>Retour<br>preparateur</th><th>Retour<br>TPE</th><th>Vendu<br>preparateur</th><th>Vendu<br>TPE</th></tr>";
  $index=0;
  $nbtype=$nbtpe=$nbdepart=0;
  $v_troltype=&get("select v_troltype from vol where v_code='$appro' and v_rot=1");
  $query = "select retoursql.*,tr_tiroir from retoursql,trolley where ret_code='$appro' and ret_cd_pr=tr_cd_pr and tr_code='$v_troltype' order by tr_tiroir,ret_ordre";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($ret_code,$ret_ordre,$ret_cd_pr,$ret_qte,$ret_qtepnc,$ret_retour,$ret_retourpnc,$ret_prix,$ret_type,$tr_tiroir)=$sth->fetchrow_array){
    $query = "select pr_desi,pr_type from produit where pr_cd_pr='$ret_cd_pr'";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    ($pr_desi,$pr_type)=$sth2->fetchrow_array;
    # tpe
    $tpe_qte = &get("select sum(vdu_qte) from vendusql where vdu_appro='$appro' and vdu_cd_pr='$ret_cd_pr'")+0;
    if ($typetampon == ""){$typetampon=$tr_tiroir;}

    if ($tr_tiroir != $typetampon){
	    print "<tr><td><b>Total tiroir $typetampon</td><td align=right><b>$nbdepart</td><td align=right><b>$nbtype</td><td align=right><b>";
	    if ($nbtpe!=$nbtype){print "<font color=red>";}
	    print "$nbtpe </td><td>&nbsp;</td><td>&nbsp;</td></tr>";
	    $typetampon=$tr_tiroir;
	    $nbtype=$nbtpe=$nbdepart=0;
	    }
    $nbtype+=$ret_retour;
    $nbtpe+=($ret_qte-$tpe_qte);
    $nbdepart+=$ret_qte;
    $retour_tpe=$ret_qtepnc-$tpe_qte;
    $vendu_fly=$ret_qtepnc-$ret_retour+0;
    if ($vendu_fly == 0){$vendu_fly="&nbsp;";}
    
    if (($tpe_qte eq "")||($tpe_qte == 0)){$tpe_qte="&nbsp;";}
    if ($ret_retour>$ret_qtepnc){$colorline="pink";}
    print "<tr bgcolor=$colorline><td style=font-size:1em;>$ret_cd_pr $pr_desi</td>";
    # qte depart
    print "<td align=right>$ret_qtepnc</td>";
    # retour fly
    print "<td align=right><input type=text name=$ret_cd_pr value=$ret_retour size=3 Onchange=\"document.all.mess.style.visibility='visible'\"></td>";
    # retour tpe
    print "</td><td align=right>";
    if ($retour_tpe!=$ret_retour){print "<font color=red>";}
    print $retour_tpe."</td>";
    # vendu fly
    print "<td align=right>";
    print $vendu_fly."</td>";
    # vendu tpe
    print "<td align=right>";
    print "$tpe_qte</td>";
    # total fly
    # total tpe
    print "</tr>";
    $index++;
    if ($colorline eq "white"){$colorline="#efefef";} else {$colorline="white";}
  }
  print "<tr><td><b>Total tiroir $tr_tiroir</td><td align=right><b>$nbdepart</td><td align=right><b>$nbtype </td><td align=right><b>";
  if ($nbtpe!=$nbtype){print "<font color=red>";}
  print "$nbtpe</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
  $total = &get("select sum((ret_qtepnc-ret_retour)*ret_prix) from retoursql where ret_code=$appro")+0;
  print "<tr><td colspan=5><b>TOTAL RETOUR</td><td>$total</td></tr>";
  $total_tpe = &get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro=$appro")+0;
  $total_tpe=int($total_tpe);
  print "<tr><td colspan=5><b>TOTAL TPE </td><td><font color=red>$total_tpe</td>";
  $ecart=$total_tpe-$total;
  print "<tr><td colspan=5><b>ECART </td><td>$ecart</td></tr>";
  print "</table><br>";
  print "<input type=hidden name=action value=sairet>";
  print "<input type=hidden name=appro value=$appro>";
  print "<input type=submit value=modif></form>";
  print "<form>";
  &form_hidden();
  print "<input type=hidden name=appro value='$appro'>";
  print "<input type=hidden name=action value=qualite>";
  print "<input type=submit value=Qualit�>";
  print "</form>";
  &save("update inforetsql set infr_caisseth=$total where infr_code='$appro'");
  print "<div id=mess style=\"visibility: hidden\"><font size=+3 color=red>Saisie en cours merci de valider</font></div>";
  print "<a href=?action=tpe&appro=$appro>TPE</a>";
  print "<br><a href=bon_de_preparation.pl?appro=$appro target=_blank>Bon de preparation</a>";
}


;1 

