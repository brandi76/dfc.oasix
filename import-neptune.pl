#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
print $html->header;
open(FILE1,"neptune.csv");
@liste_dat = <FILE1>;
close(FILE1);



foreach (@liste_dat){
	chop($_);
	# print $_;
	($numero,$Code_Barre,$Libelle,$null,$Prix_Achat,$Prix_vente)=split(/;/,$_);
	if ($Code_Barre eq ""){next;}
	print "$Code_Barre<br>";
	if (grep (/\//,$Code_Barre)){next;}
 	print "*";
	while($Libelle=~s/\'//){};
	$Prix_vente=~s/,/./;
	$Prix_Achat=~s/,/./;

	$Prix_Achat*=100;
	$Prix_vente*=100;
	$aprixv=&get("select nep_prx_vte from neptune where nep_cd_pr='$numero'");
	$aprixa=&get("select nep_prac from neptune where nep_cd_pr='$numero'");
	
	# $desi=&get("select nep_desi from neptune where nep_cd_pr='$numero'");

	print "$Code_Barre $Prix_vente  $aprixv $desi<br>";
	if (($Prix_Achat!=$aprixa)||($Prix_vente!=$aprixv)){
		&save("replace into neptune values ('$numero','$Code_Barre','$Libelle','$Prix_Achat','$Prix_vente')","aff");
        }
	$nb=&get("select count(*) from neptune where nep_codebarre='$Code_Barre'")+0;
	if ($nb==0){
		&save("replace into neptune values ('$numero','$Code_Barre','$Libelle','$Prix_Achat','$Prix_vente')","aff");
        }
	
}


=pod	
	($numero,$Code_Barre,$Libelle,$Libelle_Caisse,$Creation,$Modif,$Famille,$Sous_Fami,$SS_Fam,$Type,$Code_Tva,$Prix_vente,$Code_Unite_Vente,$Type_de_prix,$Depot_vente,$Num_comment,$Num_Fournisseur,$Code_Four,$Code_Unite_Achat,$Coef,$Prix_Achat,$PAMP,$Condit,$Numero_Depot,$Code_Unite_Stock,$Suivi_Cmde,$Qte_Mini,$tPrdt_Transforme_,$Marge)=split(/;/,$_);
	if ($Code_Barre eq ""){next;}
	while($Libelle=~s/\'//){};
	$Prix_Achat=~s/,/\./;
	if ($Prix_Achat eq ''){next;}
       $Prix_vente=~s/,/\./;
	$Prix_Achat*=100;
	$Prix_vente*=100;
	# $prix=&get("select nep_prx_vte from neptune where nep_cd_pr='$numero'");
	# $desi=&get("select nep_desi from neptune where nep_cd_pr='$numero'");

	# print "$Code_Barre $Prix_vente  $prix $desi<br>";
	&save("replace into neptune values ('$numero','$Code_Barre','$Libelle','$Prix_Achat','$Prix_vente')","aff");
}
