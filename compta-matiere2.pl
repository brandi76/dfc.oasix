#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';
print $html->header;    

# mouvement des produits a declarer
%compta_idx = &get_index_multiple("comptamatiere2",1);            
open(FILE2,"/home/var/spool/uucppublic/comptamatiere2.txt");     
@compta_dat = <FILE2>;
%enso_idx = &get_index_multiple("douane/2002/enso021203",1);            
open(FILE2,"/home/var/spool/uucppublic/douane/2002/enso021203.txt");     
@enso_dat = <FILE2>;

# nature des produits 
%nature_idx = &get_index_num("nature",0);            
open(FILE2,"/home/var/spool/uucppublic/nature.txt");     
@nature_dat = <FILE2>;



# --------------------- gestion des mouvements par type bis ----------------

print "<html><body>";

@index = keys %compta_idx;
@index =sort { $a <=> $b} @index ; # astuce trie numerique
$min=999999999;
$max=0;
foreach (@enso_dat){
	($null,$date)=split(/;/,$_);
	$date=&daten($date);
	$date+=0;
	if ($date<$min){$min=$date;}
	if ($date>$max){$max=$date;}
}

$min=21110;
print "<b><font size=-3>Bis france <br>ZI Rouxmenils Bouteilles <br><br>Numéro d'identification:FR 01 116 S 0072<br>Periode du:";
print &date(&daten($min));
print " au ";
print &date(&daten($max));
print "</b><br><center><h2>COMPTABILITE MATIERES DOUANES/ACCISES</h2><br>(PRODUITS EN SUSPENSION DE DROITS)<br>";

$total_type_entree=$total_type_sortie=$total_entree=$total_sortie=0;
print "<table border=1 width=100%><tr><td rowspan=2><b><font size=-3>Numéro de l'operation</td><td rowspan=2><b><font size=-3>Date</td><td rowspan=2><b><font size=-3>Nature des produits</td><td rowspan=2><b><font size=-3>Codes</td>";
foreach (@index){
	# 18 c'est les vins
	if (($nature_idx{$_} ne "")&&($_<18)){
		($tp,$desi,$unite)=split(/;/,$nature_dat[$nature_idx{$_}]);
	print "<td colspan=2 align=center><font size=-1><b><font size=-3>$tp $desi<br></b>$unite</td>";
	}
}
print "</tr><tr>";
foreach (@index){
	if ($_<18){
	print "<td bgcolor=#efefef><font size=-3>Entrée</td><td><font size=-3>Sortie</td>";}
}
print "</tr>";
$total_sortie2=$total_entree2=0;
$total_sortie=$total_entree=0;
foreach (sort (@compta_dat)){
	($date,$type,$douane,$sortie2,$entree2,$sortie,$entree)=split(/;/,$_);
	if (&daten($date)<$min){next;}
	# if ($type!=15){next};
	if ($type>=18){next;}# on saute les vins
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
print "<tr><td colspan=4><b><font size=-3>TOTAL</td>";
foreach (@index){
	if ($_<18){
		print "<td bgcolor=#efefef><font size=-3><b><font size=-3>";
		print &separateur($total_entree[$_]);	
		print "</td><td><font size=-3><b><font size=-3>";
		print &separateur($total_sortie[$_]);
		print "</td>"
		}
	}	
print "</tr><tr><td rowspan=2><b><font size=-3>Numéro de l'operation</td><td rowspan=2><b><font size=-3>Date</td><td rowspan=2><b><font size=-3>Nature des produits</td><td rowspan=2><b><font size=-3>Codes</td>";
foreach (@index){
		if (($nature_idx{$_} ne "")&&($_ <18)){
			($tp,$desi,$unite)=split(/;/,$nature_dat[$nature_idx{$_}]);
			print "<td colspan=2 align=center><font size=-1><b><font size=-3>$desi<br></b>$unite</td>";
		}
}
print "</tr></table>";

sub ligne{
	print "<tr><td><font size=-3>";
	$douane_ref+=0;
	$total_sortie+=0;
	if (($douane_ref>1000)&&($douane_ref<2000)){print "A:"}
	else{
		if ($total_entree>0){
			print "E:";
			if (int($douane_ref/10000)==89){
				print "IM7 ";
				# $douane_ref+=351000;
			}
			else {
				@ligne=selecte("/home/var/spool/uucppublic/inf-ent.txt",$douane_ref,0);
				if ($ligne[2]eq""){$ligne[2]="--- ";}
				else {$douane_ref="";}
				print @ligne[2];
			
			}
		}	
		if ($total_sortie>0){
			print "S:";
			if ($douane_ref<10000){
				print "DAA ";
			}
			if (($douane_ref>=890000)&&($douane_ref<896000)){ 
				print "IM4 ";
			}
			if (($douane_ref>=896000)&&($douane_ref<896999)){ 
				print "EX3 ";
			}
			if ($douane_ref>=968500){ 
				print "DOC111 ";
			}
			if ($douane_ref<2000){$douane_ref=" Export ".$douane_ref;}	
		}
	}

	print "$douane_ref</td><td align=right><font size=-3>";
	print &date(&daten($date_ref));
	print "</td><td nowrap align=right><font size=-3>";
	if ($total_sortie >0){
		if ($type_ref==15){print $total_sortie*5;}
		else{print $total_sortie;}
		}
	else{
		if ($type_ref==15){print $total_entree*5;}
		else{print $total_entree;}
	}
	
	if ($nature_idx{$type_ref} ne ""){
		($tp,$desi,$unite,$libelle)=split(/;/,$nature_dat[$nature_idx{$type_ref}]);
		print " $libelle";
	}
	print "</td><td><font size=-3>$type_ref</td>";
	
	for ($i=0;$i<=($#index-1);$i++){
		if ($index[$i]==$type_ref){last;}
		}
	for ($j=0;$j<$i;$j++){
		print "<td bgcolor=#efefef>&nbsp;</td><td><font size=-3>&nbsp;</td>";
	}
	print "<td align=right bgcolor=#efefef><font size=-3>";
	print &separateur($total_entree2);
	print "</td><td align=right><font size=-3>";
	print &separateur($total_sortie2);
	print "</td>";
	for ($j=($#index-1);$j>$i;$j--){
		print "<td bgcolor=#efefef>&nbsp;</td><td><font size=-3>&nbsp;</td>";
	}
	
	$total_entree[$type_ref]+=$total_entree2;
	$total_sortie[$type_ref]+=$total_sortie2;
	
}


# --------------------- fin gestion des mouvements par type bis ----------------
# -E Listing compta matiere de BIS