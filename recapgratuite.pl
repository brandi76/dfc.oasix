#!/usr/bin/perl
# #!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
print "<title>Recap gratuite</title>";
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
if ($action eq ""){&premiere();}
if ($action eq "go"){
	&go();
}

if ($action eq "client"){&clien();}
sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=10><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";

}


sub clien{
	$query="select distinct cl_cd_cl,cl_nom from vol,client where v_cd_cl=cl_cd_cl order by v_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
		print "$cl_cd_cl $cl_nom <br>";
	}
}
sub go{
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	
	print "<b> Gratuité et voucher </b><br>";
	print "Mois:$mois   Client:$cl_nom <br><br><bR>";
	$query="select v_code,v_vol,v_date,v_dest from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_date,$v_dest)=$sth->fetchrow_array){
	    $query="select oaa_serial,oaa_date  from oasix_appro where oaa_appro='$v_code'";
	    $sth2=$dbh->prepare($query);
	    $sth2->execute();
	    while (($oa_serial,$oa_date_import)=$sth2->fetchrow_array){
		
		$query="select oa_type,oa_col2,oa_col3 from oasix where oa_date_import='$oa_date_import' and oa_serial='$oa_serial'";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while (($oa_type,$oa_col2,$oa_col3,$oa_date_import,$oa_serial)=$sth3->fetchrow_array){
		    if ($oa_type eq "p"){push (@tab, $oa_col2);}
		    if ($oa_type eq "c"){
			if (($oa_col3==4)||($oa_col3==5)){
			    print "<b>ref:$v_code date:$v_date $v_vol $v_dest</b> <br>";
			    foreach (@tab){
				print "$_<br>";
			    }
			}
			@tab=();
		    }
		}
	    }
	}
}	
