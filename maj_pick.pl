#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);
$datesimple="1".substr($an,2,2).$mois.$jour;
$dateok=$datesimple;
$datesimple-=15;
print $html->header;
require "./src/connect.src";
$action=$html->param('action');

 	for ($i=0;$i<15;$i++){
	  $index=14-$i;
	  $datesql=&get("select date_sub(curdate(),interval $index day)","af");
	  ($an,$mois,$jour)=split(/-/, $datesql, 3); 
	  $datesimple="1".substr($an,2,2).$mois.$jour;
# 	  &save("delete from pick where pi_date='$datesql'","aff");
 	  print "$i $datesimple $dateok $datesql<br>";
 	  $query="SELECT v_troltype,count(*) from apjour,vol where aj_date=$datesimple and aj_code=v_code and v_rot=1 group by v_troltype";
 	  print "$query<br>";
 	  $sth=$dbh->prepare($query);
 	  $sth->execute();
 	  while (($troltype,$nb)=$sth->fetchrow_array){
 	  print "$troltype $nb<br>";
 		  $query="select tr_cd_pr,tr_qte/100 from trolley where tr_code='$troltype'";
 		  $sth2=$dbh->prepare($query);
 		  $sth2->execute();
 		  while (($tr_cd_pr,$qte)=$sth2->fetchrow_array){
			  print "$tr_cd_pr $tr_qte<br>";
 			  $qte*=$nb;
 			  &save("select pi_qte from pick where pi_date='$datesql' and pi_cd_pr='$tr_cd_pr'");
 			  &save("replace into pick values ('$datesql','$tr_cd_pr','$qte')","aff");
 		  }
 	  }
	}
