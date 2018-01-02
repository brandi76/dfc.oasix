#!/usr/bin/perl                                      
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;
$action=$html->param('action');
$proforma=$html->param('proforma');
$facture=$html->param('facture');
$ref=$html->param('ref');
$produit=$html->param('produit');

if ($action eq ""){
	
	print "<body><html><h1>Facture</h1>";

	print "<form>Proforma :<input type=text name=proforma> Facture:<input type=text name=facture> Ref:<input type=text name=ref> <input type=submit><input type=hidden name=action value=go></form></body></html>";
	$query="select ic2_no,ic2_cd_cl,ic2_com1,ic2_com2 from infococ2 where ic2_cd_cl!=500 order by ic2_no desc limit 60";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=0>";
	while (($ic2_no,$ic2_cd_cl,$ic2_com1,$ic2_com2)=$sth->fetchrow_array){
		print "<tr><td>$ic2_no $ic2_cd_cl $ic2_com1 $ic2_com2</td><td><a href=?action=modif&proforma=$ic2_no>modif</a></td></tr>";
	}
	print "<table>";

}
if (($action eq "prixn")||($action eq "prixr")||($action eq "prixrr")||($action eq "prixs")){
}

if ($action eq "modif"){
	&modif();
}
if ($action eq "go"){
	&go();
}

sub go(){
	$date=`/bin/date +%d/%m/%y`;
	print '<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body><div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy>email:ibsfrance@wanadoo.fr<br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 € TVA intracommunautaire FR79393966460</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>';

	print "<br><br><br><br><br><br><pre>";
	print "                                                  Dieppe le $date<br>";
	$query="select ic2_cd_cl,ic2_com1,ic2_com2 from infococ2 where ic2_no='$proforma'";
	# print $query;

	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2)=$sth->fetchrow_array;

	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	print "                                                  <b>$cl_nom</b><br>";
        print "                                                  $rue<br>";
        print "                                                  $ville<br>";
        print "                                                  $pays<br>";
        print "$ic2_com1 $ic2com2 <br>";
	print "$ref                                        <b>FACTURE N:$facture Commande:$proforma</b><br>";
	
	$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli where coc_no='$proforma'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Montant</th></tr>";
	
	while (($coc_cd_pr,$coc_qte,$coc_puni)=$sth->fetchrow_array){
	
		$query="select pr_desi from produit where pr_cd_pr='$coc_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi)=$sth2->fetchrow_array;
		$montant=$coc_puni*$coc_qte;
		print "<tr><td>$coc_cd_pr</td><td>$pr_desi</td><td align=right>$coc_qte</td><td align=right>";
		print &deci2($coc_puni);
		print "</td><td align=right>";
		print &deci2($montant);
		$total+=$montant;
		print "</td></tr>";
	}
	print "<tr><td colspan=4><b>TOTAL HT</td><td align=right><b>";
	print &deci2($total);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TVA</td><td align=right><b>";
	print &deci2($total*19.6/100);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TOTAL TTC</td><td align=right><b>";
	print &deci2($total*1.196);
	print "</td></tr>";
	
	print "</table>";
	
}
sub modif(){
	print "<html ><body>";

	$query="select ic2_cd_cl,ic2_com1,ic2_com2 from infococ2 where ic2_no='$proforma'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($ic2_cd_cl,$ic2_com1,$ic2_com2)=$sth->fetchrow_array;

	$query="select cl_nom,cl_add from client where cl_cd_cl='$ic2_cd_cl'";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_add)=$sth->fetchrow_array;
	($rue,$ville,$pays)=split(/\*/,$cl_add);
	
	$query="select coc_cd_pr,coc_qte/100,coc_puni/100 from comcli where coc_no='$proforma'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "      <table border=1 cellspacing=0 width=600><tr bgcolor=#efefef ><th>code </th><th>Désignation</th><th>Qte</th><th>Prix</th><th>Montant</th></tr>";
	
	while (($coc_cd_pr,$coc_qte,$coc_puni)=$sth->fetchrow_array){
		$query="select pr_desi from produit where pr_cd_pr='$coc_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi)=$sth2->fetchrow_array;
		$montant=$coc_puni*$coc_qte;
		print "<tr><td>$coc_cd_pr</td><td>$pr_desi</td><td align=right>$coc_qte</td><td align=right>";
		print &deci2($coc_puni);
		print " <a href=?action=prixn&proforma=$proforma&produit=$coc_cd_pr>Prix normal</a> <a href=?action=prixr&proforma=$proforma&produit=$coc_cd_pr>- 30%</a><a href=?action=prixrr&proforma=$proforma&produit=$coc_cd_pr>- 20%</a><a href=?action=prixs&proforma=$proforma&produit=$coc_cd_pr> +10%</a></td><td align=right>";
		print &deci2($montant);
		$total+=$montant;
		print "</td></tr>";
	}
	print "<tr><td colspan=4><b>TOTAL HT</td><td align=right><b>";
	print &deci2($total);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TVA</td><td align=right><b>";
	print &deci2($total*19.6/100);
	print "</td></tr>";
	print "<tr><td colspan=4><b>TOTAL TTC</td><td align=right><b>";
	print &deci2($total*1.196);
	print "</td></tr>";
	
	print "</table><br><a href=facture.pl>retour</a>";
	
}


		
	
# -E Facture