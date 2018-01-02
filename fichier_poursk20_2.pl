#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$trolley=$html->param("trolley");
$trolley2=$html->param("trolley2");
require "./src/connect.src";
# $trolley=18691;

if ($trolley eq ""){
	print "<form>Trolley <input type=text name=trolley value=2000> trolley cfa <input type=text name=trolley2 > <input type=submit></form>";
}
else
{
print  "<pre>";
$query="select produit.pr_cd_pr,left(pr_desi,15), tr_prix/100,pr_famille,tr_ordre,pr_codebarre from produit,trolley,produit_plus  where tr_code='$trolley' and tr_cd_pr=produit.pr_cd_pr and produit.pr_cd_pr=produit_plus.pr_cd_pr order by pr_type,tr_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_prix,$cat,$ordre,$barre)=$sth->fetchrow_array){
	$pr_desi=lc($pr_desi);
	$pr_desi=ucfirst($pr_desi);
	$pr_desi=~s/\&//g;
	print "tx.executeSql('INSERT  INTO PRODUIT (produit_id, cat,desi,prix0,prix1,barrecode) VALUES (";
	$pr_prix=int($pr_prix);
	if ($cat==9){$cat=4;}
	elsif ($cat==3){$cat=1;}
	elsif ($cat==5){$cat=2;}
	elsif ($cat==4){$cat=3;}
	elsif ($cat==6){$cat=3;}
	elsif ($cat==0){$cat=3;}
	elsif ($cat==1){$cat=0;}
	elsif ($cat==15){$cat=4;}
	elsif ($cat==22){$cat=5;}
	elsif ($cat==21){$cat=3;}
	elsif ($cat==24){$cat=5;}
	elsif ($cat==16){$cat=5;}
	else {$cat=3;}
	$pr_prix0=$pr_prix;
	$pr_prix1=&get("select tr_prix/100 from trolley where tr_code='$trolley2' and tr_cd_pr=$pr_cd_pr")+0;
	if ($pr_prix1==0) {
		$pr_prix1=int($pr_prix*659/1000)*1000;
	}
	print  "$pr_cd_pr,\"";
	print  "$cat\",\"";
	print  "$pr_desi\",";
	print  "$pr_prix0,";
	print  "$pr_prix1,\"";
	print  "$barre\")',[],nullDataHandler, errorHandler);\n";
}
# print "<a href=http://togo.oasix.fr/sk20.xml>fichier créé </a>";
}