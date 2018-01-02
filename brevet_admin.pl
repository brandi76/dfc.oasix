#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);     
$html=new CGI;
print $html->header();
print "<title>Brevet admin</title>";
#require "../oasix/outils_perl2.lib";

require "./src/connect.src";

$query="select nom,no,count(*) from pilote  where flag=1 group by nom,no";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nom,$no,$qte)=$sth->fetchrow_array)
{
	$existe=&get("select count(*) from pilote2 where '$nom' and no='$no'")+0;
	if ($existe >0){
		&save("update pilote2 set ko='$qte' where nom='$nom' and no='$no'","aff");
	}
	else
	{
		&save("insert into  pilote2 values ('$nom','$no','0','$qte','0','0')","aff");
	
	}
}
print "fin";
		 



sub get()
{
	if ($_[1] eq "aff"){print "$_[0]<br>";}
	my ($sth)=$dbh->prepare($_[0]);
	$sth->execute() or die (print $query);
	return ($sth->fetchrow_array);
}
	
# FONCTION : save
# DESCRIPTION : sauvegarde mysql
# ENTREE : query, option (aff affiche la requete)
# SORTIE :rien
	
sub save()
{
	if ($_[1] eq "aff"){print "$_[0]<br>";}
	my ($sth)=$dbh->prepare($_[0]);
	$sth->execute() or die (print $query);
}
