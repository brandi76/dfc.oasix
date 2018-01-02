#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;

$action=$html->param("action");
$produit=$html->param("produit");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>Inv mer</title></head>";
print "<body link=black>";


require "./src/connect.src";
if ($action eq ""){
print "<center><h1>Inventaire Navire à bord <br><br>";
print "<form>";
print "<br>Code produit<br><input type=text name=produit><bR>";
print "<br><input type=hidden name=action value=go><input type=submit value='envoie'></form><br>"; 
                   }


if (($action eq "go")||($action eq "deliste")){
	$semaine=&semaine("");
	$query="select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no=$semaine and se_coef!=0 order by nav_nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nom)=$sth->fetchrow_array){
		push (@navire,"$nom");
	}
	print "<form><table border=1 cellspacing=0 width=100%><tr><td colspan=2>&nbsp;</td><td>Entrepot</td>";
	foreach $nom (@navire) {
		print "<th";
		print "><font size=-1>";
		for ($i=0;$i<length($nom);$i++){
			$digit=substr($nom,$i,1);
	 		print "$digit<br>";
		}
	}
	print "</font></th>";
	print "</tr>";
	$nbnavire=$#navire+1;
	if ($action eq "go"){
		$query="select pr_cd_pr,pr_desi,pr_sup from produit where pr_cd_pr='$produit'";
		}
	else {
		$query="select pr_cd_pr,pr_desi,pr_sup from produit where (pr_type=1 or pr_type=5) and (pr_sup!=0 and pr_sup!=1 and pr_sup!=3 and pr_sup!=5) and pr_cd_pr >100000000";
	}	
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_desi,$pr_sup)=$sth->fetchrow_array){
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
                # print "<td>$pr_sup</td>";
                print "<td><font color=gray>$pr_stre</td>";
                $total=0;
		foreach $nom (@navire) {
			print "<td align=right>";
			%calcul=&table_navire("$nom",$pr_cd_pr);
			print $calcul{"stock_navire"};
			# print "<font color=gray>/";
			# $commer=&get("select nav_qte from navire2 where nav_cd_pr=$pr_cd_pr and nav_type=0 and nav_nom='$nom'");
			# print $commer;
			print "</td>";
		$total+=$calcul{"stock_navire"};
		}
		print "<td align=right><b>$total</td>";
		# if (($total==0)&&($pr_sup!=1)){&save ("update produit set pr_sup=1 where pr_cd_pr='$pr_cd_pr'","aff");}
		# if (($total!=0)&&($pr_sup==1)){&save ("update produit set pr_sup=2 where pr_cd_pr='$pr_cd_pr'","aff");}
		print "</tr>";
	}
	print "</table>";
}	


# -E Stock navire mer detail