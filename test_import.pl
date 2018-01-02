#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;
$four=$html->param('fourni');
$val=$html->param('val');
(@tab)=split(/\n/,$val);
print "A partir d'un fichier excel comportant ces colonnes, faire un copier coller dans la zone ci_dessous et valider<br>";
print "<table border=1 bgcolor=yellow><tr><th>Type <br> 1 parfum 2 cosmetique</th><th>Code barre</th><th>réference fournisseur</th><th>désignation <br>sans accent ni ponctuation</th><th>packing</th><th>prix public</th><th>prix achat bateau</th><th>prix de vente bateau</th><th>prix achat avion</th><th>prix de vente avion</th></tr></table>";

foreach (@tab){
	($type,$barre,$codefo,$designation,$packing,$prixpub,$prixachatb,$prixventeb,$prixachata,$prixventea)=split(/\t/,$_);
	while ($barre=~s/ //){};
	# print "<font color=red>$_</font><br>";
	if (($type eq "")||($designation eq "")){
		print "Champ type ou désignation non renseigné";
		exit;
	}			
	if (! checkcode($barre)){
		print "Code barre $barre erronée";
		exit;
	}			
	if ($four<1000){
		print "Code Fournisseur erronée";
		exit;
	}			

	$prixpub*=100;
	$prixachatb*=100;
	$prixventeb*=100;
	$prixachata*=100;
	$prixventea*=100;
	if ($type==1){$ventil=20;$ndp='330300900000J';}
	if ($type==2){$ventil=21;$type=5;$ndp='330491000000Y';}
	$query="select * from produit where pr_cd_pr='$barre'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	(@table)=$sth->fetchrow_array;
	if ($table[0] eq "")
	{
		$query="replace into produit values ('$barre','$designation','0','0','0','$ndp','$ventil','0','$type','$prixachatb','0','0','0','$prixventea','0','0','0','0','0','0','1','12','UNIT','$fourni','$codefo','$barre')";
		# print "$query<br>";
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "<font color=green>$barre $designation créé</font><br>";

	}
	else
	{
		print "<font color=red>$barre $designation déjà existant</font><br>";
	}
	if ($packing>0){
		$query="replace into carton values ('$barre','$packing','0')";
		# print "$query<br>";
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	$query="replace into prixpr values ('$barre','$prixpub','$prixventeb','$prixventea','$prixachata','$prixachatb')";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();

}
print print "<form method=post>Choix du fournisseur <select name=fourni>";
$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from ordre,fournis,produit where pr_cd_pr=ord_cd_pr and pr_four=fo2_cd_fo group by fo2_cd_fo");
$sth2->execute;
while (my @four = $sth2->fetchrow_array) {
	next if $four eq $four[0];
	($four[1])=split(/\*/,$four[1]);
	print "<option value=\"$four[0]\">$four[0] $four[1]\n";
}
print "</select>";
print "<textarea cols=100 rows=20 name=val></textarea><input type=submit></form>";

sub checkcode
{
	my ($pr_codebarre)=@_[0];
	my ($check)=$pr_codebarre%10;
	my ($oper)=1;
	my ($somme)=0;
	my ($digit)=0;
	for (my($i)=12;$i>0;$i--){
		$digit=int($pr_codebarre/10**$i)%10;
		$somme+=$digit*$oper;
		if ($oper==1){$oper=3;}else{$oper=1;}
	}
	$somme%=10;
	$somme=(10-$somme)%10;
	if ($check!=$somme){return(0);}
	else {return(1);}
}