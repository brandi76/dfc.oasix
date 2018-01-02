#!/usr/bin/perl

use CGI;
use DBI();
require "../oasix/outils_perl2.pl";


# compare le fichier brut oasix avec les valeurs qui apparaissent dans la recap
$html=new CGI;
print $html->header;
$action=$html->param("action");
require "./src/connect.src";

$appro="25886";
$query="select vdu_tpe,vdu_qte from vendusql where vdu_appro='$appro' and vdu_cd_pr=1300";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tpe,$qte)=$sth->fetchrow_array){
	$nb=&get("select count(*) from vendusql where vdu_cd_pr=1310 and vdu_tpe='$tpe' and vdu_appro='$appro'")+0;
	if ($nb==1){
		&save("update vendusql set vdu_qte=0 where vdu_appro='$appro' and vdu_cd_pr=1300 and vdu_tpe='$tpe'","aff");
		&save("update vendusql set vdu_qte=vdu_qte+$qte where vdu_appro='$appro' and vdu_cd_pr=1310 and vdu_tpe='$tpe'","aff");
	}
	else
	{
		&save("update vendusql set vdu_cd_pr=1310 where vdu_appro='$appro' and vdu_cd_pr=1300 and vdu_tpe='$tpe'","aff");
	}
	$qtetot+=$qte;
}
&save("update retoursql set ret_retourpnc=ret_retourpnc-$qtetot where ret_code='$appro' and ret_cd_pr=1310","aff");
