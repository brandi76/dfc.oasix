#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;
$file=$html->param('file');

if ($file eq ""){
	open(FILE1,"ls -t /mnt/server-file/data_export |");
	@liste = <FILE1>;
	close(FILE1);
	foreach (@liste){
		print "<a href=import-corsica.pl?file=$_>$_</a><br>";
	}
} 
else
{
open(FILE1,"/mnt/server-file/data_export/$file");
@liste_dat = <FILE1>;
close(FILE1);
$nbligne=$html->param('nbligne');
$cde=$html->param('cde');
$action=$html->param('action');
if ($action ne "etat"){
for ($i=0;$i<$nbligne;$i++){
	$prod=$html->param("prod$i");
	$qte=$html->param("qte$i");
	$query="replace into corsica values ('$cde','$prod','','$qte')";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
}
}
$li=0;
foreach (@liste_dat){
	while ($_=~s/&nbsp;/ /){};
	if ($_=~/<head>/){
		$_=~s/<head>/<head><Meta http-equiv=Pragma content=no-cache>/;
		}
		

	if ($_=~/DEPOT/){
		($cde,$date,$bateau)=split(/<br>/,$_);
		while ($bateau=~s/DEPOT :/ /){};
		while ($bateau=~s/  / /){};
		while ($cde=~s/NUMERO :/ /){};
		while ($cde=~s/  //){};
		
		#print "$cde $bateau</br>";
	}
	if ($_=~/Reference/){
		$pass=1;
		$_=~s/<table/<form name=corsica><table/;
		$_=~s/Quantite/Quantite cde<\/td><td><b>Quantite prep/;
	}

	if (($pass==1)&&($_!~/<\/table>/)&&($_!~/Reference/)){
		while ($_=~s/<td>//){};
		while ($_=~s/<tr>//){};
		while ($_=~s/"right"/right/){};
		while ($_=~s/<td align=right>//){};
		
		($col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8)=split(/<\/td>/,$_);
		while ($col3=~s/ //){};
		if ($col3==180142){$col3=180140;} # inversion miracle;
		$query="select cor_qte_pre from corsica where cor_no=$cde and cor_cd_pr='$col3'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($cor_qte_prep)=$sth->fetchrow_array;
		($col4)=split(/ /,$col4);
		if ($cor_qte_prep eq ""){$cor_qte_prep=$col4;}
		if ($action ne "etat"){
			print "<tr><td>$col1</td><td>$col2</td><td>$col3<input type=hidden name=prod$li value=\"$col3\"></td><td>$col4 </td><td><input type=text name=qte$li value=\"$cor_qte_prep\" size=3></td><td>$col5</td><td>$col6</td><td>$col7</td><td>$col8</td>";
		}
		else
		{
			$color="black";
			if ($cor_qte_prep!=$col4){$color="red";}
			print "<tr><td><font color=$color>$col1</td><td><font color=$color>$col2</td><td><font color=$color>$col3</td><td><font color=$color>$col4 </td><td><font color=$color>$cor_qte_prep</td><td><font color=$color>$col5</td><td><font color=$color>$col6</td><td><font color=$color>$col7</td><td><font color=$color>$col8</td>";
		
		}
		$li++;
	}
	else {
		if (($_=~/<\/body>/)&&($action ne "etat")){
			($ligne)=split(/<\/body>/,$_);
			print "$ligne";
			print "</body><input type=submit value=\"Validation\"> <a href=import-corsica.pl?cde=$cde&action=etat&file=$file>mail</a><input type=hidden name=nbligne value=$li><input type=hidden name=cde value=$cde><input type=hidden name=file value=$file></form></body>";
		}
		else { print $_;}
	}

}
}
# -E importation d'une commande corsica