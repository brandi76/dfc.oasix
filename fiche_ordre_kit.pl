$action=$html->param("action");
$lot_nolot=$html->param("lot_nolot");

&tete();

if ($action eq "visusup"){
	$produit=$html->param("produit");
	$query="delete from ordre where ord_cd_pr='$produit'";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<br><font color=red>Ligne supprimée</font><br>";
	$action="";
}
if ($action eq "visumodif"){
	$query="select pr_cd_pr,pr_desi,ord_prix1,ord_ordre from produit,ordre where ord_cd_pr=pr_cd_pr order by ord_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($pr_cd_pr,$pr_desi,$tr_prix,$ord_ordre)=$sth->fetchrow_array) {
		$produit=$html->param("$pr_cd_pr");
		$prix=$html->param("prix$pr_cd_pr")*100;
		if ($prix!=$tr_prix){
			$query="update ordre set ord_prix1=$prix where ord_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute;
			print "<br><font color=red>$pr_desi prix modifié</font><br>";
		}
			
	}
	$produit=$html->param("produit");
	$ordre=$html->param("ordre");
	$prix=$html->param("prix")*100;

	if (($produit ne "")&&($ordre ne"")){
		$query="replace into ordre values('$ordre','$produit','$prix','')";
		$sth=$dbh->prepare($query);
		$sth->execute;
		print "<br><font color=red>Produit ajouté</font></br>";
	}
	$action="";
}

if ($action eq ""){
	print "\n<form name=go><font size=+2>";
	&form_hidden();
	$query="select pr_cd_pr,pr_desi,ord_prix1/100,ord_ordre from produit,ordre where ord_cd_pr=pr_cd_pr order by ord_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1 cellspacing=0><tr><th>Ordre</th><th>Code produit</th><th>Prix</th></tr>";
	while (($pr_cd_pr,$pr_desi,$tr_prix,$ord_ordre)=$sth->fetchrow_array) {
		$res=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1 limit 1")+0;
		$color="white";
		if ($res==0){$color="gray";}
		 print "<tr bgcolor=$color";
		 print "><td>$ord_ordre</td><td>$pr_cd_pr $pr_desi</td><td><input type=text name=prix$pr_cd_pr value=$tr_prix size=4></td>";
		 # <td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visusup&lot_nolot=$lot_nolot&produit=$pr_cd_pr>Sup</a>
		 print "</tr>\n";
	}
	print "<tr><td><input type=text name=ordre size=6></td><td><input type=text name=produit size=6></td><td><input type=text name=prix size=4></td></tr>";
	print "</table>\n";
	print "<input type=hidden name=action value=visumodif>";
	print "<br><br><input type=submit value=modif onclick:document.go.submit()>";
	print "</form><br>$nb";
	print "</body></html>";

}

sub tete{
	print "<html><head><style type=\"text/css\">
	.gauche {
		td {text-align:left;}
	}
	
	</style></head>";

	print "<body><center><font size=+5>Gestion du fichier ordre</font>";
}
sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	return($sth2->execute());
}
