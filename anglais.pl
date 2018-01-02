#!/usr/bin/perl
use CGI;

$html=new CGI;
print $html->header;
$reponse=$html->param("reponse");
$index=$html->param("index");

open (FILE, "<anglais.txt");
if ($index eq ""){
	$index=`/home/intranet/cgi-bin/random`;
}   
@file=<FILE>;

($a,$f)=split(/;/,$file[$index]);

if ($reponse ne ""){
		print "$reponse<br>$a<br>";
}
else
{
	print "$f<br>";
	print "<form><br><input type=text size=100 name=reponse><br><input type=submit value=verif><input type=hidden name=index value=$index></form>";
}