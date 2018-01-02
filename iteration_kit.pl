
if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "<textarea class=\"form-control\" rows=\"5\" name=texte></textarea><br>";
    print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=go1>ligne1:liste separée par virgule , ligne2 chaine  avec #1 pour l element à itérer</button>";
    print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=go2>ligne1 chaine  avec #1 et #2 pour les elements à itérer ligne2 debut,fin,pas,ecart entre#1 et #2</button>";
	print "</form>";
	
}

if ($action eq "go1"){
	(@liste)=split(/\n/,$html->param("texte"));
	(@iteration)=split(/,/,$liste[0]);
	foreach $it (@iteration){
		$a=$liste[1];
		$a=~s/#1/$it/g;
		print $a."<br>";
	}	
}
if ($action eq "go2"){
	(@liste)=split(/\n/,$html->param("texte"));
	($debut,$fin,$pas,$ecart)=split(/,/,$liste[1]);
	$it=$debut;
	while($it!=$fin){
		$a=$liste[0];
		$a=~s/#1/$it/g;
		$it2=$it+$ecart;
		$a=~s/#2/$it2/g;
		print $a."<br>";
		$it+=$pas;
	}	
}

;1 

