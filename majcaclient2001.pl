#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';
print $html->header;
print "<body>";

%produit_idx = &get_index_num("produit",1);            
open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits
@produit_dat = <FILE2>;
close(FILE2);

@facjoura_dat = `sort -t';' +1 /home/var/spool/uucppublic/archive/facjoura-2001.txt`;

foreach(@facjoura_dat){
	                                       # pour chaque produit
	 ($fja_no_fact,$fja_cd_cl,$fja_nom,$fja_dt,$fja_cd,$fja_mont,$fja_folio,$fja_dev,$fja_mont_dev)=split(/;/,$_);

	$fja_cd_cl += 0;
	
	$mois = substr($fja_dt,2,2);
	$mois = $mois + 0;
	if($mois == 1){
		$janvier{$fja_cd_cl} = 0 + $janvier{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 2){
		$fevrier{$fja_cd_cl} = 0 + $fevrier{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 3){
		$mars{$fja_cd_cl} = 0 + $mars{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 4){
		$avril{$fja_cd_cl} = 0 + $avril{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 5){
		$mai{$fja_cd_cl} = 0 + $mai{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 6){
		$juin{$fja_cd_cl} = 0 + $juin{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 7){
		$juillet{$fja_cd_cl} = 0 + $juillet{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 8){
		$aout{$fja_cd_cl} = 0 + $aout{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 9){
		$septembre{$fja_cd_cl} = 0 + $septembre{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 10){
		$octobre{$fja_cd_cl} = 0 + $octobre{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 11){
		$novembre{$fja_cd_cl} = 0 + $novembre{$fja_cd_cl} + $fja_mont;
	}
	if($mois == 12){
		$decembre{$fja_cd_cl} = 0 + $decembre{$fja_cd_cl} + $fja_mont;
	}
	if($mois >=1 && $mois <=12){
		$liste{$fja_cd_cl} += 0 + $liste{$fja_cd_cl} + $fja_mont;
	}

}

@index = sort keys(%liste);

open(FILE,"> /home/var/spool/uucppublic/CAclient2001.txt");
foreach(@index){
	$janvier{$_}=int($janvier{$_}*100)/100;
	$fevrier{$_}=int($fevrier{$_}*100)/100;
	$mars{$_}=int($mars{$_}*100)/100;
	$avril{$_}=int($avril{$_}*100)/100;
	$mai{$_}=int($mai{$_}*100)/100;
	$juin{$_}=int($juin{$_}*100)/100;
	$juillet{$_}=int($juillet{$_}*100)/100;
	$aout{$_}=int($aout{$_}*100)/100;
	$septembre{$_}=int($septembre{$_}*100)/100;
	$octobre{$_}=int($octobre{$_}*100)/100;
	$novembre{$_}=int($novembre{$_}*100)/100;
	$decembre{$_}=int($decembre{$_}*100)/100;
	
	print FILE "$_;$janvier{$_};$fevrier{$_};$mars{$_};$avril{$_};$mai{$_};$juin{$_};$juillet{$_};$aout{$_};$septembre{$_};$octobre{$_};$novembre{$_};$decembre{$_};\n";
}
close(FILE);
exec("/home/intranet/cgi-bin/suivi-commer.pl");

# -E programme pour generer les fichiers CAclient
# creer le fichier fac01.txt avec L-FACDATA sur l'aryx
# mettre le fichier dans uucppublic
# lancer ce programme pour generer CAclient2001.txt
# utiliser les programmes qui si refere ex:baton2.pl