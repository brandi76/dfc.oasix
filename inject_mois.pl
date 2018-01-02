#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
$premier=$html->param("premier");
$dernier=$html->param("dernier");
require("./src/connect.src");

if ($premier eq "") {
	print "<center><h3>injection de données de base à base</h3>";
	print " <form>";
	print " premier appro:<input type=text name=premier><br>";
	print " dernier appro:<input type=text name=dernier><br>";
	print "<input type=submit>";
	print "</form>";
}
else 
{
	&inject("retoursql","ret_code");
	&inject("appro","ap_code");
	&inject("vendusql","vdu_appro");
	&inject("vol","v_code");
	&inject("equipagesql","eq_code");
	&inject("caisse","ca_code");
	&inject("ecartpn","ecpn_code");
	&inject("oasix_caisse","oac_appro");
	&inject("tpebqsql","tb_code");
# 	&inject("tpeinsql","tb_code");
	&inject("tpeamsql","tb_code");

}

sub inject($fichier,$col)
{
	$fichier=$_[0];
	$col=$_[1];
	$query="show columns from $fichier";
   	$sth=$dbh->prepare($query);
  	$sth->execute();
	@liste=();
	while (($champ)=$sth->fetchrow_array){
		push(@liste,$champ);
	}
	&save("delete from $fichier where $col>='$premier' and $col<='$dernier'");
	$query="select * from $fichier where $col>='$premier' and $col<='$dernier'";
	print $query;
   	$sth=$dbh2->prepare($query);
  	$sth->execute();
	while ((@res)=$sth->fetchrow_array){
		$requete="replace into $fichier values (";
		foreach (@res){
			$requete.="\'$_\',";
		}
	chop($requete);
 	$requete.=')';
	&save("$requete","aff");
 	}
}
