use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
use Spreadsheet::WriteExcel;

$nocde=$html->param("nocde");
$four=$html->param("four");
if ($four eq ""){$four=$html->param("fourmanu");}
$action=$html->param("action");
$prod=$html->param("prod");
$livraison=$html->param("livraison");
$onglet=$html->param("onglet");
$sous_onglet=$html->param("sous_onglet");
$sous_sous_onglet=$html->param("sous_sous_onglet");
print "<style media=\"screen\">#pied {display:none;}</style>";
print "<style media=\"print\">#send {display:none;}</style>";
&save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");

if ($action eq "modif") {
	$check=&get("select com2_no_liv from commande where com2_no='$nocde'")+0;
	if ($check!=0){print "<span style=background:pink>Impossible elle est sur le bl $check</span><br>";}
	else {
	$query="select com2_cd_pr from commande where com2_no='$nocde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_cd_pr)=$sth->fetchrow_array){
			$qte=$html->param("qte$com2_cd_pr")+0;
			$qte*=100;
			&save("update commande set com2_qte=$qte where com2_no='$nocde' and com2_cd_pr=$com2_cd_pr","");
	}
	}
	$action="entree";	
}

		
if ($action eq "sup") {
	$check=&get("select com2_no_liv from commande where com2_no='$nocde'")+0;
	if ($check!=0){print "<span style=background:pink>Impossible elle est sur le bl $check</span><br>";}
	else {
		&save("delete from commande where com2_no=$nocde");
		&save("update commande_info set etat=-1,user='$user',date=curdate() where com_no=$nocde");
		print "<font color=red>commande $nocde supprimé<br>";
	}
	$action="";
}

if ($action eq "majprac"){
	$check=&get("select com2_no_liv from commande where com2_no='$nocde'")+0;
	if ($check!=0){print "<span style=background:pink>Impossible elle est sur le bl $check</span><br>";}
	else{
	&save("update commande,produit set com2_prac=pr_prac/100 where com2_no='$nocde' and com2_cd_pr=pr_cd_pr","af");
	print "Mise à jour des prix effectuée";
	}
	$action="entree";
}	

if ($action eq "send_pdf"){
        $four=&get("select com2_cd_fo from commande where com2_no='$nocde'");
		$fich=$four."_".$nocde.".pdf";
		$mail=$html->param('mail');
		$copie=$html->param('copie');
		$mail=~s/@/\@/g;
		$copie=~s/@/\@/g;
# 		print "/var/www/cgi-bin/$base_rep/sendpdf_cde.pl $mail $fich $copie $nocde ";
		system("/var/www/cgi-bin/$base_rep/sendpdf_cde.pl '$mail' $fich $nocde '$copie' &");
		print "<div class=titre>Mail envoyé</div>";
		&save("update commande_info set etat=0 where com_no='$nocde'");
		$action="";
}

if ($action eq "send_xls"){
        $four=&get("select com2_cd_fo from commande where com2_no='$nocde'");
		$fich=$four."_".$nocde.".xls";
		$mail=$html->param('mail');
		$copie=$html->param('copie');
		$mail=~s/@/\@/g;
		$copie=~s/@/\@/g;
# 		print "/var/www/cgi-bin/$base_rep/sendpdf_cde.pl $mail $fich $copie $nocde ";
		system("/var/www/cgi-bin/$base_rep/sendpdf_cde.pl '$mail' $fich $nocde '$copie' &");
		print "<div class=titre>Mail envoyé</div>";
		&save("update commande_info set etat=0 where com_no='$nocde'");
		$action="";
}



if ($action eq "") {
# 	$query="select sum(com2_qte*pr_prac)/10000 from commande,produit where pr_cd_pr=com2_cd_pr";
# 	$sth=$dbh->prepare($query);
# 	$sth->execute();
# 	($valeur)=$sth->fetchrow_array;
# 
# 	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo order by com2_no";
# 	$sth=$dbh->prepare($query);
# 	$sth->execute();
# 	print "<table cellspacing=0 border=1><tr><th>No de cde</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th><th>date</th></tr>";
# 	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date)=$sth->fetchrow_array){
# 		($fo2_add)=split(/\*/,$fo2_add);
# 		if ($com2_no != $no_ref){
# 			if ($color eq "#FFFFFF"){$color="#dcdcdc";}else{$color="#FFFFFF";}
# 			$no_ref=$com2_no;
# 		}
# 		$com2_qte+=0;
# 		print "<tr bgcolor=$color><td><a href=?action=entree&nocde=$com2_no&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>$com2_no</a></td>";
# 		print "<td style=font-size:smaller;>$com2_cd_fo $fo2_add</td>";
# 		print "<td>$com2_cd_pr</td>";
# 		print "<td>$pr_desi</td>";
# 		print "<td>$com2_qte</td>";
# 		print "<td>";
# 		print &date(&daten(substr($com2_date,2,6)));
# 		print "</td>";
# 		print "<td><a href=?action=sup&prod=$com2_cd_pr&nocde=$com2_no&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>sup</a></td></tr>";
# 	}
# 	print "</table>";
# 	print "<br> valeur:$valeur";
	$query="select distinct com2_no,com2_cd_fo from commande order by com2_no";
	$query="select distinct com2_no,com2_cd_fo from commande order by com2_no";
	$query="select distinct com2_no,com2_cd_fo from commande order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de cde</th><th>fournisseur</th><th>Date</th><th>Action</th></tr>";
	while (($com2_no,$com2_cd_fo)=$sth->fetchrow_array){
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$com2_cd_fo'"));
		if ($com2_no != $no_ref){
			if ($color eq "#FFFFFF"){$color="#dcdcdc";}else{$color="#FFFFFF";}
			$no_ref=$com2_no;
		}
		$com2_date=&get("select min(com2_date) from commande where com2_no='$com2_no'");
 		# $com2_date=&date(&daten(substr($com2_date,2,6)));
		$motif=&get("select cb_motif from commande_block where cb_no='$com2_no'");
		if ($motif ne ""){$color="pink";}
		print "<tr bgcolor=$color><td>$com2_no</td>";
		print "<td style=font-size:smaller;>$com2_cd_fo $fo_nom";
		if ($motif ne ""){print "<br>$motif</br>";}
		print "</td>";
		print "<td>";
		print $com2_date;
		print "</td>";
		print "<td><a href=?action=entree&nocde=$com2_no&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet><img border=0 src=../../images/b_edit.png title='Editer'></a></td></tr>";
	}
	print "</table>";

	
	print "<form>";
	&form_hidden();
  	print "<br><select name=four><option value=''></option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br><input type=text name=fourmanu size=4><br><input type=hidden name=action value=creation><input type=submit value='nouvelle commande'></form>"; 
	
}

