#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>courbe</title><body bgcolor=#eeeeee>";
print "<center><h2>Nombre de pieces de parfums vendus</h2>";
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

print "<div style=\"position:absolute; top:108px;left:70;font-size: 8pt;\">4200</div>";
print "<div style=\"position:absolute; top:158px;left:70;font-size: 8pt;\">3500</div>";
print "<div style=\"position:absolute; top:208px;left:70;font-size: 8pt;\">2800</div>";
print "<div style=\"position:absolute; top:258px;left:70;font-size: 8pt;\">2100</div>";
print "<div style=\"position:absolute; top:308px;left:70;font-size: 8pt;\">1400</div>";
print "<div style=\"position:absolute; top:358px;left:70;font-size: 8pt;\">700</div>";
print "<div style=\"position:absolute; top:408px;left:70;font-size: 8pt;\">0</div>";


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
	$y=100+(20*$col);
	$navire_sql=$navire;
	while ($navire_sql=~s/ /_/){};
	if ($html->param("$navire_sql") eq "on"){$check="checked";}else{$check="";}
	print "<div style=\"position:absolute; top:".$y."px;left:800px;font-size: 12pt;\"><input type=checkbox name=$navire_sql $check>$navire</div>";
}

if ($html->param("stock") eq "on"){$check="checked";}else{$check="";}
print "<div style=\"position:absolute; top:500px;left:800px;font-size: 12pt;\"><input type=submit value=submit><font color=black> avec le stock <input type=checkbox name=stock $check></div>";
if ($html->param("valeur") eq "on"){$check="checked";}else{$check="";}
print "<div style=\"position:absolute; top:525px;left:850px;font-size: 12pt;\"><font color=black> avec les valeurs <input type=checkbox name=valeur $check></div>";
if ($html->param("an_1") eq "on"){$check="checked";}else{$check="";}
print "<div style=\"position:absolute; top:550px;left:860px;font-size: 12pt;\"><font color=black> année derniere<input type=checkbox name=an_1 $check></div>";
               
print "</form>";               
$col=0;
$an=&get("select year(now())");
$an=$an-2000;
if ($html->param("an_1") eq "on"){$an=$an-1;}
$and=$an*100+1;
$anf=$an*100+13;
foreach $navire (@navire){
	$i=0;
	$coul=$color[$col++];
	print "<font color=$coul>";
	$navire_sql=$navire;
	while ($navire_sql=~s/ /_/){};
	if ($html->param("$navire_sql") ne "on"){next;}
	for ($mois=$and;$mois<$anf;$mois++){
		$qte=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire like '$navire' and vdu_famille like 'PARFUMS' and vdu_mois=$mois","af");
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
				$h=int($stock/14);
				&rectangle($x+32,415-$h,$h,$coul,$stock);	
			}
		}
		$y=400-int($qte/14);
		$x=(50*$i++)+125;
		if (($html->param("valeur") eq "on")&&($qte!=0)){
			print "<div style=\"position:absolute;z-index:20 ;font-size: 6pt; top:".$y."px;left:".$x."px;\">$qte</div>";
		}        
		if ($i==1){
			$y_old=$y;
			$x_old=$x;
			}
		else
			{
			if (($y_old!=400)&&($y!=400)){
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
	print "<div style=\"position:absolute; top:".$y."px;left:".($x-2).";z-index:0; background-color:lightyellow; border-top: 2px solid ".$color." ;border-left: 2px solid ".$color." ;border-right: 2px solid ".$color."  ; margin: 0px; width: 40px; height: ".$h."px\"></div> ";
}
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
        my($x)=$_[0];
        my($y)=$_[1];
        my($nx)=$_[2];
        my($ny)=$_[3];
        my($qte)=$_[4];

        my($inc)=($ny-$y)/($nx-$x);
        my($j)=0;

        for (my($i)=$x;$i<=$nx;$i++){
        	$nj=$y+int($inc*$j++);
		print "<div style=\"position:absolute;z-index:20 ; top:".$nj."px;left:".$i."px;\">.</div>";
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
