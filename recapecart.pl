#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
$query="select v_code,v_rot,v_vol,v_date,v_dest from vol where v_cd_cl=123 and v_date%10000=404 ";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table>";
while (($v_code,$v_rot,$v_vol,$v_date,$v_dest)=$sth->fetchrow_array){
	$query="select ca_recettes/100,ca_fly/100,ca_cheque/100 from caisse where ca_code='$v_code' and ca_rot=$v_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ca_recettes,$ca_fly,$ca_papi)=$sth2->fetchrow_array;
	$ca_fly-=$ca_papi;
	$ca_recettes-=$ca_papi;
	$query="select sum((ap_qte0/100-ecpn_qte)*ecpn_prix/100) from ecartpn,appro where ecpn_code='$v_code' and ap_cd_pr=ecpn_cd_pr and ap_code='$v_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ecart_pn)=$sth2->fetchrow_array;
	$query="select sum((ecfly_qte-ret_qte)*ecfly_prix/100) from ecartfly,retour where ecfly_code='$v_code' and ret_cd_pr=ecfly_cd_pr and ret_code='$v_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ecart_fly)=$sth2->fetchrow_array;
	if ($v_rot!=1){$ecart_pn=$ecart_fly=0;}
	if ($ecart_fly!=0){
		$total=0;
		print "<tr><th>$v_code</th></tr>";
		$query="select pr_cd_pr,pr_desi,ecfly_qte-ret_qte,ecfly_prix/100 from ecartfly,retour,produit where ecfly_code='$v_code' and ret_cd_pr=ecfly_cd_pr and ret_code='$v_code' and ret_cd_pr=pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($pr_cd_pr,$pr_desi,$qte,$prix)=$sth2->fetchrow_array){
			print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td><td align=right>$prix</td></tr>";
			$total+=$prix*$qte;
		}
		$vente_pn=$ca_fly-$ecart_fly+$ecartpn;
		$ecart_caisse=$ca_recettes-$vente_pn;
		print "<tr><td colspan=3><b>Ecart de caisse</td><td align=right>";
		print &deci2($ecart_caisse);
		print "</td></tr>";
		print "<tr><td colspan=3><b>TOTAL</td><td align=right>";
		print &deci2($total);
		print "</td></tr>";
	}
		
}
print "</table>";
# -E recap des erreurs