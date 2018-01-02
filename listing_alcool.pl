#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser); 
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header;
require "./src/connect.src";
print "<title>Listing alcool</title><body>";
$index=$html->param("index");
$action=$html->param("action");
$stock=$html->param("stock");
$carton=$html->param("carton")+0;
$pal=$html->param("pal")+0;
$produit=$html->param("produit");
$aux=$html->param("aux");

if ($index eq ""){$index=0;}

if ($action eq ""){
	$query="select pr_cd_pr,pr_desi,pr_deg/100,pr_pdn/1000,floor((pr_stre+pr_diff)/100),pr_prac/100 from produit where pr_ventil=6  and (pr_stre+pr_diff )!=0  and pr_cd_pr>1000000 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_deg,$pr_pdn,$pr_stre,$pr_prx_rev)=$sth->fetchrow_array){
		$res=&get("select count(*) from trolley,lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr='$pr_cd_pr'");
		if ($res >0) {next; }
		$query="select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton,$pal)=$sth2->fetchrow_array;
		$index++;
		print "$index;$pr_cd_pr;$pr_desi;$pr_pdn;$pr_deg;($carton,$pal);<b>$pr_stre</b>;$pr_prx_rev;";
		$nbcarton=$nbpack=$detail=0;
		
		if ($carton!=0){$nbcarton=int($pr_stre/$carton);}
		if ($pal!=0){$nbpack=int(($pr_stre-($nbcarton*$carton))/$pal);}
		$detail=$pr_stre-($nbcarton*$carton)-($nbpack*$pal);
		$flag=&get("select count(*) from auxiga where aux_cd_pr='$pr_cd_pr'");
		if ($flag>0){$flag="aux";}else{$flag="";}
		print "($nbcarton,$nbpack,$detail);$flag<br>";
	
	}
	$query="select pr_cd_pr,pr_desi,pr_deg/100,pr_pdn/1000,floor((pr_stre+pr_diff)/100) from produit where pr_ventil=6 and pr_cd_pr<=1000000 and (pr_stre+pr_diff )!=0  and pr_cd_pr not in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1) order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_deg,$pr_pdn,$pr_stre)=$sth->fetchrow_array){
		$res=&get("select count(*) from trolley,lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr='$pr_cd_pr'");
		if ($res >0) {next; }
		$query="select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton,$pal)=$sth2->fetchrow_array;
		$index++;
		print "$index;$pr_cd_pr;$pr_desi;$pr_pdn;$pr_deg;($carton,$pal);<b>$pr_stre</b>;";
		$nbcarton=$nbpack=$detail=0;
		
		if ($carton!=0){$nbcarton=int($pr_stre/$carton);}
		if ($pal!=0){$nbpack=int(($pr_stre-($nbcarton*$carton))/$pal);}
		$detail=$pr_stre-($nbcarton*$carton)-($nbpack*$pal);
		$flag=&get("select count(*) from auxiga where aux_cd_pr='$pr_cd_pr'");
		if ($flag>0){$flag="aux";}else{$flag="";}
		print "($nbcarton,$nbpack,$detail);$flag<br>";
	
	}
	print "*******************<br>";
	$query="select pr_cd_pr,pr_desi,pr_deg/100,pr_pdn/1000,floor((pr_stre+pr_diff)/100) from produit where pr_ventil=6 and pr_cd_pr<=1000000  and pr_cd_pr in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1) order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_deg,$pr_pdn,$pr_stre)=$sth->fetchrow_array){
		$ecart = &get("select sum(erdep_qte) from errdep where erdep_cd_pr=$pr_cd_pr");
		print "$pr_cd_pr;$pr_desi;$ecart;$pr_pdn;$pr_deg;<br>";
	}


}
if ($action eq "modif"){
	if ($produit ne "") {
		if ($carton>0 || $pal>0){
			&save("replace into carton values ('$produit','$carton','$pal')","aff");
			
		}
		$stock_data=&get("select floor((pr_stre+pr_diff)/100) from produit where pr_cd_pr='$pr_cd_pr'");
		if ($stock!=$stock_data){
			&save("update produit set pr_diff=$stock*100-pr_stre where pr_cd_pr='$produit'","aff");
		}
		
	}	
}	
if (($action eq "modif")||($action eq "suivant")){

  	$query="select pr_cd_pr,pr_desi,pr_deg/100,pr_pdn/1000,floor((pr_stre+pr_diff)/100) from produit where pr_cd_pr='$produit'";

#  	$query="select pr_cd_pr,pr_desi,pr_deg/100,pr_pdn/1000,floor((pr_stre+pr_diff)/100) from produit where pr_ventil=6 and pr_cd_pr>1000000 and pr_cd_pr not in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1) order by pr_cd_pr limit $index,1";
#  	if ($index>222){
#  		$index2=$index-223;
#  		$query="select pr_cd_pr,pr_desi,pr_deg/100,pr_pdn/1000,floor((pr_stre+pr_diff)/100) from produit where pr_ventil=6 and pr_cd_pr<=1000000 and pr_cd_pr not in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1) order by pr_cd_pr limit $index2,1";
#  	}

	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_cd_pr,$pr_desi,$pr_deg,$pr_pdn,$pr_stre)=$sth->fetchrow_array;
	$index++;
	print "$pr_cd_pr;$pr_desi;$pr_pdn;$pr_deg;$pr_stre<br>";
	print "<form><input type=hidden name=index value=$index>";
	print "<input type=hidden name=action value=modif>";
	$query="select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($carton,$pal)=$sth->fetchrow_array;
	print "carton <input type=text name=carton value='$carton'> ";
	print "pal <input type=text name=pal value='$pal'> ";
	print "stock <input type=text name=stock value='$pr_stre'> ";
	print "stock <input type=hidden name=produit value='$pr_cd_pr'> ";
	print "<br><Input type=checkbox name=aux>";
	print "<br><input type=submit></form>";
	print "<form><input type=hidden name=index value=$index>";
	print "<input type=hidden name=action value=suivant>";
	print "<br><input type=submit value=suivant></form>";

}