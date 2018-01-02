#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
$premiere="2015-09-01";
$derniere="2015-10-01";
$vendeuse="%";
$caht=&get("select sum(priht*qte) from corsica.panier_caisse,corsica.ticket_caisse where date>='$premiere' and date<'$derniere' and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and vendeuse like '$vendeuse'","af");
$cattc=&get("select sum(qte*(prix-ticket_remise_pour*prix/100)) from corsica.panier_caisse,corsica.ticket_caisse where date>='$premiere' and date<'$derniere' and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and vendeuse like '$vendeuse'","af");
$cattc2=&get("select sum(ticket_montant) from corsica.ticket_caisse where ticket_date>='$premiere' and ticket_date<'$derniere' and ticket_vendeuse!='sylvain' and ticket_sup=0 and ticket_vendeuse like '$vendeuse'","af");
$cat2=&get("select sum(qte*(prix-ticket_remise_pour*prix/100)) from corsica.famille,corsica.produit_plus,corsica.panier_caisse,corsica.ticket_caisse where date>='$premiere' and date<'$derniere' and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and code=pr_cd_pr and fa_id=pr_famille and fa_taux=2.1  and vendeuse like '$vendeuse'","af");
$cat20=$cattc2-$cat2;
$cat2ht=$cat2*100/(100+2.1);
$cat20ht=$cat20*100/(100+20);

print "priht:$caht<br>cattc:$cattc<br>detail:$cattc<br>ticket:$cattc2<br>caht2.1 $cat2ht<br>caht20:$cat20ht";

$query="select ticket_date,ticket_montant,ticket_vendeuse,ticket_no,ticket_remise_pour from corsica.ticket_caisse where ticket_date>='$premiere' and ticket_date<'$derniere' and ticket_vendeuse!='sylvain' and ticket_sup=0 and ticket_vendeuse like '$vendeuse' order by ticket_date,ticket_vendeuse";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ticket_date,$ticket_montant,$ticket_vendeuse,$ticket_no,$ticket_remise)=$sth->fetchrow_array){
    $query="select code,qte,prix from corsica.panier_caisse where vendeuse='$ticket_vendeuse' and date='$ticket_date' and no_cde='$ticket_no' ";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($code,$qte,$prix)=$sth2->fetchrow_array){
		$taux=&get("select fa_taux from corsica.famille,corsica.produit_plus where fa_id=pr_famille and pr_cd_pr='$code'");
		# print "$ticket_vendeuse;$ticket_date;$code;$qte;$prix;$ticket_remise;$taux<br>";
	}	
}