if ($action eq "entree") {
	$query="select com2_cd_fo,fo2_add,com2_date from commande,fournis where  fo2_cd_fo=com2_cd_fo and com2_no='$nocde' limit 1";
  	$sth=$dbh->prepare($query);
	$sth->execute();
	($com2_cd_fo,$fo2_add,$com2_date)=$sth->fetchrow_array;
	($fo2_add)=split(/\*/,$fo2_add);
	$four=$com2_cd_fo;
	$query="select com2_no,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,com2_prac from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
#  	print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form >";
	&form_hidden();
	print "<input type=hidden name=action value=modif>";
	print "Cde no:$nocde<br>$four $fo2_add $date<br>";
  	print "<table cellspacing=0 border=1><tr><th>Ref four</th><th>code produit</th><th>produit</th><th>qte</th><th>Prix</th></tr>";
	$total=0;
	while (($com2_no,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour,$com2_prac)=$sth->fetchrow_array){
		$com2_qte=int($com2_qte);
		print "<tr><td>$pr_refour</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right><input type=text name=qte$com2_cd_pr value='$com2_qte' size=5 style=text-align:right></td><td align=right>$com2_prac</td></tr>";
		$total+=$com2_qte*$com2_prac;
		#<input type=checkbox name=$com2_cd_pr></td></tr>";
	}
	print "</table>";
	print "total:$total<br>";
	print "<input type=hidden name=nocde value=$nocde>";
	$check=&get("select com2_no_liv from commande where com2_no='$nocde'")+0;
	if ($check==0){print "<br> <input type=submit value=\"Modification\">";}
	else{print "Commande sur le bon de livraison $check, cette commande n'est plus modifiable";}
	print "</form>";
	print "<a href=?action=majprac&nocde=$nocde&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$four>Maj prac</a><br>";
	print "<a href=?action=verif&nocde=$nocde&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$four>Verification stock</a><br>";
	print "<a href=?action=double&nocde=$nocde&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$four>Reedition</a>";
	print "<form>";
	&form_hidden();
  	print "<input type=hidden name=nocde value='$nocde'>";
  	print "<input type=hidden name=action value=sup>";
  	# if (($user eq "daniel")||($user eq "sylvain")) {print "<br><br><input type=submit value=supprimer style=background:pink>";}
	print "<br><br><input type=submit value=supprimer style=background:pink>";
	print "</form>";

}

if ($action eq "oknilnilnil") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,pr_prac/100,pr_prx_rev,com2_prac from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$date=`/bin/date +%d/%m/%y`;
	$dateenso=`/bin/date +%Y%m%d`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	$query="update atadsql set dt_no=dt_no+1 where dt_cd_dt=207";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$query="select dt_no from atadsql where dt_cd_dt=207";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($no)=$sth2->fetchrow_array;
	print "Date d'entree:$date<br>";
	print "Numero d'entree:$no<br>";
	$query="replace into enthead values ('$no','$datejl','$scelle','$provenance','$document','$lieu')";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$total=0;
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>Prix</th><th>Valeur</th><th>qte à entrer</th><th>stock restant</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour,$pr_prac,$remise,$com2_prac)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		if ($html->param("$com2_cd_pr") eq "on"){
			$qte=$html->param("qte$com2_cd_pr");
			$remise_four=$remise;
			print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>";
			print "$pr_prac</td><td align=right>";
			$val=$pr_prac*$qte;
			$total+=$val;
			print "$val</td><td align=right>";
			&carton($com2_cd_pr,$qte);
			print "</td>";
			$qte*=100;
			# $qte=$com2_qte*100;
			$query="replace into enso values ('$com2_cd_pr','$no',curdate(),'0','$qte','10')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$query="update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$com2_cd_pr'";
			# &save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$query="replace into entbody values ('$no','$com2_cd_pr','$qte')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			if ($qte>=$com2_qte){
				&save("delete from commande where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr");
# 				$date_commande="2".substr($com2_date,1,3)."-".substr($com2_date,4,2)."-".substr($com2_date,6,2);
  				$delai=&get("select datediff(now(),'$com2_date')");
				&save("replace into commandearch values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$qte','$com2_prac','0','$com2_date','$delai','')");
			}
			else
			{
				&save("update commande set com2_qte=com2_qte-$qte where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr");
			}
			%stock=&stock($com2_cd_pr,"","");
			$pr_stre=$stock{"stock"};
			print "<td>";
			&carton($com2_cd_pr,$pr_stre);
			print "</td><td><input type=checkbox></td></tr>";
		}
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
 	print "Total :".&deci($total)."<br>";

	if ($sous_douane eq "on"){
		print "<pre>Nous vous remercions et vous prions d'agreer, Messieurs,Nos sinceres salutations.</pre>";
	}
	else {print "fin";}
}



