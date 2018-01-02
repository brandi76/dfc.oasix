#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$code=$html->param("code");

print <<EOF;
<html>
  <head>
    <link href="/css/bootstrap.min.css" rel="stylesheet" >
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	<style>
	.btn-file {
        position: relative;
        overflow: hidden;
    }
    .btn-file input[type=file] {
        position: absolute;
        top: 0;
        right: 0;
        min-width: 100%;
        min-height: 100%;
        font-size: 100px;
        text-align: right;
        filter: alpha(opacity=0);
        opacity: 0;
        outline: none;
        background: white;
        cursor: inherit;
        display: block;
    }
	</style>
	<script>
	       \$(document).ready( function() {
        \$('.btn-file :file').on('fileselect', function(event, numFiles, label) {
			document.getElementById("choix").innerHTML+=label+"<br>";
            console.log(label);
        });
    });
	    \$(document).on('change', '.btn-file :file', function() {
        var input = \$(this),
            numFiles = input.get(0).files ? input.get(0).files.length : 1,
EOF
			
print 'label = input.val().replace(/\\\/g, \'/\').replace(/.*\//, \'\');';
print <<EOF;
        input.trigger('fileselect', [numFiles, label]);
    });
	</script>
  </head>
  <body>
    <div class="container">
		<div class="row">
			<div class="col-lg-12">
EOF
if ($action eq "select"){
	$retour=$ENV{"HTTP_REFERER"};
	$pr_desi=&get("select pr_desi from dfc.produit where pr_cd_pr='$code'");
	if ($pr_desi eq ""){
		print "<div class=\"alert alert-danger\">$code Code produit introuvable</div>";
		$action="";
	}
	else{	
		print "<div class=\"alert alert-info\">$code $pr_desi</div>";
		print "<h3>Selectionner les deux photos</h3>";
		print "<form  role=form method=POST enctype=multipart/form-data>";
		print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
		print "image small ";
		# print "<span class=\"btn btn-default btn-file\">";
		print "<span class=\"file-input btn btn-primary btn-file btn-sm\">";
		print "Parcourir... <input type=\"file\" name=image_s accept=application/jpg maxlength=2097152>";
		print "</span><br><br>";
		print "image large ";
		print "<span class=\"file-input btn btn-primary btn-file btn-sm\">";
		print "Parcourir... <input type=file name=image_l accept=application/jpg maxlength=2097152>";
		print "</span><br>";
		print "<input type=hidden name=code value=$code>";
		print "<input type=hidden name=action value=upload>";
		print "<input type=hidden name=retour value=\"$retour\">";
		print "<div id=choix class=\"alert alert-info\" style=margin-top:20px></div>";
		print "<button type=submit class=\"btn btn-info\">Submit</button>"; 
	}
 }

if ($code eq ""){$action="";}
if ($action eq ""){
	print "<h3>Code produit</h3>";
	print "<form  role=form >";
	print "<input type=texte name=code><br>";
	print "<input type=hidden name=action value=select><br>";
	print "<button type=submit class=\"btn btn-info\">Submit</button>"; 
	print "</form>";
}      

if ($action eq "upload"){
	$pr_desi=&get("select pr_desi from dfc.produit where pr_cd_pr='$code'");
	print "<div class=\"alert alert-info\">$code $pr_desi</div>";
		
	$fichier2=$html->param("image_l");
	if ($fichier2 ne ""){
		if (grep(/ /,$fichier2)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if (grep(/\'/,$fichier2)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if (grep(/\"/,$fichier2)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if (grep(/\;/,$fichier2)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if ($message eq ""){
			$file="/var/www/images/$fichier2";
			open(FILE,">$file");
			while (read($fichier2, $data, 2096)){
				print FILE $texte.$data;
			}
			close(FILE);
			print "<img src=/images/$fichier2>";
		}
	}
	$fichier1=$html->param("image_s");
	if ($fichier1 ne ""){
		if (grep(/ /,$fichier1)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if (grep(/\'/,$fichier1)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if (grep(/\"/,$fichier1)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if (grep(/\;/,$fichier1)){$message="Nom de fichier invalide, les espaces et les ponctuations ne sont pas accept�s";}
		if ($message eq ""){	
			$file="/var/www/images/$fichier1";
			open(FILE,">$file");
			while (read($fichier1, $data, 2096)){
				print FILE $texte.$data;
			}
			close(FILE);
			print "<img src=/images/$fichier1>";
		}
	}
	if ($message eq ""){
		&save("insert ignore into dfc.produit_mag value('$code','','','$fichier1','$fichier2')"); 
		&save("update dfc.produit_mag set image_s=\"$fichier1\",image_l=\"$fichier2\" where code='$code'"); 
		print "<div class=\"info\">image(s) enregistr�e(s) vous pouvez fermer la fen�tre et rafraichir la page produit</div>";
	}
	else {
		print "<p class=\"bg-danger\">$message</p>";
	}	
	print "<button class=\"btn btn-success\" onclick=window.close()>Fermer</button>"; 
}	
print "</div></div></div></body>";

