#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$ic2_no=$html->param("prem");
$option=$html->param("option");

print "<title> correction de facture</title>";
# print "*** $retour $action ****";
require "./src/connect.src";


if ($action eq ""){
	print "<form>
	commande <input type=text name=prem> <br>
	<input type=hidden name=action value=go>
<bR>	
option <input type=text name=option> <br>
	  
<input type=submit>
	</form>";
}
if ($action eq "go"){
	$query="select pr_cd_pr,pr_desi from comcli,produit where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr=pr_cd_pr and pr_desi not like 'TEST%'";
        $sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
	       print "$pr_cd_pr,$pr_desi <br>";
        } 
	print "<form>
	<input type=hidden name=prem value=$ic2_no>
	<input type=hidden name=action value=go2>
<input type=hidden name=option value='$option'>
		
<input type=submit value=modif>
	</form>";
}
if ($action eq "go2"){
	$query="select pr_cd_pr,pr_prx_vte from comcli,produit where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr=pr_cd_pr and pr_desi not like 'TEST%'";
        $sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$prix)=$sth->fetchrow_array){
	   $prix/=2;
	   if ($prix==0){
# 	   $flag=&get("select count(*) from prix311208 where code=$pr_cd_pr","aff")+0;
# 	   if ($flag==0){
	     $prix=&get("select nep_prac from neptune where nep_codebarre=$pr_cd_pr","aff")+0;
# 	   }
	   }
	  if ($option eq "miss" ){   
	      if ($pass eq ""){
         		$no_fact=&get("select dt_no from atadsql where dt_cd_dt=111")+1;
		   	&save("update atadsql set dt_no='$no_fact' where dt_cd_dt=111");
		 &save("update infococ2 set ic2_com3=\"$no_fact\"  where ic2_no=$ic2_no","aff");
		         $pass=1;

	       }
              &save("update comcli set coc_puni=$prix,coc_in_pos=6  where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr='$pr_cd_pr'","aff");
	  }
	  else
          {

	       &save("update comcli set coc_puni=$prix  where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr='$pr_cd_pr'","aff");
	
       }
        } 
	print "fin";

}
