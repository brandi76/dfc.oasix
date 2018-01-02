#!/usr/bin/perl 
use DBI();
# use CGI();
# $html=new CGI;
# print $html->header;
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
# push (@bases_client,"corsica");
foreach $client (@bases_client){
    if ($client ne "dfc"){
		$query="select com_no, datediff(curdate(),date) from $client.commande_info where etat=0 and accuse='0000-00-00'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while(($com_no,$diff)=$sth->fetchrow_array){
			
			$four=&get("select com2_cd_fo from $client.commande where com2_no='$com_no'");
			$fo2_identification=&get("select fo2_identification from $client.fournis where fo2_cd_fo='$four'");
		
			if (($client eq "corsica")&&($fo2_identification==0)){next;}
			if (($client ne "corsica")&&($fo2_identification==1)){next;}

			($mail)=split(/\;/,&get("select fo2_email from $client.fournis where fo2_cd_fo='$four'"));
    		$client_rep=$client;
			if ($client eq "corsica"){$client_rep="dfca";}
			$fich="";
			
			if (-f "/var/www/$client_rep.oasix/doc/$com_no.pdf"){$fich=$com_no.".pdf";}
			if (-f "/var/www/$client_rep.oasix/doc/${four}_$com_no.pdf"){$fich=$four."_".$com_no.".pdf";}
			if (-f "/var/www/$client_rep.oasix/doc/${four}_$com_no.xls"){$fich=$four."_".$com_no.".xls";}
			$mail_invalide=0;
			@liste_email=split(/\,/,$mail);
			foreach (@liste_email) {
				if (! &validemail($_)){$invalide=1;}
			}
			if (($invalide==0)&&($fich ne "")){
				$mail=~s/@/\@/g;
				$copie="supply_dfc\@dutyfreeconcept.com";
			
				if ($diff >=60){
					system("/var/www/cgi-bin/dfc.oasix/send_annulation_cde.pl '$mail' $com_no $client $copie &");
			
					&save("delete from $client.commande where com2_no=$com_no");
					&save("update $client.commande_info set etat=-1 where com_no=$com_no");
				}
				else {
					system("/var/www/cgi-bin/dfc.oasix/sendpdf_relcde.pl '$mail' $fich $com_no $client_rep $copie &");
					&save("update $client.commande_info set relance=curdate() where com_no=$com_no");
 
				}
			}
			else
			{
				$mess="relance_cde_${client}_${com_no}_${mail}_invalide";
				if ($fich eq ""){$mess="relance_cde_${client}_${com_no}_client_rep_fichier_invalide";}
				system("/var/www/cgi-bin/dfc.oasix/send_bug.pl '$mess' &");
				# print "$mess\n";
				
			}
		}
		$query="select com_no, datediff(curdate(),date) from $client.commande_info where etat=-2";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while(($com_no,$diff)=$sth->fetchrow_array){
			if ($diff>2){
				$mess="relance_daemon_Commande_${client}_${com_no}_non envoyée";
				system("/var/www/cgi-bin/dfc.oasix/send_bug.pl '$mess' &");
			}
		}
	}
}
# $mess="\'relance_cde_fait_$i\'";
# $i++;
# system("/var/www/cgi-bin/dfc.oasix/send_bug.pl '$mess' &");
