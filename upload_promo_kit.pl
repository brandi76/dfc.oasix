
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
            numFiles = input.get(0).files ? input.get(0).files.length : 1;
EOF
			
print <<EOF;
        //input.trigger('fileselect', [numFiles, label]);
    });
	</script>
  </head>
  <body>
    <div class="container">
		<div class="row">
			<div class="col-lg-12">
EOF




if ($action eq ""){
	print "<div class=\"alert alert-info\">Mise en place des promotions</div>";
	print "<form role=form method=POST enctype=multipart/form-data>";
	print "Libellé qui doit appraitre sur le site<input type=text name=libelle><br>";
	print "<h3>Selectionner le fichier</h3>";
	print "<input type=hidden name=MAX_FILE_SIZE value=1024000> ";
	print "<span class=\"file-input btn btn-primary btn-file btn-sm\">";
	print "Parcourir... <input type=\"file\" name=fichier accept=application/pdf maxlength=1024000>";
	print "</span><br><br>";
	print "<input type=hidden name=action value=upload>";
	print "<button type=submit class=\"btn btn-info\">Controle</button>"; 
	print "</form>";

}
	
if ($action eq "upload"){
	$fichier=$html->param("fichier");
	print "<div class=\"alert alert-info\">$fichier</div>";
	if ($fichier ne ""){
		if (!grep(/\.pdf$/,$fichier)){$message="Nom de fichier invalide, seul le format pdf est accepté";}
		if ($message eq ""){
			$file="/var/www/dutyfre/1.pdf";
			open(FILE,">$file");
			while (read($fichier, $data, 2096)){
				print FILE $texte.$data;
			}
			close(FILE);
		}
	}
	else {$message="Merci de selectionner un fichier";}
	if ($message eq ""){
	}
	else {
		print "<p class=\"bg-danger\">$message</p>";
	}	
	print "<a href=?><button class=\"btn btn-success\">Retour</button></a>"; 
}	
print "</div></div></div>";
print "</body>";


