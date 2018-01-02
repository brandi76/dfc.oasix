#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$trolley=$html->param("trolley");

require "./src/connect.src";
                
if ($trolley eq ""){
	print "<form> trolley <input type=text name=trolley><input type =submit></form>";
}
else
{

$query="select tr_ordre,pr_type,tr_cd_pr,ucase(left(pr_desi,1)),lcase(substring(pr_desi,2,15)),floor(tr_prix/100) from trolley ,produit,produit_plus where tr_code='$trolley' and produit.pr_cd_pr=produit_plus.pr_cd_pr and tr_cd_pr=produit.pr_cd_pr order by pr_famille,pr_desi";
$sth=$dbh->prepare($query);
$sth->execute;
while (($tr_ordre,$pr_type,$pr_cd_pr,$pr_deb,$pr_desi,$pr_prix)=$sth->fetchrow_array){
 	$pr_desi=$pr_deb.$pr_desi;
	if (grep /Cobra/,$pr_desi){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
		$pr_desi=~s/HOMME/H/;
		$pr_desi=~s/FEMME/F/;
		$pr_desi=~s/MONTRE//;
		$pr_desi=uc(substr($pr_desi,0,1)).lc(substr($pr_desi,1,15));
	}
	if (grep /Time force/,$pr_desi){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
		$pr_desi=~s/MONTRE//;
		$pr_desi=uc(substr($pr_desi,0,1)).lc(substr($pr_desi,1,15));
	}
	if (grep /guilty/,$pr_desi){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
		$pr_desi=~s/GUILTY//;
		$pr_desi=uc(substr($pr_desi,0,1)).lc(substr($pr_desi,1,15));
	}
       	if ($pr_cd_pr==280120){ $pr_desi="Khol noir";}
       	if ($pr_cd_pr==280138){ $pr_desi="Ter.Light powd";}
       	if ($pr_cd_pr==280175){ $pr_desi="Ter.Duo Gloss";}
      
        if (grep /$pr_desi/,@liste){
        print "<b>";
        }
        
 	push (@liste,$pr_desi);
 	if ($pr_cd_pr==800150){next;}

 	if ($pr_type==1 ){$type=1;
		$famille=&get("select pr_famille from produit_plus where pr_cd_pr='$pr_cd_pr'");
		if ($famille ==3){$type=2;}
	}
 	if ($pr_type==3){$type=0;}
 	if ($pr_type==2){$type=3;}
 	if ($pr_type==5){$type=4;}
 	if ($pr_type==4){$type=5;}
 	
 	if ($pr_cd_pr==800200){
 		$query="select pr_cd_pr,ucase(left(pr_desi,1)),lcase(substring(pr_desi,2,15)),floor(po_prix/100) from pochon,produit where po_cd_pr=pr_cd_pr";
 		$sth5=$dbh->prepare($query);
 		$sth5->execute();
 		while (($po_cd_pr,$po_deb,$po_desi,$po_prix)=$sth5->fetchrow_array){
 			$po_desi=$po_deb.$po_desi;
 			print "5;$po_desi;$po_prix;1;<br>";
 			&save("replace into oasix_prod values ('$po_cd_pr','$po_desi')");
 		}
 	}
 	else
 	{
		if ($pr_cd_pr==800201){$type=4;$pr_desi="Lunette";$pr_prix=15;}
		$desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
        	# print "$pr_cd_pr $desi ";
		print "$type;$pr_desi;$pr_prix;1;</b><br>";
		&save("delete from oasix_prod where oa_cd_pr='$pr_cd_pr'");
		&save("replace into oasix_prod values ('$pr_cd_pr','$pr_desi')","af");

 	}
}
}