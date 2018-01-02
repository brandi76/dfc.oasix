#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
require 'manip_table.lib';


print "<html><body>";
&tete("Téléphone","/home/var/spool/uucppublic/telephone.txt",1); 

$action=$html->param("action");
$client=$html->param("client");
$nom=$html->param("nom");

$date = `/bin/date '+%d%m%y'`;   
chop($date);  
$user = &user(); 

if ($action eq ""){
	&choixclient();
}
if ($action eq "supp"){
	&supprime_n("/home/var/spool/uucppublic/telephone.txt",$client,0,$nom,1);
	$action="ajout";
}
if ($action eq "ajout"){
	&choixajout();
}



if ($action eq "confirme"){
	&confirme();
	&choixajout();

}

sub choixclient {
	print "<center><br><br>";
	if ($erreur ==1){
		print "<font color=red>Client $client introuvable </font><br><br>";
		$erreur=0;
	}
	
	print"
	<form name=choix action=telephone.pl>Code client :<input type=text size=8 name=client><br><br>
	<input type=hidden name=action value=ajout>
	<input type=submit value=go></form>
	</body></html>";
}

sub choixajout {
	($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville)=&selecte("/home/var/spool/uucppublic/client2.txt",$client,0); 
	
	if ($cl_cd_cl eq ""){
		$erreur=1;
		&choixclient();
		exit;
		}	

	%teleph_idx = &get_index_multiple("telephone",0);
	open(FILE2,"/home/var/spool/uucppublic/telephone.txt");
	@teleph_dat=<FILE2>;
	close(FILE2);

	print "<center><br><br><table border=1>";
	print &ligne_tab("<b>","Code","Organisme","Service","Rue","Ville");
	
	print &ligne_tab("",$cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville);
	print "</table>";
	print "<br><b>Téléphone:</b><br><br>";
	print "<table border=1>";
	print &ligne_tab("<b>","Nom","Téléphone","Commentaire","saisie par");
	
	@liste=split(/;/,$teleph_idx{$cl_cd_cl});
	foreach (@liste){
		($null,$nom,$tel,$comm,$cree)=split(/;/,$teleph_dat[$_]);
		print &ligne_tab("","<a href=telephone.pl?client=$cl_cd_cl&action=supp&param=$nom>$nom</a>","<b>$tel",$comm,$cree);
	}		
	print "</table>";	
	print "<form action=telephone.pl>";
	print "<b>Ajouter</b><br>";
	print "<br>";
	print "<table><tr><td>";
	print "<input type=hidden name=client value=$cl_cd_cl>";
	print "<input type=hidden name=action value=confirme>";
	print "
	<b>Nom <input type=text name=nom zize=30><br>
	<b>Téléphone <input type=text name=tel zize=12><br>
	<b>Commentaire <input type=text name=comm size=60><br></td></tr></table>"; 
        print "<br><input type=submit value=valider></form>";
        print "</body></html>"; 

	
}

sub confirme {
	
	if ($html->param("nom") ne ""){
		$ligne=$client.";".$html->param("nom").";".$html->param("tel").";".$html->param("comm").";".$user.";"."$date".";\n";
		open(FILE2,">>/home/var/spool/uucppublic/telephone.txt");
		print FILE2 $ligne;     
		close (FILE2); 	
	}

}

# -E Téléphone 