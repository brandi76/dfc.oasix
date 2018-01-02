#!/usr/bin/perl
# #!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$appro=$html->param("appro");

require("./src/connect.src");
print "<title>Importation oasix</title>";
if ($action eq ""){
	print "<body><center><h1>Importation oasix Tpe virtuel<br><form>";
	print "<br>Numero de reference (appro) <input type=text name=appro>";
	print "<br><input type=hidden name=action value=import><input type=submit value=submit></form>";
}

	

if ($action eq "import"){
    $sth = $dbh->prepare("select ret_cd_pr,ret_qte-ret_retour,ret_prix from retoursql where ret_code='$appro'");
    $sth->execute;
    while (($pr_cd_pr,$qte,$prix) = $sth->fetchrow_array) {
	    $qte-=(&get("select sum(vdu_qte) from vendusql where vdu_appro='$appro' and vdu_cd_pr='$pr_cd_pr'")+0);
	    &save ("replace into vendusql values ('$appro','99','$pr_cd_pr','$qte','$prix')","af");
	    $esp+=$qte*$prix;
    }
    &save ("replace into oasix_appro values ('99',curdate(),'$appro')","af");
    $cb=&get("select sum(tb_montant) from tpebqsql where tb_code='$appro'");
    $cb+=0;
    $esp-=$cb;
    &save ("replace into oasix_caisse values ('$appro','99','1','$esp','$cb','0','0','0','0','0')","af");
    &save("update retoursql set ret_retourpnc=ret_qte where ret_code='$appro'");
    $query="select vdu_cd_pr,sum(vdu_qte) from vendusql where vdu_appro=$appro group by vdu_cd_pr";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($pr_cd_pr,$capr)=$sth2->fetchrow_array){
		&save("update retoursql set ret_retourpnc=ret_qte-$capr where ret_code='$appro' and ret_cd_pr='$pr_cd_pr'");
    }
    print "<br><b>Total intégré pour la tpe 99:$esp<bR>";
} 	
