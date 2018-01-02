#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

$navire="MEGA 2";
print "<table border=1><tr><th>&nbsp;</th>";

for ($i=3;$i<=9;$i++){
	print "<th>";
	print &cal($i,'l');
	print "</th>";
}

print "</tr><tr><th>date</th>";
for ($i=2;$i<=9;$i++){
	$val=0;
	$mois="2008-0".$i."-31";
	$date=&get("select max(nav_date) from navire2 where nav_type=1 and nav_nom='$navire' and nav_date<'$mois'");
 	if ($i<9){print "<td>$date</td>";}
 	$date[$i]=$date;
}

print "</tr><tr><th>stock debut de mois</th>";
for ($i=2;$i<=8;$i++){
	$val=0;
	print "<td>";
	$query="select nav_cd_pr,nav_qte from navire2 where nav_type=1 and nav_nom='$navire' and nav_date='$date[$i]'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
			$val+=$qte*$prac;
	}

	print int($val)."</td>";
	$theo[$i+1]=int($val);
}

print "</tr><tr><th>Livraison</th>";
for ($i=3;$i<=9;$i++){
	($an,$mois,$jour)=split(/-/,$date[$i-1]);
	$debut="108"."$mois"."$jour";
	if ($i==3){$debut="1080123";}
	($an,$mois,$jour)=split(/-/,$date[$i]);
	$fin="1080".$i."$jour";
	$val=0;
	$query="select coc_cd_pr,sum(coc_qte)/100 from infococ2,comcli where ic2_cd_cl=500 and coc_in_pos=5 and coc_no=ic2_no and ic2_date>=$debut and ic2_date<=$fin and ic2_com1='$navire' and coc_cd_pr!=8003080040135 and coc_cd_pr!=8003080026221 and coc_cd_pr!=3473941280003 and coc_cd_pr!=2001841 group by coc_cd_pr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
	#  		print "$pr_cd_pr;$qte;*<br>";
			$val+=$qte*$prac;
	}
	
	print "<td>".int($val)."</td>";
	$theo[$i]+=int($val);

}
print "</tr><tr><th>vente </th>";
for ($i=3;$i<=9;$i++){
	$val=0;
	$date_min=$date[$i-1];
	$date_max=$date[$i];
	if ($i==3){$date_min="2008-01-23";}

	$query="select tva_refour,sum(tva_qte),tva_prac from corsica_tva  where tva_nom='$navire' and tva_date >='$date_min' and tva_date<='$date_max' and tva_ssfamille not like 'magaz%' and tva_ssfamille not like 'journaux%' and tva_desi not like 'carte% jeux%' and tva_refour!=3473941280003 and tva_famille='PARFUMS' group by tva_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tva_refour,$tva_qte,$tva_prac)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$tva_refour");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
		
			$prac=&prac($tva_refour)+0;
			if ($prac==0){$prac=$tva_prac;}
			$val+=$tva_qte*$prac;
	}
	print "<td>".int($val)."</td>";
	$theo[$i]-=int($val);
}
print "</tr><tr><th>Stock fin de mois</th>";
for ($i=3;$i<=9;$i++){
	$val=0;
	$query="select nav_cd_pr,nav_qte from navire2 where nav_type=1 and nav_nom='$navire' and nav_date='$date[$i]'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
			$val+=$qte*$prac;
	}

# 	print "$date<br>";
	print "<td>".int($val)."</td>";
	$reel[$i]=int($val);
}
print "</tr><tr><th>Stock theorique</th>";
for ($i=3;$i<=9;$i++){
	print "<td>$theo[$i]</td>";
}
print "</tr><tr><th>ecart</th>";
for ($i=3;$i<=9;$i++){
	$ecart=$reel[$i]-$theo[$i];

	print "<td>$ecart<br>";
	$cumecart+=$ecart;
	print "$cumecart</td>";
}

print "</tr></table>";