if ($action eq "verif") {
	$date=`/bin/date +%d/%m/%y`;
	print "le $date<br>";
	$dateenso=`/bin/date +%Y%m%d`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	$total=0;

	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,pr_prac/100,pr_prx_rev,com2_prac from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
# 	print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte à entrer</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour,$pr_prac,$remise,$com2_prac)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$pr_desi</td><td>";
		&digit("$com2_cd_pr");
		print "</td><td align=right>";
		&carton($com2_cd_pr,$com2_qte);
		print "</td><td><input type=checkbox></td></tr>";
	}
	print "</table><br>";
}

if ($action eq "imprimer") {
	$date=&get("select enh_date from enthead where enh_no='$nocde'");
	$date=&julian($date);
	print "Date d'entree:$date<br>";
	print "Numero d'entree:$nocde<br>";
	$query="select enb_no,pr_four,fo2_add,enb_cdpr,pr_desi,enb_quantite/100,pr_refour,pr_prac/100,pr_prx_rev from entbody,produit,fournis where pr_cd_pr=enb_cdpr and fo2_cd_fo=pr_four and enb_no='$nocde' order by pr_refour";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>Prix</th><th>Valeur</th><th>qte à entrer</th><th>stock restant</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$qte,$pr_refour,$pr_prac,$remise)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		$remise_four=$remise;
		print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>";
		print "$pr_prac</td><td align=right>";
		$val=$pr_prac*$qte;
		$total+=$val;
		print "$val</td><td align=right>";
		&carton($com2_cd_pr,$qte);
		print "</td>";
		$qte*=100;
		%stock=&stock($com2_cd_pr,"","");
		$pr_stre=$stock{"stock"};
		print "<td>";
		&carton($com2_cd_pr,$pr_stre);
		print "</td><td><input type=checkbox></td></tr>";
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "Total :".&deci($total)."<br>";
}


if ($action eq "creation") {
	$fo_local=&get("select fo2_identification from fournis where fo2_cd_fo='$four' ")+0;
	if ((! &admin())&&($fo_local!=1)&&($user!="sylvain")) { print "<div style=background:lavender>Fonctionalité non disponible pour l'utilisateur:$user<div>";}
	else{
	print "<script>";
	print "function recalcul() {";
	print "var total=0;";
	print " for (var i=3;i<document.maform.length-4;i=i+2){
			// alert(document.maform.elements[i+1].value);
			total=eval(document.maform.elements[i].value)*eval(document.maform.elements[i+1].value)+total;
		}";
	print "document.getElementById('total').innerHTML=parseInt(total);";
	print "}";
	print "</script>";

# 	$query="select fo2_cd_fo,fo2_add,pr_cd_pr,pr_desi,pr_prac/100 from produit,fournis where pr_four='$four' and fo2_cd_fo='$four' and (pr_sup=0 or pr_sup=3) order by pr_cd_pr";
 	$query="select fo2_cd_fo,fo2_add,pr_cd_pr,pr_desi,pr_prac/100,pr_refour from produit,fournis where pr_four='$four' and fo2_cd_fo='$four'  order by pr_cd_pr";

	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form name=maform>";
	&form_hidden();
  	print "<table cellspacing=0 border=1><tr><th>fournisseur</th><th>Produit</th><th>pack</th><th>stock</th><th>en_cde</th></tr>";
	while (($fo2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$pr_prac,$pr_refour)=$sth->fetchrow_array){
		$qte=$html->param("$com2_cd_pr")+0;
		
		if ((grep /\*/,$pr_refour)&& ($html->param("option") eq "alerte")){
			$qte=0;
			$i=1;
		    (@multicolor)=split(/\*/,$pr_refour);
		    foreach (@multicolor){
				$qte+=$html->param("${com2_cd_pr}_${i}")+0;
				# print ${com2_cd_pr}_${i}." ".$html->param("${com2_cd_pr}_${i}")." ";	
				$i++;
			}	
		}
		if (($qte==0) && ($html->param("option") eq "alerte")){next;}
		($fo2_add)=split(/\*/,$fo2_add);
		$query="select car_carton from carton where car_cd_pr=$com2_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($car_carton)=$sth2->fetchrow_array;
		print "<tr><td><span style=font-size:0.8em>$fo2_cd_fo $fo2_add</span></td><td><a href=?onglet=0&sous_onglet=0&sous_sous_onglet=&pr_cd_pr=$com2_cd_pr&action=visu>$com2_cd_pr</a> $pr_desi</td><td>$car_carton</td>";
		%stock=&stock($com2_cd_pr,'','quick','');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
		if (grep /\*/,$pr_refour){
			print "<td align=right>Info:$pr_stre<br>";
		    (@multicolor)=split(/\*/,$pr_refour);
		    foreach (@multicolor){
				$stock=&get("select qte from multicolor_inv where pr_cd_pr='$com2_cd_pr' and code='$_'")+0;
				$date=&get("select date from multicolor_inv where pr_cd_pr='$com2_cd_pr' and code='$_'");
				print "<nobr>$_ ($date) $stock<br>";
		    }
			print "</td>";
		}
		else {
			print "<td align=right>$pr_stre</td>";
		}
		$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$com2_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_commande)=$sth2->fetchrow_array+0;
		print "<td align=right>$qte_commande</td>";
	
		print "<td align=right><input type=hidden name='${com2_cd_pr}_prac' value='$pr_prac'>";
		if (grep /\*/,$pr_refour){
		    (@multicolor)=split(/\*/,$pr_refour);
		    $i=1;
		    foreach (@multicolor){
				if ($html->param("option") eq "alerte")	{$qte=$html->param("${com2_cd_pr}_${i}")+0;}		
				print "<nobr><span style=font-size:0.8em>$_</span> <input type=text name='${com2_cd_pr}_${i}' value='$qte' size=3 onchange=recalcul()><br>";
				$qte=0;
				$i++;
		    }
		}
		else {
		  print "<input type=text name='$com2_cd_pr' value='$qte' size=3 onchange=recalcul()>";
		}
		print "</td></tr>";
		$total+=$qte*$pr_prac;
	}
	print "</table>";
 	print "Total:<span id=total>$total</span><br\>";
	print "<br> Adresse de livraison<br>";
	$query="select adresse_id,adresse_libelle from adresse_liv order by adresse_id";
	print "<select name=livraison>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($adresse_id,$adresse_libelle)=$sth->fetchrow_array){
	print  "<option value=$adresse_id>$adresse_libelle</option>";
	}
	print "</select>";
  	print "<input type=hidden name=action value=creer>";
	print "<input type=hidden name=four value=$four>";
	print "<br>Commentaire <textarea name=blabla></textarea><br>";
	print "<br><input type=submit value=\"Ok pour faire la commande\"></form>";
  }
}

