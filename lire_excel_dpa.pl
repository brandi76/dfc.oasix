#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
# use Spreadsheet::XLS;
use Math::Round;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";
my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/distrimarq_novembre_2017.xls");
$nb_feuille=$book->[0]{sheets};
 print $nb_feuille;
$i=1;
&save("create temporary table produit_dist (label varchar(40),ligne int(8),code_barre bigint(16),designation varchar(100),code_sap varchar(60),etat int(2),code_sap_old varchar(60), litrage varchar(30),prix decimal(8,2),prix_old decimal(8,2),code_dfc bigint(16),inode int(8),primary key(label,ligne))");
for ($i=0;$i<=$nb_feuille-1;$i++){
	$label=$book->[$i]{label};
	$nb_col=$book->[$i]{maxcol};
	$nb_ligne=$book->[$i]{maxrow};
	$colone=6;
	for ($l=1;$l<=$nb_ligne;$l++){
		$ref=$book->[$i]{cell}[2][$l];
		$code=$book->[$i]{cell}[11][$l];
		$designation=$book->[$i]{cell}[3][$l];
		$litrage=$book->[$i]{cell}[4][$l];
		$prix=$book->[$i]{cell}[6][$l];
		$prix=~s/,/\./g;
		$prix=round($prix*100)/100;
		$code_dfc=0;
		$ref_dfc=0;
		$prix_dfc=0;
		$code+=0;
		if ($code >100000 and $code <9999999999999){
			$etat=0;
			$query="select refour1,produit_inode.inode from produit_inode,produit_master where code_fournisseur1=1260 and produit_master.inode=produit_inode.inode and code='$code'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($refour1,$inode)=$sth->fetchrow_array){
				$code_dfc=$code;
				$inode_dfc=$inode;
				if (($refour1 ne $ref)&&($etat==0)){
					$etat=1;
					$prix_dfc=&get("select prac from produit_prac where inode=$inode order by date desc limit 1")+0;	
					$ref_dfc=$refour1;
				}	
				if ($refour1 eq $ref){$etat=2;$ref_dfc=$refour1;}	
			}
			if (grep /^CA/,$ref){
				$inode=&get_inode($code);
				$inode_dfc=$inode;
				$code_dfc=&get("select code from produit_inode where inode='$inode' and code <100000000");
				($pr_refour,$pr_prac)=&get("select pr_refour,pr_prac from dfc.produit where pr_cd_pr='$code_dfc'");
				$pr_prac/=100;
				$prix_dfc=$pr_prac;
				$ref_dfc=$pr_four;
				#compagnie aerienne
			}
			&save ("insert ignore into produit_dist value ('$label','$l','$code',\"$designation\",'$ref','$etat','$ref_dfc','$litrage','$prix','$prix_dfc','$code_dfc','$inode_dfc')");
		}	
	}
}
# print "<table border=1 cellspacing=0 ><tr><th>label</th><th>Code barre</th><th>Designation</th><th>Code sap</th><th>Code sap dfc</th><th>prix dfc</th><th>Code dfc</th></tr>";
# $query="select * from produit_dist order by label,ligne";
# $sth=$dbh->prepare($query);
# $sth->execute();
# while (($label,$ligne,$pr_cd_pr,$pr_desi,$code_sap,$etat,$code_sap_old,$litrage,$prix,$prix_dfc,$code_dfc)=$sth->fetchrow_array){
			# print "<tr><td>$label</td><td>$pr_cd_pr</td><td>$pr_desi $litrage</td><td>$code_sap</td><td>$code_sap_old</td><td>$prix</td><td>$prix_dfc</td><td>$code_dfc</td></tr>";
# }
# print "</table>";

print "<h3>produit avec ref sap different</h3>"; 
print "<table><tr><th>Code barre</th><th>Designation</th><th>Code sap nouveau</th><th>Code sap ancien</th></tr>";
$query="select * from produit_dist where etat=1 order by code_barre";
$sth=$dbh->prepare($query);
$sth->execute();
while (($label,$ligne,$pr_cd_pr,$pr_desi,$code_sap,$etat,$code_sap_old,$litrage,$prix,$prix_dfc,$code_dfc,$inode)=$sth->fetchrow_array){
			
			if ($inode<1){next;}
			print "<tr><td>$pr_cd_pr</td><td>$pr_desi $litrage</td><td>$code_sap</td><td>$code_sap_old</td><td>$inode</td>";
			$code_ar=&get("select pr_cd_pr from aircotedivoire.produit where pr_refour='$code_sap_old'");
			# if (($code_ar ne "")&&($code_sap_old ne "")){
				# print "<td>$code_ar</tD>";
			# }
			 print "<td>";
			 if (grep /^CA/,$code_sap){
		 		$pr_cd_pr=&get("select code from produit_inode where inode='$inode' and code <100000000");
				&save("update aircotedivoire.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
				&save("update camairco.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
				&save("update togo.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
				&save("update tacv.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
			}
			else{			
				&save("update dfc.produit_master set  refour1='$code_sap' where inode='$inode'","aff");
				&save("update corsica.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
				&save("update cameshop.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
				&save("update lome.produit set  pr_refour='$code_sap' where pr_cd_pr='$pr_cd_pr'","aff");
            print "</td>";
			}
			print "</tr>";
}
print "</table>";
# print "<h3>produit avec prix differents</h3>"; 
# print "<table><tr><th>Code barre</th><th>Designation</th><th>Prix nouveau</th><th>Prix ancien</th></tr>";
# $query="select * from produit_dist where etat=1 and prix!=prix_old order by code_barre";
# $sth=$dbh->prepare($query);
# $sth->execute();
# while (($pr_cd_pr,$pr_desi,$code_sap,$etat,$code_sap_old,$litrage,$prix,$prix_old)=$sth->fetchrow_array){
			# print "<tr><td>$pr_cd_pr</td><td>$pr_desi $litrage</td><td>$prix</td><td>$prix_old</td></tr>";
# }
# print "</table>";

# print "<h3>Produits inconnus</h3>"; 
# print "<table><tr><th>Code barre</th><th>Designation</th><th>Code sap</th></tr>";
# $query="select * from produit_dist where etat=0 order by code_barre";
# $sth=$dbh->prepare($query);
# $sth->execute();
# while (($pr_cd_pr,$pr_desi,$code_sap,$etat,$code_sap_old,$litrage,$prix,$prix_old)=$sth->fetchrow_array){
			# print "<tr><td>$pr_cd_pr</td><td>$pr_desi $litrage</td><td>$code_sap</td></tr>";
# }
# print "<table>";


