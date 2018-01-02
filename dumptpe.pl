#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
print "<title>Dump tpe</title>";
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
if ($action eq ""){&premiere();}
if ($action eq "go"){
	$an=$mois%100+2000;
	$mois=int($mois/100)+100;
	$mois=substr($mois,1,2);
	$color="lightblue";
	$debut="$an"."-"."$mois"."-01";
	$fin="$an"."-"."$mois"."-31";
	&go();
}

sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";

}


sub go{
	print "<table border=1 cellspacing=1 cellpadding=1><tr><th>Date d'importation</th><th>Date de la transaction</th><th>type</th><th>Ticket</th><th>Désignation</th><th>valeur</th><th>tronçon</th></tR>";
	$query="select oa_date_import,oa_date,oa_type,oa_col1,oa_col2,oa_col3,oa_rotation from oasix where oa_date_import >='$debut' and oa_date_import<='$fin' order by oa_date_import,oa_serial,oa_rotation,oa_ind ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($oa_date_import,$oa_date,$oa_type,$oa_col1,$oa_col2,$oa_col3,$oa_rotation)=$sth->fetchrow_array)
	{
		$oa_rotation=substr($oa_rotation,5,1);
		if ($oa_type eq ""){next;}
		if ($oa_type eq "v"){next;}
		if ($oa_type eq "h"){
				$oa_type="Crew";
				$oa_col1="&nbsp;";
				$oa_col3="&nbsp;";
				}
		if (($oa_type eq "p")&&($oa_col3 <0)){$oa_type="Annulation";}
		if ($oa_type eq "p"){$oa_type="Vente";$oa_col3/=100}
		if ($oa_type eq "P"){$oa_type="Annulation";$oa_col3/=100}
		$tampon=$oa_col2;
		if (($oa_type eq "c")&&($oa_col3 == 0)){
			$oa_col2="Especes";
			}
		if (($oa_type eq "c")&&($oa_col3 == 1)){
			$oa_col2="Carte";
			}
		if (($oa_type eq "c")&&($oa_col3 == 2)){
			$oa_col2="diners";
			}
		if (($oa_type eq "c")&&($oa_col3 == 3)){
			$oa_col2="Am";
			}
		if (($oa_type eq "c")&&($oa_col3 == 4)){
			$oa_col2="Gratuite";
			}
		if (($oa_type eq "c")&&($oa_col3 == 5)){
			$oa_col2="Voucher $oa_col3";
			}
		if (($oa_type eq "c")&&($oa_col3 == 6)){
			$oa_col2="Master";
			}
		if ($oa_type eq "c"){
			$oa_type="Encaissement";
			$oa_col3=$tampon/100;
		}	
		$cle="$oa_serial.$oa_date_import.$oa_rotation";
		if ($cle ne $cleref){
				if ($color eq "white"){$color="lightblue";}
				else {$color="white";}
		}
		$cleref=$cle;
		while ($oa_col3=~s/\./,/){};

		print "<tr bgcolor=$color><td>$oa_date_import</td><td>$oa_date</td><td>$oa_type</td><td>$oa_col1</td><td>$oa_col2</td><td>$oa_col3</td><td>$oa_rotation</td></tr>";

			
	}
	print "</table>";
}	
