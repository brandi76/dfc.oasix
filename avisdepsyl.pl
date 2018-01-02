#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

$datesimple="1".substr($an,2,2).$mois.$jour;
print $html->header;
$appro="22205";
$fl_troltype=506;
require "./src/connect.src";
$query="select tr_ordre,tr_cd_pr,tr_qte,tr_prix from trolley where tr_code='$fl_troltype' order by tr_ordre";
$sth2=$dbh->prepare($query);
$sth2->execute();
# boucle sur trolley
while (($tr_ordre,$tr_cd_pr,$tr_qte,$tr_prix)=$sth2->fetchrow_array){
	 $query="select ecr_qte from ecartrolsyl where ecr_cdtrol='$fl_troltype' and ecr_cd_pr='$tr_cd_pr'";
	 $sth3=$dbh->prepare($query);
	 $sth3->execute();
	 ($ecr_qte)=$sth3->fetchrow_array;
	 if ($ecr_qte ne ''){$tr_qte=$ecr_qte;}
	# maj appro
	$query="replace into appro values('$appro','$tr_ordre','$tr_cd_pr','$tr_prix','$tr_qte','2','$fl_cd_cl')";
	&execute();
	$cree++;
	# maj produit
	$query="update produit set pr_stvol=pr_stvol+$tr_qte where pr_cd_pr='$tr_cd_pr'";
	&execute();
	# maj sortie
	$query="replace into sortie values('$tr_cd_pr','$appro','$tr_qte')";
	print "$query<br>";
	&execute();
	if (($tr_cd_pr==800201)&&($tr_qte!=0)){ # lunette
		# maj appro
		$query="replace into appro values('$appro','3605','230502','1500','1200','2','$fl_cd_cl')";
		&execute();
		# maj produit
		$query="update produit set pr_stvol=pr_stvol+1200 where pr_cd_pr='230502'";
		&execute();
		# maj sortie
		$query="replace into sortie values('230502','$appro','1200')";
		&execute();
	}
	if (($tr_cd_pr==800200)&&($tr_qte!=0)){ # bijoux
		$query="select * from pochon";
		$sth5=$dbh->prepare($query);
		$sth5->execute();
		while (($po_ordre,$po_cd_pr,$po_qte,$po_prix)=$sth5->fetchrow_array){
			# maj appro
			$query="replace into appro values('$appro','$po_ordre','$po_cd_pr','$po_prix','$po_qte','2','$fl_cd_cl')";
			&execute();
			# maj produit
			$query="update produit set pr_stvol=pr_stvol+$po_qte where pr_cd_pr='$po_cd_pr'";
			&execute();
			# maj sortie
			$query="replace into sortie values('$po_cd_pr','$appro','$po_qte')";
			&execute();
		}	
	}
}	