if ($action eq "creer") {
	$check="nil";
	# $check=&get("select com2_cd_fo from commande order by com2_no desc limit 1");
	if ($check==$four){print "<p style=background:pink>Blocage double commande</p>";} 
	else{
	$query="select dt_no from atadsql where dt_cd_dt=205";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($nocde)=$sth->fetchrow_array;
	 $nocde+=1;
	 &save("update atadsql set dt_no=$nocde where dt_cd_dt=205");
	 &save("insert ignore into commande_info (com_no,date,user,etat) values ('$nocde',curdate(),'$user','-2')");
	 &edite_commande();
	 }
}

if ($action eq "double") {
	 &edite_commande();
}


############ PDF ###########

if ($action  eq "envoi_pdf"){
  $index=0;
  $nbligne=0;
  &page_pdf();
  $query="select pr_cd_pr,pr_desi,pr_refour,com2_prac,com2_qte/100,com2_liv from produit,commande where com2_no=$nocde and com2_cd_pr=pr_cd_pr order by pr_refour";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$pr_refour,$com2_prac,$qte,$com2_livraison)=$sth->fetchrow_array){
    if ($nb_ligne++>22){
      $tete_text->translate( 20/mm, $ligne/mm );
      $tete_text->text("Suite .....");
      $index++;
      &page_pdf();
    }
    if (grep /\*/,$pr_refour){
      (@multicolor)=split(/\*/,$pr_refour);
      $i=1;
      foreach (@multicolor){
		$qte=&get("select qte from multicolor where no_cde='$nocde' and code='$pr_cd_pr' and cle='$i'")+0;
		$i++;
		if ($qte>0){
			$pr_refour=$_;
			$livraison=$com2_livraison;
			$tete_text->translate( 20/mm, $ligne/mm );
			if (length($pr_cd_pr)>9){
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 6/pt );
			}
			$tete_text->text("$pr_cd_pr");
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
			$tete_text->translate( 40/mm, $ligne/mm );
			if (length($pr_refour)>36){
			  $tete_text->font( $font{'Helvetica'}{'Roman'}, 7/pt );
			}
			$tete_text->text("$pr_refour");
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
			$tete_text->translate( 80/mm, $ligne/mm );
			if (length($pr_desi)>40){
			  $pr_desi=substr($pr_desi,0,80);
			  $tete_text->font( $font{'Helvetica'}{'Roman'}, 7/pt );
			}
			$tete_text->text(lc $pr_desi);
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
			$tete_text->translate( 160/mm, $ligne/mm );
			$tete_text->text($qte+0);
			$val=&deci($qte*$com2_prac);
			if (($qte==0)||($com2_prac==0)){$val=0;} # c'est a cause du nbsp ajouté par &deci
			$total+=$val;
			$tete_text->translate( 175/mm, $ligne/mm );
			$tete_text->text("$com2_prac");
			$tete_text->translate( 190/mm, $ligne/mm );
			$tete_text->text("$val");
			$ligne-=5;
		}
      }
    }
    else{
	  $livraison=$com2_livraison;
	  $tete_text->translate( 20/mm, $ligne/mm );
	  if (length($pr_cd_pr)>9){
	  $tete_text->font( $font{'Helvetica'}{'Roman'}, 6/pt );
	  }
	  $tete_text->text("$pr_cd_pr");
	  $tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	 if (length($pr_refour)>36){
			  $tete_text->font( $font{'Helvetica'}{'Roman'}, 7/pt );
	}
	  $tete_text->translate( 40/mm, $ligne/mm );
	  $tete_text->text("$pr_refour");
	  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	  $tete_text->translate( 80/mm, $ligne/mm );
	  if (length($pr_desi)>40){
	    $pr_desi=substr($pr_desi,0,80);
	    $tete_text->font( $font{'Helvetica'}{'Roman'}, 7/pt );
	  }
	  $tete_text->text(lc $pr_desi);
	  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	  $tete_text->translate( 160/mm, $ligne/mm );
	  $tete_text->text($qte+0);
	  $val=&deci($qte*$com2_prac);
	  if (($qte==0)||($com2_prac==0)){$val=0;} # c'est a cause du nbsp ajouté par &deci
	  $total+=$val;
	  $tete_text->translate( 175/mm, $ligne/mm );
	  $tete_text->text("$com2_prac");
	  $tete_text->translate( 190/mm, $ligne/mm );
	  $tete_text->text("$val");
	  $ligne-=5;
    }	
  }
  &fin_page_pdf();
  print "<form>";
  &form_hidden();
  print "email:<input type=text name=mail value='$fo2_email' size=50> <br />";
  print "envoyer une copie à:<input type=text name=copie size=50> <br />";
  print "<input type=hidden name=nocde value=$nocde>";
  print "<input type=hidden name=four value=$four>";
  print "<input type=hidden name=action value=send_pdf>";
  print "<a href=http://$base_rep.fr/doc/${four}_${nocde}.pdf><img src=/images/pdf.jpg></a>";
  print "<br><input type=submit value=envoyer>";
  print "</form><br />";
}

