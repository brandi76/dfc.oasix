#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();

$action=$html->param("action");
$debut=$html->param("debut");
$option=$html->param("option");
$four=$html->param("four");
$date=$html->param("date");
$base=$html->param("base");
$user=$ENV{"REMOTE_USER"};
@alpha=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T");
print <<EOF;
<html>
  <head>
    <link href="/css/bootstrap.min.css" rel="stylesheet" >
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	</script>
  </head>
  <body>
    <div class="container">
EOF
print "<table class=\"table table-condensed table-bordered table-striped table-hover \" style=\"font-size:1em\">";
$LOGFILE = "maillog";
open(LOGFILE) or die("Could not open log file.");
foreach $line (<LOGFILE>) {
	if ($line=~/dovecot/){next;}
	($c1,$c2,$c3,$c4,$c5)=split(/:/,$line,5);
	if ($c4=~/STARTTLS/){next;}
	if ($c5=~/from=/){next;}
	if ($c5=~/ruleset=/){next;}
	

	$color="";
	($c3)=split(/ /,$c3);
	if ($c5=~/Invalid/){$color="#F2DEDE";}
	if ($c5=~/Deferred/){$color="#F2DEDE";}
	if ($c5=~/unknown/){$color="#F2DEDE";}
	if ($c5=~/stat=Sent/){$color="#DFF0D8";}
	
	$c5=~s/</&lsaquo;/g;
	$c5=~s/</&rsaquo;/g;
	print "<tr><td>$c1:$c2:$c3</td><td>$c4</td><td style=background:$color>$c5</td></tr>";	 
  }
  print "</table>";
close(LOGFILE);
print "</div>";
