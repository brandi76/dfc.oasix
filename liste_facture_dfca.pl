#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");

if ($action eq "maj"){
	$delai=$html->param("delai");
	$four=$html->param("four");
	&save("update dfc.fournis set fo_delai_pai='$delai' where fo2_cd_fo='$four'","af");
	$action="";
}	
if ($action eq "maj_reg"){
	$date=$html->param("date");
	$reglement=$html->param("reglement");
	$mode=$html->param("mode");
	$info=$html->param("info");
	$info=~s/[^A-Za-z0-9 éèà_-ç]//g;
	$liv_id=$html->param("liv_id");
	&save("replace into reglement_dfca values ('$liv_id','$date','$mode','$reglement','$info')"); 
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

if ($action=~/^reg/){
	($null,$bl)=split(/_/,$action);
	$query="select * from livraison_h where livh_id='$bl' and livh_base='corsica'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array;
	$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	($fo_nom)=split(/\*/,$fo_add);
	$query="select * from dfc.reglement_dfca where reg_id='$livh_id'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$date,$mode,$reglement,$info)=$sth->fetchrow_array;
	if ($mode eq ""){$mode="Virement";}
	$reglement+=0;
	$montant=&get("select total_tva from dfc.facture_corse where bl='$livh_id'");
	$montant=int($montant*100)/100;
	if ($reglement ==0){$reglement=$montant;}
print <<EOF;
	<div class="alert alert-info" >
	<h3>Bl:$livh_id $livh_base Facture:$livh_facture $fo_nom</h3>
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
						<input type="hidden" name=liv_id value="$livh_id" />
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

	&save("create temporary table cde_tmp (four varchar(30),bl int(8),facture varchar(30),date_fature date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2))");
	$query="select facture,fichier,total_tva,bl from facture_corse order by facture";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($facture,$fichier,$total_tva,$bl)=$sth->fetchrow_array){
		$facture_desi=$fichier;
		($null,$fournisseur)=split(/_/,$facture_desi);
		$fournisseur=$facture_desi;
		$fournisseur=~s/^CDF_//g;
		$fournisseur=~s/[0-9]//g;
		$fournisseur=~s/_/ /g;
		$fournisseur=~s/\.pdf//g;
		$date_facture=&get("select es_dt from corsica.enso,corsica.enthead where es_no_do=enh_no and enh_document='$bl'");	
		# $fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		$fo_delai=30;
		if (&get("select year(adddate('$date_facture',$fo_delai))")+0<2016){next;};
	
		$reglement=&get("select sum(montant) from dfc.reglement_dfca where reg_id='$bl'")+0;
		&save("insert into cde_tmp values ('$fournisseur','$bl','$facture','$date_facture',adddate('$date_facture','$fo_delai'),'$total_tva','$fo_delai','$reglement')","af");
	}
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des factures Corsica</h3>";
	print "	</div>";
	if ($message ne ""){
		print "<div class=\"alert alert-danger\">";
		print "<h3>$message</h3>";
		print "	</div>";
	}
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Fournisseur</th>";
	print "<th>Bon de livraison</th>";
	print "<th>Delai paiement</th>";
	print "<th>Facture</th>";
	print "<th>Date Echeance</th>";
	print "<th>Date Facture</th>";
	print "<th>Montant</th>";
	print "<th>Reglement</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from cde_tmp order by date_echance";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($four,$bl,$facture,$date_facture,$date_echeance,$montant,$delai,$reglement)=$sth->fetchrow_array){
		$semaine=&get("select week('$date_echeance',3)");
		if ($semaine ne $semaine_run){
			if ($total >0){
				print "<tr style=font-weight:bold><td colspan=7>Total Semaine $semaine_run</td><td align=right>$total_int</td></tr>";
				$total_int=0;
			}
			$semaine_run=$semaine;
		}
		$entree_faite=&get("select count(*) from corsica.enthead where enh_document='$bl'")+0; 

		# $fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		# $entree_faite=&get("select count(*) from $livh_base.enthead where enh_document='$livh_id'")+0; 
		print "<tr><td>$four</td>";
		print "<td>$bl</td>	<td>$delai</td>";
		print "<td>$facture</td><td class=warning>$date_echeance</td><td>$date_facture</td><td align=right>$montant</td>";
		print "<td align=right><form>$reglement  <button type=submit class=\"btn btn-success btn-sm pull-right\" name=action value=reg_${bl}><span class=\"glyphicon glyphicon-pencil\"></span></button></form></td>";
		print "<td align=center>";
		if ($entree_faite>0){
			print "<img src=http://dfc.oasix.fr/images/check.png>";
		}
		print "</td></tr>";
		$total+=$montant;
		$total_reglement+=$reglement;
		$total_int+=$montant;
	}
	if ($total >0){
		print "<tr style=font-weight:bold><td colspan=7>Total Semaine $semaine_run</td><td align=right>$total_int</td></tr>";
		$total_int=0;
	}
	print "<tr style=\"font-weight:bold\" class=success><td colspan=7>Total facture</td><td align=right>$total</td></tr>";
	print "<tr style=\"font-weight:bold\" class=success><td colspan=7>Total reglé</td><td align=right>$total_reglement</td></tr>";
	$solde_du=$total-$total_reglement;
	print "<tr style=\"font-weight:bold\" class=success><td colspan=7>Solde Du</td><td align=right>$solde_du</td></tr>";
	print "</table>";
}
print "		
		</div>
	</div>
</div>";
