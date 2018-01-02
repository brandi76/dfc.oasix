#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
require "./src/connect.src";
print $html->header;
$navire=$html->param('navire');
$date=$html->param('date');
$produit=$html->param('produit');
$type=$html->param('type');
$commande=$html->param('commande');
$cde1=$html->param('cde1');
$cde2=$html->param('cde2');

$action=$html->param('action');
print "<head><style>TD{text-align:right;}.gauche{text-align:left;} </style><title>sql navire</title></head>";
if ($action eq ""){
	print "<body><center><h1>sql navire<br></h1><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
	print "<option value=''><br>";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	print "code produit <input type=text name=produit>";
	print "<br>type 0:selection 1:inventaire 2:vendu 3:ecart 10:inventaire douchette<input type=text name=type>";
	print "<br>date<input type=text name=date>";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=voir></form>";
	
	print "<br> <form>mise à zero de l'inventaire <br>Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
	print "<option value=''><br>";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	print "<br>date<input type=text name=date>";
    	print "<br><input type=hidden name=action value=raz><input type=submit value=go></form>";
	print "<br> <form>sauvegarde inventaire apres desarmement à partir d'une comamnde <br>Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
	print "<option value=''><br>";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	print "<br>date<input type=text name=date>";
   	print "<br>mumero de commande<input type=text name=commande>";

    	print "<br><input type=hidden name=action value=inv><input type=submit value=go></form>";
    	
	print "<br> <form>sauvegarde inventaire à partir du fichier corsica<br>Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
	print "<option value=''><br>";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	print "<br>date<input type=text name=date>";
    	print "<br><input type=hidden name=action value=inv2><input type=submit value=go></form>";
		
	print "<br> <form>sauvegarde inventaire à partir d'un inventaire douchette<br>Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
	print "<option value=''><br>";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	print "<br>date<input type=text name=date>";
    	print "<br><input type=hidden name=action value=inv3><input type=submit value=go></form>";

	
	print "<br> <form>Duplication d une commande avec inversion des quantites (la commande doit existée)";
	print "<br>commande source<input type=text name=cde1><br>";
   	print "<br>commande cible<input type=text name=cde2><br>";
	print "<br><input type=hidden name=action value=dupl><input type=submit value=go></form>";

}

if ($action eq "dupl"){
	$ok=&get("select ic2_no from infococ2 where ic2_no='$cde2'");
	if ($ok eq ''){print "valeur des numeros de commande invalide<br>";exit;}
	$ok=&get("select coc_no from comcli where coc_no='$cde1'");
	if ($ok eq ''){print "valeur des numeros de commande invalide<br>";exit;}
	$ok=&get("select coc_no from comcli where coc_no='$cde2'");
	if ($ok ne ''){print "valeur des numeros de commande invalide<br>";exit;}
	$query="select * from comcli where coc_no='$cde1'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@comcli)=$sth->fetchrow_array){
		$comcli[0]=$cde2;
		$comcli[2]=0-$comcli[2];
		$comcli[6]=0-$comcli[6];
		$comcli[5]=0;
		$query="replace into comcli values(";
		for ($i=0;$i<=$#comcli;$i++)
		{
		 	$query.="'$comcli[$i]',";
		}
		chop($query);
		$query.=")";
		print "$query<br>";;
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	}
}	






if ($action eq "visu"){
	$query="select * from navire2 where nav_date=nav_date";
	if ($navire ne ''){$query.= " and nav_nom='$navire'";}
	if ($produit ne ''){$query.= " and nav_cd_pr='$produit'";}
	if ($date ne ''){$query.= " and nav_date='$date'";}
	if ($type ne ''){$query.= " and nav_type='$type'";}
	
	print "<table border=1><tr bgcolor=000066><th align=center><font color=\"cccccc\">nav_nom</font></th><th align=center><font color=\"cccccc\">nav_cd_pr</font></th><th align=center><font color=\"cccccc\">desi</font></th><th align=center><font color=\"cccccc\">nav_date</font></th><th align=center><font color=\"cccccc\">nav_type</font></th><th align=center><font color=\"cccccc\">nav_qte</font></th><th align=center><font color=\"cccccc\">nav_pos</font></th></tr>
	";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@navire2)=$sth->fetchrow_array){
		print "<tr>";
		$i=0;
		foreach (@navire2){
			print "<td>$_</td>";
			$i++;
			if ($i==2){
				$pr_cd_pr=$_;
			}
			
			if ($i==2){
				$desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
				print "<td>$desi</td>";
			}
			
		}
		print "</tr>";
	
	}
	print "</table>";
}

if ($action eq "raz"){
	$query="select * from navire2 where nav_type=0 and nav_nom='$navire'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[2]=$date;
			$tab[3]=1; # type
			$tab[4]=0;
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
	$query="select * from navire2 where nav_type=10 and nav_nom='$navire' and nav_date='$date'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[3]=1; # type
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
}

if (($action eq "inv")&&($commande ne "")){
	&save("delete from navire2 where nav_date='$date' and nav_type=1 and nav_nom='$navire'","aff");
	 
	$query="select * from navire2 where nav_nom='$navire' and nav_type=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[2]=$date;
			$tab[3]=1; # type
			$tab[4]=0;
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
	
	$query="select coc_cd_pr,coc_qte from comcli where coc_no=$commande";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($coc_cd_pr,$coc_qte)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[0]=$navire;
                        $tab[1]=$coc_cd_pr;
			$tab[2]=$date;
			$tab[3]=1; # type
			$tab[4]=0-($coc_qte/100);
			$tab[5]=0;
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
}
if ($action eq "inv2"){
	&save("delete from navire2 where nav_date='$date' and nav_type=1 and nav_nom='$navire'","aff");
	 
	$query="select * from navire2 where nav_nom='$navire' and nav_type=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[2]=$date;
			$tab[3]=1; # type
			$tab[4]=0;
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
	$query="select cor_cd_pr,cor_qte_pre from corsica";
	print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($coc_cd_pr,$coc_qte)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[0]=$navire;
                        $tab[1]=$coc_cd_pr;
			$tab[2]=$date;
			$tab[3]=1; # type
			$tab[4]=0-$coc_qte;
			$tab[5]=0;
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
}
if ($action eq "inv3"){
	&save("update navire2 set nav_qte=0 where nav_type=1 and nav_date='$date' and nav_nom='$navire'","aff");
	 
	$query="select * from navire2 where nav_nom='$navire' and nav_type=10 and nav_date='$date'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array)
	{
			$query="replace into navire2 value(";
			$tab[3]=1; # type
			foreach (@tab) {
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
			print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	}
}
