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
$date=$html->param("date");
$base=$html->param("base");
$user=$ENV{"REMOTE_USER"};
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
            numFiles = input.get(0).files ? input.get(0).files.length : 1;
EOF
			
print <<EOF;
        //input.trigger('fileselect', [numFiles, label]);
    });
	</script>
  </head>
  <body>
    <div class="container">
		<div class="row">
			<div class="col-lg-12">
EOF

push(@champ,'{"champ":"code","libelle":"Code barre","valeur":""}');
push(@champ,'{"champ":"prac","libelle":"Prix achat","valeur":""}');
push(@champ,'{"champ":"prixv","libelle":"Prix vente","valeur":""}');



if ($action eq ""){
	print "<div class=\"alert alert-info\">Verification avec les prix Sephora</div>";
	print "<form role=form method=POST enctype=multipart/form-data>";
	print "<h3>Selectionner le contenu des colonnes</h3>";
	foreach (@champ){
		$row=decode_json($_);
		print "<div><div style=display:inline-block;width:250px>";
		print $row->{'libelle'}."</div><div style=display:inline-block>";
		print "<select name=$row->{'champ'} required>";
		if ($row->{'champ'} eq "code_fournisseur1"){
			$query="select fo2_cd_fo,fo2_add from fournis order by fo2_add";
			$sth = $dbh->prepare($query);
			$sth->execute;
			print '<option value="" disabled="disabled" selected="selected">Veuillez sélectionner un founisseur</option>';
			while (($fo2_cd_fo,$fo2_add) = $sth->fetchrow_array) {
				($fo2_nom)=split(/\*/,$fo2_add);
				print "<option value=$fo2_cd_fo>$fo2_cd_fo $fo2_nom</option>";
	 		}
		}
		else {	
			print "<option value=0></option>";
			$i=1;
			foreach(@alpha){
				print "<option value=$i>$_</option>";
				$i++;
			}
		}
		print "</select></div></div>";
	}
	print "Commencer l'importation à la ligne <input class=form_control type=number name=debut value=1><br>";
	print "<h3>Selectionner le fichier Excel</h3>";
	print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<span class=\"file-input btn btn-primary btn-file btn-sm\">";
	print "Parcourir... <input type=\"file\" name=fichier accept=application/xls maxlength=2097152>";
	print "</span><br><br>";
	print "<input type=hidden name=action value=upload>";
	print "<button type=submit class=\"btn btn-info\">Controle</button>"; 
	print "</form>";
	print "<button class=\"btn btn-danger pull-right\" onclick=window.close()>Fermer</button>"; 

}
	
if ($action eq "upload"){
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
	if ($message eq ""){
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
		print "<th>Prix achat actuel</th><th>Designation</th><th>Prix Sephora</th><th>Ecart</th>";
		print "</tr>";		
		print "</thead>";
		for ($l=$debut;$l<=$nb_ligne;$l++){
			$err=0;
			print "<tr>";
			$code=$book->[1]{cell}[$html->param("code")][$l];
			if (length($code)==0){next;}
			$code=~s/TR$//;
			if ($code=~/[A-Z]/g){
				$err=1;
				# print "Ligne $l code invalide ligne non traitée<br>";
				# next;	
			}
			$prixv=$book->[1]{cell}[$html->param("prixv")][$l]+0;
			$prac=$book->[1]{cell}[$html->param("prac")][$l]+0;
			if ($err==0){
				$inode=&get("select inode from dfc.produit_inode where code='$code'");
				if ($inode eq ""){
					$err=2;
					# print "Ligne $l code inconnu ligne non traitée<br>";
					# next;	
				}
			}
			if ($err==1) {print "<td class=bg-danger>Code invalide Non traité</td>";}
			if ($err==2) {print "<td class=bg-success>Code inconnu Non traité</td>";}
			if ($err==0){
			    $pr_desi=&get("select designation1 from produit_master where inode='$inode'");
				$query="select pr_prx_vte,pr_acquit from corsica.produit,corsica.produit_desi where pr_cd_pr=code and code='$code'";
				$sth=$dbh->prepare($query);
				$sth->execute();
				($pr_prx_vte,$pr_acquit)=$sth->fetchrow_array;
				$prac_run=&prac_corsica($code);
				print "<td></td><td>$code</td><td align=right>$prac</td><td align=right>$prixv</td><td align=right>$prac_run</td><td>$pr_desi</td>";
				($prix,$code_seph)=&get("select prix,code from sephora_ref where ref='$pr_acquit'");
				$lien=&get("select lien from sephora where code='$code_seph'");
				$ecart=0;
				$ecart=($prixv-$prix)*100/$prix if $prix!=0;
				$color="";
				$color="red" if $ecart>0;
				if ($prix ne ""){
					print "<td align=right><a href=http://www.sephora.fr$lien>$prix</a></td><td align=right style=color:$color>";
					printf("%.2f %",$ecart);
					printf "</td>";
				}
				else{
					print "<td align=right>Inconnu</td><td>&nbsp;</td>";
				}
				
			}
			else{print "<td>$code</td>";}
			print "</tr>";
		}
		print "</table>";
	}
	else {
		print "<p class=\"bg-danger\">$message</p>";
	}	
	print "<a href=?><button class=\"btn btn-success\">Retour</button></a>"; 
}	
print "</div></div></div>";
print "</body>";


sub nom_four_inode {
	my($inode)=$_[0];
	my($fo2_add)=&get("select fo2_add from dfc.fournis,dfc.produit_master where inode='$inode' and code_fournisseur1=fo2_cd_fo");
	my($nom)="";
	($nom,$null)=split(/\*/,$fo2_add);
	return($nom);
}	
	
sub prac_corsica()
{
	my($code)=$_[0];
	my($prac)=0;
	my($four)=0;
	my($valeur)=0;
	my($sth)=$dbh->prepare("select pr_prac,pr_four from corsica.produit where pr_cd_pr=$code");
	$sth->execute();
	($prac,$four)=$sth->fetchrow_array;
	$prac=$prac/100;
	my($query)="select valeur from corsica.remise_four where four='$four' order by rang";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($valeur)=$sth->fetchrow_array){
		$prac=$prac-$valeur*$prac/100;
	}
    $prac=int($prac*100)/100;	
	return($prac);
}
