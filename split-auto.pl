#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";
print $html->header;
print "<html><head><Meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>";
$fichier=$html->param("fichier");
if ($fichier eq ''){
	print "<form>Nom du fichier<input type text name=fichier onchange=document.form[0].submit()></form>";
}
else
{
require "./src/connect.src";
$query="select subject from cfd where simple='$fichier'";
$sth=$dbh->prepare($query);
$sth->execute();
print '(';
while (($nom)=$sth->fetchrow_array){
	print "\$$nom,";
}
print ')<br>';
$query="select subject from cfd where simple='$fichier'";
$sth=$dbh->prepare($query);
$sth->execute();
print '<tr>';
while (($nom)=$sth->fetchrow_array){
	print "&#60;td>\$$fichier->{$nom}&#60;/td>";
}
print '</td></tr><br>';

}


print "<pre> #!/usr/bin/perl
use CGI;
use DBI();
\$html=new CGI;
print \$html->header;
\$dbh = DBI->connect(\"DBI:mysql:host=192.168.1.87:database=FLY;\",\"root\",\"\",{'RaiseError' => 1});
\$query=\"select * from $fichier\";
\$sth=\$dbh->prepare(\$query);
\$sth->execute();
print \"&#60;table>&#60;tr>";
$query="select subject from cfd where simple='$fichier'";
$sth=$dbh->prepare($query);
$sth->execute();
$prem=0;
while (($nom)=$sth->fetchrow_array){
	print "&#60;th>$nom&#60;/th>";
}
print "&#60;/tr>\";<br>";
print "while ((";
$query="select subject from cfd where simple='$fichier'";
$sth=$dbh->prepare($query);
$sth->execute();
$prem=0;
while (($nom)=$sth->fetchrow_array){
	if ($prem++>0){print ",";}
	print "\$$nom";
}
print ")=\$sth->fetchrow_array){<br>";
print "print \"&#60;tr>";
$query="select subject from cfd where simple='$fichier'";
$sth=$dbh->prepare($query);
$sth->execute();
$prem=0;
while (($nom)=$sth->fetchrow_array){
	print "&#60;td>\$$nom&#60;/td>";
}
print "&#60;/tr>\";<br>}<br>print \"&#60;/table>\";<br><br>";

print "print \"&#60;table>&#60;tr>";
$query="select subject from cfd where simple='$fichier'";
$sth=$dbh->prepare($query);
$sth->execute();
$prem=0;
while (($nom)=$sth->fetchrow_array){
	print "&#60;th>$nom&#60;/th>";
	print "&#60;td>\$$nom&#60;/td>&#60;/tr>";
}
print "<br>print \"&#60;/table>\";";

# -E pour le developpement