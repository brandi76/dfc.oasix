#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

# print $html->header;
require "./src/connect.src";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
# $mois+=1;
$max=$an*10000+$mois*100;
# $max+=100;
if ($jour>18){$max+=100;}
print $html->header();
print "<head><title>Compta matière</title><style type=\"text/css\">";
print "<!-- #saut { page-break-after : always } --> </style></head>";
print "<center><font size=+1>IBS FRANCE ZI ROUXMENILS BOUTEILLE<br>COMPTABILITE MATIERE</font><br>";
print "Mois de ",&cal($mois-1)," Numero d'entrepositaire agree:FR00116S0031<br>";
print "Edition du $jour ",&cal($mois)," $an<br>";

$query="delete from soen1";
$sth2=$dbh->prepare($query);
$sth2->execute();
$query="delete from ventil_sql"; # liste des ndp pour un type
$sth2=$dbh->prepare($query);
$sth2->execute();

$query="select es_cd_pr,es_no_do,es_dt,es_qte,es_qte_en,es_type from enso ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){

	if (($es_no_do <"20000")&&($es_qte_en==0)&&($es_type!=6)){next;} # corsica
        # $es_type=6 sortie facture;
	if ((($es_no_do >"20000")||$es_type!=6)&&($es_qte_en==0)){
		$query="select v_date_jl from vol where v_code='$es_no_do' and v_rot=1";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$date=$sth2->fetchrow_array;
		$es_dt=&julian($date,"YYYYMMDD");
	}
	if (($es_type==6) && ($es_dt==20071214)){next;}	
	if ($es_dt>$max){next;}
	$query="select pr_ventil,pr_pdn,pr_deg,pr_douane,pr_pdb from produit where pr_cd_pr='$es_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($vent_code,$pr_pdn,$pr_deg,$prb_ndp_sh,$pr_pdb)=$sth2->fetchrow_array;
	$query="replace into ventil_sql values ('$vent_code','$prb_ndp_sh')";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	
	if ($vent_code<1){next;}
	if ($vent_code>22){next;}
	if ($vent_code==10){next;} # biere
	if ($vent_code==18){next;} # champagne

	if (($vent_code==15)||($vent_code==17)){
		$es_qte=$es_qte*$pr_pdn/1000;
		$es_qte_en=$es_qte_en*$pr_pdn/1000;
		}

	if (($vent_code>=6)&&($vent_code<=9)){
		$es_qte=$es_qte*$pr_pdn*$pr_deg/1000000000;
		$es_qte_en=$es_qte_en*$pr_pdn*$pr_deg/1000000000;
		}

	if (($vent_code<6)||(($vent_code>=10)&&($vent_code<=19)&&($vent_code!=15)&&($vent_code!=17))){
		$es_qte=$es_qte*$pr_pdn/100000;
		$es_qte_en=$es_qte_en*$pr_pdn/100000;
		}

	if ($vent_code==16){
		$es_qte=$es_qte*$pr_pdb*100;
		$es_qte_en=$es_qte_en*$pr_pdb*100;
	}
	$query="select so1_qte,so1_qte_en from soen1 where so1_dt='$es_dt' and so1_no_do='$es_no_do' and so1_type='$vent_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($so1_qte,$so1_qte_en)=$sth2->fetchrow_array;
	$so1_qte+=$es_qte;
	$so1_qte_en+=$es_qte_en;
	
	$query="replace into soen1 values ('$es_dt','$es_no_do','$vent_code','$so1_qte_en','$so1_qte')";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
}

$query="select so1_type from soen1 group by so1_type";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1 cellspacing=0 style=\"font-size: 6pt;\">";
print "<tr><th>No de ligne</th><th>Date</th><th>Client</th><th>Document</th>";
$color="";
while (($so1_type)=$sth->fetchrow_array){
	$query="select type_desi from typedesi where type_code=$so1_type";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($type_desi)=$sth2->fetchrow_array;
	&color();
	print "<th colspan=2 bgcolor=$color><font size=-2>$type_desi<br>";
	$query="select left(vent_ndp,10) from ventil_sql where vent_code=$so1_type";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($vent_ndp)=$sth2->fetchrow_array){print "$vent_ndp<br>";}
	print "</th>";
	push (@type,$so1_type);
}

print "</tr><tr><th>&nbsp</th><th>&nbsp</th><th>&nbsp</th><th>&nbsp</th>";
$color="";
foreach (@type){
	&color();
	print "<th bgcolor=$color>Entree</th><th bgcolor=$color>Sortie</th>";
	}
print "</tr>";

