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

print "<head><title>import douche temporaire</title></head>";

if ($action eq ""){
	print "<body><center><h1>MAJ inventaire navire<br><form method=POST>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
       	$date=&get("select max(nav_date) from navire2 where nav_type=3");
       	print "</select><br>date <input type=text name=date value='$date'>";
    	print "</select><br>\n";
   	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br><input type=hidden name=action value=visu><input type=submit value=importation></form></body>";
}

else
{
#   &save("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=1","aff");

(@liste_dat)=split(/\n/,$texte);

(@liste_dat)=split(/\n/,$texte);
$i=0;
foreach (@liste_dat){
	# print "$_<br>";
	if (! grep /[0-9]/,$_){next;}
	if ( grep /CARTON/,$_){next;}

	chop($_);
	($pr_cd_pr,$qte)=split(/\t/,$_);
	# print "*$qte*";
	$jumeaux=&get("select pr_codebarre from produit where pr_cd_pr='$pr_cd_pr'");
	if (($jumeaux!=$pr_cd_pr)&&($jumeaux>100000000)){$pr_save=$pr_cd_pr;$pr_cd_pr=$jumeaux;}
	# meme produit code barre different 
		# print "$_<br>";
		if ($pr_cd_pr eq ""){ 
			print "<font color=red> produit inconnu $pr_save</font><br>";
		}
		else {
			$qte=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date' and nav_type=1","af")+$qte;
			# print "*$qte $_*";
			if ($qte >10000){
				print "<font color=red>erreur importation $qte</font>";
				last;
			}
			&save("replace navire2 values('$navire','$pr_cd_pr','$date',1,'$qte','')","af");
			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
			$nb=0+&get("select count(*) from navire2,produit where nav_nom='$navire' and nav_type=0 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_cd_pr='$pr_cd_pr'");
			# if ($nb==0){print "<font color=green>Produit non listé à bord:";}
			print "$pr_cd_pr $pr_desi $date $qte</font><br>";
			if ($nb>0){$total+=$_;}
		}
	}
}

# -E importaion par copier coller des inventaires navire sous excel 11/07