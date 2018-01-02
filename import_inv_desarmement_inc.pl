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
	print "<body><center><h1>inventaire desarmement des produits inconnus<br><form method=POST>";
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

foreach (@liste_dat){
	chop($_);
	# ($_)=split(/ /,$_);
	while ($_=~s/  / /g){};
	if ($_ eq ''){next;}
	if ($_ eq " "){next;}
	if ((grep /CARTON/,$_)||(grep /carton/,$_)){
	if ($flag==1){
		print "<br><b>$carton</b><br>";
		for($j=0;$j<$#liste;$j++){
			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$liste[$j]'");
			if ($pr_desi eq ""){$pr_desi="inconnu";}
			print "$liste[$j] $pr_desi qte:$liste[$j+1] <bR>";
			$j++;
		}
		$flag=0;
	}
	$carton=$_;
	@liste=();
	next;
	}
	if ($i==0){	
		push(@liste,$_);
		$pr_cd_pr=$_;
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
		if ($pr_desi eq "" ){
			$flag=1;
		}
		$i=1;
	}       
	else
	{
		push(@liste,$_);
		$i=0;
	}
}
if ($flag==1){
	for($i=0;$i<$#liste;$i++){
		print "$carton $liste[$i] $liste[$i+1] <bR>";
		$i++;
	}
	$flag=0;
}
}
