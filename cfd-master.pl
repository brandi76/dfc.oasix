#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;

$simplename="<B><U><i><font color=red>NOM Simple du programme :</font></b></u></i>\n\n";
$filename="<b><u>Nom de fichier :</b></u>\n\n";
$filesize="<b><u>Taille du fichier :</b></u>\n\n";
$keysize="<b><u>Taille de clef :</b></u>\n\n";


open(FILE,"< /home/var/spool/uucppublic/table.dsc");
@TAB=<FILE>;

print "<html>\n";
print "<title>  T A B L E S&nbsp;&nbsp;&nbsp;&nbsp;S I M P L E &#169;&nbsp;&nbsp;&nbsp;</title>\n";
print "<body text=darkgoldenrod link=black vlink=black alink=black>\n";
print "<CENTER><H1>LISTING DES TABLE \"SIMPLE\"&#153;</H1><p>\n\n";
$cont=0;
$pass=0;
$dernier=$#TAB;
$char = "";

print "<a href=#A>A</a>\n<a href=#B>B</a>\n";
print "<a href=#C>C</a>\n<a href=#D>D</a>\n";
print "<a href=#E>E</a>\n<a href=#F>F</a>\n";
print "<a href=#G>G</a>\n<a href=#H>H</a>\n";
print "<a href=#I>I</a>\n<a href=#J>J</a>\n";
print "<a href=#K>K</a>\n<a href=#L>L</a>\n";
print "<a href=#M>M</a>\n<a href=#N>N</a>\n";
print "<a href=#O>O</a>\n<a href=#P>P</a>\n";
print "<a href=#Q>Q</a>\n<a href=#R>R</a>\n";
print "<a href=#S>S</a>\n<a href=#T>T</a>\n";
print "<a href=#U>U</a>\n<a href=#V>V</a>\n";
print "<a href=#W>W</a>\n<a href=#X>X</a>\n";
print "<a href=#Y>Y</a>\n<a href=#Z>Z</a>\n<p>";

print "<table border=1>\n";

foreach (@TAB) {
	if ((grep /Simple/,$_)){
		($a,$b) = split(/ : /,$_);
		print "<tr>\n";
		$firstchar = substr($b, 0, 1);
		if($char ne $firstchar){
			print "<a name=\"#$firstchar\">\n\n";
			$char = $firstchar;
		}

		print "<td><font color=red><u><i><b>\n";
		print "$a :</u></i></b></font>\n";
		print "</td>\n";
		print "<td>\n";
		print "<a href=cfd-slave.pl?table=$b>$b</a>";
		print "</td></tr>";
		$cont=$cont+1;
	}         
	
}
#print "$cont";
# -E  Liste tables CISAM
