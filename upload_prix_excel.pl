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
$ref_four=$html->param("ref_four");
$ref_code=$html->param("ref_code");
$user=$ENV{"REMOTE_USER"};
@alpha=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T");
$id=$html->param("id");
$encours=$html->param("encours");


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

if ($option eq "confirmer"){
	$libelle=$html->param("libelle");
	$libelle=~s/\"//g;
	$id=&get("select id from suivi_importation where date=curdate() and nom='$user' and libelle=\"$libelle\" and action='importation prix' and base='$base'");
	if ($id ne ""){
		&save("replace into suivi_importation (id,date,nom,libelle,action,base) values ($id,curdate(),'$user',\"$libelle\",'Importation prix','$base')","ff");
	}
	else{	
		&save("insert into suivi_importation (date,nom,libelle,action,base) values (curdate(),'$user',\"$libelle\",'Importation prix','$base')","af");
		$id=&get("SELECT LAST_INSERT_ID() FROM suivi_importation");
  	}	
	
}

if ($action eq "del"){
	$id=$html->param("id");
	&save("delete from produit_prac where id='$id'","chec");
	&save("update suivi_importation set action='Importation prix suppression',date=curdate() where id='$id'","chec");
	$action="";
}	
if ($action eq "confirmer_chg"){
	$id=$html->param("id");
	&save("insert ignore into suivi_importation_prac (id,date,nom) values ('$id',curdate(),'$user')");
	$action="";
}	

if ($action eq "change_aerien"){
	$suivi_base=&get("select base from suivi_importation where id='$id'");
	$query="select inode,prac from dfc.produit_prac where produit_prac.id='$id'"; 
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($inode,$prac) = $sth->fetchrow_array) {
		$prac+=0;
		$query="select min(code),max(code),designation1 from dfc.produit_master,dfc.produit_inode where produit_inode.inode='$inode' and produit_inode.inode=produit_master.inode"; 
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		($code_mini,$code,$pr_desi) = $sth2->fetchrow_array;
		foreach (split(/:/,$suivi_base)){
			$base=&get("select base_lib from base where base_id=$_");
			if (($base eq "tacv")||($base eq "camairco")||($base eq "aircotedivoire")||($base eq "togo")){
				&save("update $base.produit set pr_prac=$prac*100 where pr_cd_pr='$code_mini'","chec");
				&save("update dfc.produit set pr_prac=$prac*100 where pr_cd_pr='$code_mini'","chec");
				if ($encours eq "on"){
					&save("update $base.commande set com2_prac=$prac where com2_cd_pr='$code_mini'","chec");
				}
			}	
		}
	}	
	$action="compare";
}

if ($action eq "compare"){
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Produit</th>";
	print "<th>Prix</th>";

	$suivi_base=&get("select base from suivi_importation where id='$id'");
	foreach (split(/:/,$suivi_base)){
		print "<th colspan=2 style=text-align:center>";
		print ucfirst(&get("select base_lib from base where base_id=$_"));
		print "</th>";
	}
	print "</tr>";
	print "</thead>";
	$query="select inode,prac from dfc.produit_prac where produit_prac.id='$id'"; 
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($inode,$prac) = $sth->fetchrow_array) {
		$query="select min(code),max(code),designation1 from dfc.produit_master,dfc.produit_inode where produit_inode.inode='$inode' and produit_inode.inode=produit_master.inode"; 
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		($code_mini,$code,$pr_desi) = $sth2->fetchrow_array;
		print "<tr><td>$code $pr_desi</td><td align=right>$prac</td>";
		foreach (split(/:/,$suivi_base)){
			$base=&get("select base_lib from base where base_id=$_");
			$prac_base=&get("select pr_prac from $base.produit where pr_cd_pr='$code'","af");
			if ($base eq "dutyfreeambassade"){
				$prac_base=&get("select prix_unite from $base.produit_four where ref_dfa='$code'","af")*100;
			}
			if (($base eq "tacv")||($base eq "camairco")||($base eq "aircotedivoire")||($base eq "togo")){
				$prac_base=&get("select pr_prac from $base.produit where pr_cd_pr='$code_mini'","af");
				$aerien=1;
			}	
			if ($prac_base eq ""){$prac_base="Non referencé";$pour="";}
			else{
				$prac_base/=100;
				$pour=0;
				if ($prac!=0){$pour=($prac-$prac_base)/$prac;}
				$pour=int($pour*10000)/100;
			}	
		print "<td align=right>$prac_base</td><td align=right>$pour%</td>";
		}
		print "</tr>";
	}
	print "</table>";
	$query="select nom,date from suivi_importation_prac where id='$id'";
	$sth = $dbh->prepare($query);
	$sth->execute;
	($nom,$date) = $sth->fetchrow_array;
	if ($nom ne ""){
		print "<div class=\"alert alert-success\">prix validé par $nom le $date</div>";
		if ($aerien==1){
			print "<form>";
			print "<input type=hidden name=action value=change_aerien>";
			print "<input type=hidden name=id value=$id>";
			print "<td><button class=\"btn btn-primary btn-sm \" role=submit>Changer les prix sur les bases aeriennes</span></button> modifier cde en cours <input type=checkbox name=encours></td>";
			print "</form>";
		}
		
	}
	else {
		print "<form>";
		print "<input type=hidden name=action value=confirmer_chg>";
		print "<input type=hidden name=id value=$id>";
		print "<td><button class=\"btn btn-primary btn-sm \" role=submit>Valider les prix sous le nom de $user</span></button></td>";
		print "</form>";
	}
}	




