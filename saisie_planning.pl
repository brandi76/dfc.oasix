#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$option=$html->param("option");
$date=$html->param("date");
$fl_date=$html->param("fl_date");
$fl_vol=$html->param("fl_vol");
$flb_rot=$html->param("flb_rot");
$flb_datetr=$html->param("flb_datetr");
$flb_voltr=$html->param("flb_voltr");
$flb_tridep=$html->param("flb_tridep");
$flb_triret=$html->param("flb_triret");
$fl_troltype=$html->param("fl_troltype");
$date_fin=$html->param("date_fin");

if (($option ne "")&&($action eq "")){
	($option,$param)=split(/_/,$option);
	$action="go";
}	

$fl_apcode=&get("select fl_apcode from flyhead where fl_date='$fl_date' and fl_vol='$fl_vol'")+0; 

if ($option eq "recopievol"){
	$date_finjl=&nb_jour_sql($date_fin);
	$nb_recopie=0;
	$query="select * from flyhead where fl_date='$fl_date' and fl_vol='$fl_vol'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$null,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nbtrol,$fl_troltypebis,$fl_nolot,$fl_part,$fl_apcode)=$sth->fetchrow_array;
	for ($i=$fl_date+7;$i<=$date_finjl;$i=$i+7){
		$datesql=&julian($i,"yyyy-mm-dd");
		&save("insert ignore into flyhead value ('$i','$fl_vol','$base_client','$fl_nbrot','$fl_troltype','$fl_nbtrol','$fl_troltypebis','0','$fl_part','0','$datesql')","chec");
		$nb_recopie++;
		$query="select * from flybody where flb_date='$fl_date' and flb_vol='$fl_vol' order by flb_rot";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=$sth->fetchrow_array){
			$j=$i+($flb_datetr-$fl_date);
			&save("replace into flybody value ('$i','$flb_vol','$flb_rot','$j','$flb_voltr','0','0','$flb_tridep','$flb_triret','0')","chec");
		}
	}
	if ($nb_recopie >0){
		$message="$nb_recopie Vol(s) Copié(s)"; 
	}
	else {
			$message="Aucun vol copié !"; 
	}
}
if ($option eq "updatetroltype"){
	&save("update flyhead set fl_troltype='$fl_troltype' where fl_date='$fl_date' and fl_vol='$fl_vol'","chec");
	$action="go";
}

if ($action eq "ajoutvol"){
	if ($fl_vol ne ""){
		$datejl=&nb_jour_sql($date);
		$fl_troltype=&get("select fl_troltype from flyhead where fl_apcode!=0 order by fl_date desc")+0;
		$flb_tridep=&get("select flb_tridep from flybody where flb_rot=11 order by flb_date desc limit 1");
		&save("insert ignore into flyhead value ('$datejl','$fl_vol','$base_client','1','$fl_troltype','0','0','0','1','0','$date')","chec");
		&save("insert ignore into flybody value ('$datejl','$fl_vol','10','$datejl','$fl_vol','0','0','$flb_tridep','','0')","chec");
	}	
	$action="go";
}	

if ($action eq "liste"){
	print "Vol du $date<br>";
	$datejl=&nb_jour_sql($date);
	$query="select flb_vol,flb_depart from flybody where flb_date='$datejl' and flb_rot=11 order by flb_depart";  
	$sth=$dbh->prepare($query);
	$sth->execute();
	$trajet="";
	while (($flb_vol,$flb_depart)=$sth->fetchrow_array){
		$query="select flb_arrivee,flb_datetr,flb_tridep,flb_triret from flybody where flb_vol='$flb_vol' and flb_date='$datejl' order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$trajet="";
		while ((@flb)=$sth2->fetchrow_array){
			$flb_arrivee=$flb[0];
			$flb_datetr=$flb[1];
			$flb_tridep=$flb[2];
			$flb_triret=$flb[3];
			$trajet=$trajet.$flb_tridep."/";
		}
		$trajet=$trajet.$flb_triret;
		$flb_depart=$flb_depart/100;
		($heure,$minute)=split(/\./,$flb_depart);
		$minute=$minute*10 if ($minute<10);
		print "$flb_vol ${heure}h${minute} $trajet <br>";
	}	
}

