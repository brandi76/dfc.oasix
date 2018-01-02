use Math::Round qw(:all);
# FONCTION : tete(titre,fichier,test)
# DESCRIPTION : Affichage de l'en-tete de page
# ENTREE : Un titre (type chaine de caractere), Un fichier (chemin complet du fichier), test 1:pas de test sur la date)
sub tete {
	$TITLE = $_[0];
print "<TABLE BORDER=1 WIDTH=100% CELLSPACING=0 CELLPADDING=0 BORDERCOLORLIGHT=#F4#B0#2D BORDERCOLORDARK=DARKGOLDENROD  RULES=NONE>\n";
print "<tr>\n";
print "<td align=left width=10%><a href=mailto:sylvain\@ibs.dom?CC=alex\@ibs.dom&Subject=$TITLE>\n";
print "<img src=http://192.168.1.4/bug.gif border=0 align=left alt=\"bug à corriger\"></a>\n";
print "</td>\n";
print "<td align=center><font size=4><b>\n";
print "$TITLE</b>";
if ($_[1] ne ""){
	&datemod($_[1],$_[2]);
	}
print "</td>\n";
print "<td width=10% align=right>\n";
print "<a href=http://192.168.1.4 target=_top><img src=http://192.168.1.4/home.jpg border=0 align=right alt=\"retour à la page intraGnet\"></a>\n";
print "</td>\n";
print "</tr></table>\n";
}

# FONCTION : body()
# DESCRIPTION : Affiche la feuille des style et <BODY> de la page
sub body {
	print "<LINK rel=\"stylesheet\" href=\"http://192.168.1.4/intranet.css\" type=\"text/css\">\n";
	print "<BODY BGCOLOR=WHITE TEXT=DARKGOLDENROD TOPMARGIN=3 LINK=DARKGOLDENROD ALINK=RED VLINK=BLACK>\n";
}

# FONCTION : user(adresse_ip)
# DESCRIPTION : retourne le nom du user en fonction de l'ip
sub user {
$rem_ip = @_[0];
if($rem_ip eq ""){
	$rem_ip = $ENV{"REMOTE_ADDR"};
}
if  (! grep /192/,$rem_ip){return $rem_ip;}
@hosts = `sort -t'	' +1 /etc/hosts`;
foreach(@hosts){
	chop($_);
	($ip, $name_tmp) = split(/	/,$_);
	($name, $null) = split(/\./,$name_tmp,2);
	if($ip eq $rem_ip){
		return $name;
	}
#	print "**",$REMOTE_ADDR,"**";
	}

}

# FONCTION : cal(mois,option)
# DESCRIPTION : retourne le mois en clair soit au format cours ex janv(pas d'option) soit au format long (option=l)

sub cal {
	my ($mois)=$_[0];
	my ($option)=$_[1];
 	my ($desi)="";
	if ($mois eq 1){$desi="janv";}
	if ($mois eq 2){$desi="fev";}
	if ($mois eq 3){$desi="mar";}
	if ($mois eq 4){$desi="avr";}
	if ($mois eq 5){$desi="mai";}
	if ($mois eq 6){$desi="juin";}
	if ($mois eq 7){$desi="juil";}
	if ($mois eq 8){$desi="aout";}
	if ($mois eq 9){$desi="sept";}
	if ($mois eq 10){$desi="oct";}
	if ($mois eq 11){$desi="nov";}
	if ($mois eq 12){$desi="déc";}
	if ($option="l"){
		if ($mois eq 1){$desi="Janvier";}
		if ($mois eq 2){$desi="Fevrier";}
		if ($mois eq 3){$desi="Mars";}
		if ($mois eq 4){$desi="Avril";}
		if ($mois eq 5){$desi="Mai";}
		if ($mois eq 6){$desi="Juin";}
		if ($mois eq 7){$desi="Juillet";}
		if ($mois eq 8){$desi="Aout";}
		if ($mois eq 9){$desi="Septembre";}
		if ($mois eq 10){$desi="Octobre";}
		if ($mois eq 11){$desi="Novembre";}
		if ($mois eq 12){$desi="Décembre";}
	}
        return ($desi);
}
# FONCTION : espace(nombre)
# DESCRIPTION : retourne &nbsp; autant de fois que nombre
# ENTREE : Un nombre 
# SORTIE : Une chaine de nbsp
sub espace {
	my ($var)=@_[0];
	my ($chaine,$i);
	for ($i=0;$i<$var;$i++){
	 	$chaine.="&nbsp;";
	}
	return ($chaine);
}

# FONCTION : deci2(variable)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : le nom de la variable 
# SORTIE : 
sub deci2 {
	my ($var)=@_[0];
	my ($chaine,$deci,$ent,$dec);
	# ${$var}=${$var}/100 ;
	${$var} = "".${$var};
	($ent,$dec) = split(/\./,${$var});
	$deci = ("0.".$dec)+0;
	$deci = int($deci*100);
	
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	# ${$var}=int(${$var});
	# ${$var}=${$var}.".".$deci;
	$var=int($var);
	$chaine=$var.".".$deci;
	return($chaine);
}

# FONCTION : deci(nombre,precision,option)
# DESCRIPTION : retourne un chiffre avec  precission chiffres apres la virgule (doit remplacer deci2)
# ENTREE : Un nombre ,un nombre de virgule une option (0:&nbsp; a la place de 0)
# SORTIE : Un chaine
sub deci {
	my ($var)=@_[0];
	my ($vir)=@_[1];
	my ($option)=@_[2];

	$vir=2 if (($vir eq "")||($vir < 0));
	#print "<font color=green>$var</font>";
	my($vir2)=1/(10**$vir);
	$var=nearest_floor($vir2,$var);

	#$var=round($var*(10**$vir))/(10**$vir);
	#print "<font color=red>$var</font>";
	my ($deci,$entier)="";
	($entier,$deci)=split(/\./,$var);
	$var=$entier.".".$deci;
	for (my($i)=0;$i<($vir-length($deci));$i++){$var=$var."0";}
	$var="&nbsp;" if (($option==0)&&($var==0));
	$var="0.00" if ($var eq "-0.00");

	return ($var);
}

