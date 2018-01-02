#!/usr/bin/perl
# #!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
print "<title>Recap tva</title>";
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
if ($action eq ""){&premiere();}
if ($action eq "go"){
	&go();
}

if ($action eq "client"){&clien();}
sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=10><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";

}

sub clien{
	$query="select distinct cl_cd_cl,cl_nom from vol,client where v_cd_cl=cl_cd_cl order by v_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
		print "$cl_cd_cl $cl_nom <br>";
	}
}
sub go{
	$caalc=$cacig=$cavab=$catab=0;
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	
	print "Mois:$mois   Client:$cl_nom <br><br><bR>";
	$query="select distinct ret_cd_pr from retoursql,vol where ret_code=v_code and  v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 order by ret_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
        while (($pr_cd_pr)=$sth->fetchrow_array){
		push(@produit,$pr_cd_pr);
	}

	print "<table border=1 cellspacing=0><tr><th>No Ref</th><th>Date</th><th>No vol</th><th>Tronçon</th><th>Départ</th><th>Arrivée</th><th>Type Tva</th><th>Fermeture de caisse no</th><th>Info vol pnc</th><th>Recette</th><th>Recette TVA 19.6</th><th>Recette Tva 5.5</th>";
	print " <th>Recette Tva europe</th><th>Recette Hors tva</th></tr>";
	$query="select v_code,v_vol,v_date,v_dest from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 order by v_code";
	# $query="select v_code,v_vol,v_date,v_dest from vol where v_code=24111 and v_rot=1";
	# if ($mois eq "411"){
	if ($mois eq "---"){
	
	print "
	<tr><td>25544</td><td>30411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">70.5</td><td align=\"right\">0</td><td align=\"right\">70.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25544</td><td>30411</td><td>SE0770</td><td>CDG/CUN/CUN/BOD/BOD/NTE/NTE/CD/CD/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:773</td><td align=\"right\">82</td><td align=\"right\">15</td><td align=\"right\">67</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25544</td><td>30411</td><td>SE0770</td><td>CDG/CUN/CUN/BOD/BOD/NTE/NTE/CD/CD/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:771</td><td align=\"right\">46.5</td><td align=\"right\">0</td><td align=\"right\">46.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25544</td><td>30411</td><td>SE0770</td><td>CDG/CUN/CUN/BOD/BOD/NTE/NTE/CD/CD/</td><td><br></td><td><br></td><td></td><td>4</td><td>vol:222</td><td align=\"right\">101</td><td align=\"right\">0</td><td align=\"right\">101</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25544</td><td>30411</td><td>SE0770</td><td>CDG/CUN/CUN/BOD/BOD/NTE/NTE/CD/CD/</td><td><br></td><td><br></td><td></td><td>5</td><td>vol:229</td><td align=\"right\">93</td><td align=\"right\">12</td><td align=\"right\">81</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25544</td><td>30411</td><td>SE0770</td><td>CDG/CUN/CUN/BOD/BOD/NTE/NTE/CD/CD/</td><td><br></td><td><br></td><td></td><td>6</td><td>vol:223</td><td align=\"right\">24</td><td align=\"right\">0</td><td align=\"right\">24</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25546</td><td>30411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">255</td><td align=\"right\">21</td><td align=\"right\">234</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25547</td><td>70411</td><td>SE0470</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:470</td><td align=\"right\">45</td><td align=\"right\">0</td><td align=\"right\">45</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25547</td><td>70411</td><td>SE0470</td><td>CDG/VCE/VCE/BOD/BOD/NTE/NTE/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:0</td><td align=\"right\">52</td><td align=\"right\">6</td><td align=\"right\">46</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25547</td><td>70411</td><td>SE0470</td><td>CDG/VCE/VCE/BOD/BOD/NTE/NTE/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:473</td><td align=\"right\">108</td><td align=\"right\">9</td><td align=\"right\">99</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25547</td><td>70411</td><td>SE0470</td><td>CDG/VCE/VCE/BOD/BOD/NTE/NTE/VC/VC/</td><td><br></td><td><br></td><td></td><td>4</td><td>vol:471</td><td align=\"right\">31.5</td><td align=\"right\">3</td><td align=\"right\">28.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25548</td><td>50411</td><td>SE0222</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:442</td><td align=\"right\">28.5</td><td align=\"right\">0</td><td align=\"right\">28.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25548</td><td>50411</td><td>SE0222</td><td>CDG/OLB/OLB/SXB/SXB/LYS/LYS/OL/OL/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:229</td><td align=\"right\">137.5</td><td align=\"right\">6</td><td align=\"right\">131.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:522</td><td align=\"right\">32.5</td><td align=\"right\">0</td><td align=\"right\">32.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:529</td><td align=\"right\">81.5</td><td align=\"right\">3</td><td align=\"right\">78.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:520</td><td align=\"right\">157.5</td><td align=\"right\">18</td><td align=\"right\">139.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>4</td><td>vol:523</td><td align=\"right\">7.5</td><td align=\"right\">0</td><td align=\"right\">7.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:522</td><td align=\"right\">65</td><td align=\"right\">0</td><td align=\"right\">65</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:529</td><td align=\"right\">66.5</td><td align=\"right\">0</td><td align=\"right\">66.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:529</td><td align=\"right\">134</td><td align=\"right\">9</td><td align=\"right\">125</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>4</td><td>vol:520</td><td align=\"right\">75.5</td><td align=\"right\">18</td><td align=\"right\">57.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25549</td><td>80411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>5</td><td>vol:523</td><td align=\"right\">20.5</td><td align=\"right\">0</td><td align=\"right\">20.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25550</td><td>80411</td><td>SE0540</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:540</td><td align=\"right\">46</td><td align=\"right\">0</td><td align=\"right\">46</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25550</td><td>80411</td><td>SE0540</td><td>CDG/TUN/TUN/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:-1</td><td align=\"right\">24</td><td align=\"right\">0</td><td align=\"right\">24</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25550</td><td>80411</td><td>SE0540</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:540</td><td align=\"right\">44</td><td align=\"right\">0</td><td align=\"right\">44</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25550</td><td>80411</td><td>SE0540</td><td>CDG/TUN/TUN/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:541</td><td align=\"right\">66.5</td><td align=\"right\">21</td><td align=\"right\">45.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25551</td><td>80411</td><td>SE0564</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:564</td><td align=\"right\">247.5</td><td align=\"right\">12</td><td align=\"right\">235.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25551</td><td>80411</td><td>SE0564</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:564</td><td align=\"right\">203</td><td align=\"right\">3</td><td align=\"right\">200</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25552</td><td>60411</td><td>SE0338</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:338</td><td align=\"right\">311</td><td align=\"right\">18</td><td align=\"right\">293</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25552</td><td>60411</td><td>SE0338</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:338</td><td align=\"right\">241.5</td><td align=\"right\">18</td><td align=\"right\">223.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25560</td><td>100411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">157.5</td><td align=\"right\">3</td><td align=\"right\">154.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25560</td><td>100411</td><td>SE0770</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:773</td><td align=\"right\">193</td><td align=\"right\">15</td><td align=\"right\">178</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25560</td><td>100411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">112.5</td><td align=\"right\">0</td><td align=\"right\">112.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25560</td><td>100411</td><td>SE0770</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:773</td><td align=\"right\">262.5</td><td align=\"right\">15</td><td align=\"right\">247.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25561</td><td>100411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">292</td><td align=\"right\">18</td><td align=\"right\">274</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25561</td><td>100411</td><td>SE0756</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:757</td><td align=\"right\">25.5</td><td align=\"right\">0</td><td align=\"right\">25.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25561</td><td>100411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">279</td><td align=\"right\">21</td><td align=\"right\">258</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25561</td><td>100411</td><td>SE0756</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:757</td><td align=\"right\">28</td><td align=\"right\">0</td><td align=\"right\">28</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25562</td><td>120411</td><td>SE0222</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:222</td><td align=\"right\">90</td><td align=\"right\">3</td><td align=\"right\">87</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25563</td><td>130411</td><td>SE0338</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:338</td><td align=\"right\">143</td><td align=\"right\">12</td><td align=\"right\">131</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25563</td><td>130411</td><td>SE0338</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:339</td><td align=\"right\">54</td><td align=\"right\">3</td><td align=\"right\">51</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25563</td><td>130411</td><td>SE0338</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:338</td><td align=\"right\">218</td><td align=\"right\">0</td><td align=\"right\">218</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25563</td><td>130411</td><td>SE0338</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:339</td><td align=\"right\">83.5</td><td align=\"right\">12</td><td align=\"right\">71.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25564</td><td>140411</td><td>SE0470</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:470</td><td align=\"right\">138</td><td align=\"right\">15</td><td align=\"right\">123</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25564</td><td>140411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:473</td><td align=\"right\">118</td><td align=\"right\">21</td><td align=\"right\">97</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25564</td><td>140411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:471</td><td align=\"right\">41</td><td align=\"right\">0</td><td align=\"right\">41</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25564</td><td>140411</td><td>SE0470</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:470</td><td align=\"right\">86</td><td align=\"right\">6</td><td align=\"right\">80</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25564</td><td>140411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:471</td><td align=\"right\">91.5</td><td align=\"right\">0</td><td align=\"right\">91.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25564</td><td>140411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:471</td><td align=\"right\">31</td><td align=\"right\">0</td><td align=\"right\">31</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25565</td><td>150411</td><td>SE0540</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:540</td><td align=\"right\">131</td><td align=\"right\">0</td><td align=\"right\">131</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25565</td><td>150411</td><td>SE0540</td><td>CDG/CTA/CTA/NTE/NTE/LYS/LYS/CT/CT/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:545</td><td align=\"right\">34.5</td><td align=\"right\">0</td><td align=\"right\">34.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25565</td><td>150411</td><td>SE0540</td><td>CDG/CTA/CTA/NTE/NTE/LYS/LYS/CT/CT/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:545</td><td align=\"right\">42.5</td><td align=\"right\">9</td><td align=\"right\">33.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25567</td><td>150411</td><td>SE0564</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:564</td><td align=\"right\">249.5</td><td align=\"right\">21</td><td align=\"right\">228.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25567</td><td>150411</td><td>SE0564</td><td>CDG/PMO/PMO/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:564</td><td align=\"right\">25.5</td><td align=\"right\">0</td><td align=\"right\">25.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25567</td><td>150411</td><td>SE0564</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td></td><td align=\"right\">240.5</td><td align=\"right\">0</td><td align=\"right\">240.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25567</td><td>150411</td><td>SE0564</td><td>CDG/PMO/PMO/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:564</td><td align=\"right\">53.5</td><td align=\"right\">6</td><td align=\"right\">47.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25568</td><td>170411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">324</td><td align=\"right\">27</td><td align=\"right\">297</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25568</td><td>170411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">128.5</td><td align=\"right\">12</td><td align=\"right\">116.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25569</td><td>170411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">209.5</td><td align=\"right\">30</td><td align=\"right\">179.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25569</td><td>170411</td><td>SE0756</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:757</td><td align=\"right\">50</td><td align=\"right\">0</td><td align=\"right\">50</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25569</td><td>170411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">122</td><td align=\"right\">3</td><td align=\"right\">119</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25569</td><td>170411</td><td>SE0756</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:757</td><td align=\"right\">46.5</td><td align=\"right\">12</td><td align=\"right\">34.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25570</td><td>190411</td><td>SE0222</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:222</td><td align=\"right\">177</td><td align=\"right\">9</td><td align=\"right\">168</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25571</td><td>200411</td><td>SE0338</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:338</td><td align=\"right\">69.5</td><td align=\"right\">12.5</td><td align=\"right\">57</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25572</td><td>210411</td><td>SE0470</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:470</td><td align=\"right\">168</td><td align=\"right\">9</td><td align=\"right\">159</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25572</td><td>210411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:473</td><td align=\"right\">92.5</td><td align=\"right\">6</td><td align=\"right\">86.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25572</td><td>210411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:471</td><td align=\"right\">90</td><td align=\"right\">6</td><td align=\"right\">84</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25572</td><td>210411</td><td>SE0470</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:470</td><td align=\"right\">161.5</td><td align=\"right\">15</td><td align=\"right\">146.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25572</td><td>210411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:473</td><td align=\"right\">61</td><td align=\"right\">3</td><td align=\"right\">58</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25572</td><td>210411</td><td>SE0470</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:471</td><td align=\"right\">67</td><td align=\"right\">3</td><td align=\"right\">64</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25573</td><td>190411</td><td>SE0822</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:822</td><td align=\"right\">537</td><td align=\"right\">15</td><td align=\"right\">522</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25573</td><td>190411</td><td>SE0822</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:322</td><td align=\"right\">389</td><td align=\"right\">9</td><td align=\"right\">380</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25573</td><td>190411</td><td>SE0822</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:322</td><td align=\"right\">364.5</td><td align=\"right\">12</td><td align=\"right\">352.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25573</td><td>190411</td><td>SE0822</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:822</td><td align=\"right\">395.5</td><td align=\"right\">15</td><td align=\"right\">380.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:0</td><td align=\"right\">62</td><td align=\"right\">9</td><td align=\"right\">53</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:0</td><td align=\"right\">224</td><td align=\"right\">9</td><td align=\"right\">215</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:520</td><td align=\"right\">92.5</td><td align=\"right\">3.5</td><td align=\"right\">89</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>4</td><td>vol:520</td><td align=\"right\">36</td><td align=\"right\">0</td><td align=\"right\">36</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:522</td><td align=\"right\">90</td><td align=\"right\">3</td><td align=\"right\">87</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:529</td><td align=\"right\">252.5</td><td align=\"right\">12</td><td align=\"right\">240.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:820</td><td align=\"right\">133</td><td align=\"right\">9</td><td align=\"right\">124</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25574</td><td>220411</td><td>SE0522</td><td>CDG/OLB/OLB/NTE/NTE/OLB/OLB/CD/CD/</td><td><br></td><td><br></td><td></td><td>4</td><td>vol:523</td><td align=\"right\">30.5</td><td align=\"right\">0</td><td align=\"right\">30.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25576</td><td>220411</td><td>SE0564</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:564</td><td align=\"right\">347</td><td align=\"right\">30</td><td align=\"right\">317</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25576</td><td>220411</td><td>SE0564</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:564</td><td align=\"right\">395</td><td align=\"right\">15</td><td align=\"right\">380</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25577</td><td>240411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">123</td><td align=\"right\">0</td><td align=\"right\">123</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25577</td><td>240411</td><td>SE0770</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:773</td><td align=\"right\">28.5</td><td align=\"right\">0</td><td align=\"right\">28.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25577</td><td>240411</td><td>SE0770</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:771</td><td align=\"right\">58</td><td align=\"right\">0</td><td align=\"right\">58</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25577</td><td>240411</td><td>SE0770</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:770</td><td align=\"right\">126.5</td><td align=\"right\">0</td><td align=\"right\">126.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25577</td><td>240411</td><td>SE0770</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:773</td><td align=\"right\">31.5</td><td align=\"right\">0</td><td align=\"right\">31.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25577</td><td>240411</td><td>SE0770</td><td>CDG/VCE/VCE/NTE/NTE/TLS/TLS/VC/VC/</td><td><br></td><td><br></td><td></td><td>3</td><td>vol:771</td><td align=\"right\">73.5</td><td align=\"right\">3</td><td align=\"right\">70.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25578</td><td>240411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">207.5</td><td align=\"right\">18</td><td align=\"right\">189.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25578</td><td>240411</td><td>SE0756</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td></td><td align=\"right\">40.5</td><td align=\"right\">0</td><td align=\"right\">40.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25578</td><td>240411</td><td>SE0756</td><td>CDG/</td><td><br></td><td><br></td><td>Tva France</td><td>1</td><td>vol:756</td><td align=\"right\">178.5</td><td align=\"right\">30</td><td align=\"right\">148.5</td><td align=\"right\">0</td><td align=\"right\">0</td></tr><tr><td>25578</td><td>240411</td><td>SE0756</td><td>CDG/AGP/AGP/CDG/CDG/</td><td><br></td><td><br></td><td></td><td>2</td><td>vol:757</td><td align=\"right\">33</td><td align=\"right\">3</td><td align=\"right\">30</td><td align=\"right\">0</td><td align=\"right\">0</td></tr>";
	$totca="12135.5";
	$totcatva1="715";
	$totcatva2="11420.5";
	$totcaeu="0";
	$totcatiers="0";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_date,$v_dest)=$sth->fetchrow_array){
		$nbtpe=&get("select count(*)  from oasix_appro where oaa_appro='$v_code' and oaa_serial!=99")+0;
		if ($nbtpe>0){
			$query="select oaa_serial,oaa_date  from oasix_appro where oaa_appro='$v_code'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($oa_serial,$oa_date_import)=$sth2->fetchrow_array){
				$query="select distinct oa_rotation from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import='$oa_date_import' ";
				$sth3=$dbh->prepare($query);
				$sth3->execute();
				while (($oa_rotation)=$sth3->fetchrow_array){
					$ca=$catva1=$catva2=0;
					$query="select oa_col2,oa_col3/100 from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import='$oa_date_import' and oa_rotation='$oa_rotation'";
					$sth4=$dbh->prepare($query);
					$sth4->execute();
					while (($desi,$prix)=$sth4->fetchrow_array){
						$ca+=$prix;
						$pr_cd_pr=&get("select oa_cd_pr from oasix_prod where oa_desi='$desi'");
						if ($pr_cd_pr eq "") { print "<font color=red>$desi produit inconnu</font>";}	
						else {
							$pr_ventil=&get("select pr_ventil from produit where pr_cd_pr='$pr_cd_pr'");
							if ($pr_ventil==1){$catva1+=$prix;}else {$catva2+=$prix;}
						}
					}
					$rotation=substr($oa_rotation,5,1);
					$oa_vol=&get("select oa_col2 from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date_import' and oa_col2 like 'vol%' and oa_rotation='$oa_rotation'");
					&ligne();
				}
			}
		}
		else
		{
		    $ca=$catva1=$catva2=0;
			$query="select vdu_cd_pr,sum(vdu_qte),vdu_prix from vendusql where vdu_appro='$v_code' group by vdu_cd_pr";
			$sth4=$dbh->prepare($query);
			$sth4->execute();
			while (($pr_cd_pr,$qte,$prix)=$sth4->fetchrow_array){
				$ca+=$prix*$qte;
				$pr_ventil=&get("select pr_ventil from produit where pr_cd_pr='$pr_cd_pr'");
				if ($pr_ventil==1){$catva1+=$prix*$qte;}else {$catva2+=$prix*$qte;}
			}
			$rotation=1;
			&ligne();
		}
	}
	print "<tr><td colspan=9><b>Total</b></td>";
	print "<td align=right><b>$totca</b></td>";
	print "<td align=right><b>$totcatva1</b></td>";
	print "<td align=right><b>$totcatva2</b></td>";
	print "<td align=right><b>$totcaeu</b></td>";
	print "<td align=right><b>$totcatiers</b></td>";
	print "</table>";
}	

