#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;
print "<title>gere ecart</title>";
require "./src/connect.src";


$action=$html->param("action");
$code_produit=$html->param("produit");
$produit2=$html->param("produit2");
if ($produit2 ne ""){$code_produit=$produit2;}

$plat_new=$html->param("plat")+0;
$carton_new=$html->param("carton")+0;
$detail_new=$html->param("detail")+0;
$stock_new=$html->param("stock")+0;

$packing=$html->param("packing")+0;
$casse=$html->param("casse")+0;
$plus=$html->param("plus")+0;
$moins=$html->param("moins")+0;

$justificatif=$html->param("justificatif");

$nom=$html->param("nom");
if ($nom eq ""){$action="";}
$nodepart=$html->param("nodepart");

if ($nodepart eq ""){
	$query = "select max(liv_dep)from listevol ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$nodepart=$sth->fetchrow_array;
}

# $stock_new=35;$packing=24;$plat_new="";$carton_new=1;$detail_new=11;$casse=3;$plus="";$moins="";$nom="sylvain";$justificatif="";$action="valider";

if ($action eq ""){

	$query="select pr_cd_pr,pr_desi from ordre,produit where pr_cd_pr=ord_cd_pr order by ord_ordre";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	print "<body onload=document.saisie.produit2.focus()><center><h1>Gestion des ecarts</h1><br><form name=saisie>Votre prénom <input type=text size=15 name=nom value=$nom><br>";
      	print "<br><br><select name=produit>\n";
       	while (my @tables = $sth2->fetchrow_array) {
      		next if $table eq $tables[0];
       		print "<option value=\"$tables[0]\">$tables[0] $tables[1]\n";
    	}
    	print "</select>&nbsp;";
    	print "ou code produit <input type=text size=15 name=produit2>";
    	print "<br>\n<br><input type=hidden name=nodepart value='$nodepart'><input type=hidden name=action value=visu><input type=submit value= envoie></form></body>";
}
	