sub test_deci {
	print "\&deci(2.36581,2):";
	print &deci(2.36581,2);
	print "<br>";
	print "\&deci(2.36581,3):";
	print &deci(2.36581,3);
	print "<br>";
	print "\&deci(\"2.36588\",\"2\"):";
	print &deci("2.36588","2");
	print "<br>";
	print "\&deci(2.36588,5):";
	print &deci(2.36588,5);
	print "<br>";
	print "\&deci(toto,1):";
	print &deci(toto,1);
	print "<br>";
	print "\&deci(2.36088,2):";
	print &deci(2.36088,2);
	print "<br>";
	print "\&deci(2.36788,2):";
	print &deci(2.36788,2);
	print "<br>";
	print "\&deci(2.36788):";
	print &deci(2.36788);
	print "<br>";
	print "\&deci(2.36788,0):";
	print &deci(2.36788,0);
	print "<br>";
	print "\&deci(2,3):";
	print &deci(2,3);
	print "<br>";
	print "\&deci(2.1,3):";
	print &deci(2.1,3);
	print "<br>";
	print "\&deci(1.98,3):";
	print &deci(1.98,3);
	print "<br>";
	print "\&deci(0,3,0):";
	print &deci(0,3,0);
	print "<br>";

}	
# FONCTION : separateur(nombre,option)
# DESCRIPTION : retourne un chiffre avec separateur de millier et 2 chiffres apres la virgule
# ENTREE : Un nombre , une option :1 signifie avec les 0 sinon c'est espace; 2 signifie sans espace (pour recuperation excel)
# SORTIE : Une chaine avec tag html
# MODIF : 12/09/01 15:34 - corretion du bug sur les nombres negatifs

