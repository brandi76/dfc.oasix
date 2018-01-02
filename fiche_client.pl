#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
# require "../oasix/manip_table.lib";
require "./src/connect.src";
$cl_cd_cl=$html->param("client");
$cl_nom=$html->param("nom");
$cl_add=$html->param("adresse");
$cl_trilot=$html->param("trilot");
$cl_com1=$html->param("com1");
$cl_com2=$html->param("com2");
$cl_magazine=$html->param("magazine");
$action=$html->param("action");
$pass=$html->param("pass");
if ($cl_cd_cl eq ""){$cl_cd_cl=$base_client;$action="visualisation";}
if (($action eq "modification")&&($cl_cd_cl ne "")&&($pass==1)){
	$query="replace into client values('$cl_cd_cl','$cl_nom','$cl_add','$cl_trilot','$cl_com1','$cl_com2','$cl_magazine')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="visualisation";
}
if (($action eq "creation")&&($cl_cd_cl ne "")){
	$query="replace into client values('$cl_cd_cl','$cl_nom','$cl_add','$cl_trilot','$cl_com1','$cl_com2','$cl_magazine')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="visualisation";
}
if (($action eq "visualisation")&&($cl_cd_cl ne "")){
	$query="select * from client where cl_cd_cl='$cl_cd_cl'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_cd_cl,$cl_nom,$cl_add,$cl_trilot,$cl_com1,$cl_com2,$cl_magazine)=$sth->fetchrow_array;
	$pass=1;
}


	
print "<html>";
print "
<form>
code client <input type=text name=client size=3 value=$cl_cd_cl><br>
Nom <input type=text name=nom size=25 value=\"$cl_nom\"><br>
Adresse <input type=text name=adresse  size=100 value=\"$cl_add\"><br>
Tri lot <input type=text name=trilot  size=3 value=$cl_trilot><br>
Commission compagnie <input type=text name=com1  size=3 value=$cl_com1><br>
Commission Pnc <input type=text name=com2  size=3 value=$cl_com2><br>
Nom Magazine <input type=text name=magazine  size=30 value=$cl_magazine><br>
<br>
<input type=submit class=bouton name=action value=visualisation> 
<input type=submit class=bouton name=action value=modification>
<input type=submit class=bouton name=action value=creation> 
<input type=hidden class=bouton name=pass value=$pass> 
</form>
</body>
</html>
";


