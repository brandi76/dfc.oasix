#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
$action=$html->param("action");
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$four=$html->param("four");
$mois=$html->param("mois");
$an=$html->param("an");
$mini_an=substr($an,2,2);
$an_en_cours=`/bin/date +%Y`;
if ($four eq ""){$four=$html->param("fourmanu");}
if ($four eq "TOUS"){$four="pr_four";}
@tab_mois= ("Janvier", "F�vrier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Ao�t", "Septembre", "Octobre", "Novembre", "D�cembre");	

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";


require "./src/connect.src";

print "<body><center><h1>$an</h1>";

if ($action eq "") {
	print "<form>";
  	print "<br>choisir un fournisseur<br><br><select name=four><option value=''></option><option value='TOUS'>TOUS</option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where  pr_four=fo2_cd_fo group by fo2_cd_fo order by fo2_add");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br><input type=text name=fourmanu size=4><br>";
 	print "<br>Ann�e AAAA <input type=text name=an value='$an_en_cours'></br>";
  	print "<input type=hidden name=action value=go><br><input type=submit value='envoie'></form>";
	print "<hr></hr>";
	print "<form><strong>mois</strong><br>";
	print "<br>choisir un fournisseur<br><br><select name=four><option value=''></option><option value='TOUS'>TOUS</option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where  pr_four=fo2_cd_fo group by fo2_cd_fo order by fo2_add");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br>";
	print "mois";
	print "<select name=mois>";
	for ($i = 0; $i<$#tab_mois; $i++){       
		$j=$i+1;	
		print "<option value=$j>$tab_mois[$i]</option>";
	}
	print "</select>";
	print "<br>Ann�e AAAA <input type=text name=an value='$an_en_cours'></br>";
	print "<br><input type=hidden name=action value=gomois><br><input type=submit value='envoie'></form>";
	
	
}
if ($action eq "go")
{
$query="select v_cd_cl from vol where floor(v_date%100)=$mini_an group by v_cd_cl order by v_cd_cl" ;
$sth3=$dbh->prepare($query);
$sth3->execute();
while (($client)=$sth3->fetchrow_array){
	push (@client,$client);
}
$nbclient=$#client+2;
$query="select pr_four,fo2_add from produit,fournis where fo2_cd_fo=pr_four  and pr_four=$four group by pr_four order by pr_four";
# print ($query);
$sth3=$dbh->prepare($query);
$sth3->execute();
while (($pr_four,$fo_nom)=$sth3->fetchrow_array){
	$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and floor(v_date%100)=$mini_an and v_rot=1 and ro_cd_pr=pr_cd_pr and pr_four='$pr_four' " ; # and (v_dest like 'LYS%' or v_dest like 'MRS%')
	$sth=$dbh->prepare($query);
	$sth->execute();
	($qte)=$sth->fetchrow_array;
	$qte+=0;
	if ($qte==0){next;}
	$totalf=0;
	print "<h3>$pr_four $fo_nom</h3><br>";
	print "<form>";
	print "<table cellspacing=0 border=1>";
	print "<tr bgcolor=#efefef><th>&nbsp;</th><th colspan=$nbclient>Janvier</th><th colspan=$nbclient>F�vrier</th><th colspan=$nbclient>Mars</th><th colspan=$nbclient>Avril</th><th colspan=$nbclient>Mai</th><th colspan=$nbclient>Juin</th><th colspan=$nbclient>Juillet</th><th colspan=$nbclient>Ao�t</th><th colspan=$nbclient>Septembre</th><th colspan=$nbclient>Octobre</th><th colspan=$nbclient>Novembre</th><th colspan=$nbclient>D�cembre</th><th colspan=$nbclient>Total</th></tr>\n";
	print "<tr bgcolor=#efefef><th>&nbsp;</th>";
	for ($j=1;$j<14;$j++){
		for ($i=0;$i<$nbclient-1;$i++){
			print "<th>$client[$i]</th>";
		}
		print "<th>total</th>";
	}
	print "</tr>";
	$query="select pr_cd_pr,pr_desi from produit where  pr_four='$pr_four'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array){
		if (($action eq "filtre")&&($html->param("$pr_cd_pr") ne "on")){next;}
		if (&get("select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and v_rot=1 and floor(v_date%100)=$mini_an and ro_cd_pr=pr_cd_pr and pr_cd_pr='$pr_cd_pr'","af")+0==0){next;}
		print "<tr><td width=30%>$pr_cd_pr $pr_desi</td>";
		$total=0;
		$totalgen=0;
		$debut=100+$mini_an;
		$fin=$mini_an*100+13;
		
		for ($i=$debut;$i<$fin;$i=$i+100){
			foreach $client (@client) {
				$query="select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and floor(v_date%10000)=$i and v_rot=1 and ro_cd_pr=$pr_cd_pr and v_cd_cl='$client' " ; #and (v_dest like 'LYS%' or v_dest like 'MRS%')
				$sth=$dbh->prepare($query);
				$sth->execute();
				($qte)=$sth->fetchrow_array;
				$qte+=0;
				print "<td align=right>$qte</td>";
				$totalcli{"$client"}+=$qte;
				$total_int+=$qte;
				$total+=$qte;
			}
			print "<td align=right><b>$total_int</td>";
			$total_int=0;
		}
		foreach $client (@client) {
			print "<td align=right><b>".$totalcli{"$client"}."</td>";
			$totalcli{"$client"}=0;
		}
		print "<td align=right><b>$total</td>";
		print "<td><input type=checkbox name='$pr_cd_pr' checked></td>";
		print "</tr>";
		$totalf+=$total;
	}
	print "<tr><td colspan=13>Total pieces</td><td align=right><b>$totalf</td></tr>";
	$totalg+=$totalf;
	print "</table>";
}
print "<b>Total pieces:$totalg";
print "<input type=hidden name=four value=$four>";
print "<input type=hidden name=action value=filtre><br><input type=submit value=filtrer></form>";
}