if (($action eq "visu")&&($code_produit<9999)){
	if (&get("select count(*) from produit where mod(pr_cd_pr,10000)=$code_produit")==1){
		$code_produit=&get("select pr_cd_pr from produit where mod(pr_cd_pr,10000)=$code_produit");
		}
	else
	{
		$query="select pr_cd_pr,pr_desi from produit where mod(pr_cd_pr,10000)=$code_produit";
		$sth=$dbh->prepare("$query");
		$sth->execute();
		while(($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
			print "$pr_cd_pr <a href=?produit2=$pr_cd_pr&action=visu&nodepart=$nodepart&nom=$nom>$pr_desi</a><br>";
		}
		$action="";
	}
}

	

if (($action eq "modif")||($action eq "visu")){
	&inventaire();
	if (($action eq "modif")&& ($justificatif eq "") && ($casse==0)){
		print "<font color=red>Justificatif obligatoire</font><br>";
	}
	if (($action eq "modif")&& (($plat_new<0)||($carton_new<0)||($detail_new<0)||($plus<0)||($moins<0)||($packing<0)||($stock_new<0))){
		print "<font color=red>Les valeurs négatives ne sont pas acceptées</font><br>";
	}

	if (($action eq "modif")&& ($justificatif ne "")){
		if ($casse!=0){
			$casse*=100;
			$query="update produit set pr_casse=pr_casse+$casse where pr_cd_pr='$pr_cd_pr'";
			&execute();			
			$query="replace into trace_jour values (now(),'5','$pr_cd_pr','$casse','$nom','','')"; 			
			&execute();
			$pr_casse+=$casse;
			$casse/=100;
			$pr_casse/=100;
			print "<font color=green>$pr_cd_pr $pr_desi casse:$casse enregistré total casse=$pr_casse</font><br>";
	
		}
		if (($plus!=0)||($moins!=0)){
			$diff=$plus-$moins;
			$query="select erdep_qte from errdep where erdep_cd_pr='$pr_cd_pr' and erdep_depart='$nodepart' and erdep_code=''";
			$sth2=$dbh->prepare("$query");
			$sth2->execute();
			($erdep_qte)=$sth2->fetchrow_array;
			$erdep_qte+=$diff;
			# $query="replace into errdep values ('$pr_cd_pr','$nodepart','','$erdep_qte','$nom','$justificatif')";
			$query="replace into errdep values ('$pr_cd_pr','$nodepart','','$erdep_qte')";
			&execute();			
			$erdep_qte*=100;
			$query="replace into trace_jour values (now(),'9','$pr_cd_pr','$erdep_qte','$nom','$justificatif','$nodepart')"; 			
			&execute();			
			print "<font color=green>$pr_cd_pr $pr_desi ecart:$diff enregistré</font><br>";
	
		}		
		if ($packing!=$car_carton){
			
			$query="replace into carton values ('$pr_cd_pr','$packing','$plat')";
			&execute();			
			print "<font color=green>$pr_cd_pr $pr_desi packink:$packing modifié</font><br>";
	
		}
		if (($carton_new!=$carton)||($detail_new!=$detail)||($plat_new!=$plat)){
			$stock=$plat_new*$car_pal*$car_carton+$carton_new*$car_carton+$detail_new;
			$diff=$stock-$pr_stre;
			$query="select erdep_qte from errdep where erdep_cd_pr='$pr_cd_pr' and erdep_depart='$nodepart' and erdep_code=''";
			$sth2=$dbh->prepare("$query");
			$sth2->execute();
			($erdep_qte)=$sth2->fetchrow_array;
			$erdep_qte+=$diff;
			$query="replace into errdep values ('$pr_cd_pr','$nodepart','','$erdep_qte')";
			&execute();			
			$erdep_qte*=100;
			$query="replace into trace_jour values (now(),'9','$pr_cd_pr','$erdep_qte','$nom','$justificatif','$nodepart')"; 			
			&execute();			
			print "<font color=green>$pr_cd_pr $pr_desi ecart:$diff enregistré</font><br>";
	
		}		
		if ($stock_new!=$pr_stre){
			$diff=$stock_new-$pr_stre;
			$query="select erdep_qte from errdep where erdep_cd_pr='$pr_cd_pr' and erdep_depart='$nodepart' and erdep_code=''";
			$sth2=$dbh->prepare("$query");
			$sth2->execute();
			($erdep_qte)=$sth2->fetchrow_array;
			$erdep_qte+=$diff;
			$query="replace into errdep values ('$pr_cd_pr','$nodepart','','$erdep_qte')";
			&execute();			
			$erdep_qte*=100;
			$query="replace into trace_jour values (now(),'9','$pr_cd_pr','$erdep_qte','$nom','$justificatif','$nodepart')"; 			
			&execute();			
			print "<font color=green>$pr_cd_pr $pr_desi ecart:$diff enregistré</font><br>";
		
		}		

		&inventaire();
	}

	$query="select pr_cd_pr,pr_desi,pr_casse from produit where pr_cd_pr=$code_produit";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_cd_pr,$pr_desi,$pr_casse)=$sth->fetchrow_array;
	# print "$query";
	$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
	$sth2->execute();
	($car_carton,$car_pal)=$sth2->fetchrow_array;
	%stock=&stock($pr_cd_pr);
	$pr_stre=$stock{"stock"};
	$pr_stre+=0;
	$detail=$pr_stre;
	$plat=$carton="&nbsp;";
	if ($car_carton!=0){
		$carton=int($pr_stre/$car_carton);
		$detail=$pr_stre%$car_carton;
		 if ($car_pal!=0){
			$plat=int($carton/$car_pal);
			 $carton=$carton%$car_pal;
		 }
	}
	print "<form><table><tr bgcolor=#FFFF66><td>&nbsp;</td><td>&nbsp;</td><th>Stock</th><th>Packing</th><th>plat</th><th>Carton</th><th>Detail</th></tr>";
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</a></td>";
	print "<td align=right><input type=text name=stock value=$pr_stre size=3></td><td align=right><input type=text name=packing value='$car_carton' size=3></td>";
	print "<td align=right>";
	if ($car_carton!=0){print "<input type=text name=plat value=$plat size=3>";}
	print "&nbsp;</td><td align=right><input type=text name=carton value='$carton' size=3></td><td align=right><input type=text name=detail value=$detail size=3></td>";
	print "</tr>";
	print "</table><br>";
	print "<table><tr bgcolor=#FFFF66><th>Casse</th><th>Quantité en plus</td><th>Quantité en moins</th></tr>";
	print "<tR><td align=center><input type=text name=casse size=3></td><td align=center><input type=text name=plus size=3></td><td align=center><input type=text name=moins size=3></td></tr>";
	print "</table>";
	print "<input type=hidden name=nom value=$nom><input type=hidden name=nodepart value='$nodepart'><br>";
	print "Justificatif pour les ecarts (si aucune recherche n'a été faite mettre <i>Aucune recherche</i>, Si c'est un changement de packaging mettre <i>packing</i>)<br>";
	print "<textarea cols=70 rows=10 name=justificatif>maj</textarea>";
	print "<input type=hidden name=produit value='$pr_cd_pr'><br>";
	print "<input type=hidden name=action value=modif><br>";
	print "<br><input type=submit value=valider><br><br><a href=?nom=$nom>Debut</a>";
	print "</form></body>";
}

