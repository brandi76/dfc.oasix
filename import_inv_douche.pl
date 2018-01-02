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
	print "<br> Choix d'un navire (corsica)<br>";
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
# open(FILE1,"douche.txt");
# $navire="MEGA 1";
# $date="2006-06-25";
if ($option eq "on"){
	&save("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=7","aff");
	$type=7;
}
else
{
	$type=10;
	&save("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=10","aff");
	&save("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=1","aff");
}
(@liste_dat)=split(/\n/,$texte);
$i=0;
foreach (@liste_dat){
	if (! grep /[0-9]/,$_){next;}
	if ( grep /CARTON/,$_){next;}
	chop($_);
	($_)=split(/ /,$_);
	if ($i==0){	
		# print "0->$_<br>";
		$pr_cd_pr=$_;
		if (&get("select count(*) from produit where pr_cd_pr='$pr_cd_pr'")==0){
			$pr_cd_pr=~s/\D/_/g;
			if (&get("select count(*) from produit where pr_cd_pr like '$pr_cd_pr'")==1){
				$pr_cd_pr=&get("select pr_cd_pr from produit where pr_cd_pr like '$pr_cd_pr'");
			}
		}
	}       
	$jumeaux=&get("select pr_codebarre from produit where pr_cd_pr='$pr_cd_pr'");
	if (($jumeaux!=$pr_cd_pr)&&($jumeaux>100000000)){
		print "<font color=green>$pr_cd_pr $jumeaux</font>";
		$pr_save=$pr_cd_pr;
		$pr_cd_pr=$jumeaux;
	}
	# meme produit code barre different 
	if ($i==1){
		# print "$_<br>";
		if ($pr_cd_pr eq ""){ 
			print "<font color=red> produit inconnu $pr_save</font><br>";
		}
		else {
			$qte=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date' and nav_type=$type","af")+0;
			 print "*$qte $_ $pr_cd_pr*";
			$qte+=$_;
			if ($qte >10000){
				print "<font color=red>erreur importation $qte</font><br>";
			}
			else {
				if ($option eq "on"){
					&save("replace navire2 values('$navire','$pr_cd_pr','$date',7,'$qte','')","af");
				}
				else
				{
					&save("replace navire2 values('$navire','$pr_cd_pr','$date',10,'$qte','')","af");
					&save("replace navire2 values('$navire','$pr_cd_pr','$date',1,'$qte','')","af");
				}
				$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
				$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
				$pr_sup=&get("select pr_sup from produit where pr_cd_pr='$pr_cd_pr'");
	
				if ($pr_desi eq ""){$pr_desi="<font color=red> Produit inconnu</font>";$pr_sup=-1;}
				$info="";
				if (($pr_type==1 or $pr_type==5)&& $pr_sup!=4 && $pr_sup!=5){
					$livre=&get("select count(*) from comcli,infococ2 where coc_cd_pr=$pr_cd_pr and coc_no=ic2_no and ic2_cd_cl=500 and ic2_date>1070101","af")+0;
					if ($livre==0){
						$info="<font color=red>parfumerie non livrée et non paul</font>";
					}
					if ($pr_sup==0 or $pr_sup==3){$total+=$qte;}
		
				}
				print "$pr_cd_pr $info $pr_desi $date $qte</font><br>";
			}
		}
	}
	$i++;
	if ($i==2){$i=0;} 
}

if ($option ne "on"){
	# mise à zero du stock des produits non inventorié
	$query="select nav_cd_pr from navire2 where nav_nom='$navire' and nav_type=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ($pr_cd_pr=$sth->fetchrow_array)
	{
		$qte=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_cd_pr='$pr_cd_pr' and nav_date='$date'");
		if ($qte eq ""){&save("insert ignore into navire2 values ('$navire','$pr_cd_pr','$date','1','0','')","af");}
}
}

if ($qte <1000){print "<font color=green size=+3>Nb de parf $total fin</font>";	}
}
# -E importaion par copier coller des inventaires douchettes 06/09