#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
use Spreadsheet::Read;
use JSON;
use Switch;
$html=new CGI;
print $html->header();
$action=$html->param("action");
$debut=$html->param("debut");
$option=$html->param("option");
$four=$html->param("four");
$creer=$html->param("creer");
$backup=$html->param("backup");
$debut=1 if ($debut eq "");
if ($backup ne ""){
 (@liste_backup)=split(/:/,&get("select choix from backup_import where backup_id='$backup'")); 
 ($four,$debut)=&get("select four,depart from backup_import where backup_id='$backup'"); 
 
 if ($#liste_backup<1){$backup="";}
}

{$user=$ENV{"REMOTE_USER"};}
@alpha=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T");

print <<EOF;
<html>
  <head>
    <link href="/css/bootstrap.min.css" rel="stylesheet" >
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	<style>
	.btn-file {
        position: relative;
        overflow: hidden;
    }
    .btn-file input[type=file] {
        position: absolute;
        top: 0;
        right: 0;
        min-width: 100%;
        min-height: 100%;
        font-size: 100px;
        text-align: right;
        filter: alpha(opacity=0);
        opacity: 0;
        outline: none;
        background: white;
        cursor: inherit;
        display: block;
    }
	</style>
	<script>
	       \$(document).ready( function() {
        \$('.btn-file :file').on('fileselect', function(event, numFiles, label) {
			document.getElementById("choix").innerHTML+=label+"<br>";
            console.log(label);
        });
    });
	    \$(document).on('change', '.btn-file :file', function() {
        var input = \$(this),
            numFiles = input.get(0).files ? input.get(0).files.length : 1,
EOF
			
print <<EOF;
        input.trigger('fileselect', [numFiles, label]);
    });
	</script>
  </head>
  <body>
    <div class="container">
		<div class="row">
			<div class="col-lg-12">
EOF

push(@champ,'{"champ":"code","libelle":"Code barre","valeur":""}');
push(@champ,'{"champ":"designation1","libelle":"Designation","valeur":""}');
push(@champ,'{"champ":"code_chapitre","libelle":"Code douane 8 caracteres","valeur":""}');
push(@champ,'{"champ":"famille","libelle":"Famille","valeur":""}');
push(@champ,'{"champ":"degree","libelle":"Degree","valeur":""}');
push(@champ,'{"champ":"poids_net","libelle":"Poids net en Gramme","valeur":""}');
push(@champ,'{"champ":"poids_brut","libelle":"Poids brut en Gramme","valeur":""}');
push(@champ,'{"champ":"conditionnement","libelle":"Packing","valeur":""}');
push(@champ,'{"champ":"code_fournisseur1","libelle":"Code fournisseur","valeur":""}');
push(@champ,'{"champ":"refour1","libelle":"Reference fournisseur","valeur":""}');
push(@champ,'{"champ":"litrage","libelle":"Litrage en cl","valeur":""}');
push(@champ,'{"champ":"concentration","libelle":"Concentration","valeur":""}');
push(@champ,'{"champ":"marque","libelle":"Marque","valeur":""}');
push(@champ,'{"champ":"gamme","libelle":"Gamme","valeur":""}');
push(@champ,'{"champ":"tr","libelle":"TR (oui ou 1) ","valeur":""}');

if ($option eq "confirmer"){
	$libelle=$html->param("libelle");
	$libelle=~s/\"//g;
	&save("replace into suivi_importation (date,nom,libelle,action) values (curdate(),'$user',\"$libelle\",'Maj info')","");
}

if ($action eq ""){
	print "<div class=\"alert alert-info\">Importation Information produit</div>";
	print "<h3>Selectionner le contenu des colonnes</h3>";
	print "<form role=form>";
	print "Charger le backup 'choix de colonne' No <input name=backup size=3 value=$bakcup>";
	print " <button type=submit class=\"btn btn-info btn-xs\">Submit</button>";
	print "</form>";
	print "<form role=form method=POST enctype=multipart/form-data>";
	$no_champ=0;
	foreach (@champ){
		$row=decode_json($_);
		print "<div><div style=display:inline-block;width:250px>";
		print $row->{'libelle'}."</div><div style=display:inline-block>";
		print "<select name=$row->{'champ'} required>";
		if ($row->{'champ'} eq "code_fournisseur1"){
			$query="select fo2_cd_fo,fo2_add from fournis order by fo2_add";
			$sth = $dbh->prepare($query);
			$sth->execute;
			print '<option value="" disabled="disabled">Veuillez sélectionner un fournisseur</option>';
			while (($fo2_cd_fo,$fo2_add) = $sth->fetchrow_array) {
				($fo2_nom)=split(/\*/,$fo2_add);
				$select="";
				if ($fo2_cd_fo==$four){$select="selected";}
				print "<option value=$fo2_cd_fo $select>$fo2_cd_fo $fo2_nom</option>";
	 		}
		}
		else {	
			print "<option value=0></option>";
			$i=1;
			foreach(@alpha){
				$defaut="";
				if (($backup ne "")&&($_ eq $liste_backup[$no_champ])){$defaut="selected";}
				print "<option value=$i $defaut>$_</option>";
				$i++;
			}
		}
		print "</select></div></div>";
		$no_champ++;
	}
	print "Commencer l'importation à la ligne <input class=form_control type=number name=debut value=$debut><br>";
	print "Ignorer les produits deja existants <input type=checkbox name=creer><br>";
	print "Sauvegarder la selection des colonnes <input type=checkbox name=sauve_backup><br>";		
	print "<h3>Selectionner le fichier Excel</h3>";
	print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<span class=\"file-input btn btn-primary btn-file btn-sm\">";
	print "Parcourir... <input type=\"file\" name=fichier accept=application/xls maxlength=2097152>";
	print "</span><br><br>";
	print "<input type=hidden name=action value=upload>";
	print "<button type=submit class=\"btn btn-info\">Vérification</button>"; 
	print "</form>";
	print "<button class=\"btn btn-danger pull-right\" onclick=window.close()>Fermer</button>"; 
	print "<h3>Liste des précédentes opérations</h3>";
	$query="select date,nom,libelle from suivi_importation where action='Maj info' order by date desc";
	$sth = $dbh->prepare($query);
	$sth->execute;
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr class=\"success\"><th>Date</th><th>Nom</th><th>Libelle</th></tr>";
	print "</thead>";
	while (($date,$nom,$libelle) = $sth->fetchrow_array) {
		print "<tr><td>$date</td><td>$nom</td><td>$libelle</td></tr>";
	}
	print "</table>";
}

if ($action eq "upload"){
	$sauve_backup=$html->param("sauve_backup");
	
	if ($sauve_backup eq "on"){
		$four=$html->param("code_fournisseur1");
		$debut=$html->param("debut");
		$choix="";
		foreach (@champ){
			$row=decode_json($_);
			if ($html->param("$row->{'champ'}")!=0){$choix.=$alpha[$html->param("$row->{'champ'}")-1];}
			$choix.=":";
		}
		&save("insert into backup_import (choix,four,depart) values ('$choix','$four','$debut')");
		$backup_id=&get("SELECT LAST_INSERT_ID() FROM backup_import");
		print "<mark>La selection a été sauvergardé avec le numero:$backup_id</mark><br>";
	}
    if ($option ne "confirmer"){
		$fichier=$html->param("fichier");
		print "<div class=\"alert alert-info\">$fichier</div>";
		if ($fichier ne ""){
			if (!grep(/\.xls$/,$fichier)){$message="Nom de fichier invalide, seul le format xls est accepté";}
			if ($message eq ""){
				$file="/var/www/dfc.oasix/doc/workfile.xls";
				open(FILE,">$file");
				while (read($fichier, $data, 2096)){
					print FILE $texte.$data;
				}
				close(FILE);
			}
			if ($html->param("code")==0){
				$message="Aucune colonne selectionnée pour le code";
			}	
		}
		else {$message="Merci de selectionner un fichier";}
	}
	if ($message eq ""){
		$creation=0;
		my $book  = ReadData ("/var/www/dfc.oasix/doc/workfile.xls");
		$nb_feuille=$book->[0]{sheets};
		$nb_col=$book->[1]{maxcol};
		$nb_ligne=$book->[1]{maxrow};
		print "Nb de col:$nb_col<br>";
		print "Nb de ligne:$nb_ligne<br>";
		print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
		print "<thead>";
		print "<tr style=font-size:0.8em class=\"info\"><th>Check</th>";
		foreach (@champ){
			$row=decode_json($_);
			if ($html->param("$row->{'champ'}")!=0){
				print "<th>";
				print "<span class=badge>".$alpha[$html->param("$row->{'champ'}")-1]."</span> ";
				print  $row->{'libelle'};
				print "</th>";
			}
		}	
		print "</tr>";		
		print "</thead>";
		for ($l=$debut;$l<=$nb_ligne;$l++){
			$err=0;
			print "<tr>";
			$code=$book->[1]{cell}[$html->param("code")][$l];
			
			if (length($code)==0){next;}
			if ($code=~/[A-Z]/g){
				$err=1;
				# print "Ligne $l code invalide ligne non traitée<br>";
				# next;	
			}
			if ($err==0){
				$inode=&get("select inode from dfc.produit_inode where code='$code'");
				if ($inode eq ""){
					$err=2;
					# print "Ligne $l code inconnu ligne non traitée<br>";
					# next;	
				}
			}
			switch ($err) {	
				case 1 {print "<td class=bg-danger>Code invalide Non traité</td>"}
				case 2 {print "<td class=bg-success>Nouveau produit</td>"}
				else{print "<td>Ok</td>"}
			}	
			print "<td>$code</td>";
			$query="update dfc.produit_master set ";
			foreach (@champ){
				$row=decode_json($_);
				# print $html->param("$row->{'champ'}")." ".$row->{'champ'}."<br>";
				if (($html->param("$row->{'champ'}")!=0)&&($row->{'champ'} ne "code")){
					$j=$html->param("$row->{'champ'}");
					$row->{'valeur'}=$book->[1]{cell}[$j][$l];
					$row->{'valeur'}=~s/"//g;
					$row->{'valeur'}=~s/ $//;
					if ($row->{'champ'} eq "code_fournisseur1"){$row->{'valeur'}=$html->param("code_fournisseur1");}
					# if (($row->{'champ'} eq "tr")&&($row->{'valeur'} eq "oui")){$row->{'valeur'}=1;}else{$row->{'valeur'}=0;}					
					# a voir
					$row->{'valeur'}=&sans_accent($row->{'valeur'});
					$query.=$row->{'champ'}."="."\"".$row->{'valeur'}."\",";
					print "<td>";
					print $row->{'valeur'};
					print "</td>";
				}
			}
			chop($query);
			if ($four ne ""){
				$query.=",code_fournisseur1='$four' ";
			}	
			print "</tr>";
			if (($option eq "confirmer")&&($err!=1)){
				if ($err==2){
					$creation=1;
					&save("insert into dfc.produit_master (designation1) values ('Nouveau produit')","");
					$inode=&get("SELECT LAST_INSERT_ID() FROM dfc.produit_master");
					&save("insert ignore into dfc.produit_inode values ('$code','$inode')");
				}
				$query.="where inode='$inode'";
				print "<tr><td colspan=4 style=font-size:0.7em>";
				if ($creer ne "on"){
					&save("$query","aff");
				}
				else {
					if ($err==2){&save("$query","aff");}
				}	
				print "</td></tr>";
			}
		}
		print "</table>";
		if ($option ne "confirmer"){
			print "<form>";
			if (($creation)&&($html->param("code_fournisseur1")==0)){
				print "Il y a des produits à creer choisir un fournisseur<br>";
				print "<select name=four><option value=></option>";  
				$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from dfc.fournis order by fo2_add");
				$sth2->execute;
				while (my @four = $sth2->fetchrow_array) {
					($four[1])=split(/\*/,$four[1]);
					print "<option value=\"$four[0]\">$four[0] $four[1]\n";
				}
				print "</select><br>";
			}			
			print "Info importation <input type=text name=libelle size=100>";
			print "<input type=hidden name=action value=upload>";
			print "<input type=hidden name=creer value='$creer'>";
			print "<input type=hidden name=option value=confirmer>";
			print "<br><button type='submit' class='btn btn-default'>Confirmer</button>";
			foreach (@champ){
				$row=decode_json($_);
				print "<input type=hidden name=".$row->{'champ'};
				if ($row->{'champ'} eq "code_fournisseur1"){print " value=".$html->param("code_fournisseur1").">\n";}
				else {print " value=".$html->param("$row->{'champ'}").">\n";}
			}
			print "</form>";
		}
		else {
				print "<p class=\"bg-success\">Importation effectuée</p>";
		}
	}
	else {
		print "<p class=\"bg-danger\">$message</p>";
	}	
	print "<a href=?><button class=\"btn btn-success\">Retour</button></a>"; 
}	
print "</div></div></div></body>";