sub separateur {
	      my ($var)=$_[0];
	      my ($option)=$_[1];
	      my ($couleur);
	      my ($cent)=100;
	      my ($neg)=1;
	      $var=round($var*100)/100;
	      if ($var < 0){
              	$couleur="<font color=green>";
              	$neg=-1;}
	      if (($var <1000) && ($var >-1000)){
	        $virgule=$neg*$var*100%$cent;
	        if ($virgule<10){$virgule="0".$virgule;}
	        $virgule=substr($virgule,0,2);
	        ($var,$nul)=split(/\./,$var);
	        $var=$var.".".$virgule;
	        }
	      
	      if (($var >=1000)&&($var <1000000) || (($var<-999)&&($var>-1000000))){
	        $virgule=$neg*$var*100%$cent;
	        if ($virgule<10){$virgule="0".$virgule;}
	        $virgule=substr($virgule,0,2);
	        
	        ($var,$nul)=split(/\./,$var);
	        
	        $groupe2=substr($var,0,length($var)-3);
	        $groupe1=substr($var,length($var)-3,3);
	        $var=$groupe2."&nbsp;".$groupe1.".".$virgule;
	        }
	      
	      if (($var >=1000000)|| ($var <= -1000000)){
	        $virgule=$neg*$var*100%$cent;
	        if ($virgule<10){$virgule="0".$virgule;}
	        $virgule=substr($virgule,0,2);
	        
	        ($var,$nul)=split(/\./,$var);
	        $groupe3=substr($var,0,length($var)-6);
	        $groupe1=substr($var,length($var)-3,3);
	        $groupe2=substr($var,length($var)-6,3);
	        $var=$groupe3."&nbsp;".$groupe2."&nbsp;".$groupe1.".".$virgule; 
	}
	#print "*$option*";
	if (($var==0)&&($option!=1)){$var="&nbsp;";}
        if ($option==2){
		if ($var=="&nbsp;"){$var=0;}
		while($var=~s/&nbsp;//g){};
	}
	else{
		if ($couleur ne ""){$var=$couleur.$var."</font>";}
	}
	return($var);
	
}

# FONCTION : date(chaine)
# DESCRIPTION : insere des slash d'un format date dans une chainere
# ENTREE : Une chaine format aammjj
# SORTIE : Une chaine format aa/mm/jj 
sub date { 
            my ($date)=@_; 
            $date+=0;
            if ($date == 0){ 
            $date="-";
           } 
       	else{ 
 		if ($date <999){$date="000".$date;} 
    		if ($date <9999){$date="00".$date;} 
    		if ($date <99999){$date="0".$date;} 
    	
    		$date=substr($date,length($date)-6,2)."/".substr($date,length($date)-4,2)."/".substr ($date,length($date)-2,2);   
        } 
	return($date);
} 
# FONCTION : today
# DESCRIPTION : retourne la date du jour au format jj/mm/aa
# ENTREE : rien
# SORTIE : Une chaine format jj/mm/aa 
sub today { 
            
	return(`/bin/date '+%d/%m/%y'`);
} 

# FONCTION : date_iso(chaine)
# DESCRIPTION : retourne une date au format JJ/MM/AA
# ENTREE : Une date format mysql aaaa-mm-jj si c'est vide c'est la date du jour
# SORTIE : Une chaine format jj/mm/aa 
sub date_iso { 
            my ($date)=@_;
	    if ($date eq ""){
		   $date=`/bin/date +%d'/'%m'/'%Y`;
		   chomp($date);
	    }
	    if (grep /-/,$date){
		$date=substr ($date,8,2)."/".substr($date,5,2)."/".substr($date,0,4);   
	    }
       return($date);
} 
# FONCTION : daten(nombre)
# DESCRIPTION : retourne une chaine  au format date en inversant le tout ex 10228 -> 280201
# ENTREE : Un nombre 
# SORTIE : Une chaine de 6 caracteres 
sub daten { 
        my ($date)=@_; 
        my ($mois,$jour,$an);
	$date+=0;
	$an=substr($date,length($date)-2,2)+0;
	$mois=substr($date,length($date)-4,2)+0;
	if ($date <100000){
		$jour=substr($date,length($date)-5,1)+0;
	}
	else {
		$jour=substr($date,length($date)-6,2)+0;
	}

	if ($jour<10){$jour="0".$jour;}
        if ($mois<10){$mois="0".$mois;}
        if ($an<10){$an="0".$an;}
        $date=$an.$mois.$jour;   
	return($date);
}
# FONCTION : datemysql(nombre)
# DESCRIPTION : retourne une chaine  au format mysql  en inversant le tout ex 90213 -> 2013-02-09
# ENTREE : Un nombre 
# SORTIE : Une chaine de 10 caracteres 
sub datemysql { 
        my ($date)=@_; 
        my ($mois,$jour,$an);
	$date+=0;
	$an=substr($date,length($date)-2,2)+0;
	$mois=substr($date,length($date)-4,2)+0;
	if ($date <100000){
		$jour=substr($date,length($date)-5,1)+0;
	}
	else {
		$jour=substr($date,length($date)-6,2)+0;
	}

	if ($jour<10){$jour="0".$jour;}
        if ($mois<10){$mois="0".$mois;}
        if ($an<10){$an="0".$an;}
        $date="20".$an."-".$mois."-".$jour;
	return($date);
}

# FONCTION : datemod(fichier,test)
# DESCRIPTION : Affichage de la date d'un fichier
# ENTREE : Un fichier (chemin complet du fichier), test 1:pas de message de mise a jour

sub datemod {
	$ladate = `/usr/local/bin/datemod.sh $_[0]`;
	@date = split(/ +/,$ladate);
	$jour = `date +%d` + 0;
	$date[2] += 0;
	$mois = `date +%B`;
	chop($mois);
	#if(( $jour==$date[2] && uc($mois) eq uc($date[1]) )||($_[1]==1)){
	if(( $jour==$date[2])||($_[1]==1)){
		print "&nbsp;&nbsp;<font size=-2 color=red><i>$date[0] $date[2] $date[1] $date[4] à $date[3]</i></font>";
	}else{
				print "<font size=5 color=red><i><b>! Fichier non mis à jour !</b></i></font>";
	}
}

# FONCTION : taillefixe(???)
# affichage en taille fixe
sub taillefixe {
		my ($char)=$_[0];
		my ($len)=$_[1];
		my ($i)=0;
		my ($chaine)="";
		$_=$char;
		if (! /[a-z,A-Z]/) # astuce test si numerique
		{ # numerique
			while ($char=~s/ //g){};
			for ($i=($len-length($char));$i>0;$i--){
				$chaine=$chaine."&nbsp;";
			}
			$chaine=$chaine.$char;
			
		}
		else
		{ # non numerique
			for ($i=0;$i<=$len;$i++){
				$car=substr($char,$i,1);
				if ($car eq " "){$car="&nbsp;";}
				if ($car eq ""){$car="&nbsp;";}
				$chaine=$chaine.$car;
			}
		}
		return($chaine);
}

# FONCTION : moisencoursFR()
sub moisencoursFR {
	$mois = `date +%B`;
	chop($mois);
	@MOIS{"January"} = "Janvier";
	@MOIS{"February"} = "Février";
	@MOIS{"March"} = "Mars";
	@MOIS{"April"} = "Avril";
	@MOIS{"May"} = "Mai";
	@MOIS{"June"} = "Juin";
	@MOIS{"July"} = "Juillet";
	@MOIS{"August"} = "Aout";
	@MOIS{"September"} = "Septembre";		
	@MOIS{"October"} = "Octobre";
	@MOIS{"November"} = "Novembre";
	@MOIS{"December"} = "Décembre";

	return $MOIS{$mois};
	#return $mois;
}

# FONCTION : selecte_n(table,position,critere)
# DESCRIPTION : Récupere les élements d'une table correspondants à un critère.
# ENTREE : Une table (type tableau), Une position (type entier), critere (type indefini)
# SORTIE : Une table (type tableau), Un code erreur (type entier)
# CODE ERREUR :	<BR>&nbsp;&nbsp;&nbsp;0	execution sans probleme<BR>&nbsp;&nbsp;&nbsp;1	table vide ou non existante<br>&nbsp;&nbsp;&nbsp;2	position n'est pas un entier
# MODIF : 04/09/01 15:34 - verification du type de 'position', retour code erreur 2
sub selecte_n {

	local(*table1) = @_;	# récuperation de la table en paramètre
	my ($code_erreur) = 0;		# code en cas d'erreur
	my ($position) = @_[1];		# colonne de critère
	my ($critere) = @_[2];		# critere de selection
	my ($tmp_position,@temp,@template);
	$position -= 1;
	
	if($#table1 <0){
			$code_erreur = 1;	# table vide ou inexistante
	}
	$tmp_position = $position;
	$tmp_position =~ s/[0-9]//g;
	if( $tmp_position ne ""){
			$code_erreur = 2;	# position n'est pas un chiffer

	}
#print "<B>$position</B>";
#print "<B>$critere </B>";

	if($code_erreur == 0){
		foreach(@table1){
			@temp = split(/;/,$_);
			$critere = uc($critere);
			if (! grep /[a-z,A-Z]/,$critere) {# astuce test si numerique
		
				$temp[$position] += 0;
				if( $critere == $temp[$position] ){
					push(@temptable,$_);
				}
			
			}else{	# le critere n'est pas un nombres
				if( grep /$critere/,uc($temp[$position]) ){
			
					push(@temptable,$_);
				}
			}
		}	
	}
	# la fonction retourne un tableau et un code d'erreur
	return (*temptable,$code_erreur);
}

# FONCTION : selecte(fichier,critere,position)
# DESCRIPTION : Récupere la ligne d'un fichier suivant le critère dans la colonne position.
# ENTREE : Un fichier (full path), critere (type indefini),Une position (type entier depart a zero)
# SORTIE : Une table avec chque element spliter par ;

sub selecte {
	my ($fichier) = $_[0];
	my ($element) = $_[1];
	my ($position) = $_[2];
	my (@tab,$i);
	my (@retour)=();
	while($element=~s/ //g){};
 	if (open(FILE,"< $fichier")){
		my (@fic) = <FILE>;
		close(FILE);
		for($i=0;$i<=$#fic;$i++){
			(@tab)=split(/;/,$fic[$i]);
			while ($tab[$position]=~s/ //g){};
 			if ($tab[$position] eq $element){
				@retour=split(/;/,$fic[$i]);
				last;
			}
		}
	}
	else
        { print "fichier $fichier introuvable<br>";}
	return (@retour);
}


# FONCTION : ligne_tab(option,liste d'element)
# DESCRIPTION : Retourne une ligne d'un tableau html en fonction d'une liste d'elements
# ENTREE :  une option (tag html a mettre a chaquee fois),Une table avec un element par colonne
# SORTIE : Une ligne html
sub ligne_tab{
	my (@tab) = @_;
	my ($i);
	my ($retour)="<tr>";
	my ($align)="";
	for ($i=1;$i<=$#tab;$i++){
		if ($tab[$i]!~/[a-z]/i){$align="align=right";}
		else {$align="align=left";}
		$retour.="<td $align>$tab[0]$tab[$i]</td>";}
	$retour.="</tr>";
	return($retour);
}
	
# FONCTION : liste_n_par_n(table,nb_element,decalage,position)
# DESCRIPTION : Retourne une table n elements avec un decalage de p elements
# ENTREE : Une table (type tableau), Un nombre d'éléments à retenir (type entier), Decalage (type indefini), Une position (type entier)
# SORTIE : Une table (type tableau), Un code erreur (type entier)
sub liste_n_par_n{
	$code_erreur = 0;
	local(*table1) = @_;
	$nb_element = $_[1];
	$decalage = $_[2];
	$position = $_[3];
	
	$position -= 1;
	$newpos = $decalage + $position;
	$nb_element -= 1;
	#print "Debut : $newpos";
	
	for($i=$newpos;$i<=$newpos+$nb_element;$i++){
			push(@table,$table1[$i]);
	}

	return (*table,$code_erreur);

}
# FONCTION : get_inode(code)
# DESCRIPTION : retourne l'inode correspondant à un code
# ENTREE : un code
# SORTIE : inode

sub get_inode {
 return(&get("select inode from dfc.produit_inode where code='$_[0]'"));
} 

# FONCTION : supprime_n(fichier,critere,position,critere2,position2)
# DESCRIPTION : enleve un element d'un fichier (un seul)
# ENTREE : le nom d'un fichier (full path) , un critere 1 et 2 de recherche,une position 1 et 2 qui correspond a la colonne(depart a zero) sur lequel il faudra verifier si l'element "critere" existe
# SORTIE : code retour 0: erreur ouverture de fichier<br>1: element supprimer<br>2:element non trouvé<br>

sub supprime_n{
	my ($fichier) = $_[0];
	my ($element) = $_[1];
	my ($position) = $_[2];
	my ($element2) = $_[3];
	my ($position2) = $_[4];
	my (@tab,$i);
	my ($retour)=0;
	if ($element2 eq ""){$element2="null";}
 	if (open(FILE,"< $fichier")){
		my (@fic) = <FILE>;
		close(FILE);
		if (open(FILE,"> $fichier")){
			$retour=2;
			for($i=0;$i<=$#fic;$i++){
				(@tab)=split(/;/,$fic[$i]);
				if ((($tab[$position] ne $element)&&($tab[$position2] ne $element2))||($retour==1)){
					print FILE $fic[$i];
				}
				else{
					$retour=1;
				}
			
			}
		close (FILE);
		}
	}
	return ($retour);
}

# FONCTION : ajoute_n(fichier,element,position)
# DESCRIPTION : ajoute ou ecrase un element d'un fichier
# ENTREE : le nom d'un fichier (full path) , une ligne du fichier (separateur ; pas de \n et ; a la fin),une position qui correspond a la colonne(depart a zero) sur lequel il faudra verifier si l'element existe
# SORTIE : code retour 0: erreur ouverture de fichier<br>1: element ajouter<br>2: element ecrase

sub ajoute_n {
	my ($fichier) = $_[0];
	my ($element) = $_[1];
	my ($position) = $_[2];
	my (@tab,@ele,$i);
	my ($pass,$retour)=0;
 	open(FILE,"< $fichier");
		my (@fic) = <FILE>;
		(@ele)=split(/;/,$element);
	
		close(FILE);
		for($i=0;$i<=$#fic;$i++){
			(@tab)=split(/;/,$fic[$i]);
			if ($tab[$position] eq $ele[$position]){
				$fic[$i]=$element."\n";
				$pass=1;
				$retour=2;
			}
		}
		if ($pass==0){
			$fic[$i]=$element."\n";
			$retour=1;
			}
		if (open(FILE,"> $fichier")){
			print FILE @fic;
			close (FILE);
		}
		else {$retour=0;}
	# }
	return ($retour);
}
# FONCTION : ajoute(fichier,element)
# DESCRIPTION : ajoute un element d'un fichier
# ENTREE : le nom d'un fichier (full path) , une ligne du fichier (separateur ; pas de \n et ; a la fin)
# SORTIE : code retour 0: erreur ouverture de fichier<br>1: element ajouter

sub ajoute {
	my ($fichier) = $_[0];
	my ($element) = $_[1];
	my ($retour)=0;
 	if (open(FILE,">> $fichier")){
			print FILE "$element\n";
			close (FILE);
	}
	return ($retour);
}

# FONCTION : plus1(fichier,element)
# DESCRIPTION : ajoute 1 a la valeur de element et sauvegarde le fichier
# ENTREE : le nom d'un fichier (full path) , un element qui se trouve dans la premiere colonne
# SORTIE : la valeur +1 

sub plus1 {
	my ($fichier) = $_[0];
	my ($element) = $_[1];
	my (@tab,$i);
	my ($retour)=0;
	if (open(FILE,"< $fichier")){
		my (@fic) = <FILE>;
		close(FILE);
		`chmod 444 $fichier`;
		for($i=0;$i<=$#fic;$i++){
			(@tab)=split(/;/,$fic[$i]);
			if ($tab[0] eq $element){
				$tab[1]+=1;
				$fic[$i]=$tab[0].";".$tab[1].";\n";
				$retour=$tab[1];
			}
		}
		`chmod 666 $fichier`;
		open(FILE,"> $fichier");
		print FILE @fic;
		close (FILE);
	}
 	return ($retour);
}

# FONCTION : nbjour(date)
# DESCRIPTION : Donne le nombre de jour a partie du premier janvier 2001 
# ENTREE : Une date (jjmmaa)
# SORTIE : Un nombre
sub nbjour {
	my ($var) = $_[0];
	my (%cal)=(1,0,2,31,3,59,4,90,5,120,6,151,7,181,8,212,9,243,10,273,11,304,12,334);
	return (($var%100-1)*365 +$cal{int($var%10000/100)}+int($var/10000));
}

# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine)=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	return "$semaine{$var%7}";
}

# FONCTION : date_fr(date)
# DESCRIPTION : Donne la dat een francais  
# ENTREE : la dat eau format mysql "AAAA-MM-JJ"
# SORTIE : Jour mois année
sub date_fr {
	my ($var) = $_[0];
	my (@semaine)=("","Dimanche","Lundi","Mardi","Mercredi","Jeudi", "Vendredi", "Samedi");
	my (@mois)=("","Janvier","Février","mars","Avril","mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  
	my ($sem)=&get("select dayofweek('$var')","af");
	my ($jour)=&get("select day('$var')","af");
	my ($mo)=&get("select month('$var')","af");
	my ($an)=&get("select year('$var')","af");
	my ($result)=$semaine[$sem]." ".$jour." ".$mois[$mo]." ".$an;
	return "$result";
}


# FONCTION : famille(code)
# DESCRIPTION : retourne la famille d'un produit
# ENTREE : Un code produit 
# SORTIE : Fa_famille initialise
sub famille {
      my ($code)=$_[0];
      my ($option)=$_[1];
      $fa_famille=&get("select fa_desi from dfc.famille,dfc.produit_plus where fa_id=pr_famille and pr_cd_pr='$code'");
      $pr_famille=&get("select pr_famille from dfc.produit_plus where pr_cd_pr='$code'");
      $fa_cat=&get("select fa_cat from dfc.famille,dfc.produit_plus where fa_id=pr_famille and pr_cd_pr='$code'");
      if (($code eq 100520)&&($base_dbh eq "aircotedivoire")){
   	$pr_famille=1;
   	$fa_cat=0;
        $fa_famille=&get("select fa_desi from dfc.famille where fa_id='$pr_famille'");
      }
      if (($code eq 100525)&&($base_dbh eq "aircotedivoire")){
   	$pr_famille=1;
   	$fa_cat=0;
        $fa_famille=&get("select fa_desi from dfc.famille where fa_id='$pr_famille'");
      }
     if (($code eq 290600)&&($base_dbh eq "aircotedivoire")){
   	$pr_famille=21;
   	$fa_cat=3;
        $fa_famille=&get("select fa_desi from dfc.famille where fa_id='$pr_famille'");
      }
      if ($fa_famille eq ""){$fa_famille="Inconnu";}
}	  

# FONCTION : fa_desi(id)
# DESCRIPTION : retourne la designation famille 
# ENTREE : pr_famille 
# SORTIE : fa_desi
sub fa_desi {
      my ($fa_id)=$_[0];
      return(&get("select fa_desi from famille where fa_id='$fa_id'"));
}      
    	  

# FONCTION : famille_tpe(code)
# DESCRIPTION : retourne la famille tpe 
# ENTREE : Un code
# SORTIE : la famille
sub famille_tpe {
      my(@famille)=("Parfum Femme","Parfum Homme","Cosmetique","Accessoire","Tabac","Alimentation");
      return($famille[$_[0]]);
}

# FONCTION : convertit(prix,devise1,devise2)
# DESCRIPTION : convertit une valeur dans devise1 en devise2
# ENTREE : Un nombre , une devise , une devise
# SORTIE : Un nombre convertit
sub convertit {
	my ($prix)=@_[0];
	my ($devise1)=@_[1];
	my ($devise2)=@_[2];
	my (@file1,@file2);
	@file1=selecte("/var/spool/uucppublic/pays.txt",$devise1,0);
	@file2=selecte("/var/spool/uucppublic/pays.txt",$devise2,0);
	$prix=&deci2($prix*$file2[3]/$file1[3]);
	return ($prix);
	}


# FONCTION : tri_num()
# DESCRIPTION : permet de specifie un trie numerique a la fonction sort ex sort tri_num (@table)
# ENTREE : 
# SORTIE : 
sub tri_num {
	my ($crit1,$crit2);
	($crit1)=split(/;/,$a);
	($crit2)=split(/;/,$b);
	if (($crit1!~/[a-z]/i)&&($crit2!~/[a-z]/i)){
		if ($crit1 > $crit2){$retval=1;}
		if ($crit1 == $crit2){$retval=0;}
		if ($crit1 < $crit2){$retval=-1;}
	}
	else {
		if ($crit1 gt $crit2){$retval=1;}
		if ($crit1 eq $crit2){$retval=0;}
		if ($crit1 lt $crit2){$retval=-1;}
	}
	$retval;
}

# FONCTION : select_mois()
# DESCRIPTION : permet de specifie un trie numerique a la fonction sort ex sort tri_num (@table)
# ENTREE : 
# SORTIE : 
sub select_mois {
	my ($type_affich,$nom_param);
	$type_affich=$_[0];
	$nom_param = $_[1];
	print "<SELECT NAME='$nom_param'>\n";
	for($i=1;$i<=12;$i++){
		print "<OPTION VALUE='$i'>$i\n";
	}	
	print "</SELECT>\n";
	


}

# FONCTION : testsaisie()
# DESCRIPTION : permet de tester la validiter d'une saisie
# ENTREE : Une variable a tester, Type désirer
# SORTIE : VRAI/FAUX soit : 0 ou 1
sub testsaisie {
	my ($param,$type_restric,$VAL);
	$param=$_[0];
	@option["taille"] = 0;
	$TYPE_RESTRIC = $_[1];
	@optionparam = split(/;/,$_[2]);
	if(@optionparam ne ""){
		foreach $theoption (@optionparam){
			@infoption = split(/=/,$theoption);
			$option["$infoption[0]"] = $infoption[1];
		}
	}
	$VAL = "FAUX";
	
	
	print "<BR>Option : ",$option["taille"],@optionparam,"<BR>";
	
	# Chiffre Uniquement avec une taille donnée éventuellement
	if($TYPE_RESTRIC eq "NUM"){
		if($param =~ /^[0-9]$/){
			$VAL = "VRAI";
		}
		$taille = $option["taille"];
		if($option["taille"] ne 0 && $param =~ /^[0-9]{$taille}$/){
			$VAL .= "VRAI";
		}elsif($option["taille"] ne 0){
			$VAL = "FAUX";
		}
	}
	if($TYPE_RESTRIC eq "ALPHA"){
		# Passe a FAUX s'il y'a au moins une lettre
		if($param !~ /[0-9]/){
			$VAL = "VRAI";
		}
	}


	#if($param !~ /{*}/){
	#		$VAL = "VRAI";
	#}
	
	
	print "$VAL";


}


# FONCTION : comparechaine(chaine1,chaine2)
# DESCRIPTION : permet de tester si deux chaines sont a peut pret pareille 
# ENTREE : deux chaine
# SORTIE : VRAI/FAUX soit : 0 ou 1

=pod
sub comparechaine {

	use String::Approx qw(amatch);
	my ($min,$ok)=0;
	my($nom1)=$_[0];
	my($nom2)=$_[1];
	while ($nom1=~s/\./ /){};
	while ($nom1=~s/-/ /){};
	while ($nom2=~s/\./ /){};
	while ($nom2=~s/-/ /){};

	my (@chaine1)=split(/ /,$nom1);
	my (@chaine2)=split(/ /,$nom2);

	if ($#chaine1<$#chaine2)
	{
		$min=$#chaine1+1;
		foreach (@chaine1){
			if (length($_)<3){$min--;}
			}
	}
	else{
		$min=$#chaine2+1;
		foreach (@chaine2){
			if (length($_)<3){$min--;}
			}
	
	}
	$ok=0;
	for (my($i)=0;$i<=$#chaine1;$i++){
		if (length($chaine1[$i])<3){next;}
		for (my($j)=0;$j<=$#chaine2;$j++){
			if (length($chaine2[$j])<3){next;}
 			if ((amatch($chaine1[$i],[ 'g' , 'i', '20%'],$chaine2[$j]))&&(amatch($chaine2[$j],[ 'g' , 'i', '20%'],$chaine1[$i]))){
				$ok++;
			}
		}
	}
	#print "*$ok*$min*";
	if (($ok >= $min)&&($ok !=0)){

	return (1);
	}
	else{
		return (0);
	}
}
=cut
# FONCTION : printcle(fichier)
# DESCRIPTION : permet de d'afficher de maniere sequentiel un fichier indexe 
# ENTREE : le fichier indexe
# SORTIE : rien

sub printcle {
	my (%fichier)=@_;
	my ($cle);
	foreach $cle ( sort tri_num keys(%fichier)){
		print "$cle $fichier{$cle}<br>";
	}
}

# FONCTION : checkbarre(code)
# DESCRIPTION : permet de verifier un code barre 
# ENTREE : le code barre
# SORTIE : 1 ou 0

sub checkbarre {
	my($pr_codebarre)=$_[0];
	if ($pr_codebarre<10000000){return(1);}
	my($check)=$pr_codebarre%10;
	my($oper)=1;
	my($somme)=0;
	my($digit)=0;
	for (my($i)=12;$i>0;$i--){
		$digit=int($pr_codebarre/10**$i)%10;
		$somme+=$digit*$oper;
		if ($oper==1){$oper=3;}else{$oper=1;}
	}
	$somme%=10;
	$somme=(10-$somme)%10;
	if ($check!=$somme){return(0);}else{return(1);}		
}
# FONCTION : digit(code,four)
# DESCRIPTION : permet d affichier un code barre en separant les quatres derniers digits 
# ENTREE : le code barre , le code fournsiseur
# SORTIE : affiche  code produit 

sub digit {
	my($pr_cd_pr)=$_[0];
	my($pr_four)=$_[1];
	if ($pr_cd_pr<10000000){return();}
	my($digit_f)=$pr_cd_pr%10000+10000;
	$digit_f=substr($digit_f,1,4);
	my($digit_p)=int($pr_cd_pr/10000);
	if ($pr_four==2070){
		$digit_f=$pr_cd_pr%100000+100000;
		$digit_f=substr($digit_f,1,5);
		$digit_p=int($pr_cd_pr/100000);
	}
	 print "$digit_p <font size=+2><b>$digit_f</b></font>";
}

# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}

# FONCTION : nb_jour_sql
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : yyyy-mm-jj
# SORTIE : le nombre de seconde

sub nb_jour_sql{
	my ($jour)=0;
	my ($mois)=0;
	my ($annee)=0;
	($annee,$mois,$jour)=split(/-/,$_[0]);
	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}

# FONCTION : nb_jour_an(annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : annee (yyyy)
# SORTIE : le nombre en jour

sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}
# FONCTION : bissextile(annee)
# DESCRIPTION : vrai si bissextile
# ENTREE : annee (yyyy)
# SORTIE : vrai si bissextile

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/mm/DD
# SORTIE : la date formatée

sub julian {
	my ($val)=$_[0];
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
# FONCTION : select_date
# DESCRIPTION : retourne un select sur la date
# ENTREE : 
# SORTIE : variable formulaire:datejour,datemois,datean

sub select_date
{
 	my ($nom)=$_[0];
	my($date)=`/bin/date +%d';'%m';'%Y`;
  	(my(@dates))=split(/;/, $date, 3); 
  	my (@select_jour,$select_mois);
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	my($firstyear)=$dates[2];
	print "<select name=".$nom."datejour>"; 
 	for(my($i)=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	my(@cal)=("","Janvier","Février","mars","Avril","mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print " <select name=".$nom."datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=".$nom."datean>"; 
	for($i=$firstyear-2;$i<=($firstyear+1);$i++) { 
		print "<option value=$i";
		if ($i==$firstyear){print " selected";}
		print ">$i</option> ";
		} 
 	print "</select>"; 
} 

sub select_heure
{
  	print "<select name=dateheure>"; 
 	for(my($i)=0;$i<=24;$i++) {print "<option value=\"$i\">$i</option>\n";} 
 	print "</select> h "; 
  	print "<select name=dateminute> ";
 	for($i=0;$i<=59;$i++) { print "<option value=\"$i\">$i</option>\n"; } 
  	print "</select> mm" ; 
} 

# FONCTION : stock
# DESCRIPTION : retourne un fichier asscociatif %stock
# ENTREE : code produit, date de reference pour les retours  en julian, option quick,option2 debug
# SORTIE : 

sub stock {
	my($prod)=$_[0];
	my($today)=$_[1];
	my($option)=$_[2];
	my($option2)=$_[3];

	my($stock,$non_sai,$pastouch,$max,$pastouch2,$retourdujour,$errdep);
	my(%stock);
	my($query) = "select * from produit where pr_cd_pr=$prod";
	
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit)=$sth->fetchrow_hashref;
	if ($option ne "quick"){
		# stock entrepot
		$query = "select sum(ret_retour)  from  non_sai,retoursql where ret_cd_pr=$prod and ns_code=ret_code";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$non_sai=$sth->fetchrow*100;
		$stock{"nonsai"}=$non_sai/100;
		$query = "select sum(ap_qte0) from  appro,geslot where (gsl_ind=10 or gsl_ind=11) and gsl_apcode=ap_code and ap_cd_pr=$prod";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$stock{"pastouch"}=$sth->fetchrow;
		
		# $query = "select max(liv_dep)  from  geslot,listevol where gsl_nolot=liv_nolot and gsl_ind=11";
	 	# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $max = $sth->fetchrow;
		
		# $query = "select sum(ap_qte0)  from  appro,listevol where ap_code=liv_aprec and ap_cd_pr=$prod and liv_dep='$max'";
	 	# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $pastouch2 = $sth->fetchrow;  # pas touche des pas touche dans le depart
		
		
		#$stock{"pastouch"}=$pastouch+$pastouch2;
		if ($option eq "retour"){
 			$query = "select sum(ret_retour) from retoursql,retjour,geslot,etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$prod and rj_appro=ret_code and rj_date>=$today and gsl_ind!=10 and gsl_ind!=11";
# 			print "$query";
			$sth=$dbh->prepare($query);
 			$sth->execute();
			$retourdujour = $sth->fetchrow;
			$stock{"retourdujour"}=$retourdujour;
	        }
		# $query = "select sum(ap_qte0)  from  appro,geslot,retjour where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod and rj_appro=gsl_apcode and rj_date>=$today";
		# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $pastouchdujour = $sth->fetchrow;
		# $stock{"pastouchdujour"}=$pastouchdujour/100;
	
	}
	$stock{"vol"}=$produit->{'pr_stvol'}/100;
	$query = "select sum(erdep_qte) from errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$errdep=$sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
		
	
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	$stock{"pr_stre"}=$stock{"stre"}-$stock{"casse"}+$stock{"diff"}+$stock{"errdep"}; # stock comptable
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100; # entrepot
	if ($option2 eq "debug"){
		print "$prod<br>";
		print "stock compta:$stock{'pr_stre'}<br>";
		print "casse:$stock{'casse'}<br>";
		print "en vol:$stock{'vol'}<br>";
		print "diff :$stock{'diff'}<br>";
		print "errdep :$stock{'errdep'}<br>";
        	print "entrepot:$stock{'stock'}<br>";
        	print "non saisie:";
		print $non_sai/100;
		print "<br>";
		print "pas touche: $stock{'pastouch'}<br>";
      
		
	}	
	return(%stock);
}

# FONCTION : backup
# DESCRIPTION : sauvegarde de la base de donneé oasix
# ENTREE : 
# SORTIE : 

sub backup {	
	my($date)=`/bin/date +%y%m%d'_'%T`;
	system ("/usr/bin/mysqldump -h 127.0.0.1 -u root oasix >/home/backup/FLY/fly.$date");
	system ("/bin/gzip /home/backup/oasix/fly.$date");
}

# FONCTION : execute
# DESCRIPTION : mise a jour du fichier avec trace
# ENTREE : $query
# SORTIE : vrai ou faux

sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	return($sth2->execute());
}

# FONCTION : carton
# DESCRIPTION : retourne un affichage stock (pal,carton,detail)
# ENTREE : code produit, stock
# SORTIE :(packing) stock (plat,carton,detail) 

sub carton {
	my($prod)=$_[0];
	my($stock)=$_[1]+0;
	my($plat,$carton,$car_carton,$car_pal)=0;
	my($query) = "select car_carton,car_pal from carton where car_cd_pr='$prod'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($car_carton,$car_pal)=$sth->fetchrow_array;
	my($detail)=$stock;
	$car_carton+=0;
	if ($car_carton!=0){
		$carton=int($stock/$car_carton);
		$detail=$stock%$car_carton;
		if ($car_pal!=0){
			$plat=int($carton/$car_pal);
			$carton=$carton%$car_pal;
		}
	}
	if ($plat==0){$plat="";}
	else {$plat=$plat.',';}
	print "($car_carton) <b>$stock</b> ($plat $carton,$detail)";
}
# FONCTION : get
# DESCRIPTION : retourne les valeur du get
# ENTREE : query, option (aff affiche la requete)
# SORTIE :tableau des valeurs) 

sub get(){
	if ($_[1] eq "aff"){print "$_[0]<br>";}
	my ($sth)=$dbh->prepare($_[0]);
	$sth->execute() or die (print $_[0]);
	return ($sth->fetchrow_array);
}



	
# FONCTION : save
# DESCRIPTION : sauvegarde mysql
# ENTREE : query, option (aff affiche la requete)
# SORTIE :rien
	
sub save()
{
	if ($_[1] eq "aff"){print "$_[0]<br>";}
	if ($_[1] eq "check"){print "$_[0]<br>";}
	if ($_[1] ne "check"){
	  my ($sth)=$dbh->prepare($_[0]);
	  $sth->execute() or die (print $_[0]);
	}
	if ($_[2] eq "trace"){
		$_[0]=~s/\'//g;
		$_[0]=~s/\"//g;
		my ($sth)=$dbh->prepare("insert into traceur values (now(),'$_[0]','$user','$ip')");
			$sth->execute() or die (print $query);
	}
}

# FONCTION : lock
# DESCRIPTION : permet de savoir si un programme est locker (10 secondes) sinon il le lock 
# ENTREE : nom du programme ($0)
# SORTIE :boolean vrai c'est bon faux dernier acces <10 secondes

sub lock()
{
	my($t)=time();
	# print "*";
	my($ru_time)=&get("select ru_time from running  where ru_name='$_[0]'")+0;
	# print "+$ru_time+";
	if ($ru_time){
		my($diff)=$t-$ru_time;
		# print "++ $diff ++";
		if ($diff >10){
			&save("update running set ru_time='$t' where ru_name='$_[0]'");
			# print "*1*";
			return(1);
		}
		else {
			return(0);
		}
	}
	else {
		&save ("insert into running values ('$_[0]','$t')");
		return(1);
	}
}

# FONCTION : semaine
# DESCRIPTION : permet de connaitre le numero de semaine
# ENTREE : rien (aujourd'hui) sinon un jour au format sql aaaa-mm-jj
# SORTIE :le jour de la semaine

sub semaine()
{
	my($date)=$_[0];
	my($semaine);
	if ($date eq ""){
		$semaine=&get("select week(now(),1)")
	}
	else
	{
		$semaine=&get("select week(\"$date\",1)")
	}
	return($semaine);
}

# FONCTION : jourdelan
# DESCRIPTION : permet de connaitre le premier jour de lannee
# ENTREE : rien  ou -1 pour l'annee precedente
# SORTIE :le premier jour l anne au format "aaaa-01-01"

sub jourdelan()
{
	my($option)=$_[0];
	my($date)=`/bin/date +%Y`;
	chop($date);
	$date+=$option;
	$date=$date."-01-01";
	return($date);
}
# FONCTION : paneg
# DESCRIPTION : permet de mettre a zero un produit negatif
# ENTREE : la variable 
# SORTIE :la variable ou zero
    
sub paneg()
{
	${"$_[0]"}=0 if (${"$_[0]"}<0);
}
# FONCTION : prac
# DESCRIPTION : retourne le prix d'achat vec les remises
# ENTREE : produit 
# SORTIE :prix d'achat

sub prac()
{
	my($produit)=$_[0];
	my($pr_prac,$pr_rem,$pr_remise2,$query);
	$query="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$produit'";
	my($sth)=$dbh->prepare($query);
	$sth->execute;
	($pr_prac,$pr_rem) = $sth->fetchrow_array;
	$pr_remise2=&get("select pr_remise_com from produit_plus where pr_cd_pr='$produit'","af")+0;
	if ($pr_rem>0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}
	if ($pr_remise2 >0){$pr_prac=$pr_prac-($pr_prac*$pr_remise2/100);}
	$pr_prac=int($pr_prac*100)/100;
	return($pr_prac);
}

sub prac_base()
{
	my($code)=$_[0];
	my($prac)=0;
	my($four)=0;
	my($valeur)=0;
	my($sth)=$dbh->prepare("select pr_prac,pr_four from produit where pr_cd_pr='$code'");
	$sth->execute();
	($prac,$four)=$sth->fetchrow_array;
	$prac=$prac/100;
	my($query)="select valeur from remise_four where four='$four' order by rang";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($valeur)=$sth->fetchrow_array){
		$prac=$prac-$valeur*$prac/100;
	}
    $prac=int($prac*100)/100;	
	return($prac);
}

# FONCTION : generate_random_string
# DESCRIPTION : retourne une chaine au hazard
# ENTREE : nb de caractere 
# SORTIE :la chaine

sub generate_random_string
{
	my $length_of_randomstring=shift;# the length of 
			 # the random string to generate

	my @chars=('a'..'z','A'..'Z','0'..'9','_');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}
# FONCTION : traduit
# DESCRIPTION : retourne une chaine sans accent use HTML::Entities; use Encode;
# ENTREE : une chaine sans tag  
# SORTIE :la chaine

sub traduit
{
        print encode_entities(decode('utf8',"$_[0]"));

}
sub sans_accent
{
  my $chaine=$_[0];
  $chaine=~s/[àáâãäå]/a/g;
  $chaine=~s/[èéêë]/e/g;
  $chaine=~s/[ìíîï]/i/g;
  $chaine=~s/[óôõö]/o/g;
  $chaine=~s/\&/et/g;
  $chaine=~s/'/ /g;
 
  return($chaine);
}

sub form_hidden
{
	print "<input type=hidden name=onglet value=$onglet> 
<input type=hidden name=sous_onglet value=$sous_onglet> 
<input type=hidden name=sous_sous_onglet value=$sous_sous_onglet>";
}
sub addslashes {
    $text = shift;
    ## Make sure to do the backslash first!
    $text =~ s/\\/\\\\/g;
    $text =~ s/'/\\'/g;
    $text =~ s/"/\\"/g;
    $text =~ s/\\0/\\\\0/g;
    return $text;
}

sub datepicker {
  if (grep(/\//,$_[0])) {
	  ($jj,$mm,$aa)=split(/\//,$_[0]);
	  $_[0]=$aa."-".$mm."-".$jj;
  }
  return $_[0];
}
sub desi_court {
  my $code=$_[0];
  my($sth)=$dbh->prepare("select * from dfc.produit_desi where code='$code'");
  $sth->execute();
  ($null,$desi_court,$desi_tpe,$marque,$marque_court)=$sth->fetchrow_array;
  if (($code eq 290600)&&($base_dbh eq "aircotedivoire")){
    $desi_court="CARRE SOIE ABLA POKOU";
    $desi_tpe="CARRE SOIE";
  }
   if (($code eq 100520)&&($base_dbh eq "aircotedivoire")){
    $desi_court="AQUA AMARA";
    $desi_tpe="AQUA AMARA";
  }
   if (($code eq 100525)&&($base_dbh eq "aircotedivoire")){
    $desi_court="OMNIA INDIAN";
    $desi_tpe="OMNIA INDIAN";
  }
}


sub info {
  my $chaine=$_[0];
  my $option=$_[1];
  print "<div id=info style=\"position:relative;margin:auto;width:400px;padding:0px;top:200px;background-color:#EFEFEF;border-radius:5px;box-shadow:10px 10px 30px 0px #656565;\">
  <div style=\"margin:0;width:399px;height:20px;background-color:#CECECE;border-radius:5px 5px 0px 0px;border-top:1px solid #8f8f8f;border-left:1px solid #8f8f8f;border-right:1px solid #8f8f8f\";></div>
  <div style=\"text-align:justify;margin:0;padding:10px;border:1px solid black;height:120px;border-radius:0px 0px 5px 5px;\">
  <img src=http://image.oasix.fr/info.png style=padding-right:20px;float:left>$chaine
  <input type=button style=\"position:relative;margin:auto;display:block;margin-top:5px\" value=Ok onclick=";
  if ($option eq ""){print "getElementById(\"info\").style.display='none'";}
  print "></div></div> ";
}

sub validemail {
	my ($mail);
	my (@tabmail)=split(/\;/,$_[0]);
	my ($ok)=1;
	foreach $mail (@tabmail) {
		$mail=~ s/\.\@/\@/;
		if ($mail eq '') { $ok=0;}
		if ($mail!~ /\@/) { $ok=0;}
		if ($mail=~ /\@.*\@/) { $ok=0;}
		if ($mail=~ /[\,|\s|\;]/) {$ok=0;}
		if ($mail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/ || ($mail !~ /^.+\@localhost$/ && $mail !~ /^.+\@\[?(\w|[-.])+\.[a-zA-Z]{2,3}|[0-9]{1,3}\]?$/)) {
				$ok=0;
		} 	
	}
	return($ok);
}

sub nom_four{
	(my $nom)=split(/\*/,&get("select fo2_add from dfc.fournis where fo2_cd_fo='$_[0]'"));
	return($_[0]." ".$nom);
}

sub admin {
  my ($admin)=0;
  if (($user eq "daniel")||($user eq "pierrette")||($user eq "philippe")||($user eq "sylvain")||($user eq "isabelle")){$admin=1;}
  return($admin);
}

sub print_td {
  my $val=$_[0];
  if ($val eq ""){$val="&nbsp;";}
  print $val;
}
sub switch_color {
  if ($color eq "white"){$color="lavender";}else{$color="white";}
  $run=$_[0];
}


sub cle_ean13 {
	$nb=$_[0];
	my ($i,$x,$y,$z,$m);
	for ($i=0;$i<11;$i+=2){
		$x+=substr($nb,$i,1);
	}
	for ($i=1;$i<12;$i+=2){
		$y+=substr($nb,$i,1);
	}
	$z=$y*3+$x;
	$m=int(($z+9)/10)*10-$z;
	# print $x;
	# print "\n";
	# print $y;
	# print "\n";
	# print $z;
	# print "\n";
	# print $m;
	return($nb.$m);
}

# FONCTION : trash
# DESCRIPTION : retourne une chaine sans accent à la con;
# ENTREE : une chaine   
# SORTIE :la chaine néttoyée
sub trash{
 # codage ansi
  my $chaine=$_[0];
  $chaine =~ s/^\s+//; 
  $chaine =~ s/\s+$//; 
  my $chaine_clean="";
  my ($i)=0;
  for ($i=0;$i<length($chaine);$i++){
		$ok=1;
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==180)){
			$chaine_clean.="ô";
			$i++;
			$ok=0;
		}	
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==169)){
			$chaine_clean.="é";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==172)){
			$chaine_clean.="ì";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==136)){
			$chaine_clean.="È";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==160)){
			$chaine_clean.="à";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==128)){
			$chaine_clean.="À";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==174)){
			$chaine_clean.="î";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==142)){
			$chaine_clean.="Î";
			$i++;
			$ok=0;
		}
		
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==168)){
			$chaine_clean.="è";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==175)){
			$chaine_clean.="ï";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==148)){
			$chaine_clean.="Ô";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==178)){
			$chaine_clean.="ò";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==188)){
			$chaine_clean.="ü";
			$i++;
			$ok=0;
		}
		
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==167)){
			$chaine_clean.="ç";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==162)){
			$chaine_clean.="â";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==187)){
				$chaine_clean.="û";
				$i++;
				$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==185)){
			$chaine_clean.="ù";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==171)){
			$chaine_clean.="«";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==174)){
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==187)){
			$chaine_clean.="»";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==160)){
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==170)){
			$chaine_clean.="ê";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==138)){
			$chaine_clean.="Ê";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==137)){
			$chaine_clean.="É";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==197)&&(ord(substr($chaine,$i+1,1))==147)){
			$chaine_clean.="œ";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==197)&&(ord(substr($chaine,$i+1,1))==146)){
			$chaine_clean.="Œ";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==226)&&(ord(substr($chaine,$i+1,1))==128)&&(ord(substr($chaine,$i+2,1))==153)){
			$chaine_clean.="'";
			$i++;
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==176)){
			$chaine_clean.="°";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==169)){
			$i++;
			$ok=0;
		}
		if ($ok) {
		# print ord(substr($chaine,$i,1)," ";
		$chaine_clean.=substr($chaine,$i,1);
		}
  }
  return($chaine_clean);
}

# FONCTION : param
# DESCRIPTION : retourne les variables de param;
# ENTREE : rien 
# SORTIE :les variables
sub param
{
	@names = $html->param;
	foreach (@names){
		${$_}=$html->param("$_");
	}
 }
1;
