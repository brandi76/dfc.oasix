#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
open (FILE ,"grep \.51 /usr/local/apache2/logs/access_log|tail -1000");
@tab=<FILE>;
close (FILE);

foreach $ligne (@tab) {
 	$ligne=~s/192\.168\.1\.13/sylvain/;
	 	$ligne=~s/192\.168\.1\.13/sylvain/;
 	$ligne=~s/192\.168\.1\.50/abel/;
 	$ligne=~s/192\.168\.1\.51/abel/;
 	$ligne=~s/192\.168\.1\.51/abel/;
 	$ligne=~s/192\.168\.1\.55/sonia/;
 	$ligne=~s/192\.168\.1\.14/entrepot/;
 	$ligne=~s/192\.168\.1\.22/carole/;
 	$ligne=~s/192\.168\.1\.8/lucie/;
 	$ligne=~s/192\.168\.1\.41/marie/;
 	$ligne=~s/192\.168\.1\.127/soulet/;
 	$ligne=~s/192\.168\.1\.10/micheline/;

	
	print "$ligne<br>";
}

