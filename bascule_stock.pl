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
print "merci d'utiliser le nouveau menu fichier->produit->bascule de stock";
 exit;
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
print "<body><h2>Bascule de stock</h2><br>";
print `date`;
print "<br>";


require "./src/connect.src";

$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where (pr_cd_pr >100000000 and (pr_type=1 or pr_type=5)) and pr_sup!=1 and pr_sup!=2 and pr_sup!=4 order by pr_four";
$sth=$dbh->prepare($query);
$sth->execute();
if ($action eq ""){&table();}
if ($action eq "creer"){
	print "<table border=1 cellspacing=0><caption><h3>Stock navire</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à sortir</th><th>reste</th><th>Check</th></tr>";
	$dateref=$today-15;
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup)=$sth->fetchrow_array)
	{
		$qte=$html->param("$pr_cd_pr")+0;
		if ($qte==0){ next;}

		######################
		&maj_prodnavire();		
		######################

		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 
		$digit_f=$pr_cd_pr%1000000+1000000;
		$digit_f=substr($digit_f,3,4);
		$digit_p=int($pr_cd_pr/10000);
		print "<tr><td>$digit_p <b>$digit_f</b></td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($pr_cd_pr,$qte);
		print "</td><td align=right>";
		&carton($pr_cd_pr,$pr_stre);
		print "</td><td><input type=checkbox></tr>";
		push (@table,$pr_cd_pr);
	}
	print "</table><br><br>";
	print "<table border=1 cellspacing=0><caption><h3>Stock avion</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à entrer</th><th>nouveau stock</th><th>Check</th></tr>";
	foreach (@table) {
		$query="select pr_cd_pr,pr_desi from produit where pr_codebarre=$_ and pr_cd_pr<1000000";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($prodavion,$pr_desi)=$sth2->fetchrow_array;
		$qte=$html->param("$_");
		
		######################
		&maj_prodavion();		
		######################
	
		%stock=&stock($prodavion,'','');
		$stockavion=$stock{"stock"}+0; # stock entrepot + stock avion
		print "<tr><td>$prodavion</td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($prodavion,$qte);
		print "</td><td align=right>";
		&carton($prodavion,$stockavion);
		print "</td><td><input type=checkbox></tr>";
	}
	print "</table>";
	
	
}

sub table{
	$dateref=$today-15;
	print "<form><table border=1 cellspacing=0>";
	&titre();

	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup)=$sth->fetchrow_array)
	{
		$query="select pr_cd_pr from produit where pr_codebarre=$pr_cd_pr and pr_cd_pr<1000000";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$prodavion=$sth2->fetchrow_array;
		if ($prodavion eq ""){next;}
		$query="select max(pi_qte) from pick where pi_cd_pr='$prodavion' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$pick=$sth2->fetchrow_array+0; # stock enlair maximum depuis les 15 derniers jours
		 if ($pr_sup==3 && $pick==0){$pick=60;}
		 if (($pr_sup==3)&&($pick<60)){$pick=60;} # debut des nouveautés
		
		if ($pick == 0){next;}
		# commande en cours	
		$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_commande)=$sth2->fetchrow_array+0;
	

		$vendu=0;
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 
		if (($pr_stre<=0)&&($option ne "check")){next;}	
	
		%stock=&stock($prodavion,'','quick');
		$stockavion=$stock{"pr_stre"}+0; # stcok entrepot + stock avion
		# if ($prodavion eq ""){print "**** $stockavion ***";}
	
		# ventes avions sur les 15 derniers jours
		$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_cd_pr=pr_cd_pr and ro_code=v_code and v_date_jl>$dateref and pr_cd_pr='$prodavion' group by ro_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($vendu)=$sth2->fetchrow_array+0;
	
	        
		$color="white";
		$stock_ideal=$vendu+$pick+int($vendu/2);
		$ecart=$stockavion-$stock_ideal;
		# if ($pr_cd_pr eq "3352810051596"){print "$stockavion $pick $pr_sup";}
	
		if ($ecart >=0) {next;}
	
		if ($option eq "check"){
			 if ($stockavion<120){$color="orange";}
			 if ($stockavion<60){$color="red";}
		}
		$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton)=$sth2->fetchrow_array+0;
		if ($pr_stre <=(0-$ecart) ){$proposition=$pr_stre;}
		else {
			if ($carton==0){$carton=1;}
			# $proposition=(int(((($qte*2)-$qte_commande+$corsica-$pr_stre)/$carton)))*$carton+$carton;
			$proposition=int((0-$ecart)/$carton)*$carton;
			# print "<td>$proposition***</td>";
			if ($ecart%$carton!=0){$proposition+=$carton;}
			# print "<td>$proposition $ecart $carton $pr_stre***</td>";
			if ($proposition >= $pr_stre){$proposition=$pr_stre;}
			
		}
		 #       print "$prodavion $pick $proposition<br>";
	
		if ($proposition <12){next;}
		print "<tr><td>";
		print "$pr_cd_pr</td><td  bgcolor=$color>$pr_desi</td>";
		print "<td align=right>$stockavion</td>";
		print "<td align=right>$pr_stre</td><td align=right>$stock_ideal</td><td align=right>$ecart</td>";
		print "<td align=right>$carton</td>";
	
		print "<td><input type=text name=$pr_cd_pr size=4 value=$proposition ></td>";

		if ($pr_sup==2){print "<td><font color=blue>délisté</td>";}
		if ($pr_sup==3){print "<td><font color=red>new</td>";}
		print "</tr>";
	}
	print "</table>";
	print "<input type=hidden name=action value=creer>";
	print "<br><input type=submit value=\"Ok pour faire la bascule\"</form>";
}
sub titre {
	print "<tr><th>Code produit</th><th>Désignation</th><th>Stock avion</th><th>Stock navire</th><th>Stock ideal</th><th>Ecart</th><th>Packing</th></tr>";
}

sub maj_prodnavire {
	$query="select count(*) from enso where es_cd_pr=$pr_cd_pr and es_dt=curdate()+0 and es_type=24";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array+0;
	if ($nb>0) { 
		print "<font color=red>$pr_cd_pr $pr_desi une seule bascule de stock autorisé par jour </font><br>";
		return();
	}
	$qtemaj=($qte*100);
	
	$query="update produit set pr_stre=pr_stre-$qtemaj where pr_cd_pr=$pr_cd_pr;";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query="insert into enso values ($pr_cd_pr,'',curdate()+0,'$qtemaj','0','24')";	
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

	$qtemaj=0-($qte*100);
	
	$query="update produit set pr_stre=pr_stre-$qtemaj where pr_cd_pr='$prodavion';";
	$sth=$dbh->prepare($query);
	$sth->execute();

	$query="insert into enso values ('$prodavion','',curdate()+0,'$qtemaj','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
}

# -E bascule de stock
