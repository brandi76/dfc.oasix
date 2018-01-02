#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
require "./src/connect.src";
$client=$html->param("client");
$com_no=$html->param("com_no");
&save("update $client.commande_info set accuse=curdate() where com_no='$com_no'");
print "
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
\"http://www.w3.org/TR/html4/loose.dtd\">
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">
<title>Duty Free Concept I Paris</title>
<style type=\"text/css\">
<!--
body {
	background-color: #999999;
}
.Style1 {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	color: #FFFFFF;
}
a:link {
	color: #222222;
	text-decoration: none;
-->
</style></head>

<body>
<body background=\"/images/bg-main.jpg\" background=no-repeat>
<div align=\"center\" background=\"/images/bg-main.jpg\">
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p><background=\"/images/bg.jpg\"></p>
  <p><img src=\"/images/logoDFC.png\" width=\"250\" height=\"180\" border=\"0\"></p>
  </p>
  </p>
  <p class=\"Style1\">Merci, votre accusé de reception de notre commande no:$com_no a bien été enregistré</p>
  </p>
 </div>
</body>
</html>";

;1