sub ligne () {
	print "<tr><td>$v_code</td><td>$v_date</td><td>$v_vol</td><td>";
	(@rot)=split(/\//,$v_dest);
	$aff=0;
	$nbrot=$#rot;
	$troncon="???";
	$depart="";
	$arrive="";
	if ($rotation <=$nbrot){
		$troncon=$rot[$rotation-1]."-".@rot[$rotation];
		$depart=$rot[$rotation-1];
		$arrive=$rot[$rotation];
		if ($arrive eq "CD"){$arrive="CDG";}
	}
	print "$troncon</td>";
	print "<td>";
	$aero_desi=&get("select aero_desi from aeroport where aero_tri='$depart'");
	$pays=&get("select aerd_desi from aerodesi where aerd_trig='$depart'");
	print "$aero_desi<br>$pays";    
	print "</td>";
	print "<td>";
	$aero_desi=&get("select aero_desi from aeroport where aero_tri='$arrive'");
	$pays=&get("select aerd_desi from aerodesi where aerd_trig='$arrive'");
	print "$aero_desi<br>$pays";    
	print "</td>";

	print "<td>";
	$type=&get("select aero_type from aeroport where aero_tri='$depart'");
	  
	$catiers=$caeu=0;
	if ($type==0){print "Tva France";}
	if ($type==1){print "Tva Europe";$catva1=0;$catva2=0;$caeu=$ca;}
	if ($type==3){print "Hors tva";$catva1=0;$catva2=0;$catiers=$ca;}
	print "</td>";
	print "<td>$rotation</td><td>$oa_vol</td>";
	print "<td align=right>$ca</td>";
	print "<td align=right>$catva1</td>";
	print "<td align=right>$catva2</td>";
	print "<td align=right>$caeu</td>";
	print "<td align=right>$catiers</td>";
	$totca+=$ca;
	$totcatva1+=$catva1;
	$totcatva2+=$catva2;
	$totcaeu+=$caeu;
	$totcatiers+=$catiers;
	print "</tr>";
}