sub page_pdf{
  $nb_ligne=0;
  if ($index==0){
      $four=&get("select com2_cd_fo from commande where com2_no='$nocde'");
      $file="/var/www/$base_rep/doc/".$four."_".$nocde.".pdf";
      $fich=$four."_".$nocde.".pdf";
      if (-f $file){unlink ($file);}
      $pdf = PDF::API2->new(-file => $file);
      $date_commande=&get("select min(com2_date) from commande where com2_no='$nocde'");
      $date_commande=&date_iso($date_commande);
#       $date_du_jour=`/bin/date +%d'/'%m'/'%Y`;

      # $page->cropbox  (7.5/mm, 7.5/mm, 97.5/mm, 140.5/mm);
      %font = (
      Helvetica => {
      Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
      Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
      Italic => $pdf->corefont( 'Helvetica-Oblique', -encoding => 'latin1' ),
      },
      Times => {
	      Bold   => $pdf->corefont( 'Times-Bold',   -encoding => 'latin1' ),
	      Roman  => $pdf->corefont( 'Times',        -encoding => 'latin1' ),
	      Italic => $pdf->corefont( 'Times-Italic', -encoding => 'latin1' ),
      },
      );
      $query="select * from fournis where fo2_cd_fo='$four'";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
      ($nom,$rue,$ville)=split(/\*/,$fo2_add);
      $livraison=&get("select com2_liv from commande where com2_no=$nocde");
      $query="select * from adresse_liv where adresse_id='$livraison'";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($adresse_id,$adresse_libelle,$adresse_adresse,$adresse_info)=$sth->fetchrow_array;
      ($adresse_adresse1,$adresse_adresse2,$adresse_adresse3)=split(/\*/,$adresse_adresse);
      $parf=0;
      $total=0;
    }	  
    $page[$index] = $pdf->page();
    $page[$index]->mediabox('A4');
    $tete_text = $page[$index]->text;
    $tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
    $tete_text->fillcolor('navy');
    $tete_text->translate( 20/mm, 280/mm );
    $tete_text->text("DutyFree Concept");
    $tete_text->translate( 20/mm, 275/mm );
    $tete_text->text("7 passage du Ponceau ");
    $tete_text->translate( 20/mm, 270/mm );
    $tete_text->text("75002 Paris");
    $tete_text->translate( 20/mm, 265/mm );
    $tete_text->text("Tel 06 98 37 94 94");
    $tete_text->translate( 20/mm, 260/mm );
    $tete_text->text("Email:supply_dfc\@dutyfreeconcept.com");
    $tete_text->fillcolor('black');
    $tete_text->translate( 110/mm, 265/mm );
    $tete_text->text("$nom");
    $tete_text->translate( 110/mm, 260/mm );
    $tete_text->text("$rue");
    $tete_text->translate( 110/mm, 255/mm );
    $tete_text->text("$ville");
    
    $tete_text->font( $font{'Helvetica'}{'Bold'}, 14/pt );
    $tete_text->translate( 20/mm, 245/mm );
    $suite="";
    if ($index){$suite=" (suite)";}
    $tete_text->text("BON DE COMMANDE N° $nocde Du $date_commande $suite");

    $tete_text->font( $font{'Helvetica'}{'Roman'}, 9/pt );
    $tete_text->translate( 20/mm, 235/mm );
    $tete_text->text("A l'attention de $fo2_contact Fax:$fo2_fax Email:$fo2_email");
    
    &boite(20,230,200,200);
    &boite(138,230,200,200);
    &boite(20,200,200,185);
    
    $tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
    $tete_text->translate( 22/mm, 222/mm );
    $tete_text->text("Adresse de Livraison");
    $tete_text->translate( 140/mm, 222/mm );
    $tete_text->text("Adresse de Facturation");
    $tete_text->translate( 22/mm, 195/mm );
    $tete_text->text("Observation");
    $tete_text->font( $font{'Helvetica'}{'Roman'}, 8/pt );
    $blabla=&get("select blabla from commande_info where com_no=$nocde");
    $tete_text->translate( 22/mm, 190/mm );
    $tete_text->text("$blabla");
    
    $tete_text->translate( 22/mm, 218/mm );
    $tete_text->text("$adresse_libelle");
    $tete_text->translate( 22/mm, 214/mm );
    $tete_text->text("$adresse_adresse1");
    $tete_text->translate( 22/mm, 210/mm );
    $tete_text->text("$adresse_adresse2");
    $tete_text->translate( 22/mm, 206/mm );
    $tete_text->text("$adresse_adresse3");
    $tete_text->translate( 22/mm, 202/mm );
    $tete_text->text("$adresse_info");
    $tete_text->translate( 140/mm, 215/mm );
    $tete_text->text("DUTY FREE CONCEPT");
    $tete_text->translate( 140/mm, 210/mm );
    $tete_text->text("7 passage du Ponceau ");
    $tete_text->translate( 140/mm, 205/mm );
    $tete_text->text("76002 PARIS");
    $tete_text->fillcolor('navy');
    $tete_text->translate( 20/mm, 10/mm );
    $tete_text->text("SAS au capital de 100000¤€ RCS PARIS 524 057049 00024 TVA FR 09524057049");
    $tete_text->fillcolor('black');
    $ligne=160;
    $tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
    $tete_text->translate( 20/mm, $ligne/mm );
    $tete_text->text("Ref dfc");
    $tete_text->translate( 40/mm, $ligne/mm );
    $tete_text->text("Votre Ref");
    $tete_text->translate( 80/mm, $ligne/mm );
    $tete_text->text("Produit");
    $tete_text->translate( 160/mm, $ligne/mm );
    $tete_text->text("Qte");
    $tete_text->translate( 175/mm, $ligne/mm );
    $tete_text->text("Prix");
    $tete_text->translate( 190/mm, $ligne/mm );
    $tete_text->text("Total");
    $ligne-=5;
    $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
}	

