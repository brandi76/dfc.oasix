#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"temp.csv");
@liste_dat = <FILE1>;


close(FILE1);

$prod=$html->param("prod");
$desi=$html->param("desi");

foreach (@liste_dat){
	chop($_);
	($prod,$prix)=split(/\;/,$_);
	while ($prix=~s/,/\./){};
	$existe=&get("select count(*) from prix311208 where code=$prod");
	if ($existe >0){
		print "<font color=black>$prod $prix</font><br>";

		&save("update prix311208 set priv='$prix',flag=3,date=now() where code='$prod'","aff");
	}
	else
	{
		$prac=&prac($prod);
		print "<font color=red>$prod $prix *$prac*</font><br>";
		if ($prac!=0){&save("insert into prix311208 values('$prod','$prix','$prac',now(),'3')","aff");}
	
	}
	

}