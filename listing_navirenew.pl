#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$today=&nb_jour($jour,$mois,$an);

print $html->header;
$action=$html->param("action");
$pr_cd_pr=$html->param("pr_cd_pr");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right } 
        
-->
</style></head>";
print "<body link=black>";

require "./src/connect.src";

$query="select distinct se_navire from semaine2 where se_coef!=0 order by se_navire ";
$sth=$dbh->prepare($query);
$sth->execute();
$indnav=0;
while (($nom)=$sth->fetchrow_array){
	push (@navire,$nom);
	$mess="mess"."$indnav";
	print "<div id=$mess style=\"position:absolute;background-color:yellow;border:1px solid black ; padding:0.2em; visibility:hidden;\">$nom</div>";
	$indnav++;
}


if ($action eq "go"){
	foreach $nom (@navire) {
		if ($html->param("$nom") eq "on"){
			&save("replace into navire2 values ('$nom','$pr_cd_pr',curdate(),0,6,0)");
		}
		else
		{
			&save("delete  from navire2 where nav_nom='$nom' and nav_cd_pr='$pr_cd_pr' and nav_type=0","af");
		}
	}
	$action="";
}


if ($action eq ""){
$prod=$pr_cd_pr;
print "<table border=1 cellspacing=0><tr><td colspan=2>&nbsp;</td>";
foreach $nom (@navire) {
	print "<th><font size=-1>";
	for ($i=0;$i<length($nom);$i++){
		$digit=substr($nom,$i,1);
	 	print "$digit<br>";
	}
	print "</font></th>";
}
print "</tr>";
$nbnavire=$#navire+1;
print "<tr><th>Code barre</th><th>Désignation</th><th colspan=$nbnavire>referencé</th><th><font size=-1>Code neptune</th><th>Particularité</th><th>Stock</th><th>En cde</th></tr>";

$query="select nav_cd_pr,pr_desi,pr_sup from navire2,produit where nav_type=0 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) group by nav_cd_pr order by pr_four,nav_cd_pr ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_sup)=$sth->fetchrow_array){
	$query="select nep_cd_pr from neptune where nep_codebarre='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nep_cd_pr)=$sth2->fetchrow_array;
	$color="white";
	if ($pr_cd_pr==$prod){$color="yellow";}
	print "<tr bgcolor=$color><td><a href=?pr_cd_pr=$pr_cd_pr&action=modif>$pr_cd_pr</a></td><td><font size=-3>$pr_desi</td>";
	$indnav=0;
	foreach (@navire) {
		$query="select nav_qte from navire2 where nav_nom='$_' and nav_type=0 and nav_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte)=$sth2->fetchrow_array+0;
		
		if ($qte==0){$qte="<font color=red size=+1>X</font>";}
		else {$qte="<font color=green size=+1>X</font>";}
		print "<td align=center>";
		$mess="mess"."$indnav";
		print "<a Onmouseover=aff_".$mess."() Onmouseout=eff_".$mess."()>$qte</a>";
		print "</td>";
		$indnav++;
	}	
	if ($nep_cd_pr eq ""){$nep_cd_pr="<font color=red size=+1>X</font>";}
	print "<td align=right>$nep_cd_pr</td>";
	$part="&nbsp;";
	$query="select count(*) from trolley,produit where tr_cd_pr=pr_cd_pr and tr_code=100 and pr_codebarre='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nb)=$sth2->fetchrow_array;
	if ($nb >0){$part="catalogue aérien";}
	if ($pr_sup==1){$part.="supprimé";}
	if ($pr_sup==2){$part.="délisté du listing avion";}
	if ($pr_sup==3){$part.=" new";}
	if ($pr_sup==4){$part.="<font color=red>hors catalogue destockage</font>";}
	if ($pr_sup==5){$part.="suivi paul";}
	if ($pr_sup==6){$part.="délisté paul";}

	print "<td><font size=-2>$part</td>";
	%stock=&stock($pr_cd_pr,'','quick');
	$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	if ($pr_sup==4){	
		# recherche si un produit avec le meme code barre existe dans les references 6 chioffres
		$query="select pr_cd_pr from produit where pr_codebarre=$pr_cd_pr and pr_cd_pr<1000000";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$prodavion=$sth2->fetchrow_array;
		if ($prodavion ne ""){
			# pour les produit navire qui ont une coorespondance avec un code avion on ajoute le stock avion
			%stock=&stock($prodavion,'','quick');
			$pr_stre+=$stock{"pr_stre"};
		}
	}
	print "<td align=right>$pr_stre</td>";
	$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr=$pr_cd_pr";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($qte_commande)=$sth2->fetchrow_array+0;
	print "<td align=right>$qte_commande</td>";
		
	print "</tr>";
}
print "</table>";
print "<br> Nouveau produit <form><input type=text name=pr_cd_pr size=14><input type=hidden name=action value=modif> <input type=submit value=creer></form>";

print "
<script type=\"text/javascript\">
var x,y;
function position(e) {
	if (navigator.appName.substring(0,3) == \"Net\") {
		x = e.pageX;
		y = e.pageY;
	}
	else {
		x = event.x+document.body.scrollLeft;
		y = event.y+document.body.scrollTop;
	}
}
if(navigator.appName.substring(0,3) == \"Net\") document.captureEvents(Event.MOUSEMOVE);
document.onmousemove = position;
";
$ind=0;
foreach $nom (@navire) {
	$mess="mess".$ind;
	print "$mess"."_style = document.getElementById(\"$mess\").style;
	function aff_$mess() {
		$mess"."_style.top = (y+10)+\"px\";
		$mess"."_style.left = (x-40)+\"px\";
		$mess"."_style.visibility = \"visible\";
	}
	function eff_$mess() {
		$mess"."_style.visibility = \"hidden\";
	}";
	$ind++;
}
print "	</script>";
}
if ($action eq "modif"){
	print "<form>";
	print "<table border=1 width=100% cellspacing=0><tr><td colspan=2>&nbsp;</td>";
	foreach $nom (@navire) {
		print "<th><font size=-1>";
		for ($i=0;$i<length($nom);$i++){
			$digit=substr($nom,$i,1);
			print "$digit<br>";
		}
		print "</font></th>";
	}
	print "</tr>";
	$nbnavire=$#navire+1;
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
	foreach (@navire) {
		$qte=&get("select nav_qte from navire2 where nav_nom='$_' and nav_type=0 and nav_cd_pr='$pr_cd_pr'");
		print "<td align=center>";
		if ($qte==0){print $qte="<input type=checkbox name='$_'>";}
		else {print $qte="<input type=checkbox name='$_' checked>";}
		print "</td>";
	}	
	print "</tr>";
	print "</table><br><center>";
	print "<input type=hidden name=action value=go>"; 
	print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>"; 
	print "<input type=submit value=modif>";
}	