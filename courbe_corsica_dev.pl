#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>courbe</title><body bgcolor=#eeeeee>";
print "<center><h2>Nombre de pieces de parfums vendus</h2>";
$xref=100;
$yref=400;
# $larg=600;
$larg=360;
$haut=180;
$pas=30;
$leg_x=600; # legende
&droite($xref,$yref,$xref+$larg,$yref);
&verticale($xref,$yref-$haut,$haut);
&place_h($xref,$yref,12,"|",$pas);
&place_v($xref-2,$yref-$haut,5,"_",$pas);

my(@cal)=("Janvier","Février","mars","Avril","mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 

for ($i=$xref+5;$i<($larg+$xref);$i=$i+$pas) {
	print "<div style=\"position:absolute; top:".($yref+15)."px;left:".$i.";font-size: 5pt;\">".$cal[$index++]."</div>";
}
$index=0;
for ($i=$yref-$haut+8;$i<=($yref);$i=$i+$pas) {
	print "<div style=\"position:absolute; top:".$i."px;left:".($xref-30).";font-size: 8pt;\">".(4200-$index)."</div>";
	$index=$index+700;
}

require "./src/connect.src";


$query="select nav_nom from navire";
$sth = $dbh->prepare($query);
$sth->execute;
while (($navire) = $sth->fetchrow_array) {
	push (@navire,$navire);
}
@color=("#009999","blue","green","black","red","brown","pink","orange","purple","navy","grey","lightblue","darkred","olive");
$col=0;
print "<form>";
foreach $navire (@navire){
	print "<font color=$color[$col++]>";
	$y=$yref-$haut+(20*$col);
	$navire_sql=$navire;
	while ($navire_sql=~s/ /_/){};
	if ($html->param("$navire_sql") eq "on"){$check="checked";}else{$check="";}
	print "<div style=\"position:absolute; top:".($y-$haut+50)."px;left:".$leg_x."px;font-size: 12pt;\"><input type=checkbox name=$navire_sql $check>$navire</div>";
}

if ($html->param("stock") eq "on"){$check="checked";}else{$check="";}
print "<div style=\"position:absolute; top:".$yref."px;left:".$leg_x."px;font-size: 12pt;\"><input type=submit value=submit><font color=black> avec le stock <input type=checkbox name=stock $check></div>";
if ($html->param("valeur") eq "on"){$check="checked";}else{$check="";}
print "<div style=\"position:absolute; top:".($yref+25)."px;left:".($leg_x+50)."px;font-size: 12pt;\"><font color=black> avec les valeurs <input type=checkbox name=valeur $check></div>";
               
print "</form>";               
$col=0;
foreach $navire (@navire){
	$i=0;
	$coul=$color[$col++];
	print "<font color=$coul>";
	$navire_sql=$navire;
	while ($navire_sql=~s/ /_/){};
	if ($html->param("$navire_sql") ne "on"){next;}
	for ($mois=601;$mois<613;$mois++){
		$qte=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire like '$navire' and vdu_famille like 'PARFUMS' and vdu_mois=$mois");
		$ratio=4200/$haut;
		if ($html->param("stock") eq "on"){
			$a=substr($mois,0,1);
			$m=substr($mois,1,2);
			$date_d="200".$a."-".$m."-00";
			$date_f="200".$a."-".$m."-31";
			# inventaire douchette
			$stock=0+&get("select sum(nav_qte) from navire2,produit where nav_nom='$navire' and (nav_type=10 or nav_type=1) and nav_date>='$date_d' and nav_date<='$date_f' and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and nav_qte>0","af");
			$nbinv=0+&get("select count(DISTINCT nav_date,nav_type) from navire2 where nav_nom='$navire' and (nav_type=10 or nav_type=1) and nav_date>='$date_d' and nav_date<='$date_f' and nav_qte>0","af");
			if ($nbinv !=0){$stock=int($stock/$nbinv);}
			if ($stock !=0 ){
				$h=int($stock/$ratio);
				&rectangle($x+$pas/2-4,$yref+15-$h,$h,$coul,$stock);	
			}
		}
		$y=$yref-int($qte/$ratio);
		$x=($pas*$i++)+25+$xref;
		if ($i==1){
			$y_old=$y;
			$x_old=$x;
			}
		else
			{
			if (($y_old!=$yref)&&($y!=$yref)){
				&droite($x_old,$y_old,$x,$y,$qte);
			}
			$y_old=$y;
			$x_old=$x;
		}
	}
	print "</font>";
}

sub rectangle()
{
	my($x)=$_[0];
        my($y)=$_[1];
        my($h)=$_[2];
	my($color)=$_[3];
	my($stock)=$_[4];
	if ($html->param("valeur") eq "on"){
       		print "<div style=\"position:absolute;z-index:20 ;font-size: 6pt; top:".($y-10)."px;left:".($x+10)."px;\">$stock</div>";
        }
	print "<div style=\"position:absolute; top:".$y."px;left:".($x-2).";z-index:0; background-color:lightyellow; border-top: 2px solid ".$color." ;border-left: 2px solid ".$color." ;border-right: 2px solid ".$color."  ; margin: 0px; width: ".($pas-10)."px; height: ".$h."px\"></div> ";
}
sub place_h() 
{
        my($x)=$_[0];
        my($y)=$_[1];
        my($nb)=$_[2];
        my($chaine)=$_[3];
        my($pas)=$_[4];
        for ($i=$x;$i<=$x+($nb*$pas);$i=$i+$pas){
		print "<div style=\"position:absolute; top:".$y."px;left:".$i.";\">$chaine</div>";
        }
}
sub place_v() 
{
        my($x)=$_[0];
        my($y)=$_[1];
        my($nb)=$_[2];
        my($chaine)=$_[3];
        my($pas)=$_[4];
        for ($i=$y;$i<=$y+($nb*$pas);$i=$i+$pas){
		print "<div style=\"position:absolute; top:".$i."px;left:".$x.";\">$chaine</div>";
        }
}

sub droite() 
{
        my($x)=$_[0];
        my($y)=$_[1];
        my($nx)=$_[2];
        my($ny)=$_[3];
        my($qte)=$_[4];

        my($inc)=($ny-$y)/($nx-$x);
        my($j)=0;

	if ($html->param("valeur") eq "on"){
       		print "<div style=\"position:absolute;z-index:20 ;font-size: 6pt; top:".$ny."px;left:".$nx."px;\">$qte</div>";
        }
        for (my($i)=$x;$i<=$nx;$i++){
        	$nj=$y+int($inc*$j++);
		print "<div style=\"position:absolute;z-index:20 ; top:".$nj."px;left:".$i."px;\">.</div>";
	}
}
sub verticale() 
{
        my($x)=$_[0];
        my($y)=$_[1];
        my($ny)=$_[2];
        for ($i=$y;$i<=$ny+$y;$i++){
		print "<div style=\"position:absolute; top:".$i."px;left:".$x."px;\">.</div>";
	}
}
