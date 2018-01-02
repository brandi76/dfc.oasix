#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

$lastm=9;
$nav_prod="nav_cd_pr";
$tva_prod="tva_refour";
$coc_prod="coc_cd_pr";
$option=$html->param("option");
if ($option eq "on" ){$option="qte";}
$navire=$html->param("navire");
$prod=$html->param("prod");
print "<title>rebuild</title>";
if ($navire eq ""){
	print "<body><center><h1>Tracage du stock<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
    	print "<br></h1>produit <input type=texte name=prod size=16><br>qte <input type=checkbox name=option> <br><input type=hidden name=action value=visu><br><input type=submit value=voir></form></body>";
}
else
{
=pod
 $query="select distinct nav_cd_pr from navire2 where nav_nom='$navire' and nav_date>'2008-01-01'";
 $sth2=$dbh->prepare($query);
 $sth2->execute();
 while (($prod)=$sth2->fetchrow_array){
 		$pr_type=&get("select pr_type from produit where pr_cd_pr=$prod");
 		if (($pr_type!=1) and ($pr_type!=5)){next;}
 		$prac=&prac($prod)+0;
 		if ($prac==0){next;}

=cut
if ($prod  ne ""){
	$nav_prod=$prod;
	$tva_prod=$prod;
	$coc_prod=$prod;
	$desi=&get("select pr_desi from produit where pr_cd_pr=$prod");
}

print "<h2>$navire $prod $desi<bR></h2>";
print "<table border=1 cellspacing=0 cellpading=0><tr><th>&nbsp;</th>";

for ($i=1;$i<=$lastm;$i++){
	print "<th>";
	print &cal($i,'l');
	print "</th>";
}

print "<th>total</th></tr><tr><th>date</th>";
for ($i=0;$i<=$lastm;$i++){
	$val=0;
	$mois="2008-0".$i."-31";
	$mois2="2008-0".$i."-20";
	$date=&get("select max(nav_date) from navire2 where nav_type=1 and nav_nom='$navire' and nav_date>'$mois2' and  nav_date<'$mois'");
	if ($date eq "") {$date=$mois;}
	if ($i==$lastm){
		$date=&get("select max(nav_date) from navire2 where nav_type=1 and nav_nom='$navire' and nav_date>='2008-10-05' and nav_date<'2008-10-12'");
 	        if ($date eq ""){$date="2008-09-31";}
        }
	if ($i==0){
		$date=&get("select min(nav_date) from navire2 where nav_type=1 and nav_nom='$navire' and nav_date>='2008-01-00' and nav_date<='2008-01-15'");
 	        if ($date eq ""){$date="2008-01-01";}
        }

 	if ($i>0){print "<br>$date</td>";}
 	if ($i<$lastm){print "<td>$date";}
 	$date[$i]=$date;
}
print "</tr><tr><th>stock debut de mois</th>";
$total=0;
for ($i=0;$i<$lastm;$i++){
	$val=0;
	print "<td>";
	$query="select nav_cd_pr,nav_qte from navire2 where nav_type=1 and nav_nom='$navire' and nav_date='$date[$i]' and nav_cd_pr=$nav_prod";
# 	 print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
 			$pr_sup=&get("select pr_sup from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_sup==5) or ($pr_sup==6)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
			if ($option eq "qte"){$prac=1;}
			$val+=$qte*$prac;
	}

	print int($val)."</td>";
	$theo[$i+1]=int($val);
	$total+=int($val);
}

###### LIVRAISON ##############"

print "<td>$total</td></tr><tr><th>Livraison</th>";
$total=0;
for ($i=1;$i<=$lastm;$i++){
	($an,$mois,$jour)=split(/-/,$date[$i-1]);
	$j=$i-1;
	$debut="1080"."$j"."$jour";
	($an,$mois,$jour)=split(/-/,$date[$i]);
	$fin="108".$mois."$jour";
	$val=0;
	$query="select coc_cd_pr,sum(coc_qte)/100 from infococ2,comcli where ic2_cd_cl=500 and coc_in_pos=5 and coc_no=ic2_no and ic2_date>=$debut and ic2_date<$fin and ic2_com1='$navire' and coc_cd_pr!=8003080040135 and coc_cd_pr!=8003080026221 and coc_cd_pr!=3473941280003 and coc_cd_pr!=2001841 and coc_cd_pr=$coc_prod group by coc_cd_pr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
 			$pr_sup=&get("select pr_sup from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_sup==5) or ($pr_sup==6)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
	#  		print "$pr_cd_pr;$qte;*<br>";
			if ($option eq "qte"){$prac=1;}
			$val+=$qte*$prac;
	}
	
	print "<td>".int($val)."</td>";
	$theo[$i]+=int($val);
	$total+=int($val);
}
############## VENTE ################"

print "<td>$total</td></tr><tr><th>vente </th>";
$total=0;
for ($i=1;$i<=$lastm;$i++){
	$val=0;
	$date_min=$date[$i-1];
	$date_max=$date[$i];
	$query="select tva_refour,sum(tva_qte),tva_prac from corsica_tva  where tva_nom='$navire' and tva_date >='$date_min' and tva_date<'$date_max' and tva_ssfamille not like 'magaz%' and tva_ssfamille not like 'journaux%' and tva_desi not like 'carte% jeux%' and tva_refour!=3473941280003 and tva_famille='PARFUMS' and tva_refour=$tva_prod group by tva_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tva_refour,$tva_qte,$tva_prac)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$tva_refour");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
 			$pr_sup=&get("select pr_sup from produit where pr_cd_pr=$tva_refour");
 			if (($pr_sup==5) or ($pr_sup==6)){next;}
			$prac=&prac($tva_refour)+0;
			if ($prac==0){$prac=$tva_prac;}
			if ($option eq "qte"){$prac=1;}
			$val+=$tva_qte*$prac;
	}
	print "<td>".int($val)."</td>";
	$theo[$i]-=int($val);
	$total+=int($val);
}
print "<td>$total</td></tr><tr><th>Stock fin de mois</th>";
$total=0;
for ($i=1;$i<=$lastm;$i++){
	$val=0;
	$query="select nav_cd_pr,nav_qte from navire2 where nav_type=1 and nav_nom='$navire' and nav_date='$date[$i]' and nav_cd_pr=$nav_prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
 			$pr_sup=&get("select pr_sup from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_sup==5) or ($pr_sup==6)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
			if ($option eq "qte"){$prac=1;}
			$val+=$qte*$prac;
	}

# 	print "$date<br>";
	print "<td>".int($val)."</td>";
	$reel[$i]=int($val);
	$total+=int($val);
}
print "<td>$total</td></tr><tr><th>Stock theorique</th>";
$total=0;
for ($i=1;$i<=$lastm;$i++){
	print "<td>$theo[$i]</td>";
	$total+=$theo[$i];

}
print "<td>$total</td></tr><tr><th>ecart</th>";
$total=0;
$cumecart=0;
for ($i=1;$i<=$lastm;$i++){
	$ecart=$reel[$i]-$theo[$i];
	print "<td>$ecart<br>";
	$cumecart+=$ecart;
	print "$cumecart</td>";
	$total+=$ecart;
}

print "<td>$total";
if ($total!=0){push (@liste,"$prod;$desi;$total");}
print "</td></tr></table>";
}
=pod
 }
 foreach (@liste){
 print "$_<br>";
 }
 