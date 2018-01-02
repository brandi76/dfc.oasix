#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
$action=$html->param("action");
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$four=$html->param("four");
if ($four eq ""){$four=$html->param("fourmanu");}
if ($four eq "TOUS"){$four="pr_four";}

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";


require "./src/connect.src";

print "<body><center><h1>2006</h1>";

if ($action eq "") {
	print "<form>";
  	print "<br>choisir un fournisseur<br><br><select name=four><option value=''></option><option value='TOUS'>TOUS</option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from ordre,fournis,produit where pr_cd_pr=ord_cd_pr and pr_four=fo2_cd_fo group by fo2_cd_fo order by fo2_add");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br><input type=text name=fourmanu size=4><br><input type=hidden name=action value=go><input type=submit value='envoie'></form>"; 
	
}
else
{

$query="select v_cd_cl from vol where floor(v_date%100)=6 group by v_cd_cl order by v_cd_cl" ;
$sth3=$dbh->prepare($query);
$sth3->execute();
while (($client)=$sth3->fetchrow_array){
	push (@client,$client);
}
$nbclient=$#client+2;
$query="select pr_four,fo2_add from produit,ordre,fournis where fo2_cd_fo=pr_four and pr_cd_pr=ord_cd_pr and (pr_type=1 or pr_type=5) and pr_four=$four group by pr_four order by pr_four";
# print ($query);
	print "<table cellspacing=0 border=1>";

$sth3=$dbh->prepare($query);
$sth3->execute();
while (($pr_four,$fo_nom)=$sth3->fetchrow_array){
	$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and floor(v_date%100)=6 and ro_cd_pr=pr_cd_pr and pr_four='$pr_four' " ; # and (v_dest like 'LYS%' or v_dest like 'MRS%')
	$sth=$dbh->prepare($query);
	$sth->execute();
	($qte)=$sth->fetchrow_array;
	$qte+=0;
	if ($qte==0){next;}
	$totalf=0;
	# print "<h3>$pr_four $fo_nom</h3><br>";
	# print "<tr bgcolor=#efefef><th>&nbsp;</th><th colspan=$nbclient>Janvier</th><th colspan=$nbclient>Février</th><th colspan=$nbclient>Mars</th><th colspan=$nbclient>Avril</th><th colspan=$nbclient>Mai</th><th colspan=$nbclient>Juin</th><th colspan=$nbclient>Juillet</th><th colspan=$nbclient>Août</th><th colspan=$nbclient>Septembre</th><th colspan=$nbclient>Octobre</th><th colspan=$nbclient>Novembre</th><th colspan=$nbclient>Décembre</th><th colspan=$nbclient>Total</th></tr>\n";
	# print "<tr bgcolor=#efefef><th>&nbsp;</th>";
	#for ($j=1;$j<14;$j++){
		#for ($i=0;$i<$nbclient-1;$i++){
			#print "<th>$client[$i]</th>";
		#}
		#print "<th>total</th>";
	#}
	#print "</tr>";
	$query="select pr_cd_pr,pr_desi,pr_codebarre from produit,ordre where pr_cd_pr=ord_cd_pr and pr_four='$pr_four' and (pr_type=1 or pr_type=5)";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth2->fetchrow_array){
		if (&get("select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and floor(v_date%100)=6 and ro_cd_pr=pr_cd_pr and pr_cd_pr='$pr_cd_pr'","af")+0==0){next;}
		print "<tr><td width=30%>$pr_codebarre</td><td>$pr_desi</td>";
		$total=0;
		$totalgen=0;
		for ($i=1006;$i<=1206;$i=$i+100){
			foreach $client (@client) {
				$query="select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and floor(v_date%10000)=$i and ro_cd_pr=$pr_cd_pr and v_cd_cl='$client' " ; #and (v_dest like 'LYS%' or v_dest like 'MRS%')
				$sth=$dbh->prepare($query);
				$sth->execute();
				($qte)=$sth->fetchrow_array;
				$qte+=0;
				# print "<td align=right>$qte</td>";
				$totalcli{"$client"}+=$qte;
				$total_int+=$qte;
				$total+=$qte;
			}
			print "<td align=right><b>$total_int</td>";
			$total_int=0;
		}
		foreach $client (@client) {
			# print "<td align=right><b>".$totalcli{"$client"}."</td>";
			$totalcli{"$client"}=0;
		}
		# print "<td align=right><b>$total</td></tr>";
		print "</tr>";
		$totalf+=$total;
	}
	# print "<tr><td colspan=13>Total pieces</td><td align=right><b>$totalf</td></tr>";
	$totalg+=$totalf;
}
	print "</table>";

print "<b>Total pieces:$totalg";
}