if ($option eq "supvol"){
	$check=&get("select fl_apcode from flyhead where fl_date='$fl_date' and fl_vol='$fl_vol'")+0; 
	if ($check == 0){
		$message="Impossible ce vol a fait l'objet d'un bon d'appro";
	}
	else {
		&save("delete from flyhead where fl_date='$fl_date' and fl_vol='$fl_vol' limit 1","chec");
		&save("delete from flybody where flb_date='$fl_date' and flb_vol='$fl_vol'","chec");
	}
}

if ($option eq "addleg"){
	$flb_datetr=&nb_jour_sql(&datepicker($flb_datetr));
	&save("insert ignore into flybody value ('$fl_date','$param','$flb_rot','$flb_datetr','$flb_voltr','0','0','$flb_tridep','$flb_triret','0')","chec");
	$nb_rot=(int(&get("select max(flb_rot) from flybody where flb_date='$fl_date' and flb_vol='$fl_vol'","chec")+0)/10);
	&save("update flyhead set fl_nbrot='$nb_rot' where fl_date='$fl_date' and fl_vol='$fl_vol'","chec");
	$fl_apcode=&get("select fl_apcode from flyhead where fl_vol='$fl_vol' and fl_date='$fl_date'")+0;
	if ($fl_apcode >0){&maj_vol();}
}	
if ($option eq "modifleg"){
	$flb_datetr=&nb_jour_sql(&datepicker($flb_datetr));
	$flb_depart=$html->param("flb_depart");
	$flb_depart=~s/://g;
	$flb_arrivee=$html->param("flb_arrivee");
	$flb_arrivee=~s/://g;
	&save("replace into flybody value ('$fl_date','$param','$flb_rot','$flb_datetr','$flb_voltr','$flb_depart','$flb_arrivee','$flb_tridep','$flb_triret','0')","chec");
	$fl_apcode=&get("select fl_apcode from flyhead where fl_vol='$fl_vol' and fl_date='$fl_date'")+0;
	if ($fl_apcode >0){&maj_vol();}
}	

if (($option eq "ajouttron")||($option eq "modiftron")){
	$param2=$fl_vol;
}	

