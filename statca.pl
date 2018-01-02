#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';
print $html->header;

$action=$html->param("action");

if ($action ne "edition"){&html();}
else {

%caclient1997_idx = &get_index_num("CAclient1997",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient1997.txt");  
@caclient1997_dat = <FILE1>;    
close(FILE1);
%caclient1998_idx = &get_index_num("CAclient1998",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient1998.txt");  
@caclient1998_dat = <FILE1>;    
close(FILE1);
%caclient1999_idx = &get_index_num("CAclient1999",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient1999.txt");  
@caclient1999_dat = <FILE1>;    
close(FILE1);
%caclient2000_idx = &get_index_num("CAclient2000",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient2000.txt");  
@caclient2000_dat = <FILE1>;    
close(FILE1);
%caclient2001_idx = &get_index_num("CAclient2001",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient2001.txt");  
@caclient2001_dat = <FILE1>;    
close(FILE1);

open(FILE2,"/home/var/spool/uucppublic/client2.txt");
@client_dat = <FILE2>;
close(FILE2);




@total1997=@total1998=@total1999=@total2000=@total2001="";
@cal1997_tot=@cal1998_tot=@cal1999_tot=@cal2000_tot=@cal2001_tot="";
#@adresse="";
$compt=0;
$total_cl=0;


                
for($j=0;$j<=$#client_dat;$j++){
	($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville)=split(/;/,@client_dat[$j]);
	$cl_mini=$cl_cd_cl%1000;
	 if (($cl_cd_cl >1010002)&&($cl_cd_cl <1900000)&&(($cl_mini <600)||($cl_mini>999))){ # selection des clients corps diplo
	#if (($cl_cd_cl >6000000)&&($cl_cd_cl <7000000)){ # selection des clients londres
	
		$cl_cour=substr($cl_cd_cl,0,4);
		if (($cl_cour != $cl_tampon)&&($#adresse >=0)) {
			print "<br><center><table border=2 width=700 frame=box rules=none>";
			foreach (@adresse){
				($cl,$add,$contact,$rue,$ville)=split(/;/,$_);
				print "<tr><td><font size=-2>$cl</td><td><font size=-2>$add</td><td><font size=-2>$contact</td><td><font size=-2>$rue</td><td><font size=-2>$ville</td></tr>";
			}
			print "<tr><td colspan=5 align=center><table border=1 width=100% cellspacing=0 cellpadding=0 width=100%><tr><td>&nbsp;</td>";
			for ($i=1;$i<13;$i++){
				print "<td><font size=-2><b>",&cal($i,"c"),"</td>";
				}
			print "<td><font size=-2><b>Total</td></tr>";
			print "<tr><td><font size=-2><b>1997</td>";
			$total_ligne="";
			for ($i=0;$i<12;$i++){
	 			if ($cal1997_tot[$i] eq ""){
	 				print "<td>&nbsp;</td>";
	 			}
	 			else{
	 				print "<td align=right><font size=-2>",&separateur($cal1997_tot[$i]),"</td>";
	 	        		$total_ligne+=$cal1997_tot[$i];
	 	        		$total1997[$i]+=$cal1997_tot[$i];
	 			}
	 		}
			print "<td align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
			print "</tr><tr><td><font size=-2><b>1998</td>";
			$total_ligne="";
			for ($i=0;$i<12;$i++){
	 			if ($cal1998_tot[$i] eq ""){
	 				print "<td>&nbsp;</td>";
	 			}
	 			else{
	 				print "<td align=right><font size=-2>",&separateur($cal1998_tot[$i]),"</td>";
	 	        		$total_ligne+=$cal1998_tot[$i];
	 	        		$total1998[$i]+=$cal1998_tot[$i];
	 			}
	 		}
			print "<td align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
			print "</tr><tr><td><font size=-2><b>1999</td>";
			$total_ligne="";
			for ($i=0;$i<12;$i++){
	 			if ($cal1999_tot[$i] eq ""){
	 				print "<td>&nbsp;</td>";
	 			}
	 			else{
	 				print "<td align=right><font size=-2>",&separateur($cal1999_tot[$i]),"</td>";
	 	        		$total_ligne+=$cal1999_tot[$i];
	 	        		$total1999[$i]+=$cal1999_tot[$i];
	 			}
	 		}
			print "<td align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
			print "</tr><tr><td><font size=-2><b>2000</td>";
			$total_ligne="";
			for ($i=0;$i<12;$i++){
	 			if ($cal2000_tot[$i] eq ""){
	 				print "<td>&nbsp;</td>";
	 			}
	 			else{
	 				print "<td align=right><font size=-2>",&separateur($cal2000_tot[$i]),"</td>";
	 	        		$total_ligne+=$cal2000_tot[$i];
	 	        		$total2000[$i]+=$cal2000_tot[$i];
	 			}
	 		}
			print "<td align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
			print "</tr><tr><td><font size=-2><b>2001</td>";
			$total_ligne="";
			for ($i=0;$i<12;$i++){
	 			if ($cal2001_tot[$i] eq ""){
	 				print "<td>&nbsp;</td>";
	 			}
	 			else{
	 				print "<td align=right><font size=-2>",&separateur($cal2001_tot[$i]),"</td>";
	 	        		$total_ligne+=$cal2001_tot[$i];
	 	        		$total2001[$i]+=$cal2001_tot[$i];
	 			}
	 		}
	 	        print "<td align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
	 	        print "</tr></table></td>";
			$cl_tampon=$cl_cour;
			@cal1997_tot=@cal1998_tot=@cal1999_tot=@cal2000_tot=@cal2001_tot="";
			
			# print "<td align=right><font size=-2><b>",&separateur($total_cl),"</td>";
		        $total_cl=0;
			@adresse=""; 	
                	print "</tr>";
                	#if ($compt++==10){last};
		}
		
		@cal_1997=@cal_1998=@cal_1999=@cal_2000=@cal_2001="";
		if ($caclient1997_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_1997)=split(/;/,$caclient1997_dat[$caclient1997_idx{$cl_cd_cl}]);
                }
                if ($caclient1998_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_1998)=split(/;/,$caclient1998_dat[$caclient1998_idx{$cl_cd_cl}]);
                }
                if ($caclient1999_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_1999)=split(/;/,$caclient1999_dat[$caclient1999_idx{$cl_cd_cl}]);
                }
                if ($caclient2000_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_2000)=split(/;/,$caclient2000_dat[$caclient2000_idx{$cl_cd_cl}]);
						                }
                if ($caclient2001_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_2001)=split(/;/,$caclient2001_dat[$caclient2001_idx{$cl_cd_cl}]);
                }
                push (@adresse ,"$cl_cd_cl;$cl_nom;$cl_contact;$cl_rue;$cl_ville");
                for ($i=0;$i<12;$i++){
                	@cal1997_tot[$i]+=@cal_1997[$i];
                	@cal1998_tot[$i]+=@cal_1998[$i];
                	@cal1999_tot[$i]+=@cal_1999[$i];
                	@cal2000_tot[$i]+=@cal_2000[$i];
                	@cal2001_tot[$i]+=@cal_2001[$i];
                }
	                                       
	} # fin du test fourchette client
}

print "</table><br><table width=700 border=1>";
print "<tr><td>&nbsp;</td>";
for ($i=1;$i<13;$i++){
				print "<td><font size=-2><b>",&cal($i,"c"),"</td>";
				}
			
$total=0;
print "</tr><tr><td><b>1997</td>";
for ($i=0;$i<12;$i++){
	print "<td><font size=-2>",&separateur($total1997[$i]),"</td>";
	$total+=$total1997[$i];
}
print "<td><font size=-2><b>",&separateur($total),"</td></tr>";

$total=0;
print "<tr><td><b>1998</td>";
for ($i=0;$i<12;$i++){
	print "<td><font size=-2>",&separateur($total1998[$i]),"</td>";
	$total+=$total1998[$i];
}
print "<td><font size=-2><b>",&separateur($total),"</td></tr>";
print "<tr><td><b>1999</td>";
$total=0;
for ($i=0;$i<12;$i++){
	print "<td><font size=-2>",&separateur($total1999[$i]),"</td>";
	$total+=$total1999[$i];
}
print "<td><font size=-2><b>",&separateur($total),"</td></tr>";
print "<tr><td><b>2000</td>";
$total=0;
for ($i=0;$i<12;$i++){
	print "<td><font size=-2>",&separateur($total2000[$i]),"</td>";
	$total+=$total2000[$i];
}
print "<td><font size=-2><b>",&separateur($total),"</td></tr>";
print "<tr><td><b>2001</td>";
$total=0;
for ($i=0;$i<12;$i++){
	print "<td><font size=-2>",&separateur($total2001[$i]),"</td>";
	$total+=$total2001[$i];
}
print "<td><font size=-2><b>",&separateur($total),"</td></tr>";

print "</table><br>";

print "</body></html>";
}

sub html{
	print "<html><body>";
	&tete("CHIFFRE D'AFFAIRE BIS <a href=http://intranet.dom/cgi-bin/majCAclient2001.pl>init</a> ","/home/var/spool/uucppublic/CAclient2001.txt");
	print "<br><br>";
	print "<a href=statca.pl?action=edition>go</a>";
	print "</body></html>";
}
# -E stat sur 5 ans des clients regrouper par addresse de livraison