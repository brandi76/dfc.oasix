#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";


print "<table><tr><th>produit</th><th>cameshop</th><th>corsica</th></tr>";
$query="select cameshop.produit.pr_cd_pr,cameshop.produit.pr_desi,cameshop.produit.pr_four,corsica.produit.pr_four from cameshop.produit,corsica.produit where cameshop.produit.pr_cd_pr=corsica.produit.pr_cd_pr and cameshop.produit.pr_four!=corsica.produit.pr_four and corsica.produit.pr_four!=2100 and corsica.produit.pr_four!=2072 and corsica.produit.pr_four!=12661 and corsica.produit.pr_four!=2180";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$four1,$four2)=$sth->fetchrow_array){
    $fo2_add=&get("select fo2_add from dfc.fournis where fo2_cd_fo='$four1'");
	($nom1)=split(/\*/,$fo2_add);
	$fo2_add=&get("select fo2_add from dfc.fournis where fo2_cd_fo='$four2'");
	($nom2)=split(/\*/,$fo2_add);
	print "<tr><td>$pr_cd_pr $pr_desi</td><td>$four1 $nom1</td><td>$four2 $nom2</td></tr>";
}
print "</table>";
