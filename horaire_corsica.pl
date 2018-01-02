#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser); 
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
print "<head><title>Horaire navire</title></head>";






print "<style type=\"text/Css\">
<!--
{
	Font-size: 10px;
}
-->
</style>

<page backtop=\"25mm\" backbottom=\"10mm\" font-size: 10px>
</page>
";
$premiere=$html->param("premiere");
$derniere=$html->param("derniere");
$now=&get("select curdate()");
$now2=&get("select DATE_ADD(curdate(),INTERVAL 5 DAY)");
print "<form>
premiere date AAAA-MM-JJ :<input type=text size=10 name=premiere value=$now>
<br>
derniere date AAAA-MM-JJ :<input type=text size=10 name=derniere value=$now2>
<br>
<input type=submit></form>";
$query="select nav_date,nav_jour from horaire where nav_date >= '$premiere' and nav_date <= '$derniere' group by nav_date";
$sth=$dbh->prepare($query);
$sth->execute;
print "<table border=1 cellspacing=0><tr><td>&nbsp;</td>";
while (($date,$jour)=$sth->fetchrow_array){
	print "<td";
	if ($date eq $now){print " bgcolor=lightblue";}
	print ">$jour<br><font size=-2>$date</td>";
}
print "</tr>";

$query="select distinct nav_nom from horaire where nav_date >= '$premiere' and nav_date <= '$derniere'";
$sth=$dbh->prepare($query);
$sth->execute;
while (($nom)=$sth->fetchrow_array){
	push (@flotte,$nom);
}

foreach $navire (@flotte) {
	$dest_1="";
	$ha_1="";
	print "<tr><td><b>$navire</td>";
	$query="select nav_date from horaire where nav_date >= '$premiere' and nav_date <= '$derniere' group by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($date)=$sth->fetchrow_array){
		$query="select nav_trajet,nav_hd,nav_ha from horaire where nav_date='$date' and nav_nom='$navire' order by nav_hd";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		print "<td align=center style=font-size:12 px;>";
 		if ($dest_1 ne ""){ print &desiquai(substr($dest_1,1,1),$ha_1);print "<br>";}
		$pass=0;
		while (($dest,$hd,$ha)=$sth2->fetchrow_array){
			$hd=substr($hd,0,5);
			$hdh=substr($hd,0,2);
			$dep=substr($dest,0,1);
			# if (($hdh>12)&&($pass==0)&&(($dep eq 'T')||($dep eq 'N')||($dep eq 'S')||($dep eq 'L'))){print " bgcolor=green";}
# 			if ($pass==0){
# 				print "><nobr>";
# 				$pass=1;
# 			}

			$ha=substr($ha,0,5);			                                                                                                         	
	        	print &desiquai(substr($dest,0,1),$hd);
			print "<br><font size=-3>";
			print "&#8595;</font><br>";
			print &desiquai(substr($dest,1,1),$ha);
		        $ha_1=$ha;
		        $dest_1=$dest;
			print "<br>";
		}
 		if ($pass==0){print "&nbsp;";}
		print "</td>";
	}	
 	print "</tr>";
}	
print "</table>";

sub desiquai()
{ 
 my $q=$_[0];
 if ($q eq "A"){return("Ajaccio:$_[1]");}
 if ($q eq "S"){return("<b>Vado:$_[1]</b>");}
 if ($q eq "B"){return("Bastia:$_[1]");}
 if ($q eq "T"){return("<b>Toulon:$_[1]</b>");}
 if ($q eq "R"){return("Golfo:$_[1]");}
 if ($q eq "L"){return("<b>Livourne:$_[1]</b>");}
 if ($q eq "N"){return("<b>Nice:$_[1]</b>");}
 if ($q eq "V"){return("Civitavecc:$_[1]");}
 if ($q eq "C"){return("Calvi:$_[1]");}
 if ($q eq "I"){return("Ile rousse:$_[1]");}
 if ($q eq "P"){return("Piombino:$_[1]");}
 return("<font color=red>Inconnu:$_[1]</font>");

}
