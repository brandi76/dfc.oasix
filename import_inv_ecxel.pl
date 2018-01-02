#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$navire=$html->param('navire');
$action=$html->param('action');
$date=$html->param('date');
$texte=$html->param('texte');
$option=$html->param('option');

print "<head><title>import douche</title></head>";

if ($action eq ""){
	print "<body><center><h1>MAJ inventaire navire<br><form method=POST>";
	print "<br> Choix d'un navire (corsica) code produit qte<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
       	$date=&get("select max(nav_date) from navire2 where nav_type=1");
       	print "</select><br>date <input type=text name=date value='$date'>";
    	print "</select><br>\n";
   	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br>code 7 <input type=checkbox name=option> <input type=hidden name=action value=visu><input type=submit value=importation></form></body>";
}

else
{
	$type=10;
	&save("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=10","aff");
	&save("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=1","aff");
	(@liste_dat)=split(/\n/,$texte);
	$i=0;
	foreach (@liste_dat){
		($pr_cd_pr,$qte)=split(/\t/,$_);
		if (($pr_cd_pr eq "")||($qte eq "")){next;}
		if (($pr_cd_pr == 0)||($qte == 0)){next;}
		$pr_save=$pr_cd_pr;
		$pr_cd_pr=&get("select pr_cd_pr from produit where pr_cd_pr like '$pr_cd_pr'");
		if ($pr_cd_pr eq ""){ 
				print "<font color=red> produit inconnu $pr_save</font><br>";
		}
		else {
			$qte_anc=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date' and nav_type=$type","af")+0;
			$qte_anc+=$qte;
			if ($qte >10000){
				print "<font color=red>erreur importation $pr_cd_pr $qte</font>";
				last;
			}
			&save("replace navire2 values('$navire','$pr_cd_pr','$date',10,'$qte','')","af");
			&save("replace navire2 values('$navire','$pr_cd_pr','$date',1,'$qte','')","aff");
		}
	}

	$query="select nav_cd_pr from navire2 where nav_nom='$navire' and nav_type=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ($pr_cd_pr=$sth->fetchrow_array)
	{
		$qte=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_cd_pr='$pr_cd_pr' and nav_date='$date'");
		if ($qte eq ""){&save("insert ignore into navire2 values ('$navire','$pr_cd_pr','$date','1','0','')","af");}
	}
	if ($qte <1000){print "<font color=green size=+3>ok</font>";	}
}
