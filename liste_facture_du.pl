#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$client=$html->param("client");

push(@bases_client,"corsica");
push(@bases_client,"cameshop");

if ($action eq "maj"){
	$delai=$html->param("delai");
	$four=$html->param("four");
	&save("update dfc.fournis set fo_delai_pai='$delai' where fo2_cd_fo='$four'","af");
	$action="";
}
$date_fin="2015-12-31";	
if ($action eq "maj_reg"){
	$date=$html->param("date");
	$reglement=$html->param("reglement");
	$mode=$html->param("mode");
	$info=$html->param("info");
	$info=~s/[^A-Za-z0-9 éèà_-ç]//g;
	$liv_id=$html->param("liv_id");
	&save("replace into reglement values ('$liv_id','$date','$mode','$reglement','$info')"); 
	$action="";
	$message="Reglement pour un montant de $reglement enregistré";
}	

	
print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>

</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

if ($action=~/^delai/){
	($null,$four)=split(/_/,$action);
	$query="select fo_delai_pai,fo2_add from dfc.fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($delai,$fo_add)=$sth->fetchrow_array;
	($fo_nom)=split(/\*/,$fo_add);

print <<EOF;
	<div class="alert alert-info" >
	<h3>$fo_nom</h3>
	</div>
	<form role="form">
				<fieldset>
					<div class="form-group">
						<label for="dtp_input2" class="control-label">Delai de paiement</label>
						<div class="input-group col-md-3"> 
							<input class="form-control" size="16" type="text" value="$delai" id="dtp_input2" name=delai>
						</div>
						<input type="hidden" name=action value="maj" />
						<input type="hidden" name=four value="$four" />
					</div>
				</fieldset>
			<button type="submit" class="btn btn-info">Submit</button>
	</form>
EOF
}
if ($action=~/^reg/){
	($null,$liv_id)=split(/_/,$action);
	$query="select * from livraison_h where livh_id='$liv_id'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array;
	$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	($fo_nom)=split(/\*/,$fo_add);
	$query="select * from dfc.reglement where reg_id='$livh_id'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$date,$mode,$reglement,$info)=$sth->fetchrow_array;
	if ($mode eq ""){$mode="Virement";}
	$reglement+=0;
	$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	$montant=int($montant*100)/100;
	$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	$montant+=$frais;
	if ($reglement ==0){$reglement=$montant;}
print <<EOF;
	<div class="alert alert-info" >
	<h3>Bl:$livh_id $livh_base Facture:$livh_facture $fo_nom</h3>
	</div>
	<div>
		<form role="form">
			<fieldset>
				<div class="form-group">
					<label for="dtp_input1" class="control-label">Montant du reglement</label>
					<div class="input-group col-md-6"> 
						<input class="form-control" size="16" type="text" value="$reglement" id="dtp_input1" name=reglement>
					</div>
					<label for="dtp_input2" class="control-label">Date</label>
    </div>
	<form role="form">
				<fieldset>
					<div class="form-group">
						<label for="dtp_input1" class="control-label">Montant du reglement</label>
						<div class="input-group col-md-6"> 
							<input class="form-control" size="16" type="text" value="$reglement" id="dtp_input1" name=reglement>
						</div>
						<label for="dtp_input2" class="control-label">Date</label>
						<div class="input-group date form_date col-md-3" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd"> 
							<input class="form-control" size="16" type="text" value="$date" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
						</div>
						<input type="hidden" id="dtp_input2" value="" name=date /><br/>
						<label for="dtp_input3" class="control-label">Mode</label>
						<div class="input-group col-md-6">
							<input class="form-control" size="16" type="text" value="$mode" id="dtp_input3" name=mode>
						</div>
						<label for="dtp_input4" class="control-label">Commentaire</label>
						<div class="input-group col-md-12"> 
							<input class="form-control" size="16" type="text" value="$info" id="dtp_input4" name=info>
						</div>
						<input type="hidden" name=action value="maj_reg" />
						<input type="hidden" name=liv_id value="$liv_id" />
					</div>
				</fieldset>
			<button type="submit" class="btn btn-info">Submit</button>
	</form>
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

}

