#!/usr/bin/perl
use HTML::Parser ();
use CGI::Carp qw(fatalsToBrowser);
use CGI;
$html=new CGI;
print $html->header();

open(FILE,"/etc/httpd/logs/error_log");
@tab=<FILE>;
close(FILE);
$fin=$#tab;

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
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";

for ($i=0;$i<50;$i++){
	$ligne=$tab[$fin-$i];
	($date,$err,$client,$erreur)=split(/]/,$ligne,4);
	$date=~s/\[//g;
	$err=~s/\[//g;
	$client=~s/\[client//g;
	if (grep /185\.42\.31\.28/,$client){next;}
	# $erreur=~s/^ \[.*\]//g;
	print "<tr>";
	print "<td style=font-size:0.7em>$date</td>";
	# print "<td style=font-size:0.7em>$err</td>";
	# print "<td style=font-size:0.7em>$client</td>";
	print "<td>$erreur</td>";
	print "</tr>";
}
print "</table>";
print "		
		</div>
	</div>
</div>";
