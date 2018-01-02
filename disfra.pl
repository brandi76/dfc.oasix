#!/usr/bin/perl
use CGI; 
require 'manip_table.lib';
require 'outils_perl.lib';
$html=new CGI;
print $html->header;
$client=$html->param('code_client'); 
$annee=$html->param('annee'); 

# traitement via une recherche
if (! grep /[0-9]/,$client)
{ 
	exec("/home/intranet/cgi-bin/choix-col.pl client $client http://intranet.dom/cgi-bin/disfra.pl?code_client= 1");
}


# recuperation de la date de derniere modification
open(DATE," /usr/local/bin/datemod.sh /home/var/spool/uucppublic/impfran.txt |");
$ladate = <DATE>;
@ladate = split(/ /,$ladate);
close(DATE);
print "<html>\n";
print "<title>DIS-FRA3 &copy;</title>\n";
print "<LINK rel=\"stylesheet\" href=\"/intranet.css\" type=\"text/css\">\n\n";
&body();

&tete("DIS-FRA3","/home/var/spool/uucppublic/impfran.txt","");

if ($client !=0){

%client_idx = &get_index_num("client2",0);
open(FILE1,"/home/var/spool/uucppublic/client2.txt");
@client_dat = <FILE1>;
%impfran_idx= &get_index_multiple("impfran",0);
open(FILE,"/home/var/spool/uucppublic/impfran.txt");
@impfran_dat = <FILE>;
close(FILE);
close(FILE1);    
}   
print "<br><center>\n";
if ($client_idx{$client}){
	   		
                ($code,$type,$nom,$rue,$ville)=split (/;/,@client_dat[$client_idx{$client}]);
        }
        else{
        $code="Code client inexistant";
        }
print "<h3><b><i>$code $type $pays $org $nom</h3></b></i><table border=1 width=75%>\n";
print "<tr>\n<td bgcolor=black><font color=white><b><i>Type de Franchise</td>\n";
print "<td bgcolor=black><font color=white><b><i>Total de Franchise</td>\n";
print "<td bgcolor=black><font color=white><b><i>Equivalence</td>\n";
print "<td bgcolor=black><font color=white><b><i>Dernière Franchise le :</td>\n";
print "</tr>\n";

# print "<td>",%impfran_idx,"</td>";
$date_alc=$date_tab=$date_alim=0;
if ($impfran_idx{$client}ne""){
	
         (@franchise)=split(/;/,$impfran_idx{$client});   
         foreach (@franchise){ 
         	($code,$type,$imp_no,$date,$imp_nom,$imp_qte_dep,$valeur)=split (/;/,@impfran_dat[$_]);
		$an=$date%100;
		if (($annee ne "")&&($an != $annee)){next;}
        	if ($type==1){$total_alim+=$valeur/100;}
         	if ($type==2){$total_alcool+=$valeur;}
         	if ($type==3){$total_tabac+=$valeur;}
         	# type 11 12 13 on recupere la valeur 1 2 3 on recupre la date la plus recente
         	
        	$date+=20000000;
	        $date=substr ($date,length($date)-2,2).substr($date,length($date)-4,2).substr($date,length($date)-6,2); 
	       	if (($type==1)&&($date > $date_alim)){$date_alim=$date;}
		if (($type==2)&&($date > $date_alc)){$date_alc=$date;}
		if (($type==3)&&($date > $date_tab)){$date_tab=$date;}
        }
}else{
	$total_alim = "9999999999";
	$date_alim = "######";
	$total_alcool = "999999999999999";
	$date_alc = "######";
	$total_tabac = "9999999999999";
	$date_tab = "######"
}	
	
$date=$date_alim;
$date_alim=substr ($date,length($date)-2,2)."/".substr($date,length($date)-4,2)."/".substr($date,length($date)-6,2); 
$date=$date_alc;
$date_alc=substr ($date,length($date)-2,2)."/".substr($date,length($date)-4,2)."/".substr($date,length($date)-6,2);
$date=$date_tab;
$date_tab=substr ($date,length($date)-2,2)."/".substr($date,length($date)-4,2)."/".substr($date,length($date)-6,2); 

if ($date_alim==0){$total_alim=0;}
if ($date_alc==0){$total_alcool=0;}
if ($date_tab==0){$total_tabac=0;}
	       	
print "<tr>\n";
print "<td><font color=blue><b><i>Alimentation</td>\n";
print "<td align=right>";
if($total_alim  != 0){
	print "<font color=blue>$total_alim EU";
}
print "&nbsp;</td>\n";
print "<td align=right>&nbsp;";

print "</td>\n";

print "<td align=right>";
if($date_alim  ne ""){
	print "<font color=blue>$date_alim";
}
print "</td>\n";
print "</tr>\n";

print "<tr>\n";
print "<td><font color=red><b><i>Alcool</td>\n";
print "<td align=right>";
if($total_alcool != 0){
	$total_alcool = $total_alcool / 1000;
	print "<font color=red>$total_alcool L d'alcool Pure";
}
print "&nbsp;</td>\n";
print "<td align=right>";
if($total_alcool != 0){
	$total_alcool = int(($total_alcool * 10000) / 3225);
	print "<font color=red>$total_alcool Bouteille(s)";
}

print "&nbsp;</td>\n";

print "<td align=right>";
if($date_alc ne ""){
	print "<font color=red>$date_alc";
}
print "</td>\n";
print "</tr>\n";

print "<tr>\n";
print "<td><font color=green><b><i>Tabac</td>\n";
print "<td align=right>";
if($total_tabac != 0){
	$total_tabac = $total_tabac / 1000;
	print "<font color=green>$total_tabac Kg";
}
print "&nbsp;</td>\n";
print "<td align=right>";
if($total_tabac != 0){
	$total_tabac = int($total_tabac * 1000 / 200);
	print "<font color=green>$total_tabac Cartouche(s)";
}
print "&nbsp;</td>\n";

print "<td align=right>";
if($date_tab ne ""){
	print "<font color=green>$date_tab";
}
print "</td>\n";
print "</tr>\n";
       

print "</table>";
print "<br><br>";
print "<p><hr width=25%><p>";
print "<form action=disfra.pl>";
print "<b>Code Client ou Pays : </b><input type=text name=code_client>\n";
print "<input type=submit value=go>";
print "<br><br>Option année (AA) <input type=text name=annee size=2></form>";
print "<p><hr width=25%><p>";
print "<br><br><br><input type=button Value=Retour onClick='javascript:history.back()'>\n\n";
print "</body></html>";


# -E DISFRA3 : display franchise infos