$query="select so1_dt,so1_no_do from soen1 group by so1_dt,so1_no_do";
$sth=$dbh->prepare($query);
$sth->execute();
$i=1;
while (($so1_dt,$so1_no_do)=$sth->fetchrow_array){
	if ($ligne++ >18){&saut();}
	$query="select sum(so1_qte_en),sum(so1_qte) from soen1 where so1_dt='$so1_dt' and so1_no_do='$so1_no_do' group by so1_dt,so1_no_do";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($tot_qte_en,$tot_qte)=$sth2->fetchrow_array;
	if (($tot_qte_en==0)&&($tot_qte==0)){next;}
	print "<tr><td>$i</td><td><b>$so1_dt</td>";
	$i+=1;
	if ($so1_no_do>"15000"){
		$query="select v_cd_cl from vol where v_code='$so1_no_do'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$cl_cd_cl=$sth2->fetchrow_array;
		print "<td>$cl_cd_cl</td><td>Appro $so1_no_do</td>";
	}
	elsif($tot_qte_en!=0) {
		$query="select enh_document from enthead where enh_no='$so1_no_do'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$doc=$sth2->fetchrow_array;
		print "<td>Entree </td><td>$doc</td>";
		}	
	else {
		$query="select sod_info from sortie_douane where sod_no_do='$so1_no_do'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$doc=$sth2->fetchrow_array;

		if ($doc eq ""){ print "<td>Sortie</td><td>daa $so1_no_do</td>"; }
		else { print "<td>Sortie</td><td>$doc</td>";}

		}	


	$color="";
	foreach (@type){
		$query="select so1_qte_en,so1_qte from soen1 where so1_dt='$so1_dt' and so1_no_do='$so1_no_do' and so1_type='$_'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_en,$qte)=$sth2->fetchrow_array;
		$qte/=100;
		$qte_en/=100;
		$total[$_]+=$qte;
		$total_en[$_]+=$qte_en;
		if ($qte==0){$qte="&nbsp;";}
		if ($qte_en==0){$qte_en="&nbsp;";}
		&color();
		print "<td align=right bgcolor=$color>$qte_en</td><td align=right bgcolor=$color>$qte</td>";
	}
	print "</tr>";
}
print "<tr><th>&nbsp</th><th>&nbsp</th><th>&nbsp</th><th>Total</th>";
$color="";
foreach (@type){
	&color();
	print "<th align=right bgcolor=$color>$total_en[$_]</td><th align=right bgcolor=$color>$total[$_]</td>";
}

print "</tr></table>";
$sth->finish();
$sth2->finish();

sub color(){
	if ($color eq ""){$color="#efefef";}else{$color="";}
}	
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/MM/DD
# SORTIE : la date formatée

sub julian {
	my ($val)=$_[0];
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
# FONCTION : cal(mois,option)
# DESCRIPTION : retourne le mois en clair soit au format cours ex janv(pas d'option) soit au format long (option=l)

sub cal {
	my ($mois)=$_[0];
	$mois+=0;
	if ($mois eq 0){$desi="Décembre";}
	if ($mois eq 1){$desi="Janvier";}
	if ($mois eq 2){$desi="Fevrier";}
	if ($mois eq 3){$desi="Mars";}
	if ($mois eq 4){$desi="Avril";}
	if ($mois eq 5){$desi="Mai";}
	if ($mois eq 6){$desi="Juin";}
	if ($mois eq 7){$desi="Juillet";}
	if ($mois eq 8){$desi="Aout";}
	if ($mois eq 9){$desi="Septembre";}
	if ($mois eq 10){$desi="Octobre";}
	if ($mois eq 11){$desi="Novembre";}
	if ($mois eq 12){$desi="Décembre";}
        return ($desi);
}

sub saut {
	$ligne=0;
	print "</table>";
	print "<div id=saut>.</div>";
	my($query)="select so1_type from soen1 group by so1_type";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0 style=\"font-size: 6pt;\">";
	print "<tr><th>No de ligne</th><th>Date</th><th>Client</th><th>Document</th>";
	my ($so1_type);
	while (($so1_type)=$sth->fetchrow_array){
		$query="select type_desi from typedesi where type_code=$so1_type";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($type_desi)=$sth2->fetchrow_array;

		print "<th colspan=2 bgcolor=$color><font size=-2>$type_desi<br>";
		$query="select left(vent_ndp,10) from ventil_sql where vent_code=$so1_type";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($vent_ndp)=$sth2->fetchrow_array){print "$vent_ndp<br>";}
		print "</th>";
	}
}        
	

# -E Compta matiere	
