#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";

# @liste1=("MEGA 1","MEGA 2","MEGA 4");
# @liste1=("MARINA","MEGA 3","REGINA","VICTORIA","VERA");
@liste1=("MEGA 1","MEGA 2","MEGA 4","MARINA","MEGA 3","REGINA","VICTORIA","VERA");
# $query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 0,1000";
$query="select vdu_cd_pr,sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois>=701 and vdu_mois<=712 and vdu_famille like 'PARFUMS' group by vdu_cd_pr order by qte desc limit 0,1000";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
	push (@top60,$pr_cd_pr);
}

foreach $navire (@liste1){
$navireref="AUTRES";
&go1();
}

sub go1{
print "$navire<table border=1 cellspacing=0>";

print "</tr>";
@perdu=@perdu2=@perdu3=@totalr=@totalp=@sauve1=@sauve2=@sauve3=();

foreach $pr_cd_pr (@top60){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr","af");
		#print "<tr><td>$pr_cd_pr $pr_desi</td>";
		for ($i=701;$i<710;$i++){
			@reel[$i]=@prev[$i]=0;
		}

		for ($ref=701;$ref<710;$ref++){
			$qterefp2=0;
			for ($mois=701;$mois<$ref+3;$mois++){
				$qte=0;
				$nav=0;
				$qte+=&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire like '$navire' and vdu_famille like 'PARFUMS' and vdu_mois=$mois and vdu_cd_pr=$pr_cd_pr","af");
				$refm=$mois-700;
				$semaine=$refm*4+int($refm/3);
				$coef=&get("select se_coef from semaine2 where se_no=$semaine and se_navire='$navireref'","af");
				if ($mois==$ref){
					$qteref=$qte/$coef;
					@reel[$mois]=$qte;
				}
				if ($mois==$ref+1){
					$qterefp1=$qte/$coef;
				}
				if ($mois==$ref+2){
					@prev[$mois]=int(($qteref+$qterefp1)*$coef/2);
				}
				
			}
		}
		for ($i=701;$i<710;$i++){
			@totalr[$i]+=$reel[$i];
			@totalp[$i]+=$prev[$i];
			$ecart=$reel[$i]-int($prev[$i]);
			if ($ecart>0){
				$perdu[$i]+=$ecart;
				$ecart2=$reel[$i]-(int($prev[$i])*2);
				if ($ecart2<0){$ecart2=0;}
				$perdu2[$i]+=($ecart-$ecart2);
                        	$ecart2=$reel[$i]-(int($prev[$i])*3);
				if ($ecart2<0){$ecart2=0;}
				$perdu3[$i]+=($ecart-$ecart2);
				$sauve1[$i]++;
				$sauve2[$i]++;
				$sauve3[$i]++;
				if ($ecart>1){$sauve2[$i]++;$sauve3[$i]++;}
				if ($ecart>2){$sauve3[$i]++;}
			}
		}
	}
print "<tr><td>mois</td>";
for ($i=701;$i<710;$i++){
	print "<td>$i</td>";
}
print "</tr><td>coef</td>";
for ($i=1;$i<10;$i++){
	$semaine=$i*4+int($i/3);
	$coef=&get("select se_coef from semaine2 where se_no=$semaine and se_navire='$navireref'","af");
	print "<td>$coef</td>";
}

print "</tr><td>prevision</td>";
for ($i=1;$i<10;$i++){
	$semaine=$i*4+int($i/3);
	$coef=int(&get("select se_coef from semaine2 where se_no=$semaine and se_navire='$navireref'","af")*@totalr[708]/&get("select se_coef from semaine2 where se_no=33 and se_navire='$navireref'","af"));
	print "<td>$coef</td>";
}
print "</tr><tr><td>reel</td>";
for ($i=701;$i<710;$i++){
	print "<td>@totalr[$i]</td>";
}
print "</tr><tr><td>prevision corrigée</td>";
for ($i=701;$i<710;$i++){
	print "<td>@totalp[$i]</td>";
}
print "</tr><tr><td>ventes perdues</td>";
for ($i=701;$i<710;$i++){
	print "<td>@perdu[$i]</td>";
}
print "</tr><tr><td>ventes sauvées avec une secu à ventes*2</td>";
for ($i=701;$i<710;$i++){
	print "<td>@perdu2[$i]";
	if (@perdu[$i]!=0){
		$pour=int(@perdu2[$i]*100/@perdu[$i]);
		print " $pour%";
	}
	print "</td>";
}
print "</tr><tr><td>ventes sauvées avec une secu à ventes*3</td>";
for ($i=701;$i<710;$i++){
	print "<td>@perdu3[$i]";
	if (@perdu[$i]!=0){
		$pour=int(@perdu3[$i]*100/@perdu[$i]);
		print " $pour%";
	}
	print "</td>";
}
print "</tr><tr><td>ventes sauvées avec 1 piece en plus</td>";
for ($i=701;$i<710;$i++){
	print "<td>@sauve1[$i]";
	if (@perdu[$i]!=0){
		$pour=int(@sauve1[$i]*100/@perdu[$i]);
		print " $pour%";
	}
	print "</td>";
}
print "</tr><tr><td>ventes sauvées avec 2 pieces en plus</td>";
for ($i=701;$i<710;$i++){
	print "<td>@sauve2[$i]";
	if (@perdu[$i]!=0){
		$pour=int(@sauve2[$i]*100/@perdu[$i]);
		print " $pour%";
	}
	print "</td>";
}
print "</tr><tr><td>ventes sauvées avec 3 pieces en plus</td>";
for ($i=701;$i<710;$i++){
	print "<td>@sauve3[$i]";
	if (@perdu[$i]!=0){
		$pour=int(@sauve3[$i]*100/@perdu[$i]);
		print " $pour%";
	}
	print "</td>";
}

print "</tr></table>";
}

		