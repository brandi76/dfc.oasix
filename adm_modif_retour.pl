#!/usr/bin/perl
use CGI;
use DBI();

# envoyez à robert le 7 juillet 2013 demande de modifaction des quantité , prg admin_modif_retour en cours, l'idee c'est de modifier enso,produit en focntion de l'ecart entre retoursql et le reste
# pemret de modifier un bon d'appro apres la sortie douane

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param('action');
require "./src/connect.src";
$appro=$html->param('appro');
$prod=$html->param('prod');
$qte=$html->param('qte');


if ($action eq "maj") {
    if ($prod ne ""){&update_prod();}
    else {
      $query="select distinct ret_cd_pr from retoursql where ret_code='$appro'";
      $sth=$dbh->prepare($query);
      $sth->execute();
      while (($prod)=$sth->fetchrow_array){
	&update_prod();
      }
    }
 	$ca_fly=&get("select sum((ret_qte-ret_retour)*ret_prix) from retoursql where ret_code='$appro'")*100+0;
	&save("update caisse set ca_fly='$ca_fly' where ca_code='$appro' and ca_rot=1");
	

    $action="";
}
	
sub update_prod(){	
    $vendu_retoursql=&get("select ret_qte-ret_retour from retoursql where ret_code ='$appro' and ret_cd_pr='$prod'","af")+0;
    $vendu_douane=&get("select es_qte from enso where es_no_do='$appro' and es_cd_pr='$prod'","af")+0;
    $vendu_retoursql*=100;
    $ecart=$vendu_douane-$vendu_retoursql;
    $datesimple=`/bin/date +%y%m%d`;
    &save("update produit set pr_stre=pr_stre+$ecart where pr_cd_pr='$prod'","aff");
    if ($vendu_retoursql==0){
      &save("delete from enso where es_cd_pr='$prod' and es_no_do='$appro'","aff");
      &save("delete from rotation where ro_code='$appro' and ro_rot='1' and ro_cd_pr='$prod' ","aff");
    }
    else
    {
      $date_orig=&get("select es_dt from enso where es_cd_pr='$prod' and es_no_do='$appro'");
      if ($date_orig ne ""){$datesimple=$date_orig;}
      &save("replace into enso value ('$prod','$appro',curdate(),'$vendu_retoursql','0','1')","aff");
      &save("replace into rotation values('$appro','1','$prod','$vendu_retoursql')","aff");
    }
}	 


if ($action eq "info") {
	if ($prod ne ""){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$prod'");
		print "$appro $prod $pr_desi<br>";
		$vendu_retoursql=&get("select ret_qte-ret_retour from retoursql where ret_code ='$appro' and ret_cd_pr='$prod'","af")+0;
		$vendu_douane=&get("select es_qte from enso where es_no_do='$appro' and es_cd_pr='$prod'","af")+0;
		$vendu_retoursql*=100;
		print "saisie :$vendu_retoursql<br />";
		print "douane :$vendu_douane<br />";
		print "<form><input type=hidden name=action value=maj>";
		print "<input type=hidden name=appro value='$appro'>";
		print "<input type=hidden name=prod value='$prod'>";
		print "<input type=submit value='maj'>";
		print "</form>";
	}
	else{
		$action="";
		$query="select distinct ret_cd_pr from retoursql where ret_code='$appro'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($prod)=$sth->fetchrow_array){
			$vendu_retoursql=&get("select ret_qte-ret_retour from retoursql where ret_code ='$appro' and ret_cd_pr='$prod'","af")+0;
			$vendu_douane=&get("select es_qte from enso where es_no_do='$appro' and es_cd_pr='$prod'","af")+0;
			$vendu_retoursql*=100;
			if ($vendu_douane!=$vendu_retoursql){
				$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$prod'");
				print "$appro $prod $pr_desi ";
				print "<span style=position:absolute;left:600px>Saisie :".$vendu_retoursql/100;
				print " Douane :".$vendu_douane/100;
				print "</span><br />";
			 }
		}
	}
}

if ($action eq "") {
	print "
	<form>
	code appro <input type=text name=appro value='$appro'> code produit (optionnel) <input type=text name=prod>";
	#print "qte retour (rien info)  <input type=text name=qte>";
	print "<br>
	<input type=submit name=action value=info>
	<input type=submit name=action value=maj>
	</form>";
}