if ($option eq "supleg"){
	$check=0;
	if (($fl_apcode>0)&&($param%10==1)){
		$rot=int($param/10);
		$check=&get("select ca_fly from caisse where ca_code='$fl_apcode' and ca_rot='$rot'","af")+0;
		if ($check>0){
			$message="Impossible une caisse a été saisie pour cette rotation";
		}
	}	
	if ($check==0){		
		$flb_datetr=&nb_jour_sql(&datepicker($flb_datetr));
		&save("delete from flybody where flb_date='$fl_date' and flb_vol='$fl_vol' and flb_rot='$param'","chec");
		$nb_rot=(int(&get("select max(flb_rot) from flybody where flb_date='$fl_date' and flb_vol='$fl_vol'","chec")+0)/10);
		&save("update flyhead set fl_nbrot='$nb_rot' where fl_date='$fl_date' and fl_vol='$fl_vol'","chec");
		$fl_apcode=&get("select fl_apcode from flyhead where fl_vol='$fl_vol' and fl_date='$fl_date'")+0;
		if ($fl_apcode >0){&maj_vol();}
	}
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
if ($action eq ""){
print <<EOF;
			<div class="alert alert-info" >
			<h3>Gestion Planning de Vol</h3>
			</div>
			<form role="form">
				<fieldset>
					<div class="form-group">
						<label for="dtp_input2" class="control-label">Saisir une Date</label>
						<div class="input-group date form_date col-md-3" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd"> 
							<input class="form-control" size="16" type="text" value="" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
						</div>
						<input type="hidden" id="dtp_input2" value="" name=date /><br/>
						<input type="hidden" name=action value="go" />
					</div>
				</fieldset>
			<button type="submit" class="btn btn-info">Submit</button>
			</form>
		</div>
	</div>
</div>
EOF
}
if ($action eq "go"){
	print "<div class=well><h3>";
	print &date_fr($date);
	print "</h3></div>";
	if ($message ne ""){
		print "<h3 class=\"bg-danger text-center\">$message</h3>"; 
	}
	print "<table class=\"table table-condensed table-bordered table-hover \">";
	print "<thead>";
	print "<tr class=\"info\">";
	print "<th>No de vol</th>";
	print "<th>Destination</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from flyhead where fl_date_sql='$date'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nbtrol,$fl_troltypebis,$fl_nolot,$fl_part,$fl_apcode)=$sth->fetchrow_array){
		print "<tr><td>";
		print "<form role=form>";
		print "<input type=hidden name=date value='$date'>";
		print "<input type=hidden name=fl_date value='$fl_date'>";
		print "<input type=hidden name=fl_vol value='$fl_vol'>";

		if (($option eq "recopie")&&($fl_vol eq "$param")){
			
print <<EOF;
			<div class="form-group">
				Date butoire:
				<div class="input-group date form_date" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd" style=width:200px> 
					<input class="form-control" type="text" value="$date" readonly>
					<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
				</div>
				<input type="hidden" id="dtp_input2" value="$date" name=date_fin />
			</div>
EOF
			print " <button type=submit class=\"btn btn-success btn-sm\" name=option value=recopievol_${fl_vol}>Submit</button> <button type=submit class=\"btn btn-primary btn-sm \" onclick=history.back()>Cancel</button>";
		}
		else {
			print "No vol:$fl_vol ";
			print "<button type=submit class=\"btn btn-success btn-sm \" name=option value=recopie_${fl_vol}>Recopier</button>";
			if ($fl_apcode==0){
				print " <button type=submit class=\"btn btn-danger btn-sm pull-right\" name=option value=supvol_${fl_vol}><span class=\"glyphicon glyphicon-trash\"></span></button>";
			}
			print "<br><br>";
		}
		if ($option ne "recopie"){
		    if ($fl_apcode==0){
				if (($option eq "modtroltype")&&($fl_vol eq "$param")){
					print "Trolley type:<input type=text name=fl_troltype value='$fl_troltype' required>";
					print " <button type=submit class=\"btn btn-success btn-sm\" name=option value=updatetroltype_${fl_vol}>Submit</button> <button type=submit class=\"btn btn-primary btn-sm\" onclick=history.back()>Cancel</button>";
				}
				else {
					print "Trolley type:$fl_troltype";
					print "<button type=submit class=\"btn btn-success btn-sm \" name=option value=modtroltype_${fl_vol}><span class=\"glyphicon glyphicon-pencil\"></span></button>";
				}
			}
			else {
				print "<p style=background:#f0ad4e> Bon d'appro No:$fl_apcode Trolley type:$fl_troltype</p>";
			}
		}
		print "</form>";
		print "</td><td>";
		print "<form role=form>";
		print "<input type=hidden name=fl_vol value='$fl_vol'>";
		print "<table class=\"table table-condensed table-bordered table-hover \">";
		print "<thead>";
		print "<tr class=\"success\">";
		print "<th>Leg</th><th>No de vol</th><th>Date</th>";
		print "<th>Depart</th>";
		print "<th>Arrivee</th><th>Action</th>";
		print "</tr>";
		print "</thead>";
		$query="select * from flybody where flb_date='$fl_date' and flb_vol='$fl_vol' order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=$sth2->fetchrow_array){
			$leg=int($flb_rot/10);
			$bute=($leg+1)*10;
			$maxrot=&get("select max(flb_rot) from flybody where flb_date='$fl_date' and flb_vol='$fl_vol' and flb_rot<$bute");
			$flb_triret_sv=$flb_triret;
			$flb_voltr_sv=$flb_voltr;
			$flb_datetr_sv=&julian($flb_datetr);
			$datetr=&julian($flb_datetr);
			if ($flb_depart eq "0"){$flb_depart="";}else{$flb_depart=int($flb_depart/100).":".substr($flb_depart,length($flb_depart)-2,2);}
			if ($flb_arrivee eq "0"){$flb_arrivee="";}else{$flb_arrivee=int($flb_arrivee/100).":".substr($flb_arrivee,length($flb_arrivee)-2,2);}
				
			if (($option eq "modiftron")&&($flb_rot eq $param)&&($fl_vol eq $param2)){
				print "<input type=hidden name=flb_rot value='$flb_rot'>";
				print "<tr><td style=font-size:0.8em>Equipage $leg</td><td><input type=text name=flb_voltr value='$flb_voltr_sv' required></td><td>";
print <<EOF;
					<div class="form-group">
						<div class="input-group date form_date" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd" style=width:200px> 
							<input class="form-control" type="text" value="$flb_datetr_sv" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
						</div>
						<input type="hidden" id="dtp_input2" value="$flb_datetr_sv" name=flb_datetr />
					</div>
					
EOF
				print "</td><td><input name=flb_tridep value='$flb_tridep' required>";
print <<EOF;				
					<div class="form-group">
						<div class="input-group date form_time" data-date="" data-date-format="hh:ii" data-link-field="dtp_input3" data-link-format="hh:ii" style=width:100px> 
							<input class="form-control" type="text" value="$flb_depart" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-time"></span></span>
						</div>
						<input type="hidden" id="dtp_input3" value="$flb_depart" name=flb_depart />
					</div>
EOF
				
				print "</td><td><input name=flb_triret value='$flb_triret' required>";
print <<EOF;				
					<div class="form-group">
						<div class="input-group date form_time" data-date="" data-date-format="hh:ii" data-link-field="dtp_input4" data-link-format="hh:ii" style=width:100px> 
							<input class="form-control" type="text" value="$flb_arrivee" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-time"></span></span>
						</div>
						<input type="hidden" id="dtp_input4" value="$flb_arrivee" name=flb_arrivee />
					</div>
EOF

				print "</td>";
				print "<td>";
				print " <button type=submit class=\"btn btn-success btn-sm\" name=option value=modifleg_${flb_vol}>Submit</button> <button type=submit class=\"btn btn-primary btn-sm\" onclick=history.back()>Cancel</button></td>";
				print "</tr>";
			}
			else {
				print "<tr><td style=font-size:0.8em>Equipage $leg</td><td>$flb_voltr</td><td>$datetr</td><td>";
				if (($flb_rot!=11)&&($flb_tridep ne $flb_tridep_sv)){print "<img src=/images/warning.gif width=50px />";}
				print "$flb_tridep $flb_depart</td><td>$flb_triret $flb_arrivee</td>";
				$disabled="";
				if ((($option eq "ajoutleg")&&($fl_vol eq $param))||($option eq "ajouttron")||($option eq "modiftron")){$disabled="disabled=\"disabled\"";}
				print "<td>";
				if ($flb_rot!=11){
					print "<button type=submit class=\"btn btn-danger btn-sm \" $disabled name=option value=supleg_${flb_rot}><span class=\"glyphicon glyphicon-trash\"></span></button>";
				}
				print " <button type=submit class=\"btn btn-success btn-sm \" $disabled name=option value=modiftron_${flb_rot}><span class=\"glyphicon glyphicon-pencil\"></span></button>";
				if ($flb_rot==$maxrot){
					print " <button type=submit class=\"btn btn-primary btn-sm \" $disabled name=option value=ajouttron_${flb_rot}>Ajouter un tronçon</button></td>";
				}
				print "</tr>";
			}
			if (($option eq "ajouttron")&&($flb_rot eq $param)&&($fl_vol eq $param2)){
				$flb_rot++;
				print "<input type=hidden name=flb_rot value='$flb_rot'>";
				print "<input type=hidden name=flb_tridep value='$flb_triret_sv'>";
				print "<tr><td style=font-size:0.8em>Equipage $leg</td><td><input type=text name=flb_voltr value='$flb_voltr_sv' required></td><td>";
print <<EOF;
							<div class="form-group">
						<div class="input-group date form_date" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd" style=width:200px> 
							<input class="form-control" type="text" value="$flb_datetr_sv" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
						</div>
						<input type="hidden" id="dtp_input2" value="$flb_datetr_sv" name=flb_datetr />
					</div>
EOF
				print "</td><td>$flb_triret_sv</td><td><input name=flb_triret required></td>";
				print "<td>";
				print " <button type=submit class=\"btn btn-success btn-sm\" name=option value=addleg_${flb_vol}>Submit</button> <button type=submit class=\"btn btn-primary btn-sm\" onclick=history.back()>Cancel</button></td>";
				print "</tr>";
			}		
			$flb_tridep_sv=$flb_triret;
		}
		if (($option eq "ajoutleg")&&($fl_vol eq $param)){
			$leg++;
			$flb_rot=$leg*10+1;
			print "<input type=hidden name=flb_rot value='$flb_rot'>";
			print "<input type=hidden name=flb_tridep value='$flb_triret_sv'>";
			print "<tr><td style=font-size:0.8em>Equipage $leg</td><td><input type=text name=flb_voltr value='$flb_voltr_sv' required></td><td>";
print <<EOF;
							<div class="form-group">
						<div class="input-group date form_date" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd" style=width:200px> 
							<input class="form-control" type="text" value="$flb_datetr_sv" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
						</div>
						<input type="hidden" id="dtp_input2" value="$flb_datetr_sv" name=flb_datetr />
					</div>
EOF
			
			print "</td><td>$flb_triret_sv</td><td><input name=flb_triret required></td>";
			print "<td>";
			print " <button type=submit class=\"btn btn-success btn-sm\" name=option value=addleg_${fl_vol}>Submit</button> <button type=submit class=\"btn btn-primary btn-sm\" onclick=history.back()>Cancel</button></td>";
			print "</tr>";
		}
		
		print "</table>";
		print "<input type=hidden name=date value='$date'>";
		print "<input type=hidden name=fl_date value='$fl_date'>";
		$disabled="";
		if (($option eq "ajouttron")||($option eq "modiftron")){$disabled="disabled=\"disabled\"";}
	
		if (($option ne "ajoutleg")||($fl_vol ne $param)){
			print "<button type=submit class=\"btn btn-success btn-xs\" $disabled name=option value=ajoutleg_${fl_vol}>Ajouter un equipage</button>";
		}	
		print "</td></tr>";
		print "</form>";
	}
	print "</table>";
	print "<form role=form>";
	print "<input type=hidden name=date value='$date'>";
	print "No de vol <input type=text name=fl_vol>  <button type=submit class=\"btn btn-success btn-sm\" $disabled name=action value=ajoutvol>Creer un nouveau vol</button>";
	print " <button type=submit class=\"btn btn-info btn-sm\" name=action value=>Changer de jour</button>";
	print " <button type=submit class=\"btn btn-alert btn-sm\" name=action value=liste>Liste chronologique</button>";
	print "</form>";
	print "</div></div></body>";	
}
 
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