sub fin_page_pdf{
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		$tete_text->translate( 172/mm, $ligne/mm );
		$tete_text->text("Total :$total");
		$tete_text->translate( 172/mm, ($ligne-5)/mm );
		$tete_text->text("Remise:$remise");
		$total-=$remise;
	}
	$tete_text->translate( 172/mm, ($ligne-10)/mm );
	$tete_text->text("Total :$total");
	if ($parf==1){
		$tete_text->translate( 20/mm, ($ligne-15)/mm );
		$tete_text->text("Merci d'ajouter produits factices,testeurs,echantillons,mouillettes");
	}
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	$tete_text->translate( 20/mm, ($ligne-20)/mm );
	$tete_text->text("Priere d'envoyer les factures à l'adresse administrative duty Free Concept BP143 Dieppe Cedex");
	$tete_text->translate( 20/mm, ($ligne-25)/mm );
	$tete_text->text("Merci d'accuser reception de cette commande, les quantités non disponibles seront annulées");
	$tete_text->translate( 20/mm, ($ligne-30)/mm );
	$tete_text->text("La facture doit comporter impérativement le numéro de commande et doit d'une part être");
	$tete_text->translate( 20/mm, ($ligne-35)/mm );
	$tete_text->text("envoyée à supply_dfc\@dutyfreeconcept.com et accompagner la marchandise");
	$tete_text->translate( 20/mm, ($ligne-40)/mm );
	# $tete_text->font( $font{'Helvetica'}{'bold'}, 12/pt );
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
  $tete_text->text("Nous vous demandons d’envoyer une liste de colisage des marchandises livrées");
	$tete_text->translate( 20/mm, ($ligne-45)/mm );
	$tete_text->text("et porter la destination finale sur chaque colis.");
	# $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$pdf->save();
}	

########## FIN PDF ##################
########## EXCEL #################
if ($action  eq "envoi_xls"){
  &page_xls();
  $query="select pr_cd_pr,pr_desi,pr_refour,com2_prac,com2_qte/100,com2_liv from produit,commande where com2_no=$nocde and com2_cd_pr=pr_cd_pr order by pr_refour";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$pr_refour,$com2_prac,$qte,$com2_livraison)=$sth->fetchrow_array){
    if (grep /\*/,$pr_refour){
      (@multicolor)=split(/\*/,$pr_refour);
      $i=1;
      foreach (@multicolor){
		$qte=&get("select qte from multicolor where no_cde='$nocde' and code='$pr_cd_pr' and cle='$i'")+0;
		$i++;
		if ($qte>0){
			$pr_refour=$_;
			$livraison=$com2_livraison;
			$col=0;
			$worksheet->write($row,$col,"$pr_cd_pr");
			$col=1;
			$worksheet->write($row,$col,"$pr_refour");
			$col=2;
			$worksheet->write($row,$col,"$pr_desi");
			$col=3;
			$worksheet->write($row,$col,"$qte");
			if ($fo2_cd_fo==1260){
				$col=8;
				$worksheet->write($row,$col,"$qte");
			}	
			$val=&deci($qte*$com2_prac);
			if (($qte==0)||($com2_prac==0)){$val=0;} # c'est a cause du nbsp ajouté par &deci
			$total+=$val;
			$col=4;
			$worksheet->write($row,$col,"$com2_prac");
			$col=5;
			$worksheet->write($row,$col,"$val");
			$row++;
		}
      }
    }
    else{
	  $livraison=$com2_livraison;
	  $col=0;
	  $worksheet->write($row,$col,"$pr_cd_pr");
	  $col=1;
	  $worksheet->write($row,$col,"$pr_refour");
      $col=2;	 
	 $worksheet->write($row,$col,"$pr_desi");
	  $col=3;
	  $worksheet->write($row,$col,"$qte");
		if ($fo2_cd_fo==1260){
	$col=8;
	$worksheet->write($row,$col,"$qte");
	}	

	  $val=&deci($qte*$com2_prac);
	  if (($qte==0)||($com2_prac==0)){$val=0;} # c'est a cause du nbsp ajouté par &deci
	  $total+=$val;
	  $col=4;	 
	  $worksheet->write($row,$col,"$com2_prac");
	  $col=5;
	  $worksheet->write($row,$col,"$val");
	  $row++;
    }	
  }
  &fin_page_xls();
	print "<p style=background:pink>Version Excel ! merci de verifier le fichier</p>";
 print "<form>";
  &form_hidden();
  print "email:<input type=text name=mail value='$fo2_email' size=50> <br />";
  print "envoyer une copie à:<input type=text name=copie size=50> <br />";
  print "<input type=hidden name=nocde value=$nocde>";
  print "<input type=hidden name=four value=$four>";
  print "<input type=hidden name=action value=send_xls>";
  print "<a href=http://$base_rep.fr/doc/${four}_${nocde}.xls><img src=/images/xls.jpg></a>";
  print "<br><input type=submit value=envoyer>";
  print "</form><br />";
}

