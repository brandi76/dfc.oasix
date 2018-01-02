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

print "<head><title>import douche</title></head>";

if ($action eq ""){
	print "<body><center><h1>inventaire desarmement<br><form method=POST>";
  	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=importation></form></body>";
}

else
{

@liste_dat = <FILE1>;

close(FILE1);
$i=0;
(@liste_dat)=split(/\n/,$texte);

print "<table border=1>";
foreach (@liste_dat){
	chop($_);
	# ($_)=split(/ /,$_);
	while ($_=~s/  / /g){};
	if ($_ eq ''){next;}
	if ($_ eq " "){next;}
	if ((grep /CARTON/,$_)||(grep /carton/,$_)){
	$carton=$_;
	next;
	}
	if ($i==0){	
		print "<tr><td><b>$carton</b><td>$_</td>";
		$pr_cd_pr=$_;
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
		if ($pr_desi eq "" ){
			$query="select nep_desi,nep_prac,nep_prx_vte from neptune where nep_codebarre='$pr_cd_pr'";			 
		 	# print "<td>$query</td>";
		 	$sth=$dbh->prepare($query);
		 	$sth->execute;
			($pr_desi,$nep_prac,$nep_prx_vte)=$sth->fetchrow_array;
			if ($pr_desi ne "") {
				while ($pr_desi=~s/\'//){};
				&save("insert into produit value ('$pr_cd_pr','$pr_desi','0','0','0','0','0','0','4','$nep_prx_vte','0','5','0','$nep_prac','0','0','0','0','0','0','0','0','12','0','0','$pr_codebarre')","aff");
			}
			else 
			{
				$pr_desi="Inconnu";
			}
		}
		print "<td>$pr_desi</td>";
		$i=1;
	}       
	else
	{
		print "<td>$_</td></tr>";
		$i=0;
	}
 
}
print "</table>";;	
}
# -E mise en tableau html d'un inventaire desarmement en vue d'un copier coller vers excel 06/09