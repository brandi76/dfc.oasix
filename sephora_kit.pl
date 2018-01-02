$marque=$html->param("marque");
$libelle=$html->param("libelle");

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

if ($action eq ""){
	print "<div class=\"alert alert-success\">Consultation du listing importé de Sephora </div>";
	print "<form>";
	print "<h5>Marque</h5>";
	&form_hidden();
	$query="select distinct marque from sephora order by marque";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<select name=marque>";
	while (($marque)=$sth->fetchrow_array){
		print "<option value='$marque'>$marque</option>";
	}
	print "</select>";
	print "<input type=hidden name=action value=marque>";
	print "<br><br><button type=\"submit\" class=\"btn btn-info\">Submit</button>";
	print "</form>";
}
if ($action eq "marque"){
	print "<form>";
	print "<div class=\"alert alert_info\">$marque</div>";
	print "<h5>Gamme</h5>";
	&form_hidden();
	$query="select distinct libelle from sephora where marque='$marque' order by libelle";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<select name=libelle>";
	while (($libelle)=$sth->fetchrow_array){
		print "<option value=\"$libelle\">$libelle</option>";
	}
	print "</select>";
	print "<input type=hidden name=action value=liste>";
	print "<input type=hidden name=marque value=\"$marque\">";
	
	print "<br><br><button type=\"submit\" class=\"btn btn-info\">Submit</button>";
	print "</form>";
	print "<br><form>";
	&form_hidden();
	print "<button type=\"submit\" class=\"btn btn-info\">Retour</button>";

}

if ($action eq "liste"){
	print "<h3$marque</h3>";
	$query="select distinct code,lien,description,note,genre from sephora where marque=\"$marque\" and libelle=\"$libelle\"";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$lien,$description,$note,$genre)=$sth->fetchrow_array){
		$description=&trash($description);
		$note=&trash($note);
		if ($genre eq "H") {$genre="HOMME";}
		if ($genre eq "F") {$genre="FEMME";}
		
		print "<h3>$code $libelle</h3>";
		print "<img src=/images_produits/${code}.jpg width=100px>";
		print "<a href=http://www.sephora.fr$lien>Lien Sephora</a><br>";
		print "<b>Description</b><div style=\"border:1px solid black;font-size:0.8em\">$description</div><br>";
		print "<b>Notes Olfactives</b><div style=\"border:1px solid green;font-size:0.8em\">$note</div><br>";
		
		$query="select desi,prix,ref from sephora_ref where code='$code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($desi,$prix,$ref)=$sth2->fetchrow_array){
			$desi=&trash($desi);
			print "$desi <span style=position:absolute;left:600px>$prix</span>";
			$img=$code."_".$ref.".jpg";
			print "<img src=/images_produits/$img width=30px>";
			print "<br><br>";
		}	
	}
	print "<br>";
	$query="select pr_cd_pr,pr_desi,pr_prx_vte from corsica.produit,corsica.produit_desi where code=pr_cd_pr and marque='$marque'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_prx_vte)=$sth->fetchrow_array){
		print "$pr_cd_pr $pr_desi <span style=position:absolute;left:600px>$pr_prx_vte</span><br>";
	}	
	print "<br><form>";
	&form_hidden();
	print "<button type=\"submit\" class=\"btn btn-info\">Retour</button>";
	
}

print "		
		</div>
	</div>
</div>";
sub trash{
  my $chaine=$_[0];
  my $chaine_clean="";
  my ($i)=0;
  for ($i=0;$i<length($chaine);$i++){
		$ok=1;
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==180)){
			$chaine_clean.="ô";
			$i++;
			$ok=0;
		}	
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==169)){
			$chaine_clean.="é";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==172)){
			$chaine_clean.="ì";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==136)){
			$chaine_clean.="È";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==160)){
			$chaine_clean.="à";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==174)){
			$chaine_clean.="î";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==168)){
			$chaine_clean.="è";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==175)){
			$chaine_clean.="ï";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==148)){
			$chaine_clean.="Ô";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==170)){
			$chaine_clean.="ê";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==137)){
			$chaine_clean.="É";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==226)&&(ord(substr($chaine,$i+1,1))==128)&&(ord(substr($chaine,$i+2,1))==153)){
			$chaine_clean.="'";
			$i++;
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==176)){
			$chaine_clean.="°";
			$i++;
			$ok=0;
		}
		if ($ok) {
		# print ord(substr($chaine,$i,1)," ";
		$chaine_clean.=substr($chaine,$i,1);
		}
  }
  return($chaine_clean);
}
