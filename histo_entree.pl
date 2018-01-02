#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();
$nocde=$html->param("nocde");
$four=$html->param("four");
$action=$html->param("action");
$prod=$html->param("prod");

  	print "<form><br><select name=four><option value=''></option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from ordre,fournis,produit where pr_cd_pr=ord_cd_pr and pr_four=fo2_cd_fo group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br><input type=hidden name=action value=creation><input type=submit value='Historique'></form>"; 

        $query="select pr_four,pr_cd_pr,pr_desi,enh_date,enb_qte from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and pr_four=$four order by enh_date desc"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table>";
	while (($pr_four,$pr_cd_pr,$pr_desi,$enh_date,$qte)=$sth->fetchrow_array){
	 	print &ligne_tab("",$pr_four,$pr_cd_pr,$pr_desi,&julian($enh_date),$qte);
	}
	print "</table>";
	
# -E historique des entrées fly 08/06	
