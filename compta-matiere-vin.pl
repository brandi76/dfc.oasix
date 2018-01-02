#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';
print $html->header;    

# mouvement des produits a declarer
%enso_idx = &get_index_multiple("comptamatiere-vin",1);            
open(FILE2,"/home/var/spool/uucppublic/comptamatiere-vin.txt");     
@enso_dat = <FILE2>;
# nature des produits 
%nature_idx = &get_index_num("nature",0);            
open(FILE2,"/home/var/spool/uucppublic/nature.txt");     
@nature_dat = <FILE2>;



# --------------------- gestion des mouvements par type bis ----------------

print "<html><body>";

@index = keys %enso_idx;
@index =sort { $a <=> $b} @index ; # astuce trie numerique

 

print "<b>Bis france <br>ZI Rouxmenils Bouteilles <br><br>Numéro d'identification:FR 01 116 S 0072<br>Mois de:</b><br><center><h2>COMPTABILITE MATIERES DES VINS</h2><br>(PRODUITS EN DROITS ACQUITES)<br>";

$total_type_entree=$total_type_sortie=$total_entree=$total_sortie=0;
print "<table border=1><tr><td rowspan=2><b>Numéro de l'operation</td><td rowspan=2><b>Date</td><td rowspan=2><b>Nature des produits</td><td rowspan=2><b>Codes</td>";
foreach (@index){
		# 18 c'est les vins
		
		if (($nature_idx{$_} ne "")&&($_>=18)){
			($tp,$desi,$unite)=split(/;/,$nature_dat[$nature_idx{$_}]);
			print "<td colspan=2 align=center><font size=-1><b>$desi<br></b>$unite</td>";
		}
}
print "</tr><tr>";
foreach (@index){
	if ($_>=18){
	print "<td bgcolor=#efefef>Entrée</td><td>Sortie</td>";}
}
print "</tr>";
$total_sortie2=$total_entree2=0;
$total_sortie=$total_entree=0;
foreach (sort (@enso_dat)){
	($date,$type,$douane,$sortie2,$entree2,$sortie,$entree)=split(/;/,$_);
	if ($type<18){next;}# on saute ce qui n'est pas les vins
	if (($type != $type_ref)||($douane != $douane_ref)){
		if (($total_sortie2!=0)||($total_entree2!=0)){
			&ligne;
			}
		$type_ref=$type;
		$douane_ref=$douane;
		$date_ref=$date;
		$total_sortie2=$total_entree2=0;
		$total_sortie=$total_entree=0;
	}
	$total_sortie+=$sortie;
	$total_entree+=$entree;
	$total_sortie2+=$sortie2;
	$total_entree2+=$entree2;
}
	if (($total_sortie2!=0)||($total_entree2!=0)){
		$type=9999;
		&ligne;
		}
print "<tr><td colspan=4><b>TOTAL</td>";
foreach (@index){
	if ($_>=18){
		print "<td bgcolor=#efefef><b>";
		print &separateur($total_entree[$_]);	
		print "</td><td><b>";
		print &separateur($total_sortie[$_]);
		print "</td>"
		}
	}	

print "</tr></table>";

sub ligne{
	print "<tr><td>";
	$douane_ref+=0;
	$total_sortie+=0;
	if ($total_entree>0){
		if (int($douane_ref/1000)==547){
			print "IM7 ";
			$douane_ref+=351000;
		}
		else {
			print "--- ";
		}
	}
	if ($total_sortie>0){
		if ($douane_ref<=2000){
			print "--- ";
			}
		if (($douane_ref<10000)&&($douane_ref>2000)){
			print "DAA ";
		}
		if ($douane_ref>890000){ 
			print "IM4 ";
		}	
	}
	print "$douane_ref</td><td align=right>$date_ref</td><td nowrap align=right>";
	if ($total_sortie >0){
		print $total_sortie;
		}
	else{
		print $total_entree;
	}
	
	if ($nature_idx{$type_ref} ne ""){
		($tp,$desi,$unite,$libelle)=split(/;/,$nature_dat[$nature_idx{$type_ref}]);
		print " $libelle";
	}
	print "</td><td>$type_ref</td>";
	
	if ($type_ref==19){
		print "<td bgcolor=#efefef>&nbsp;</td><td>&nbsp;</td>";
	}
	print "<td align=right bgcolor=#efefef>";
	print &separateur($total_entree2);
	print "</td><td align=right>";
	print &separateur($total_sortie2);
	print "</td>";
	if ($type_ref==18){
		print "<td bgcolor=#efefef>&nbsp;</td><td>&nbsp;</td>";
	}
	
	$total_entree[$type_ref]+=$total_entree2;
	$total_sortie[$type_ref]+=$total_sortie2;
	
}

# --------------------- fin gestion des mouvements par type bis ----------------