sub stock {
	$prod=$_[0];
	my($stock);
	my(%stock);
	$query = "select * from produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$produit= $sth->fetchrow_hashref;
	
	$query = "select sum(ret_retour)  from  non_sai,retoursql where ret_cd_pr=$prod and ns_code=ret_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$non_sai =$sth->fetchrow*100;
	$stock{"nonsai"}=$non_sai/100;
	
	$query = "select sum(ap_qte0)  from  appro,geslot where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$pastouch = $sth->fetchrow;
	
	$query = "select max(liv_dep)  from  geslot,listevol where gsl_nolot=liv_nolot and gsl_ind=11";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	$max = $sth->fetchrow;
	
	$query = "select sum(ap_qte0)  from  appro,listevol where ap_code=liv_aprec and ap_cd_pr=$prod and liv_dep='$max'";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	$pastouch2 = $sth->fetchrow;  # pas touche des pas touche dans le depart
	
	
	$stock{"pastouch"}=$pastouch+$pastouch2;
	$query = "select sum(ret_retour) from retoursql,retjour,geslot,etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$prod and rj_appro=ret_code and rj_date>='$today' and gsl_ind!=10 and gsl_ind!=11";
	$sth=$dbh->prepare($query);
	# print $query;
	$sth->execute();
	$retourdujour = $sth->fetchrow;
	$stock{"retourdujour"}=$retourdujour;

	# $query = "select sum(ap_qte0)  from  appro,geslot,retjour where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod and rj_appro=gsl_apcode and rj_date>=$today";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $pastouchdujour = $sth->fetchrow;
	# $stock{"pastouchdujour"}=$pastouchdujour/100;

	$query = "select sum(erdep_qte)  from  errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	$errdep = $sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"vol"}=$produit->{'$pr_vol'}/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	
	
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100;

	return(%stock);
}
sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	return($sth2->execute());
}
sub inventaire {
	$sth=$dbh->prepare("select pr_cd_pr,pr_desi,pr_casse from produit where pr_cd_pr='$code_produit'");
	$sth->execute();
	($pr_cd_pr,$pr_desi,$pr_casse)=$sth->fetchrow_array;
	
	$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
	$sth2->execute();
	($car_carton,$car_pal)=$sth2->fetchrow_array;
	%stock=&stock($pr_cd_pr);
	$pr_stre=$stock{"stock"};
	$pr_stre+=0;
	$detail=$pr_stre;
	$plat=$carton="&nbsp;";
	if ($car_carton!=0){
		$carton=int($pr_stre/$car_carton);
		$detail=$pr_stre%$car_carton;
		 if ($car_pal!=0){
			$plat=int($carton/$car_pal);
			 $carton=$carton%$car_pal;
		 }
	}
}