if ($action eq ""){
	print "<div class=\"alert alert-info\">Importation Prix</div>";
	print "<form role=form method=POST enctype=multipart/form-data>";
print <<EOF;
	<label for="dtp_input2" class="control-label">Saisir une Date</label>
	<div class="input-group date form_date col-md-3" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd"> 
		<input class="form-control" size="16" type="text" value="" readonly>
		<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
	</div>
	<input type="hidden" id="dtp_input2" value="" name=date /><br/>
EOF
    # print "Date de validité du tarif <input id=datepicker><br>";
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
		print "</select>";
		print "</div></div>";
	}
	print "Ref fournisseur à la place du code barre <input type=checkbox name=ref_four><br>";
	print "Code produit à la place du code barre <input type=checkbox name=ref_code><br>";
	print "<h3>Selectionner les bases concernées</h3>";
	$query="select distinct base_type from dfc.base";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($base_type) = $sth->fetchrow_array) {
		print "<div>";
		print ucfirst($base_type)," <input type=checkbox name='$base_type' checked>";
		print "</div>";
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
	print "<h3>Liste des précédentes opérations</h3>";
	$query="select id,date,nom,libelle,action,base from suivi_importation where action like 'Importation prix%' and action not like '%suppression%' order by date desc";
	$sth = $dbh->prepare($query);
	$sth->execute;
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr class=\"success\"><th>Date Importation</th><th>Date Validitée</th><th>Nom</th>";
	print "<th>Check</th>";
	print "<th>Fournisseur</th><th>Libelle</th><th>Action</th><th>Base</th></tr>";
	print "</thead>";
	while (($id,$date,$nom,$libelle,$action,$suivi_base) = $sth->fetchrow_array) {
		$date_validite=&get("select date from produit_prac where id='$id' limit 1");
		$inode=&get("select inode from produit_prac where id='$id' limit 1");
		print "<tr><td>$date</td><td>$date_validite</td><td>$nom</td><td>";
		$check=&get("select nom from suivi_importation_prac where id='$id'");
		if ($check ne ""){print "<span class=\"glyphicon glyphicon-ok\" style=color:#5cb85c></span>";}else {print "&nbsp;";}
		print "<td>";
		print &nom_four_inode($inode);
		print "</td><td>$libelle</td><td>$action </td><td>";
		@base_faite=split(/:/,&get("select fait from suivi_importation_prac where id='$id'"));
		foreach (split(/:/,$suivi_base)){
			if (grep(/$_/,@base_faite)){$color="#5cb85c";}else{$color="";}
			print "<span style=color:$color>";
			print &get("select base_lib from base where base_id=$_","af");
			print "</span> ";
		}
		print "</td>";
		print "<td>";
		print "<form>";
		print "<input type=hidden name=action value=compare>";
		print "<input type=hidden name=id value=$id>";
		if (! grep/suppression/,$action){
			print "<button class=\"btn btn-primary btn-sm \" role=submit><span class=\"glyphicon glyphicon-transfer\"></span></button>";
		}
		print "</form>";
		print "</td>";
		print "<td>";
		print "<form>";
		print "<input type=hidden name=action value=del>";
		print "<input type=hidden name=id value=$id>";
		if (! grep/suppression/,$action){
			print "<button class=\"btn btn-danger btn-sm \" role=submit onclick=\"return confirm('Etes vous sur de vouloir supprimer')\"><span class=\"glyphicon glyphicon-trash\"></span></button>";
		}
		print "</form>";
		print "</td>";
		print "</tr>";
	}
	print "</table>";
}
	