sub maj_vol(){
	$nb_rot=(int(&get("select max(flb_rot) from flybody where flb_date='$fl_date' and flb_vol='$fl_vol'","chec")+0)/10);
	&save("delete from caisse where ca_code='$fl_apcode' and ca_rot>'$nb_rot' and ca_fly=0");
	&save("delete from vol where v_code='$fl_apcode' and v_rot>'$nb_rot'");
	$query="select fl_troltype,fl_cd_cl from flyhead where fl_date='$fl_date' and fl_vol='$fl_vol' limit 1";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_troltype,$fl_cd_cl)=$sth2->fetchrow_array;
	$query="select flb_arrivee,flb_datetr,flb_tridep,flb_triret from flybody where flb_vol='$fl_vol' and flb_date='$fl_date' order by flb_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$trajet="";
	while ((@flb)=$sth2->fetchrow_array){
		$flb_arrivee=$flb[0];
		$flb_datetr=$flb[1];
		$flb_tridep=$flb[2];
		$flb_triret=$flb[3];
		$trajet=$trajet.$flb_tridep."/";
		}
	$trajet=$trajet.$flb_triret;
	
	$query="select flb_datetr,flb_rot,flb_voltr from flybody where flb_vol='$fl_vol' and flb_date='$fl_date' and (flb_rot%10)=1 order by flb_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($flb2_datetr,$flb2_rot,$flb2_voltr)=$sth2->fetchrow_array){
		$rot=int($flb2_rot/10);	
		$date2=&julian($flb2_datetr,"DDMMYY");
		$date2_sql=&julian($flb2_datetr,"YYYY-MM-DD");
		&save("replace into vol values ('$fl_apcode','$rot','$flb2_voltr','$date2','','','','$trajet','$fl_cd_cl','','','','$fl_troltype','$flb2_datetr','0','$date2_sql')","af");
		&save("insert ignore into caisse values ('$fl_apcode','$rot','0','0','0','0','0','0','0','0','','0','0','','')","af");
	}
}