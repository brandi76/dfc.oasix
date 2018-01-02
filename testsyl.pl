#!/usr/bin/perl    
use CGI;    
use DBI();
require "./src/connect.src";
$html=new CGI; 
print $html->header;    
print $html->param("param1");    
print "<br>";
print $html->param("param2");    
$val=$html->param("param1");    
print "<br>--$val--<br>";
print "<form>";
print "<input type=text name=param1 >";
# $val=$dbh->quote($val);
while($val=~s/\'/&#39;/){};
print "<input type=text name=param2 value='$val'>";
print "<input type=submit></form>";
