#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<title>debug appro</title>";
require "./src/connect.src";

$appro=$html->param('appro');
print "<body><center><form> <input type=text name=appro><input type=submit> </form><br>";

if ($appro ne ""){
	print "<h1>$appro</h1>";
	&show("etatap","at_code");
	&show("vol","v_code");
	&show("geslot","gsl_apcode");
	&show("non_sai","ns_code");
	&show("retjour","rj_appro");
	&show("inforetsql","infr_code");
	&show("apjour","aj_code");
	&show("retoursql","ret_code");
	&show("appro","ap_code");
	&show("sortie","so_appro");
	&show("enso","es_no_do");
	&show("rotation","ro_code");
	&show("caissesql","ca_code");
	
}

sub show()
{
	print "<b>$_[0]</b><br>";
	
	$query="show columns from $_[0]";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0><tr bgolor=lightyellow>";
	while ((@table)=$sth->fetchrow_array)
	{
		print "<th>$table[0]</th>";
	}
	print "</tr>";
	$query="select * from $_[0] where $_[1]='$appro'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@table)=$sth->fetchrow_array)
	{
		for ($i=0;$i<=$#table;$i++)
		{
			print "<td>$table[$i] ";
			if (($_[0] eq "appro")&&($i==2)){
				print &get("select pr_desi from produit where pr_cd_pr=$table[$i]");
			}
			if (($_[0] eq "geslot")&&($i==1)){
				if ($table[$i]==0) {print " disponible";}
				if ($table[$i]==3) {print " bon créé";}
				if ($table[$i]==10) {print " pas touché";}
				if ($table[$i]==11) {print " pas touché en preparation";}
				if ($table[$i]==5) {print " avis de retour effectué";}
			}
			if (($_[0] eq "etatap")&&($i==1)){
				if ($table[$i]==3) {print " livre";}
			}
			print "</td>";
		}
		print "</tr>";
	}
	print "</table><br>";
}

