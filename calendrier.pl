#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";

$html=new CGI;
print $html->header;

require "./src/connect.src";
print "<title> vol regulier</title>";
$action=$html->param('action');
$client=$html->param('client');
$date=$html->param('date');
$vol=$html->param('vol');

if ($action eq "del")
{
	&save("delete from flyhead where fl_date='$date' and fl_vol='$vol'","aff");
	&save("delete from flybody where flb_date='$date' and flb_vol='$vol'","aff");
	$action="action";
}
print "<center><form>Code client <input type=text name=client>";
print "<input type=hidden name=action value=action> <input type=submit></form>";
if ($action eq "action")
{
$nom=&get("select cl_nom from client where cl_cd_cl=$client");
print "<table border=1><caption><h1>$client $nom</h1></caption><tr><th>Semaine</th><th>Lundi 1</th><th>Mardi 2</th><th>Mercredi 3</th><th>Jeudi 4</th><th>Vendredi 5</th><th>Samedi 6</th><th>Dimanche 7</th></tr>";

$query="select fl_date,fl_apcode,fl_vol from flyhead where fl_cd_cl=$client and datediff(curdate(),from_unixtime(fl_date*24*60*60,'%Y-%m-%d'))<60 order by fl_date,fl_vol";

$sth = $dbh->prepare($query);
$sth->execute;
# raz();
while (($datejl,$code,$vol)= $sth->fetchrow_array) {
	$datef=&julian($datejl,"yyyy-mm-dd");
	$jours=&jour($datejl);
	$semaine=&semaine($datef);
# 	if ($code+0!=0){$vol="<font color=gray>".$vol."</font>";}
	if ($semaine!=$semref)
	{
		if ($semref!=0){&lignetab();%table=();}
		$semref=$semaine;
		$dateref=$datef;
		# &raz();
	}
	$table{"$jours"}.=$vol.";".$datejl."!";

}
&lignetab();
print "</table>";
}
sub raz {
$table{"Lundi"}="&nbsp;";
$table{"Mardi"}="&nbsp;";
$table{"Mercredi"}="&nbsp;";
$table{"Jeudi"}="&nbsp;";
$table{"Vendredi"}="&nbsp;";
$table{"Samedi"}="&nbsp;";
$table{"Dimanche"}="&nbsp;";
}

sub lignetab {
		
		my (@semaine)=("Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche");
		my ($vol);
		my ($date);
		print "<tr><th ";
		if ($semref==&semaine()){print " bgcolor=yellow";}
		print ">$semref $dateref</td>";
		foreach (@semaine){
			print "<td ";

			if ($table{"$_"} eq ""){ print "bgcolor=#efefef";}
			print ">";
			if ($table{"$_"} ne ""){
				@liste=split(/\!/,$table{"$_"});
				foreach $ele (@liste) {
					($vol,$date)=split(/;/,$ele);
					my ($an,$mois,$jour)=split(/-/,&julian($date,"yyyy-mm-dd"));
					print "(<a href=http://ibs.oasix.fr/cgi-bin/planningfly.pl?action=affiche&nbjour=1&datejour=$jour&datemois=$mois&datean=$an>$vol</a>";
					# $heure=&get("select flb_depart from flybody where flb_vol='$vol' and flb_date=$date and flb_rot=11","af");
					$troltype=&get("select fl_troltype from flyhead where fl_vol='$vol' and fl_date=$date","af");
					print " $troltype)";
				}
			}
			else
			{print "&nbsp";}
# 			 if (($table{"$_"} ne "")&&(! grep /font/,$vol)){print " <a href=?action=del&vol=$vol&date=$date&client=$client><font color=red> sup</font></a></td>"};
		}
		print "</tr>";
}