if ($action eq "gomois")
{
	$date_ref=$mois.$mini_an;
	$query="select v_cd_cl from vol where floor(v_date%10000)=$date_ref group by v_cd_cl order by v_cd_cl" ;
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	while (($client)=$sth3->fetchrow_array){
		push (@client,$client);
	}
	$query="select pr_four,fo2_add from produit,fournis where fo2_cd_fo=pr_four and pr_four=$four group by pr_four order by pr_four";
	 #print ($query);
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	while (($pr_four,$fo_nom)=$sth3->fetchrow_array){
		$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and floor(v_date%10000)=$date_ref and v_rot=1 and ro_cd_pr=pr_cd_pr and pr_four='$pr_four' " ; # and (v_dest like 'LYS%' or v_dest like 'MRS%')
		#	print "$query<br>";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($qte)=$sth->fetchrow_array;
		$qte+=0;
		if ($qte==0){next;}
		$totalf=0;
		print "<h3>$pr_four $fo_nom</h3><br>";
		print "<h2>$tab_mois[$mois-1] $an</h2><br>";
		print "<table cellspacing=0 border=1>";
		print "<tr bgcolor=#efefef><th>&nbsp;</th>";
		for ($i=0;$i<=$#client;$i++){
			$nom=&get("select cl_nom from client where cl_cd_cl=".$client[$i]);
			print "<th>$nom</th>";
		}
		print "<th>total</th>";
		print "</tr>";
		$query="select pr_cd_pr,pr_desi from produit where  pr_four='$pr_four'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array){
			if (($action eq "filtre")&&($html->param("$pr_cd_pr") ne "on")){next;}
			if (&get("select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and v_rot=1 and floor(v_date%10000)=$date_ref and ro_cd_pr=pr_cd_pr and pr_cd_pr='$pr_cd_pr'","af")+0==0){next;}
			print "<tr><td width=30%>$pr_cd_pr $pr_desi</td>";
			$total=0;
			$totalgen=0;
				foreach $client (@client) {
					$query="select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and floor(v_date%10000)=$date_ref and v_rot=1 and ro_cd_pr=$pr_cd_pr and v_cd_cl='$client' " ; #and (v_dest like 'LYS%' or v_dest like 'MRS%')
					$sth=$dbh->prepare($query);
					$sth->execute();
					($qte)=$sth->fetchrow_array;
					$qte+=0;
					print "<td align=right>$qte</td>";
					$totalcli{"$client"}+=$qte;
					$total_int+=$qte;
					$total+=$qte;
				}
				print "<td align=right><b>$total_int</td>";
				$total_int=0;
			print "</tr>";
			$totalf+=$total;
		}
		print "<tr><td colspan=2>Total pieces</td><td align=right><b>$totalf</td></tr>";
		$totalg+=$totalf;
		print "</table>";
	}
	$totalg+=0;
	print "<b>Total pieces:$totalg";
}
