#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"00051623099.csv");
@liste_dat = <FILE1>;

close(FILE1);
($null,$date)=split(/;/,$liste_dat[0]);
if (! grep /200/,$liste_dat[0]){print "erreur importation";exit;}
($jour,$mois,$an)=split(/\//,$date);
$an=~ s/"//;
$an=substr($an,2,2);
$an*=100;
$mois+=$an;
&save("delete from comptes where co_mois=$mois","aff");

$i=0;
$query="select id,libelle from type";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$libelle)=$sth->fetchrow_array){
	print "$id $libelle<br>";
}

foreach (@liste_dat){
	chop($_);
	($date,$libelle,$detail,$montant)=split(/;/,$_);
	# &save("update navire2 set nav_qte='$qte' where nav_nom='MEGA 2' and nav_type=1 and nav_date='2006-04-06' and nav_cd_pr='$code'","aff");
	if (grep /\//,$date) {
		($jour,$null,$an)=split(/\//,$date);
		$an=~ s/"//;
		$an=substr($an,2,2);
		$an*=100;
		# $mois+=$an;
		$montant=~s/,/./;
		if ($montant<0){
			$sens="debit";	
			$montant=0-$montant;
		}
		else
		{ 
			$sens="credit";
		}
		# print "$montant $sens";
		$type=0;
		if (grep /ING DIRECT/,$detail){$type=14;}
		if (grep /RET\. DAB/,$detail){$type=13;}
		if (grep /RETRAIT DAB/,$detail){$type=13;}
		if (grep /RET ECLAIR/,$detail){$type=13;}
		if (grep /INTERMARCHE/,$detail){$type=1;}
		if (grep /ALDI/,$detail){$type=1;}
		if (grep /AUCHAN/,$detail){$type=1;}
		if (grep /LIDL/,$detail){$type=1;}
		if (grep /LECLERC/,$detail){$type=1;}
		if (grep /BRICO/,$detail){$type=9;}
		if (grep /BOUYGUES/,$detail){$type=19;}
		if (grep /ORANGE/,$detail){$type=19;}
		if (grep /STUDIO DE/,$detail){$type=18;}
		if (grep /STUDIOS LA/,$detail){$type=18;}
		if (grep /DONALD/,$detail){$type=2;}
		if (grep /SAPN/,$detail){$type=15;}
		if (grep /JEAN BART/,$detail){$type=15;}
		if (grep /CAFE DES VOY/,$detail){$type=15;}
		if (grep /DECATHLON/,$detail){$type=2;}
		if (grep /LUDIBUL/,$detail){$type=2;}
		if (grep /LITTLE BOUDHA/,$detail){$type=2;}
		if (grep /MAXI TOYS/,$detail){$type=2;}
		if (grep /GYMGLISH/,$detail){$type=2;}
		if (grep /HALLE/,$detail){$type=11;}
		if (grep /GEMO/,$detail){$type=11;}
		if (grep /PIMKIE/,$detail){$type=11;}
		if (grep /MIM DI/,$detail){$type=11;}
		if (grep /YVES ROCHER/,$detail){$type=2;}
		if (grep /TRESOR/,$detail){$type=8;}
		if (grep /MAAF/,$detail){$type=6;}
		if (grep /MAE VIE/,$detail){$type=6;}
		if (grep /CPAM/,$detail){$type=6;}
		if (grep /IMADIES/,$detail){$type=6;}
		if (grep /MACIF/,$detail){$type=5;}
		if (grep /CHEQUE/,$detail){$type=10;}
		if (grep /FERMIERE/,$detail){$type=17;}
		if (grep /ECHEANCE PRET/,$detail){$type=3;}
		if (grep /FRAIS RET EUR/,$detail){$type=12;}
		if (grep /PODOLOG/,$detail){$type=16;}
		if (grep /M.A.A.F/,$detail){$type=16;}
		if (grep /CAF DIEPPE/,$detail){$type=12;}
		if (grep /BGR/,$detail){$type=18;}
		if (grep /CASINOCAF/,$detail){$type=18;}
		if (grep /EDF/,$detail){$type=4;}
		if (grep /JOHANNA/,$detail){$type=7;}
		if (grep /AUTOROUTE/,$detail){$type=15;}
		if (grep /PHCIE/,$detail){$type=16;}
		if (grep /CINE DIEPPE/,$detail){$type=2;}
		if (grep /VENT D/,$detail){$type=2;}
		if (grep /CAMAIEU/,$detail){$type=2;}
		if (grep /QUICK/,$detail){$type=2;}
		if (grep /MACHIN CHOZ/,$detail){$type=11;}
		if (grep /PROMOD/,$detail){$type=11;}
		if (grep /CACHE-CACHE/,$detail){$type=11;}
		if (grep /CHAMPION/,$detail){$type=1;}
		if (grep /INTERM/,$detail){$type=1;}

        	
        	if ($type ==0) {print "$date,$libelle,$detail,$montant<br>";}
        	else
        	{ 	
        		&save("insert into comptes (co_mois,co_sens,co_type,co_val,co_part) values ('$mois','$sens','$type','$montant',0)","af");
			# print $query;
		}

		# print "<br>";
	}	
	

}