if ($action eq ""){
    if ($client eq ""){
		print "<form><select name=client class=\"form-control\">";
		foreach $client (@bases_client){
			if ($client eq "dfc"){next;}
			print "<option value=$client>$client</option>";
		}
		print "</select>";
		print "<button type=\"submit\" class=\"btn btn-success\">Filtrer</button>";
		print "</form>";
		$client="%";
	}
   
	&save("create temporary table cde_tmp (base varchar(20),four int(8),id int(8),facture varchar(30),date_fature date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2))");
	$query="select * from livraison_h where livh_date >='2015-06-01' and livh_base like '$client' order by livh_date_facture";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		# if (&get("select year(adddate('$livh_date_facture',$fo_delai))")+0<2016){next;};
		$echeance=&get("select adddate('$livh_date_facture',$fo_delai)");
		# je vire les factures dont l'echance depasse la date de fin
		if (&get("select datediff('$echance','$date_fin')")>0){next;};
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		if ($montant==0){next;}
		# je vire les factures réglé à avant la date de fin
		$reglement=&get("select sum(montant) from dfc.reglement where reg_id='$livh_id' and date<='$date_fin'")+0;
		if ($reglement>==$montant){next;}
		&save("insert into cde_tmp values ('$livh_base','$livh_four','$livh_id','$livh_facture','$livh_date_facture',adddate('$livh_date_facture','$fo_delai'),'$montant','$fo_delai','$reglement')","af");
	}
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des factures</h3>";
	print "	</div>";
	
	if ($message ne ""){
		print "<div class=\"alert alert-danger\">";
		print "<h3>$message</h3>";
		print "	</div>";
	}
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Base</th>";
	print "<th>Fournisseur</th>";
	print "<th>Delai paiement</th>";
	print "<th>Bon de livraison</th>";
		print "<th>Facture</th>";
	print "<th>Date Echeance</th>";
	print "<th>Date Facture</th>";
	print "<th>Montant</th>";
	if ($client eq "corsica"){
			print "<th>montant refacturation</td>";
	}
	print "<th>Reglement</th>";
	print "<th>Livrée</th>";
	print "<th>Date entrée</th>";
	print "<th>Delai</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from cde_tmp order by date_echance";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($livh_base,$livh_four,$livh_id,$livh_facture,$date_facture,$date_echeance,$montant,$delai,$reglement)=$sth->fetchrow_array){
		$semaine=&get("select week('$date_echeance',3)");
		if ($semaine ne $semaine_run){
			if ($total >0){
				print "<tr style=font-weight:bold><td colspan=7>Total Semaine $semaine_run</td><td align=right>$total_int</td></tr>";
				$total_int=0;
			}
			$semaine_run=$semaine;
		}
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'")+0; 
		if ($date_entree==0){$date_entree="0000-00-00";}else{$date_entree=&julian($date_entree,"YYYY-MM-DD");}
		print "<tr><td>$livh_base</td><td>$fo_nom</td>";
		print "<td><form> $delai <button type=submit class=\"btn btn-success btn-sm pull-right\" name=action value=delai_${livh_four}><span class=\"glyphicon glyphicon-pencil\"></span></button></form></td>";
		print "<td>$livh_id</td><td>$livh_facture</td><td class=warning>$date_echeance</td><td>$date_facture</td><td align=right>$montant</td>";
		if ($client eq "corsica"){
			$montant_corse=&get("select total_tva from facture_corse where bl=$livh_id")+0;
			print "<td align=right>$montant_corse</td>";
		}
		print "<td align=right><form>$reglement <button type=submit class=\"btn btn-success btn-sm pull-right\" name=action value=reg_${livh_id}><span class=\"glyphicon glyphicon-pencil\"></span></button></form></td>";
		print "<td align=center>";
		if ($date_entree ne "0000-00-00"){
			print "<img src=http://dfc.oasix.fr/images/check.png>";
			$delai_entree=&get("select datediff('$date_echeance','$date_entree')");
		}
		else {
			print "<img src=http://dfc.oasix.fr/images/checkr.png>";
			$delai_entree="";
		}	
		print "<td>$date_entree</td><td align=right>$delai_entree</td>";
		print "</tr>";
		$total+=$montant;
		$total_int+=$montant;
	}
	if ($total >0){
		print "<tr style=font-weight:bold><td colspan=7>Total Semaine $semaine_run</td><td align=right>$total_int</td></tr>";
		$total_int=0;
	}
	print "<tr style=\"font-weight:bold\" class=success><td colspan=7>Total</td><td align=right>$total</td></tr>";
	print "</table>";
}
print "		
		</div>
	</div>
</div>";
