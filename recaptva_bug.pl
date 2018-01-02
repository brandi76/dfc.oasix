#!/usr/bin/perl
# #!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
print "<title>Recap tva</title>";
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
if ($action eq ""){&premiere();}
if ($action eq "go"){
	&go();
}

if ($action eq "client"){&clien();}
sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=10><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";

}

sub clien{
	$query="select distinct cl_cd_cl,cl_nom from vol,client where v_cd_cl=cl_cd_cl order by v_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
		print "$cl_cd_cl $cl_nom <br>";
	}
}
sub go{
	$caalc=$cacig=$cavab=$catab=0;
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	
	print "Mois:$mois   Client:$cl_nom <br><br><bR>";
	$query="select distinct ret_cd_pr from retoursql,vol where ret_code=v_code and  v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 order by ret_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
        while (($pr_cd_pr)=$sth->fetchrow_array){
		push(@produit,$pr_cd_pr);
	}

	print "<table border=1 cellspacing=0><tr><th>No Ref</th><th>Date</th><th>No vol</th><th>Tronçon</th><th>Recette</th><th>Recette TVA 19.6</th><th>Recette Tva 5.5</th>";
	print " <th>Recette Tva europe</th><th>Recette Hors tva</th></tr>";
	$query="select v_code,v_vol,v_date,v_dest from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 order by v_code";
	# $query="select v_code,v_vol,v_date,v_dest from vol where v_code=24111 and v_rot=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_date,$v_dest)=$sth->fetchrow_array){
		$ca=$catva1=$catva2=0;
		$query="select ret_cd_pr,ret_qte-ret_retour,ret_prix from retoursql where ret_code='$v_code'";
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		while (($ret_cd_pr,$qte,$prix)=$sth4->fetchrow_array){
			$ca+=$prix*$qte;
			$pr_ventil=&get("select pr_ventil from produit where pr_cd_pr='$ret_cd_pr'");
			if ($pr_ventil==1){$catva1+=$prix*$qte;}else {$catva2+=$prix*$qte;}
		}
		print "<tr><td>$v_code</td><td>$v_date</td><td>$v_vol</td><td>$v_dest";
		    print "</td>";
# 		print "<td>";
# 		$aero_desi=&get("select aero_desi from aeroport where aero_tri='$depart'");
# 		$pays=&get("select aerd_desi from aerodesi where aerd_trig='$depart'");
# 		print "$aero_desi<br>$pays";    
# 		print "</td>";
# 		print "<td>";
# 		print "</td>";
		
# 		print "<td>";
		$catiers=$caeu=0;
		$type=0;
		if (($type!=3)&&($rotation==1)){print "Tva France";}
		if (($type==1)&&($rotation!=1)){print "Tva Europe";$catva1=0;$catva2=0;$caeu=$ca;}
		if ($type==3){print "Hors tva";$catva1=0;$catva2=0;$catiers=$ca;}
# 		print "</td>";
# 		print "<td>$rotation</td><td>$oa_vol</td>";
		print "<td align=right>$ca</td>";
		print "<td align=right>$catva1</td>";
		print "<td align=right>$catva2</td>";
		print "<td align=right>$caeu</td>";
		print "<td align=right>$catiers</td>";
		$totca+=$ca;
		$totcatva1+=$catva1;
		$totcatva2+=$catva2;
		$totcaeu+=$caeu;
		$totcatiers+=$catiers;
		print "</tr>";
	}
	print "<tr><td colspan=4><b>Total</b></td>";
	print "<td align=right><b>$totca</b></td>";
	print "<td align=right><b>$totcatva1</b></td>";
	print "<td align=right><b>$totcatva2</b></td>";
	print "<td align=right><b>$totcaeu</b></td>";
	print "<td align=right><b>$totcatiers</b></td>";
	print "</table>";
}	
