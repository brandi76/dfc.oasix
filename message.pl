#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.lib";
require("./src/connect.src");
print $html->header();
$user=$ENV{"REMOTE_USER"};
$adresse=$html->param("adresse");
$action=$html->param("action");
$texte=$html->param("texte");
$texte=~s/'//g;

if ($action eq "go"){
	system("/var/www/cgi-bin/dfc.oasix/send_bug.pl '$user $adresse $texte' &");
	
}
print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>

</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
if ($action eq "go"){
print <<EOF;
						<form>
						<div class="form-group">
							$user adresse web:$adresse
							<br><label for="comment">Texte</label>
							<textarea class="form-control" rows="5" id="comment" name="texte" required></textarea>
							<br>
							<input type=hidden name=action value=send>
							<input type=hidden name=adresse value="$adresse">
							<button type="submit" class="btn btn-success" >Submit</button>
						   <button type=submit class="btn btn-danger" onclick=window.close() >Fermer</button>

						</div>
					</form>
EOF
}
if ($action eq "send"){
print <<EOF;
					<form>
						message envoyé
						<div class="form-group">
							<button type=submit class="btn btn-danger" onclick=window.close() >Fermer</button>
						</div>
					</form>
EOF

}
print "</div></div></div>";


