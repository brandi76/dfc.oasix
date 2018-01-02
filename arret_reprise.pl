#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>arret et reprise</title></head><body>";


require "./src/connect.src";

$an=&get("select year(now())");
$an_1=$an-1;
$dateref=$an_1."-12-31";
$debut=&get("select min(weekofyear(nav_date)) from horaire where nav_date>'$dateref'","af");

$an=&get("select year(now())");
$sem=&get("select weekofyear(now())");
# $debut=$sem;
print "<style type=\"text/css\">
#droite{
display: block;
width:1200px;
overflow:hidden;
overflow-x: auto;
overflow-y: hidden;
overflow : -moz-scrollbars-horizontal;
border-style:solid;
border-width:0px;
border-color:#000;
}
#gauche{
display: block;
width:100px;
overflow:hidden;
overflow-x: hidden;
overflow-y: hidden;
overflow : -moz-scrollbars-horizontal;
border-style:solid;
border-width:0px;
border-color:#000;
}


</style>
<table cellspacing=0 cellpadding=0 border=0><tr><td><div id=gauche>";

print "<table border=1 cellspacing=0><tr><th>Navire</th>";
for ($i=$debut;$i<53;$i++){          
	print "<th>";
	if ($i==$sem){print "<font color=red>";}
	print "$i</th>";
}
print "</tr>";
	
	
	
	$query="select nav_nom from navire";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_nom_sql)=$sth->fetchrow_array)
	{
		$nav_nom=$nav_nom_sql;
		$nb=&get("select count(*) from horaire where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)>=$debut and weekofyear(nav_date)<=53","af")+0;
		if ($nb==0){next;}
		print "<tr><td><b>$nav_nom_sql</b></td>";
		for ($i=$debut;$i<53;$i++){
			$arret="";
			$depart="";
			$nb=&get("select count(*) from horaire where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i","af")+0;
			if ($nb==0){	
				if ($tab{"$nav_nom_sql"} eq "on"){
					$arret=&get("select max(nav_date) from horaire  where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i-1");
			                $tab{"$nav_nom_sql"} = "";
				}
			}
			else
			{
				if ($tab{"$nav_nom_sql"} eq ""){
					if ($i>$debut){
						$depart=&get("select min(nav_date) from horaire  where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i");
					}
			                $tab{"$nav_nom_sql"} = "on";
				}
			
			}
			$color="white";
			if (($nb <=0)&&($arret eq "")){$color="#efefef";}
			print "<td bgcolor=$color align=center>";
			if ($depart ne ""){print "<b>$depart</b><br><img src=http://ibs.oasix.fr/images/corsica_on.jpg>";}
			if ($nb>0){
				$query="select distinct nav_trajet from horaire where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				while (($trajet)=$sth2->fetchrow_array){
			        	print "<font size=-2>".&desiquai(substr($trajet,0,1));
					print "-";
					print &desiquai(substr($trajet,1,1));
					print "<br>";
				}
			}
			if ($arret ne ""){print "<img src=http://ibs.oasix.fr/images/corsica_off.jpg><br><b>$arret</b>";}

			if (($nb <=0)&&($arret eq "")){print "&nbsp;";}
			if ($nb <=0){
                		&save("update semaine2 set se_coef=0  where se_no='$i' and se_navire='$nav_nom_sql'");
			}		
			$coef=&get("select se_coef from semaine2 where se_no='$i' and se_navire='$nav_nom_sql'","af")+0;
			if (($nb>0)&&($coef==0)){
				&save("update semaine2 set se_coef=1  where se_no='$i' and se_navire='$nav_nom_sql'");
			}
			print "$coef</td>";
		}
		print "</tr>";
	}

print "</table></div></td><td>
<div id=\"droite\">";
	
	
print "<table border=1 cellspacing=0><tr><th>Navire</th>";
for ($i=$debut;$i<53;$i++){          
	print "<th>";
	if ($i==$sem){print "<font color=red>";}
	print "$i</th>";
}
print "</tr>";
	$query="select nav_nom from navire";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_nom_sql)=$sth->fetchrow_array)
	{
		$nav_nom=$nav_nom_sql;
		$nb=&get("select count(*) from horaire where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)>=$debut and weekofyear(nav_date)<=53","af")+0;
		if ($nb==0){next;}
		print "<tr><td><b>$nav_nom_sql</b></td>";
		for ($i=$debut;$i<53;$i++){
			$arret="";
			$depart="";
			$nb=&get("select count(*) from horaire where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i","af")+0;
			if ($nb==0){	
				if ($tab{"$nav_nom_sql"} eq "on"){
					$arret=&get("select max(nav_date) from horaire  where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i-1");
			                $tab{"$nav_nom_sql"} = "";
				}
			}
			else
			{
				if ($tab{"$nav_nom_sql"} eq ""){
					if ($i>$debut){
						$depart=&get("select min(nav_date) from horaire  where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i");
					}
			                $tab{"$nav_nom_sql"} = "on";
				}
			
			}
			$color="white";
			if (($nb <=0)&&($arret eq "")){$color="#efefef";}
			print "<td bgcolor=$color align=center>";
			if ($depart ne ""){print "<b>$depart</b><br><img src=http://ibs.oasix.fr/images/corsica_on.jpg>";}
			if ($nb>0){
				$query="select distinct nav_trajet from horaire where nav_nom='$nav_nom_sql' and year(nav_date)=$an and weekofyear(nav_date)=$i";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				while (($trajet)=$sth2->fetchrow_array){
			        	print "<font size=-2>".&desiquai(substr($trajet,0,1));
					print "-";
					print &desiquai(substr($trajet,1,1));
					print "<br>";
				}
			}
			if ($arret ne ""){print "<img src=http://ibs.oasix.fr/images/corsica_off.jpg><br><b>$arret</b>";}

			if (($nb <=0)&&($arret eq "")){print "&nbsp;";}
			if ($nb <=0){
                		&save("update semaine2 set se_coef=0  where se_no='$i' and se_navire='$nav_nom_sql'");
			}		
			$coef=&get("select se_coef from semaine2 where se_no='$i' and se_navire='$nav_nom_sql'","af")+0;
			if (($nb>0)&&($coef==0)){
				&save("update semaine2 set se_coef=1  where se_no='$i' and se_navire='$nav_nom_sql'");
			}
			print "$coef</td>";
		}
		print "</tr>";
	}
print "</table></div></tr></table>";
sub desiquai()
{ 
 my $q=$_[0];
 if ($q eq "A"){return("Ajaccio");}
 if ($q eq "S"){return("Vado");}
 if ($q eq "B"){return("Bastia");}
 if ($q eq "T"){return("Toulon");}
 if ($q eq "R"){return("Golfo");}
 if ($q eq "L"){return("Livourne");}
 if ($q eq "N"){return("Nice");}
 if ($q eq "V"){return("Civitavecc");}
 if ($q eq "C"){return("Calvi");}
 if ($q eq "I"){return("Ile rousse");}
 if ($q eq "P"){return("Piombino");}
 return("<font color=red>$_[0] Inconnu</font>");

}