sub page_xls{
	$nb_ligne=0;
	$four=&get("select com2_cd_fo from commande where com2_no='$nocde'");
	$file="../../$base_rep/doc/".$four."_".$nocde.".xls";
	$fich=$four."_".$nocde.".xls";
	if (-f $file){unlink ($file);}
	$workbook = Spreadsheet::WriteExcel->new("$file");
	$worksheet = $workbook->add_worksheet();
	$col = $row = 0;
	$date_commande=&get("select min(com2_date) from commande where com2_no='$nocde'");
	$date_commande=&date_iso($date_commande);
	$query="select * from fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	$livraison=&get("select com2_liv from commande where com2_no=$nocde");
	$query="select * from adresse_liv where adresse_id='$livraison'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($adresse_id,$adresse_libelle,$adresse_adresse,$adresse_info)=$sth->fetchrow_array;
	($adresse_adresse1,$adresse_adresse2,$adresse_adresse3)=split(/\*/,$adresse_adresse);
	$parf=0;
	$total=0;
	$worksheet->write($row, $col, "DutyFree Concept");
	$row++;
	$worksheet->write($row,$col,"7 passage du Ponceau");
	$row++;
	$worksheet->write($row,$col,"75002 Paris");
	$row++;
	$worksheet->write($row,$col,"Tel 06 98 37 94 94");
	$row++;
	$worksheet->write($row,$col,"Email:supply_dfc\@dutyfreeconcept.com");
	$row++;
	$col+=5;
	$worksheet->write($row,$col,"$nom");
	$row++;
	$worksheet->write($row,$col,"$rue");
	$row++;
	$worksheet->write($row,$col,"$ville");
	$col=0;
	$row+=2;
	$worksheet->write($row,$col,"BON DE COMMANDE N° $nocde Du $date_commande $suite");
	$row++;
	$worksheet->write($row,$col,"A l'attention de $fo2_contact Fax:$fo2_fax Email:$fo2_email");
	$row++;
	$worksheet->write($row,$col,"Adresse de Livraison");
	$row++;
	$worksheet->write($row,$col,"$adresse_libelle");
	$row++;
	$worksheet->write($row,$col,"$adresse_adresse1");
	$row++;
	$worksheet->write($row,$col,"$adresse_adresse2");
	$row++;
	$worksheet->write($row,$col,"$adresse_adresse3");
	$row++;
	$worksheet->write($row,$col,"$adresse_info");
	$row++;
	$worksheet->write($row,$col,"Adresse de Facturation");
	$row++;
	$worksheet->write($row,$col,"DUTY FREE CONCEPT");
	$row++;
	$worksheet->write($row,$col,"7 passage du Ponceau");
	$row++;
	$worksheet->write($row,$col,"76002 PARIS");

=pod


   $tete_text->text("SAS au capital de 100000¤€ RCS PARIS 524 057049 00024 TVA FR 09524057049");

	
    $tete_text->text("Observation");
    $col++;
    $blabla=&get("select blabla from commande_info where com_no=$nocde");
    $tete_text->text("$blabla");
    
    $tete_text->translate( 140/mm, 210/mm );
    $tete_text->text("7 passage du Ponceau ");
    $tete_text->translate( 140/mm, 205/mm );
    $tete_text->text("76002 PARIS");
    $tete_text->fillcolor('navy');
    $tete_text->translate( 20/mm, 10/mm );
    $tete_text->text("SAS au capital de 100000¤€ RCS PARIS 524 057049 00024 TVA FR 09524057049");
    $tete_text->fillcolor('black');
    $ligne=160;
=cut	
    $row=23;
	$col=0;
    $worksheet->write($row,$col,"Ref dfc");
	$col++;
    $worksheet->write($row,$col,"Votre Ref");
	$col++;
    $worksheet->write($row,$col,"Produit");
	$col++;
    $worksheet->write($row,$col,"Qte");
	$col++;
    $worksheet->write($row,$col,"Prix");
	$col++;
    $worksheet->write($row,$col,"Total");
	$col++;
	$row++;
}	

sub fin_page_xls{
	if ($remise_four!=0){ 
	  $remise=$total*$remise_four/10000;
	  $worksheet->write($row,4,"Total");
	  $worksheet->write($row,5,"$total");
	  
	  $row++;
	  $worksheet->write($row,4,"Remise");
	  $worksheet->write($row,5,"$remise");
	  $row++;
	  $total-=$remise;
	}
	
	$worksheet->write($row,4,"Total");
	$worksheet->write($row,5,"$total");
	$col=0;
	if ($parf==1){
	  $worksheet->write($row,$col,"Merci d'ajouter produits factices,testeurs,echantillons,mouillettes");
	}
	$row++;
	$worksheet->write($row,$col,"Priere d'envoyer les factures à l'adresse administrative duty Free Concept BP143 Dieppe Cedex");
	$row++;
	$worksheet->write($row,$col,"Merci d'accuser reception de cette commande, les quantités non disponibles seront annulées ");
	$row++;
	$worksheet->write($row,$col,"La facture doit comporter impérativement le numéro de commande et doit d'une part être envoyée à supply_dfc\@dutyfreeconcept.com at accompagner la marchandise");
	$row++;
	$worksheet->write($row,$col,"Nous vous demandons  d’envoyer une liste de colisage des marchandises livrées et porter la destination finale sur chaque colis.");
	$row+=5;
    $worksheet->write($row,$col,"SAS au capital de 100000 Euros RCS PARIS 524 057049 00024 TVA FR 09524057049");
	$workbook->close();


}	

########## FIN EXCEL #################


