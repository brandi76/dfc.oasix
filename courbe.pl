#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>courbe</title>";

&droite(100,400,700,400);
&verticale(100,100,400);
&place_h50(100,400,12,"|");
&place_v50(100,98,5,"_");

print "<div style=\"position:absolute; top:415px;left:105;font-size: 8pt;\">Janvier</div>";
print "<div style=\"position:absolute; top:415px;left:155;font-size: 8pt;\">Fevrier</div>";
print "<div style=\"position:absolute; top:415px;left:205;font-size: 8pt;\">Mars</div>";
print "<div style=\"position:absolute; top:415px;left:255;font-size: 8pt;\">Avril</div>";
print "<div style=\"position:absolute; top:415px;left:305;font-size: 8pt;\">Mai</div>";
print "<div style=\"position:absolute; top:415px;left:355;font-size: 8pt;\">Juin</div>";
print "<div style=\"position:absolute; top:415px;left:405;font-size: 8pt;\">Juillet</div>";
print "<div style=\"position:absolute; top:415px;left:455;font-size: 8pt;\">Aout</div>";
print "<div style=\"position:absolute; top:415px;left:505;font-size: 8pt;\">Septembre</div>";
print "<div style=\"position:absolute; top:415px;left:555;font-size: 8pt;\">octobre</div>";
print "<div style=\"position:absolute; top:415px;left:605;font-size: 8pt;\">Novembre</div>";
print "<div style=\"position:absolute; top:415px;left:655;font-size: 8pt;\">Decembre</div>";


sub place_h50() 
{
        $x=$_[0];
        $y=$_[1];
        $nb=$_[2];
        $chaine=$_[3];
        for ($i=$x;$i<=$x+($nb*50);$i=$i+50){
		print "<div style=\"position:absolute; top:".$y."px;left:".$i.";\">$chaine</div>";
        }
}
sub place_v50() 
{
        $x=$_[0];
        $y=$_[1];
        $nb=$_[2];
        $chaine=$_[3];
        for ($i=$y;$i<=$y+($nb*50);$i=$i+50){
		print "<div style=\"position:absolute; top:".$i."px;left:".$x.";\">$chaine</div>";
        }
}

sub droite() 
{
        $x=$_[0];
        $y=$_[1];
        $nx=$_[2];
        $ny=$_[3];
        $inc=($ny-$y)/($nx-$x);
        $j=0;
        for ($i=$x;$i<=$nx;$i++){
        	$nj=$y+int($inc*$j++);
		print "<div style=\"position:absolute; top:".$nj."px;left:".$i."px;\">.</div>";
	}
}
sub verticale() 
{
        $x=$_[0];
        $y=$_[1];
        $ny=$_[2];
        for ($i=$y;$i<=$ny;$i++){
		print "<div style=\"position:absolute; top:".$i."px;left:".$x."px;\">.</div>";
	}
}
