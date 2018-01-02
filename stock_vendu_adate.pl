#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
require "./outils_corsica.pl";
$html=new CGI;
print $html->header();
# $an=2016;
# foreach $base (@bases_client){
	# if ($base eq "dfc"){next;}
	# for ($mois=1;$mois<10;$mois++){
		# $query="select ro_cd_pr,sum(ro_qte)/100 from $base.vol,$base.rotation where ro_code=v_code and v_rot=1 and year(v_date_sql)=$an and month(v_date_sql)=$mois group by ro_cd_pr";
		# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $total=$sth->rows;
		# $nb=0;
		# while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
			# $pr_prac=&get("select pr_prac/100 from $base.produit where pr_cd_pr=$pr_cd_pr");
			# &save("insert ignore into dfc.vendu_mensuel values('$base','$an','$mois','$pr_cd_pr','0','$pr_prac')","af");
			# &save("update dfc.vendu_mensuel set qte=qte+$qte where base='$base' and an='$an' and mois='$mois' and code='$pr_cd_pr'","af");
			# $nb++;
			# $pour=int(10000*$nb/$total)/100;
		# }
		# print "$an $mois $base %\n";
	# }	
# }

# $an=2016;
# $base="cameshop";
# for ($mois=1;$mois<10;$mois++){
	# $query="select code,sum(qte) from cameshop.panier_caisse,cameshop.ticket_caisse_js where  ticket_pdv=pdv and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and year(ticket_date)='$an' and month(ticket_date)='$mois'  and ticket_sup=0 and vendeuse!='sylvain' group by code";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $total=$sth->rows;
	# $nb=0;
	# while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		# $pr_prac=&prac_cameshop($pr_cd_pr);
		# &save("insert ignore into dfc.vendu_mensuel values('$base','$an','$mois','$pr_cd_pr','0','$pr_prac')","af");
		# &save("update dfc.vendu_mensuel set qte=qte+$qte where base='$base' and an='$an' and mois='$mois' and code='$pr_cd_pr'","af");
	# }
	# print "$an $mois $base \n";
# }	

$an=2016;
$base="corsica";
for ($mois=1;$mois<10;$mois++){
	$query="select code,sum(qte) from $base.panier_caisse,$base.ticket_caisse where  ticket_pdv=pdv and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and year(ticket_date)='$an' and month(ticket_date)='$mois'  and ticket_sup=0 and vendeuse!='sylvain' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=$sth->rows;
	$nb=0;
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		$pr_prac=&prac_corsica($pr_cd_pr);
		&save("insert ignore into dfc.vendu_mensuel values('$base','$an','$mois','$pr_cd_pr','0','$pr_prac')","af");
		&save("update dfc.vendu_mensuel set qte=qte+$qte where base='$base' and an='$an' and mois='$mois' and code='$pr_cd_pr'","af");
	}
	print "$an $mois $base \n";
}	
sub prac_cameshop()
{
	my($code)=$_[0];
	my($prac)=0;
	my($four)=0;
	my($valeur)=0;
	my($sth)=$dbh->prepare("select pr_prac,pr_four from cameshop.produit where pr_cd_pr=$code");
	$sth->execute();
	($prac,$four)=$sth->fetchrow_array;
	$prac=$prac/100;
	my($query)="select valeur from cameshop.remise_four where four='$four' order by rang";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($valeur)=$sth->fetchrow_array){
		$prac=$prac-$valeur*$prac/100;
	}
    $prac=int($prac*100)/100;	
	return($prac);
}
sub prac_corsica()
{
	my($code)=$_[0];
	my($prac)=0;
	my($four)=0;
	my($valeur)=0;
	my($sth)=$dbh->prepare("select pr_prac,pr_four from corsica.produit where pr_cd_pr=$code");
	$sth->execute();
	($prac,$four)=$sth->fetchrow_array;
	$prac=$prac/100;
	my($query)="select valeur from corsica.remise_four where four='$four' order by rang";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($valeur)=$sth->fetchrow_array){
		$prac=$prac-$valeur*$prac/100;
	}
    $prac=int($prac*100)/100;	
	return($prac);
}
