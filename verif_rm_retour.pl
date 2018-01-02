#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";

print $html->header;
print "<html><head><Meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>";
$today=$html->param('today');
$nodepart=$html->param('nodepart');
$pr_cd_pr=$html->param('pr_cd_pr');
$action=$html->param('action');


require "./src/connect.src";


print "<center><h1>$nodepart</h1>";
$query = "select ret_code,ret_retour,gsl_nolot from retoursql,retjour,geslot,etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$pr_cd_pr and rj_appro=ret_code and rj_date>='$today' and gsl_ind!=10 and gsl_ind!=11 order by gsl_nolot";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ret_code,$ret_retour,$gsl_nolot)=$sth->fetchrow_array){
	print "$ret_code $gsl_nolot $ret_retour<br>";
	$total+=$ret_retour;
}
print "Total:$total<br>";
sub select_date
{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	(@dates)=split(/;/, $date, 3); 
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	$firstyear=$dates[2];
  	print "<select name=datejour>"; 
 	for($i=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	@cal=("","Janvier","Février","mars","Avril","mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print "<select name=datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=datean>"; 
	for($i=$firstyear;$i<=($firstyear+1);$i++) { print "<option value=$i>$i</option> ";} 
 	print "</select>"; 
} 
