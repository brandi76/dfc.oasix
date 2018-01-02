#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$date=$html->param("date");
  $vol=$html->param("vol");
  $action=$html->param("action");
  
if ($action eq "import"){
open (FILE,"/var/www/cgi-bin/togo.oasix/cross_over.txt");
@tab=<FILE>;
close(FILE);
foreach $ligne (@tab){
  chomp($ligne);
  $ligne=~s/^ko//g;
  if (grep /XForms:Model/,$ligne){
    # debut de dechargement
    ($null,$ligne)=split(/=/,$ligne,2);
    $ligne=~s/ko//g;
    $dech=1;
#     print "<hr></hr>";
    @entete=();
    }
  if ((grep /Ã/,$ligne)&&(! grep /XForms:Model/,$ligne)){
#     print "$ligne<br>";
    ($rot,$date,$vol,$depart,$arrive)=split(/:/,$ligne);
    ($jour,$journb,$mois,$an,$null,$heure)=split(/ /,$date);
    if ($mois eq "janvier"){$mois="01";}
    if ($mois eq "fevrier"){$mois="02";}
    if ($mois eq "mars"){$mois="03";}
    if ($mois eq "avril"){$mois="04";}
    if ($mois eq "mai"){$mois="05";}
    if ($mois eq "juin"){$mois="06";}
    if ($mois eq "juillet"){$mois="07";}
    if ($mois eq "aout"){$mois="08";}
    if ($mois eq "septembre"){$mois="09";}
    if ($mois eq "octobre"){$mois="10";}
    if ($mois eq "novembre"){$mois="11";}
    if ($mois eq "decembre"){$mois="12";}
    ($hh,$mm)=split(/h/,$heure);
    $heure="$hh:$mm:00";
    if ($journb<10){$journb="0".$journb;}
    
    $entete[$rot]="$an-$mois-$journb $heure;$vol:$depart:$arrive";
#     print "$rot,$date,$vol,$depart,$arrive<br>";
  }
  if (! grep /Ã/,$ligne){
    $dech=0;
    ($rot,$ticket,$type,$ref)=split(/:/,$ligne);
    ($date,$vol)=split(/;/,$entete[$rot]);
      if (($rot ne $rot_ancien)||($date != $date_ancien)){
	$indecs=0;
	$rot_ancien=$rot;
	$date_ancien=$date;	
      }
      $indecs++;
#     chomp($ref);
      if ($date ne ""){
      &save("replace into sk20 value ('$date','$rot','$vol','$indecs','$ticket','$type','$ref')","aff");
#       print "$date $rot $vol $indecs $ticket $type $ref <br>";

     }
     }

}
}
if ($action eq ""){
  $query="select distinct date from sk20 order by date desc limit 50";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($date,$rot,$vol)=$sth->fetchrow_array){
    $query="select distinct vol from sk20 where date='$date' order by vol,rot";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($vol)=$sth2->fetchrow_array){
      $date=~s/ /+/g;
      print "<a href=?action=visu&date=$date&vol=$vol>$date vol:$vol</a><br>";
    }
  }
} 
if ($action eq "visu"){
  print "<p style=color:orange;font-size:1.2em>$date $vol</p>";
  $query="select * from sk20 where date='$date' and vol='$vol' order by rot,indecs";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($date,$rot,$vol,$indecs,$ticket,$type,$ref)=$sth->fetchrow_array){
    if ($ticket != $ticket_anc){
      print "<strong>Ticket:$ticket</strong><br> ";
      $ticket_anc=$ticket;
      }
    $mess=$type;
    if ($type eq "E"){$mess="Especes";}
    if ($type eq "CB"){$mess="CB";}
    if ($type eq "CH"){$mess="Cheque";}
    if ($type eq "F"){$mess="Fin de caisse";}
    if ($type eq "R"){$mess="Rendu";}
    if ($type eq "P"){
      $desi=&get("select pr_desi from produit where pr_cd_pr=$ref");
      $mess="$ref $desi";
    }
    print "$mess<br>";
  }
}