sub edite_commande {
	$date=`/bin/date +%d/%m/%y`;
	# $datesimple="10".`/bin/date +%y%m%d`;
	$date_commande=&get("select min(com2_date) from commande where com2_no='$nocde'");
	$date_commande=&date_iso($date_commande);
#    	
	print "<div style=color:navy;;font-weight:bold;>DutyFree Concept<br>7 passage du Ponceau <br />75002 PARIS <br />Tel 06 98 37 94 94 Email:supply_dfc\@dutyfreeconcept.com</div>";
	$query="select * from fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	print "<div style=position:relative;left:60%;>Paris le $date_commande<br /><b>$nom</b><br />$rue<br />$ville <br /></div>";
	print "<br />A l'attention de $fo2_contact fax:<b>$fo2_fax</b> $fo2_email";
	print "<br>";
	print "Commande No:$nocde<br>";
	print "veuillez prendre la commande suivante:<br /><br />";
	if ($action eq "creer"){
		$query="select pr_cd_pr,pr_desi,pr_refour,pr_prac/100,pr_type,pr_prx_rev from produit where pr_four='$four' order by pr_refour";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$parf=0;
		$total=0;
		print "<table cellspacing=0 border=1> <tr><th>Ref dfc</th><th>Votre ref</th><th>produit</th><th>qte</th><th>Prix</th><th>Total</th></tr>";
		while (($pr_cd_pr,$pr_desi,$pr_refour,$pr_prac,$pr_type,$remise)=$sth->fetchrow_array){
			$qte=$html->param("$pr_cd_pr")+0;
			if (grep /\*/,$pr_refour){
			    $qte=0,
			    (@multicolor)=split(/\*/,$pr_refour);
			    $i=1;
			    foreach (@multicolor){
					$qte_int=$html->param("${pr_cd_pr}_${i}")+0;
					if ($qte_int>0){
					  $qte+=$qte_int;
					  &save("replace into multicolor values ('$nocde','$pr_cd_pr','$i','$qte_int')");
					  print "<tr><td>$pr_cd_pr</td><td>$_ </td><td>$pr_desi</td><td>";
					  print $qte_int;
					  $val=$qte_int*$pr_prac;
					  $total+=$val;
					  print "</td><td align=right>$pr_prac</td><td>$val</td></tr>";
					}
					$i++;
			    }
			    if ($pr_type==1 || $pr_type==5){$parf=1;}
				if ($qte!=0){ $qte*=100;&save("replace into commande values ('$nocde','$four','$pr_cd_pr','$qte','$pr_prac','',curdate(),'','$livraison','')");}
			}
			elsif($qte!=0) {
				    $remise_four=$remise;
				    print "<tr><td>$pr_cd_pr</td><td>$pr_refour </td><td>$pr_desi</td><td>";
				    print $qte;
				    $qte=$qte*100;
				    $val=$qte*$pr_prac/100;
				    $total+=$val;
				    print "</td><td align=right>$pr_prac</td><td>$val</td></tr>";
				    if ($pr_type==1 || $pr_type==5){$parf=1;}
				    &save("replace into commande values ('$nocde','$four','$pr_cd_pr','$qte','$pr_prac','',curdate(),'','$livraison','')");
			}
		}
		$blabla=&addslashes($html->param("blabla"));
		if ($blabla ne ""){&save("update commande_info set blabla='$blabla' where com_no='$nocde'");}
				
	}
	if ($action eq "double"){
		$query="select pr_cd_pr,pr_desi,pr_refour,com2_prac,com2_qte/100,com2_liv from produit,commande where com2_no=$nocde and com2_cd_pr=pr_cd_pr order by pr_refour";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$parf=0;
		$total=0;
		print "<table cellspacing=0 border=1> <tr><th>Ref dfc</th><th>Votre ref</th><th>produit</th><th>qte</th><th>Prix</th><th>Total</th></tr>";
		while (($pr_cd_pr,$pr_desi,$pr_refour,$com2_prac,$qte,$com2_livraison)=$sth->fetchrow_array){
			$livraison=$com2_livraison;
			print "<tr><td>$pr_cd_pr</td><td>$pr_refour </td><td>$pr_desi</td><td>$qte</td>";
			$val=$qte*$pr_prac/100;
			$total+=$val;
			print "</td><td align=right>$com2_prac</td><td>$val</td></tr>";
		}
	}
	
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "Total :".&deci($total)."<br>";
	if ($parf==1){
		print "<br>Merci d'ajouter produits factices,testeurs,echantillons,mouillettes<br>"; 	
	}
	print "<br>PRIERE D ENVOYER LES FACTURES A  L ADRESSE ADMINISTRATIVE   DUTY FREE CONCEPT  BP 143  76204 DIEPPE CEDEX</br>";
	$query="select * from adresse_liv where adresse_id=$livraison";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($adresse_id,$adresse_libelle,$adresse_adresse,$adresse_info)=$sth->fetchrow_array;
	print "<br>Livraison: $adresse_libelle\n$adresse_adresse\n$adresse_info\n";
	print "<br>Commentaire:".$html->param("blabla");
	print "<div id=pied style=color:navy;font-weight:bold;position:absolute;bottom:10px;>SAS au capital de 100000¤€ RCS PARIS 524 057049 00024 TVA FR 09524057049</div>";
	# if ($action ne "double"){
	 	print "<div id=send><a href=?action=envoi_xls&nocde=$nocde&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$four>Envoyer par mail version excel</a></send>";
	 	print "<div id=send><a href=?action=envoi_pdf&nocde=$nocde&onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$four>Envoyer par mail version pdf</a></send>";
	  
	# }
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

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}
sub boite() {
	$a=$_[0];
	# x gauche
	$b=$_[1];
	# y haut
	$c=$_[2];
	# x droit
	$d=$_[3];
	# y bas
	# y bas
	my $line = $page[$index]->gfx;
	$line->strokecolor('black');

	# horizontale 
	$line->move( $a/mm, $b/mm );
	$line->line( $c/mm, $b/mm );
	$line->stroke;
	$line->move( $a/mm, $d/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;

	# verticale 	
	$line->move( $a/mm, $b/mm );
	$line->line( $a/mm, $d/mm );
	$line->stroke;
	$line->move( $c/mm, $b/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
}

;1
