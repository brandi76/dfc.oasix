#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;

$simplename="<B><U><i><font color=red>NOM Simple du programme :</font></b></u></i>\n\n";
$filename="<b><u>Nom de fichier :</b></u>\n\n";
$filesize="<b><u>Taille du fichier :</b></u>\n\n";
$keysize="<b><u>Taille de clef :</b></u>\n\n";

$parametre = $html->param('table');

open(FILE,"< /home/var/spool/uucppublic/table.dsc");
@TAB=<FILE>;

print "<html>\n";
print "<title> D E S C R I P T I O N&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;L A&nbsp;&nbsp;&nbsp;&nbsp;T A B L E&nbsp;&nbsp;&nbsp;&nbsp;$parametre&nbsp;&nbsp;&nbsp;&nbsp;&#169;</title>\n";

print "<body>\n";
print "<table border=1>\n";
$cont=-1;
$pass=0;
$dernier=$#TAB;
foreach (@TAB) {
#        print "#########################################################################\n<br>";
        $cont++;
        #print "$_\n<br>";
        ($a,$b) = split(/ : /,$_);
        #print "**$a**$b**\n<br>";
        #if(grep /Simple/,$a){
        #	while ($_ =~ s/ / /g){};
        #}
        $b =~ s/ //g;
#        print "**$b**:**$parametre**\n<br>";
        if ((grep /Simple/,$a) && ($parametre eq$b) ){
          $premier=$cont;
          $pass=1;
        }
        elsif ((grep /Simple/,$_) && ($pass==1)){
          $dernier=$cont-1;
          last;
        }
         
}
for($nbline=$premier;$nbline<=$dernier-2;$nbline++){
	if($nbline==$premier){
		@TAB[$nbline] =~ s/Simple name/$simplename/gs;	
	}
	elsif($nbline==$premier+1){
	  		@TAB[$nbline] =~ s/Filename/$filename/gs;
			@TAB[$nbline] =~ s/Record size/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$filesize/gs;
			@TAB[$nbline] =~ s/Key size/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$keysize/gs;
	
	}
        else {
	@TAB[$nbline] =~ s/ +/_/g;
	($a,$b,$c,$d,$e,$f) = split (/_/,@TAB[$nbline]);
	@TAB[$nbline] = "$a</td><td>$b</td><td>$c</td><td>$f\n\n";
	}
        if (($nbline!=$premier+2)&&($nbline!=$premier+5)){
        if ($nbline>=$premier+5){
	 print "<tr><td>",$nbline-($premier+5),"</td><td>",@TAB[$nbline],"</td></tr>\n\n";
        }
        else{
	 print "<tr><td></td><td>",@TAB[$nbline],"</td></tr>\n\n";
        }
        }
}
print "</table></body></html>\n";