if ($action eq "upload"){
	if ($option ne "confirmer"){
		$fichier=$html->param("fichier");
		print "<div class=\"alert alert-info\">$fichier</div>";
		if ($date eq ""){$message="Aucune date selectionnée";}
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
		$query="select distinct base_type from dfc.base";
		$sth = $dbh->prepare($query);
		$sth->execute;
		$base="";
		while (($base_type) = $sth->fetchrow_array) {
			if ($html->param("$base_type") eq "on"){
				$query="select base_id from base where base_type='$base_type'";
				$sth2 = $dbh->prepare($query);
				$sth2->execute;
				while (($base_id) = $sth2->fetchrow_array) {
					if ($base eq ""){$base=$base_id;}else{$base.=":$base_id";}
				}	
			}	
		}	
		if ($base eq ""){$message="Merci de selectionner une base";}
	}
	
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
		print "</tr>";		
		print "</thead>";
		for ($l=$debut;$l<=$nb_ligne;$l++){
			$err=0;
			print "<tr>";
			$code=$book->[1]{cell}[$html->param("code")][$l];
			if (length($code)==0){next;}
			if ($ref_four eq "on"){
				$code=&get("select code from dfc.produit_inode,dfc.produit_master where produit_inode.inode=produit_master.inode and  refour1='$code'");
				if ($code eq ""){$code="nill";$err=2;}
			}
			if ($ref_code eq "on"){
				$code=&get("select code from dfc.produit_inode,dfc.produit_master where produit_inode.inode=produit_master.inode and  produit_inode.code='$code'");
				if ($code eq ""){$code="nill";$err=2;}
			}
			
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

			$prac=$book->[1]{cell}[$html->param("prac")][$l]+0;
			if ($prac==0){$err=3;}
			if ($err==1) {print "<td class=bg-danger>Code invalide Non traité</td>";}
			if ($err==2) {print "<td class=bg-success>Code inconnu Non traité</td>";}
			if ($err==3) {print "<td class=bg-success>Prix achat à zero Non traité</td>";}
			
			if (($err!=2)&&($err!=1)&&($err!=3)) {print "<td>Ok</td>";}
			print "<td>$code</td>";
			$query="update dfc.produit_prac set ";
			foreach (@champ){
				$row=decode_json($_);
				# print $html->param("$row->{'champ'}")." ".$row->{'champ'}."<br>";
				if (($html->param("$row->{'champ'}")!=0)&&($row->{'champ'} ne "code")){
					$j=$html->param("$row->{'champ'}");
					$row->{'valeur'}=$book->[1]{cell}[$j][$l];
					$row->{'valeur'}=~s/"//g;
					if ($row->{'champ'} eq "code_fournisseur1"){$row->{'valeur'}=$html->param("code_fournisseur1");}
					$query.=$row->{'champ'}."="."'".$row->{'valeur'}."',";
					print "<td>";
					print $row->{'valeur'};
					print "</td>";
				}
			}
			chop($query);
			# if ($four ne ""){
				# $query.=",code_fournisseur1='$four' ";
			# }	
			print "</tr>";
			if (($option eq "confirmer")&&($err!=1)&&($err!=2)&&($err!=3)){
				$query2="insert ignore into produit_prac (id,inode,date,base) value ('$id','$inode','$date','$base')";
				$query.=" where id=$id and inode='$inode' and date='$date'";
				print "<tr><td colspan=4 style=font-size:0.7em>";
				&save("$query2","af");
				&save("$query","af");
				print "</td></tr>";
			}
		}
		print "</table>";
		if ($option ne "confirmer"){
			print "<form>";
			print "Info importation <input type=text name=libelle size=100>";
			print "<input type=hidden name=action value=upload>";
			print "<input type=hidden name=base value='$base'>";
			print "<input type=hidden name=debut value='$debut'>";
			print "<input type=hidden name=option value=confirmer>";
			print "<input type=hidden name=date value='$date'>";
			print "<input type=hidden name=ref_four value='$ref_four'>";
			print "<input type=hidden name=ref_four value='$ref_code'>";
			print "<br><button type='submit' class='btn btn-default'>Confirmer</button>";
			foreach (@champ){
				$row=decode_json($_);
				# if ($row->{'champ'} eq "code_fournisseur1"){print "<input type=hidden name=".$row->{'champ'}." value=".$html->param("code_fournisseur1").">\n";}
				print "<input type=hidden name=".$row->{'champ'}." value=".$html->param("$row->{'champ'}").">\n";
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
print "</div></div></div>";
print <<EOF;
<script type="text/javascript">
   \$('.form_date').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 2,
		minView: 2,
		forceParse: 0
    });
	\$('.form_time').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 1,
		minView: 0,
		maxView: 1,
		forceParse: 0
    });
</script>
</body>
EOF
print "</body>";


sub nom_four_inode {
	my($inode)=$_[0];
	my($fo2_add)=&get("select fo2_add from dfc.fournis,dfc.produit_master where inode='$inode' and code_fournisseur1=fo2_cd_fo");
	my($nom)="";
	($nom,$null)=split(/\*/,$fo2_add);
	return($nom);
}	
	
