#!/usr/bin/perl
use DBI();
use CGI();
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
$html=new CGI;
print $html->header();

&param();
print "<form>";
&form_hidden();
print "No de liste";
print "<input name=liste>
<input type=submit>
</form>";
if ($liste ne ""){
	$query="select * from suivi_importation where id='$liste'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($id,$date,$nom,$libelle,$action,$base)=$sth->fetchrow_array){
		 print "$libelle";
		 foreach (split(/:/,$base)){
		 		push (@base_tmp,(&get("select base_lib from base where base_id=$_")));
		}		
	}
	foreach $base (@base_tmp){
		&save("update dfc.suivi_importation_prac set fait=curdate() where id='$liste'","aff");
		
		$query="select inode,prac from produit_prac where id=$liste";
		$sth = $dbh->prepare($query);
		$sth->execute;
		while (($inode,$prac) = $sth->fetchrow_array) {
			#if ($base eq "dutyfreeambassade"){
				$code=&get("select produit_web.code from dutyfreeambassade.produit_web,produit_inode where produit_inode.code=produit_web.code and inode=$inode","af");
				print "$code $prac<br>";
				# &save("update dutyfreeambassade.produit_four set prix_unite='$prac' where ref_dfa='$code'","aff");
				
			#}	
		}
	}	
}