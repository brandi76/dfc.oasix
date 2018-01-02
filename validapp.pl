#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
# require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;

$type=$html->param('type');
$depart=$html->param('depart');
$action=$html->param('action');

require "./src/connect.src";

print "<div style=background-color:pink;text-align:center>Attention si le bon d'appro est déjà créé les modification en compte ne seront pas prises en compte</div>";
if ($action eq "modif"){
	$query="select tr_cd_pr,tr_qte from trolley where tr_code=$type ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		$qte=int($qte/100);
		if ($html->param($pr_cd_pr)!=$qte){
			$qte=$html->param($pr_cd_pr)*100;
			&save("replace into ecartrol values ($type,$pr_cd_pr,$qte,'')","af","trace");
		}
		else
		{
			&save("delete from ecartrol where ecr_cdtrol=$type and ecr_cd_pr=$pr_cd_pr","af","trace");
		}		
	}
	$action="";
}		

if ($action eq ""){
	$colorline="white";
	print "<center><h3>Trolley type:$type</h3><form>";
	print "<table cellspacing=0 border=1><tr><th>Produit</th><th>Départ</th></th><th>Qte<br>Standard</th><th>Qte<br>réel</th></tr>";
	$query="select tr_cd_pr,pr_desi,tr_qte from trolley,produit where tr_code=$type and tr_cd_pr=pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$qte)=$sth->fetchrow_array){
		$qte=int($qte/100);
		$qter=$qte;
		$ecart=&get("select ecr_qte from ecartrol where ecr_cdtrol=$type and ecr_cd_pr=$pr_cd_pr");
		if (($ecart ne "")&&($ecart!=$qte*100)){
			$colorline="pink";
			$qter=int($ecart/100);
		}
		print "<tr bgcolor=$colorline><td>".$pr_cd_pr."</td><td>".$pr_desi."</td>";
		$color="black";
		print "<td align=right><font color=$color>".$qte."</td>";
		print "<td align=right><input type=text name=".$pr_cd_pr." value=".$qter." size=3 </td>";
		print "</tr>";
		$index++;
		if ($colorline eq "white"){$colorline="&ffffff";} else {$colorline="white";}
	}
	print "</form></table><br><input type=hidden name=action value=modif><input type=hidden name=type value='$type'><input type=hidden name=depart value='$depart'><input type=submit value=modification></form>";
	print "<br><a href=preparation.pl?action=go&nodepart=$depart>Retour</a>";
}



# -E validtaion des qte

                	