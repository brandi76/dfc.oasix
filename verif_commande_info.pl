#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
use CGI;
$html=new CGI;
print $html->header();
$option=$html->param("option");
push(@bases_client,"corsica");
push(@bases_client,"cameshop");
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	# print "<h3>$client</h3>";
	$query="SELECT com_no,etat,blabla FROM $client.commande_info order by com_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com_no,$etat,$blabla)=$sth->fetchrow_array){
		$nb=0;
		$commande=&get("select count(*) from $client.commande where com2_no='$com_no'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no='$com_no'","af")+0;
		if (($commande==0)&&($commandearch==0)&&($etat!=-1)){
			print "$com_no etat:$etat non trouve mais dans commande_info <br>";
			if ($option eq "maj"){&save("update $client.commande_info set etat=-1 where com_no='$com_no'","aff");  }
		}
		elsif (($commande>0)&&($commandearch>0)){
			print "$com_no $etat manquant";
			$liv=&get("select com2_no_liv from $client.commande where com2_no='$com_no'")+0;
			$liv_arch=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'")+0;
			print "no liv $liv no liv arch:$liv_arch<br>";
			if ($option eq "maj"){&save("delete from $client.commande where com_no='$com_no' and com2_no_liv=0","aff");  }
			if ($option eq "maj"){&save("delete from $client.commandearch where com_no='$com_no' and com2_no_liv=0","aff");  }

		}
		elsif (($commandearch>0)&&($etat<5)){
			print "$com_no $etat pb etat ";
			$bl=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'");
			$entree=&get("select enh_no from $client.enthead where enh_document='$bl'");
			print "no entree:$entree";
			# if ($entree >0){&save("update $client.commande_info set etat=5 where com_no='$com_no'","aff");}
			print "<br>";
			if ($option eq "maj"){&save("update $client.commande_info set etat=5 where com_no='$com_no'","aff");  }
		}
		elsif (($commande>0)&&($etat==5)){
			print "$com_no $etat pb etat<br>";
			if ($option eq "maj"){&save("update $client.commande_info set etat=0 where com_no='$com_no'","aff");  }
		}
	}
	$query="SELECT livh_id,livh_date,livh_facture from livraison_h where livh_base='$client' and livh_id>416 order by livh_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($liv_id,$livh_date,$livh_facture)=$sth->fetchrow_array){
		$check=&get("select datediff('2016-07-25','$livh_date')");
		if ($check>0){next;}
		
		$commande=&get("select count(*) from $client.commande where com2_no_liv='$liv_id'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no_liv='$liv_id'","af")+0;
		if ($livh_facture eq ""){next;}
		if (($commande==0)&&($commandearch==0)){
			print "$client bl:$liv_id $livh_date commande inconnu <br>";
		}	
	}
	$query="select distinct(com2_no) from $client.commande where com2_no not in (select com_no from $client.commande_info)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no)=$sth->fetchrow_array){
		print "$client $com2_no introuvable dans commande_info<br>";
	}
	$query="select distinct com2_no,com2_cd_fo,com2_no_liv from $client.commande where com2_no_liv!=0 order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com_no_liv)=$sth->fetchrow_array){
		# if ($com2_no_liv <500){next;}
		$diff=&get("select datediff(curdate(),livh_date) from livraison_h where livh_id='$com_no_liv'"); 
		if ($diff<16){next;}
		$livh_user=&get("select livh_user from livraison_h where livh_id='$com_no_liv'"); 
		$livh_date=&get("select livh_date from livraison_h where livh_id='$com_no_liv'"); 
		
		$fo_add=&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo' ");
	    ($fo_nom)=split(/\*/,$fo_add);
	      
		print "$client $com2_no bl:$com_no_liv $fo_nom créé par:$livh_user le $livh_date non rentré <br>";
		$query="select * from livraison_x where livx_id=$com_no_liv";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($livx_id,$livx_date,$livx_nom,$livx_blabla)=$sth2->fetchrow_array;
		print "<span style=color:navy>$livx_date $livx_nom $livx_blabla</span><br>";
	    
	}
}