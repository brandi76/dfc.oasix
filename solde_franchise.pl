#!/usr/bin/perl
use CGI; 
require 'manip_table.lib';
require 'outils_perl.lib';
$html=new CGI;
print $html->header;
open(FILE1,"/home/var/spool/uucppublic/client2.txt");
@client_dat = <FILE1>;
close(FILE1);    

%impfran_idx= &get_index_multiple("impfran",0);
open(FILE,"/home/var/spool/uucppublic/impfran.txt");
@impfran_dat = <FILE>;
close(FILE);
%tel_idx= &get_index_num("telephone",0);
open(FILE,"/home/var/spool/uucppublic/telephone.txt");
@tel_dat = <FILE>;
close(FILE);
&tete("SOLDE FRANCHISE","/home/var/spool/uucppublic/impfran.txt","");
print "<br><br>";
print "<table border=1>";
print &ligne_tab("<b>",Code,Ambassade,Service,Telephone,Bouteille,Cartouche,"Alimentaire EU"); 

foreach (@client_dat){
        ($client,$amb,$nom,$rue,$ville)=split (/;/,$_);
       	$teltel="&nbsp;";
       	if ($tel_idx{$client}ne""){
       		($telcl,$telser,$teltel)=split(/;/,$tel_dat[$tel_idx{$client}]);
       		}
	$total_alcool=$total_tabac=$total_alim=0;
	if ($impfran_idx{$client}ne""){
		(@franchise)=split(/;/,$impfran_idx{$client});   
         	foreach (@franchise){ 
        		($code,$type,$imp_no,$date,$imp_nom,$imp_qte_dep,$valeur)=split (/;/,@impfran_dat[$_]);
        		if ($type==11){$total_alim=$valeur/100;}
         		if ($type==12){$total_alcool=$valeur;}
         		if ($type==13){$total_tabac=$valeur;}
        	}
        }
	if (($total_alcool!=0)||($total_tabac!=0)||($total_alim!=0)){
		$total_alcool/=1000;
		$total_tabac/=1000;
		$total_alcool = int(($total_alcool * 10000) / 3225);
		$total_tabac = int($total_tabac * 1000 / 200);
	
		print &ligne_tab("",$client,$amb,$nom,$teltel,$total_alcool,$total_tabac,$total_alim); 
	}
}


print "</table></body></html>";


# -E listing des solde de franchise 