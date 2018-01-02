#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$trolley=$html->param("trolley");
require "./src/connect.src";
# $trolley=18691;

if ($trolley eq ""){
	print "<form>Trolley <input type=text name=trolley value=2000><input type=submit></form>";
}
else
{
$query="select produit.pr_cd_pr,left(pr_desi,15), tr_prix/100,pr_famille,tr_ordre,pr_codebarre from produit,trolley,produit_plus  where tr_code='$trolley' and tr_cd_pr=produit.pr_cd_pr and produit.pr_cd_pr=produit_plus.pr_cd_pr order by pr_famille,tr_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_prix,$cat,$ordre,$barre)=$sth->fetchrow_array){
	$pr_desi=lc($pr_desi);
	$pr_desi=ucfirst($pr_desi);
	$pr_desi=~s/\&//g;
	$pr_famille=$cat;
	$pr_prix=int($pr_prix);
	if ($cat==9){$cat=4;}
	elsif ($cat==3){$cat=1;}
	elsif ($cat==5){$cat=2;}
	elsif ($cat==4){$cat=3;}
	elsif ($cat==6){$cat=3;}
	elsif ($cat==0){$cat=3;}
	elsif ($cat==1){$cat=0;}
	elsif ($cat==15){$cat=4;}
	elsif ($cat==22){$cat=4;}
	elsif ($cat==21){$cat=3;}
	else {$cat=3;}
	$desi="Inconnu $pr_famille";
	if ($cat==0){$desi="Parfum Femme";}
	if ($cat==1){$desi="Parfum Homme";}
	if ($cat==2){$desi="Cosmetique";}
	if ($cat==3){$desi="Accessoire";}
	if ($cat==4){$desi="Cigarette";}
	print "$desi: $pr_cd_pr $pr_desi<br>;"
}
}