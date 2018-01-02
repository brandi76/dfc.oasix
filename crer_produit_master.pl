#!/usr/bin/perl
use CGI;
use DBI();
       
$html=new CGI;
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
=pod
$query="select * from produit_master";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$designation1,$code_chapitre,$famille,$degree,$poids_net,$poids_brut,$conditionnement,$code_fournisseur1,$refour1,$litrage,$concentration)=$sth->fetchrow_array){
	$code_barre=&get("select pr_codebarre from produit where pr_cd_pr='$inode'");
	&save("insert into produit_master2 (designation1,code_chapitre,famille,degree,poids_net,poids_brut,conditionnement,code_fournisseur1,refour1,litrage,concentration) values (\"$designation1\",'$code_chapitre','$famille','$degree','$poids_net','$poids_brut','$conditionnement','$code_fournisseur1','$refour1','$litrage','$concentration')","aff");
	$inode=&get("SELECT LAST_INSERT_ID() FROM produit_master2");
	&save("insert ignore into produit_inode values ('$code','$inode')");
	if ($code_barre!=0){
		&save("insert ignore into produit_inode values ('$code','$inode')");
	}
}
$query="select pr_codebarre,inode from produit,produit_inode where pr_cd_pr=code";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$inode)=$sth->fetchrow_array){
&save("insert ignore into produit_inode values ('$code','$inode')","aff");}
=cut;


$query="select pr_cd_pr,pr_desi,pr_pdn,pr_pdb,pr_douane,pr_deg,pr_four,pr_refour from corsica.produit";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$designation1,$poids_net,$poids_brut,$code_chapitre,$degree,$code_fournisseur1,$refour1)=$sth->fetchrow_array){
    $inode=&get("select inode from dfc.produit_inode where code='$code'");
	$marque=&get("select marque from corsica.produit_desi where code='$code'");
	$famille=&get("select pr_famille from corsica.produit_plus where pr_cd_pr='$code'");
	$litrage=0;
	$conditionnement=&get("select car_carton from corsica.carton where car_cd_pr='$code'");
	if ($inode eq ""){
		&save("insert into dfc.produit_master (designation1,code_chapitre,famille,degree,poids_net,poids_brut,conditionnement,code_fournisseur1,refour1,litrage,concentration) values (\"$designation1\",'$code_chapitre','$famille','$degree','$poids_net','$poids_brut','$conditionnement','$code_fournisseur1','$refour1','$litrage','$concentration')","aff");
		$inode=&get("SELECT LAST_INSERT_ID() FROM dfc.produit_master");
		&save("insert ignore into dfc.produit_inode values ('$code','$inode')");
	}
	else {
		#&save("update dfc.produit_master set marque=\"$marque\",conditionnement='$conditionnement',famille='$famille' where inode='$inode'");
	}
print "$code $inode<br>";	
}
