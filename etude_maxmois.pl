#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";




 &groupe1(0,10);
 &groupe1(10,10);
 &groupe1(20,10);
 &groupe1(30,30);
 &groupe1(60,30);
 &groupe1(90,30);
 &groupe1(120,500);
 &groupe2(0,30);
 &groupe2(30,30);
 &groupe2(60,500);


sub groupe1()
{
	print "<hr>";
	$deb=$_[0];
	$fin=$_[1];
	$rank=$deb."_".$fin;
	
	print "$rank<br><table><tr><td><b>2006</b></td>";
	for ($i=601;$i<613;$i++){
		$qte=&get("select qte from maxmois where type=1 and rank='$rank' and mois=$i");
		print "<td>$qte</td>";
	}
	print "</tr>";
	print "<tr><td><b>2007</b></td>";
	for ($i=701;$i<713;$i++){
		$qte=&get("select qte from maxmois where type=1 and rank='$rank' and mois=$i");
		print "<td>$qte</td>";
	}
	print "</tr>";
	print "<tr><td><b>2008</b></td>";
	for ($i=801;$i<813;$i++){
		$qte=&get("select qte from maxmois where type=1 and rank='$rank' and mois=$i");
		print "<td>$qte</td>";
	}

	print "</tr></table>";
}

sub groupe2()
{
	print "<hr>";
	$deb=$_[0];
	$fin=$_[1];
	$rank=$deb."_".$fin;
	
	print "$rank<br><table><tr><td><b>2006</b></td>";
	for ($i=601;$i<613;$i++){
		$qte=&get("select qte from maxmois where type=2 and rank='$rank' and mois=$i");
		print "<td>$qte</td>";
	}
	print "</tr>";
	print "<tr><td><b>2007</b></td>";
	for ($i=701;$i<713;$i++){
		$qte=&get("select qte from maxmois where type=2 and rank='$rank' and mois=$i");
		print "<td>$qte</td>";
	}
	print "</tr>";
	print "<tr><td><b>2008</b></td>";
	for ($i=801;$i<813;$i++){
		$qte=&get("select qte from maxmois where type=2 and rank='$rank' and mois=$i");
		print "<td>$qte</td>";
	}

	print "</tr></table>";
}

