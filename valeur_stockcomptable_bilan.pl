#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";

	print $html->header;
	print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }
	-->
	</style></head><body>";

require "./src/connect.src";

$an=2006;
$date="$an-12-00";

# listing produit maritime actif
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_prac>0 and pr_prac<30000) and pr_cd_pr in (select nav_cd_pr from navire2,produit where nav_nom='MEGA 2' and nav_type=0 and (pr_type=1 or pr_type=5)) order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock maritime fiable <br>";
print "<table border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
$total_gen=0;
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_ventil)=$sth->fetchrow_array)
{
		%stock=&stock($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		if ($stck==0){next;}
		
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}

		
		
		if ($pr_prac<=0){next;}
		if ($pr_prac>30000){next;}
		# $pr_prac=&prac('$pr_cd_pr');
		$total=$stck*$pr_prac;
		$total_gen+=int($total);
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
		push(@trace,$pr_cd_pr);
}
print "<tr><td>total:$total_gen</td></tr>";


print "</table>";

# produit aerien actif

$query="select ap_cd_pr,pr_desi,pr_prac/100,pr_type,count(*)  from produit,appro,inforetsql where infr_date>'$date' and ap_code=infr_code and pr_cd_pr=ap_cd_pr and pr_type>0 and pr_type<6  group by ap_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock aerien fiable <br>";
print "<table border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
$total_gen=0;
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_ventil,$nb)=$sth->fetchrow_array)
{
		if ($nb <5 ) {next;} # one shoot
		%stock=&stock($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		if ($stck==0){next;}
				
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}


		if ($pr_prac<=0){next;}
		if ($pr_prac>300){next;}
		$total=$stck*$pr_prac;
		$total_gen+=int($total);
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
		push(@trace,$pr_cd_pr);
}
print "<tr><td>total:$total_gen</td></tr>";
print "</table>";

$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock non actif prix achat sensé<br>";
print "<table  border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
$total_gen=0;
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_ventil,$nb)=$sth->fetchrow_array)
{
		if (grep /$pr_cd_pr/,@trace){next;} # deja traité
		%stock=&stock($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		if ($stck==0){next;}
				
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}


		if ($pr_prac<=0){next;}
		if ($pr_prac>300){next;}
		$total=$stck*$pr_prac;
		$total_gen+=int($total);
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
		push(@trace,$pr_cd_pr);
}
print "<tr><td>total:$total_gen</td></tr>";
print "</table>";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock non actif  prix achat sujet à caution<br>";
print "<table  border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
$total_gen=0;
while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
{
		if (grep /$pr_cd_pr/,@trace){next;} # deja traité
		%stock=&stock($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		if ($stck==0){next;}
				
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}


		$total=$stck*$pr_prac;
		$total_gen+=int($total);
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
}
print "<tr><td>total:$total_gen</td></tr>";
print "</table>";


