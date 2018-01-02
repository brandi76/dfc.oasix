#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$texte=$html->param('texte');
$action=$html->param('action');

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>IMPORTATION </h1><br>";
	print "<form method=post>";
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form></body>";
}
	

if ($action eq "import"){
	(@tab)=split(/\n/,$texte);
	foreach (@tab){
		while ($texte=~s/\t\t/\t/){};
		($pr_cd_pr,$t1,$t2,$t3,$t4,$t5,$t6)=split(/\t/,$_);
		print "$pr_cd_pr $t1 $t2 $t3 $t4 $t5 $t6<br>";
		$num=11265;
		$qte=$t1*100;
#  		&save("insert ignore into comcli values ($num,$pr_cd_pr,$qte,0,0,0,$qte)","aff");
		$num=11260;
		$qte=$t2*100;
#  		&save("insert ignore into comcli values ($num,$pr_cd_pr,$qte,0,0,0,$qte)","aff");
		$num=11267;
		$qte=$t3*100;
#  		&save("insert ignore into comcli values ($num,$pr_cd_pr,$qte,0,0,0,$qte)","aff");
		$num=11268;
		$qte=$t4*100;
#  		&save("insert ignore into comcli values ($num,$pr_cd_pr,$qte,0,0,0,$qte)","aff");
		$num=11269;
		$qte=$t5*100;
#  		&save("insert ignore into comcli values ($num,$pr_cd_pr,$qte,0,0,0,$qte)","aff");
		$num=11277;
		$qte=$t6*100;
 		&save("insert ignore into comcli values ($num,$pr_cd_pr,$qte,0,0,0,$qte)","aff");

	}
}

