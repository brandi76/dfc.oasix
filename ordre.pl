#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "./src/connect.src";
$action=$html->param("action");
$ordre=$html->param("ordre");
$prix=$html->param("prix");


&tete();
if (($action eq "prix")&&($ordre ne "")){
	$query="update trolley,lot set tr_prix=$prix*100 where tr_ordre='$ordre' and lot_nolot=tr_code";
	$sth=$dbh->prepare($query);
	$nb=$sth->execute;
&save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	print "<br><font color=red>$nb Lot modifié<br></font>";
	$query="update ordre set ord_prix1=$prix*100 where ord_ordre='$ordre'";
	$sth=$dbh->prepare($query);
	$nb=$sth->execute;
	$action="ordre";
}
if (($action eq "qte")&&($ordre ne "")){
	$query="select lot_nolot from lot where lot_flag>0";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($lot_nolot)= $sth->fetchrow_array)
	{
		$nom=$lot_nolot."qte";
		$qte=$html->param("$nom")+0;
		$query="select tr_qte/100 from trolley where tr_ordre='$ordre' and tr_code='$lot_nolot'";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($tr_qte)=$sth2->fetchrow_array;
		$tr_qte+=0;
		if ($tr_qte ne $qte){
			if (($tr_qte>0)&&($qte==0)){
				$query="delete from trolley where tr_ordre='$ordre' and tr_code='$lot_nolot'";
				$sth2=$dbh->prepare($query);
				$nb=$sth2->execute;
				print "<br><font color=red>$nb trolley:$lot_nolot ligne supprimée<br></font>";
			}
			elsif($tr_qte>0){
				$query="update trolley set tr_qte=$qte*100 where tr_ordre='$ordre' and tr_code='$lot_nolot'";
				$sth2=$dbh->prepare($query);
				$nb=$sth2->execute;
				print "<br><font color=red>$nb trolley:$lot_nolot ligne modifiée<br></font>";
			}
			else{
				$query="select ord_prix1,ord_cd_pr from ordre where ord_ordre='$ordre'";
				$sth2=$dbh->prepare($query);
				$sth2->execute;
				($prix,$ord_cd_pr)=$sth2->fetchrow_array;
				$qte*=100;
				$query="replace into trolley values ('$lot_nolot','$ordre','$ord_cd_pr','$qte','$prix','','')";
				$sth2=$dbh->prepare($query);
				$nb=$sth2->execute;
				print "<br><font color=red>$nb trolley:$lot_nolot ligne ajoutée<br></font>";
			}
		}
	}
	$action="ordre";
}


if ($action eq ""){
	print "<form><table border=1 cellspacing=0>";
	print "<tr><th>Ordre</th><th>Produit</th><th>Prix</th></tr>";
	
	$query="select ordre.*,pr_desi from ordre,produit where ord_cd_pr=pr_cd_pr order by ord_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($ord_ordre,$ord_cd_pr,$ord_prix,$null,$pr_desi)= $sth->fetchrow_array) {
		$ord_prix/=100;
		print "<tr><td><a href=ordre.pl?action=ordre&ordre=$ord_ordre>$ord_ordre</a></td><td>$ord_cd_pr $pr_desi</td><td>$ord_prix</td></tr>";
	}
	print "</table><br>";
	# print "<input class=bouton type=submit name=action value=edite></form>";
	print "</body></html>";

}



if ($action eq "ordre"){
	$query="select ordre.*,pr_desi from ordre,produit where ord_ordre='$ordre' and ord_cd_pr=pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($ord_ordre,$ord_cd_pr,$ord_prix,$null,$pr_desi)= $sth->fetchrow_array;
	$ord_prix/=100;
	print "<br><br><br><br><font size=+2>$ord_cd_pr $pr_cd_pr $pr_desi </font><form>Prix <input type=text name=prix value=$ord_prix size=3><br>";
	print "<input type=hidden name=ordre value=$ordre>";
	print "<input type=hidden name=action value=prix>";
	print "<br><input class=bouton type=submit value=\"Modification du prix\"></form>";

	$query="select lot_nolot,lot_desi,cl_nom from lot,client where lot_flag>0 and floor(lot_nolot/10)=cl_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<form><table border=0>";
	while (($lot_nolot,$lot_desi,$cl_nom)= $sth->fetchrow_array)
	{
		$query="select tr_code,tr_prix,tr_qte from trolley where tr_ordre='$ordre' and tr_code=$lot_nolot";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($tr_code,$tr_prix,$tr_qte)= $sth2->fetchrow_array;
		$nom=$lot_nolot."qte";
		$tr_qte/=100;
		print "<tr><td class=gauche>$cl_nom </td><td><font size=+2>$lot_nolot</td><td><input type=text size=3 name=$nom value=$tr_qte></td><td>$lot_desi</td></tr>";
	}
	print "</table>";
	print "<input type=hidden name=ordre value=$ordre>";
	print "<input type=hidden name=action value=qte>";
	print "<input class=bouton type=submit value=\"Modification de la qte\"></form>";
	print "<br><br><br><a href=ordre.pl>Debut</a></body></html>";

}





sub tete{
	print "<html><head><style type=\"text/css\">
	body {color=white;}
	td {font-weight:bold;text-align:center;}
	.gauche {
		td {font-weight:bold;text-align:left;}
	}
	
	<!--
	.ombre {
	filter:shadow(color=black, direction=120 , strength=3);
	width:800px;}
	.ombre2 {
	filter:shadow(color=white, direction=120 , strength=3);
	width:800px;}
		
	.bouton {border-width=3pt;color:black;background-color:white;font-weight:bold;}
	-->
	</style></head>";

	print "<body background=../fond2.jpg link=white alink=white vlink=white><center><div class=ombre><font size=+5>Gestion des trolleys</font>";
}

