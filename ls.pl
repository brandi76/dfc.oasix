#!/usr/bin/perl
use CGI; 
$html=new CGI;
require 'outils_perl.lib';

print $html->header; 
print "<body><html><table>";
$rep=$html->param('rep');
$option=$html->param("option");
ls();
print "</table></body></html>";

sub ls(){
if ($option eq "short"){
	 open(REP,"ls -lt $rep 2>/dev/null|grep \"^d\"|");
	 open(FICHIER,"ls -lt $rep 2>/dev/null|grep -v \"^d\"|head -100 |sed -e 1d|");

}
else
{
	 open(REP,"ls -l $rep 2>/dev/null|grep \"^d\"|");
	 #  open(FICHIER,"ls -l $rep/$option* 2>/dev/null|grep -v \"^d\"|sed -e 1d|sed -e 's/\/home\/intranet\/cgi-bin\///'|");
	 # open(FICHIER,"ls -l $rep/$option* 2>/dev/null|grep -v \"^d\"|sed -e 1d|grep \"^$option\"|");
	
	  open(FICHIER,"ls -l $rep/$option* 2>/dev/null|grep -v \"^d\"|sed -e 1d|");

}
@ls1=<REP>;
@ls2=<FICHIER>;
@ls=(@ls1,@ls2);
print "<tr><td><font color=red>$rep</font></td></tr>";
foreach (@ls)
{
	print "<tr><td>";
	$lien="";
	while ($_=~ s/  / /g){};
	@ligne=split(/ /,$_);
	$fichier = $ligne[8];
	$fichier=~s/\/home\/intranet\/cgi-bin\///;	
	($base,$ext)=split(/\./,$fichier);
	# fichier perl htm et photo et shell
	if ((grep /pl/,$ext)||(grep /htm/,$ext)||(grep /jpg/,$ext)||(grep /gif/,$ext)||(grep /sh/,$ext)||(grep /php/,$ext)){
		$couleur="<font color=blue>";
		@chemin=split(/\//,$rep);
		$lien="http://ibs.oasix.fr/";
		for ($i=3;$i<=$#chemin;$i++){
			$lien.=$chemin[$i]."/";
		}
		$lien="<a href=".$lien.$fichier.">run</a>";
		$lien=~s/public_html\///;
		if (grep /php/,$ext){
			$lien=~s/cgi-bin\///;
			}
			
		$lien=$lien."</td><td>"."<a href=\"http://ibs.oasix.fr/cgi-bin/visu.pl?fichier=".$rep."/".$fichier."\">voir</a>";
			
	}
	
	# fichier perl uniquement
	# if ((grep /pl/.$ext){
	#	$lien=$lien."<td><a href=http://ngh.dom/cgi-bin/chmod.pl?fichier=".$rep."/".$fichier.">777</a></td>";
	#	}
	# repertoire
	if ($ext eq ""){
		$couleur="<font color=black size=+1>";
		$lien="<a href=\"http://ibs.oasix.fr/cgi-bin/ls.pl?rep=".$rep."/".$fichier."\">entrer</a>";
	}
	# fichier texte et librairie
	if (((grep /txt/,$ext)|| (grep /lib/,$ext))&&(! grep /livraison/,$fichier)){
		$couleur="<font color=green>";
		$lien="<a href=\"http://ibs.oasix.fr/cgi-bin/visu.pl?fichier=".$rep."/".$fichier."\">voir</a>";
	}
	print " $couleur $fichier </font></td><td>$lien </td>";
	$fichier=$rep."/".$fichier;
	$com="";
	if ($ext ne ""){
		open(COM,"grep \"# -E\" $fichier 2>/dev/null|");
		$com=<COM>;
		$com=~s/\# -E//;
		}
	print "<td>$com</td>";
	
	#if ((grep /ids/,$ext)||(grep /IDS/,$ext)){
	#		print "<td>$fichier";
	#		print &datemod("/home/var/spool/uucppublic/IDS/$fichier",1);
	#		print "</td>";
	#}
	close(COM);
	print "</tr>";
}

}

# -E explorateur linux en perl 
