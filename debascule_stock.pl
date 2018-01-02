#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

print $html->header;

$action=$html->param("action");
$four=$html->param("four");
$option=$html->param("option");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "merci d'utiliser le nouveau menu fichier->produit->bascule de stock";
 exit;

print "<body><h2>Debascule de stock</h2><br>";
print `date`;
print "<br>";


require "./src/connect.src";

# $query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup,pr_codebarre from produit where (pr_cd_pr <100000000 and (pr_type=1 or pr_type=5)) and pr_sup!=0 and pr_sup!=3 order by pr_four";
$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup,pr_codebarre from produit where pr_cd_pr <1000000 and (pr_type=1 or pr_type=5) and pr_cd_pr not in (select tr_cd_pr from trolley where tr_code=100)";
$sth=$dbh->prepare($query);
$sth->execute();
if ($action eq ""){&table();}
if ($action eq "creer"){
	print "<table border=1 cellspacing=0><caption><h3>Stock avion</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à sortir</th><th>reste</th><th>Check</th></tr>";
	$dateref=$today-15;
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup,$pr_codebarre)=$sth->fetchrow_array)
	{
		$qte=$html->param("$pr_cd_pr")+0;
		if ($qte==0){ next;}
		$prodavion=$pr_cd_pr;	
		
		######################
		&maj_prodavion();		
		######################
	
		%stock=&stock($prodavion,'','');
		$stockavion=$stock{"stock"}+0; # stock entrepot 
		print "<tr><td>$prodavion</td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($prodavion,$qte);
		print "</td><td align=right>";
		&carton($prodavion,$stockavion);
		print "</td><td><input type=checkbox></tr>";
		push (@table,$pr_codebarre);
		$tableqte{"$pr_codebarre"}=$qte;
	}
	print "</table><br><br>";
	print "<table border=1 cellspacing=0><caption><h3>Stock navire</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à entrer</th><th>nouveau stock</th><th>Check</th></tr>";
	foreach (@table) {
		$query="select pr_cd_pr,pr_desi from produit where pr_cd_pr='$_'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($prodnavire,$pr_desi)=$sth2->fetchrow_array;
	
		$qte=$tableqte{"$_"};
		print "-$qte-";
	
		######################
		&maj_prodnavire();		
		######################

		%stock=&stock($prodnavire,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 
		$digit_f=$prodnavire%1000000+1000000;
		$digit_f=substr($digit_f,3,4);
		$digit_p=int($prodnavire/10000);
		print "<tr><td>$digit_p <b>$digit_f</b></td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($prodnavire,$qte);
		print "</td><td align=right>";
		&carton($prodnavire,$pr_stre);
		print "</td><td><input type=checkbox></tr>";

	}
	print "</table>";
	
	
}

sub table{
	$dateref=$today-15;
	print "<form><table border=1 cellspacing=0>";
	&titre();

	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup,$pr_codebarre)=$sth->fetchrow_array)
	{
		$query="select pr_cd_pr from produit where pr_cd_pr='$pr_codebarre'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$prodnavire=$sth2->fetchrow_array+0;
		if ($prodnavire ==0 ){next;}
		%stock=&stock($pr_cd_pr,'','');
		$pr_stre=$stock{"stock"}+0;  # stock reel entrepot  
		if ($pr_stre<=0){next;}
		%stock=&stock($prodnavire,'','quick');
		$stocknavire=$stock{"pr_stre"}+0; # stock entrepot 
		print "<tr><td>";
		print "$pr_cd_pr</td>";
		$digit_f=$prodnavire%1000000+1000000;
		$digit_f=substr($digit_f,3,4);
		$digit_p=int($prodnavire/10000);
		print "<td>$digit_p <b>$digit_f</b></td>";
		print "<td  bgcolor=$color>$pr_desi</td>";
		print "<td align=right>$pr_stre</td>";
		print "<td align=right>$stocknavire</td>";
		$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton)=$sth2->fetchrow_array+0;
		print "<td align=right>$carton</td>";
		print "<td><input type=text name=$pr_cd_pr size=4 value=$pr_stre></td>";

		print "</tr>";
	}
	print "</table>";
	print "<input type=hidden name=action value=creer>";
	print "<br><input type=submit value=\"Ok pour faire la debascule\"</form>";
}
sub titre {
	print "<tr><th>Code produit</th><th>Code barre</th><th>Désignation</th><th>Stock avion</th><th>Stock navire</th><th>Packing</th></tr>";
}

sub maj_prodnavire {
	$query="select count(*) from enso where es_cd_pr=$prodnavire and es_dt=curdate()+0 and es_type=24";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array+0;
	if ($nb>0) { 
		print "<font color=red>$prodnavire $pr_desi une seule bascule de stock autorisé par jour </font><br>";
		return();
	}
	$qtemaj=0-($qte*100);
	
	$query="update produit set pr_stre=pr_stre-($qtemaj) where pr_cd_pr=$prodnavire;";
	
	 $sth=$dbh->prepare($query);
	 $sth->execute();
	$query="insert into enso values ($prodnavire,'',curdate()+0,'$qtemaj','0','24')";	
	
	 $sth=$dbh->prepare($query);
	 $sth->execute();
}
sub maj_prodavion {
	$query="select count(*) from enso where es_cd_pr=$prodavion and es_dt=curdate()+0 and es_type=24";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array+0;
	if ($nb>0) { 
		print "<font color=red>$prodavion $pr_desi une seule bascule de stock autorisé par jour </font><br>";
		return();
	}

	$qtemaj=($qte*100);
	
	$query="update produit set pr_stre=pr_stre-$qtemaj where pr_cd_pr='$prodavion';";
	
	 $sth=$dbh->prepare($query);
	 $sth->execute();

	$query="insert into enso values ('$prodavion','',curdate()+0,'$qtemaj','0','24')";	
	 $sth=$dbh->prepare($query);
	 $sth->execute();
}

# -E bascule de stock
