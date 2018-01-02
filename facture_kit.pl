# foreach $base (@bases_client){
#   if ($base eq "dfc"){next;}
#   print "<div class=titre style=\"clear:both;\"><span style=text-transform:uppercase>$base</span></div>";
#   open (FILE,"ls /var/www/$base.oasix/doc/pub*|");
#   @liste=<FILE>;
#   close(FILE);
#   print "<div style=\"border:1px solid black\">";
#   foreach (@liste){
#     ($null,$null,$null,$null,$null,$facture)=split(/\//,$_);
#     print "<figure style=float:left;width:80px;><a href=http://$base.oasix.fr/doc/$facture><img src=/images/pdf.jpg /></a><figcaption>$facture</figcaption></figure>";
#   }
#   print "</div>";
# }

if ($action eq "sendpdf"){ 
 $mail=$html->param("mail"); 
 $mag=$html->param("mag"); 
 $pdf=$html->param("pdf"); 
 $base=$html->param("base"); 
 $four=$html->param("four");
 
 if (&validemail($mail)){
  $mail=~s/@/\@/;
  system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $pdf $mag &");
  print "Mail envoyé<br>
  <i>Bonjour,<br>
  Nous vous prions de bien vouloir trouvez ci-joint notre facture<br>
  relative à la participation publicitaire du magazine No:$mag<br>
  Cordialement<br>
  Le service facturation Duty Free Concept<br></i>
  ";
  print "<form>";
  &form_hidden();
  print "<input type=submit value=retour></form>";
  &save("update dfc.facture_pub set date_mail=curdate() where base='$base' and mag='$mag' and fournisseur='$four' and pdf='$pdf'","af");
 }
 else
 {
  print "mail invalide";
 }
 $action="send";
} 

if ($action eq "mail"){ 
 $mag=$html->param("mag"); 
 $pdf=$html->param("pdf"); 
 $base=$html->param("base"); 
 $four=$html->param("four");
  $mail=&get("select fo2_email from fournis where fo2_cd_fo='$four'");
  print "<form>";
  &form_hidden();
  print "email:<input type=text name=mail value='$mail' size=50";
  if (! &validemail($mail)){print " style=background:pink";}
  print "> <br />";
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=four value=$four>";
  print "<input type=hidden name=pdf value=$pdf>";
  print "<input type=hidden name=base value=$base>";
  print "<input type=hidden name=action value=sendpdf>";
  print "<a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a>";
  print "<br><input type=submit value=envoyer>";
  print "</form><br>	";
  print "<form>";
  &form_hidden();
  print "<input type=submit value=retour></form>";

}  



if (($action eq "")||($action eq "tout")){
print "Les cases avec une bordure correspondent à des regroupements de facture<br>";
if ($action ne "tout"){
  print "Les 100 dernieres factures ";
  print "<form>";
  &form_hidden();
  print "<input type=hidden name=action value=tout>";
  print "<input type=submit value='Toutes les factures'>";
  print "</form>";
 $query="select * from facture_pub order by no_facture desc limit 100 ";
}
else { $query="select * from facture_pub order by no_facture desc";}


$sth=$dbh->prepare($query);
$sth->execute();
while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement)=$sth->fetchrow_array){
  ($nom)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$fournisseur'"));
  if ($groupement ne $groupement_tamp ){$engroup=0;}
  
  if (($groupement ne "")&&($groupement ne $groupement_tamp )){
    $montant_group=&get("select sum(montant) from facture_pub where groupement='$groupement'");
    $engroup=1;
    &changecolor();
    print "<div style=\"float:left;width:158px;height:198px;padding:19px;margin:10px;font-size:0.8em;background:$color;border:1px solid black;overflow:hidden\"><span style=color:#FF8000;font-size:1.2em;font-weight:bold>$base</span><br>";
    print "<a href=http://dfc.oasix.fr/doc/$groupement><img src=/images/pdf.jpg /></a><br>";
    print "<strong>Fact_no:$groupement</strong><br>$fournisseur $nom<br><span style=color:#FF8000;>$marque</span><br>$montant_group Euros<br>Date facture:$date<br>";
    if (($date_mail ne "0000-00-00")&&($date_mail ne "")){
      print "Date mail:$date_mail";
    }
    else {
      print "<span style=color:red>mail non envoyé</span>";
    }
    print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=mail&mag=$mag&four=$fournisseur&mag=$mag&base=$base&pdf=$groupement><img border=0 src=http://image.oasix.fr/email.png></a>";
    print "</div>";
    $groupement_tamp=$groupement;
  }  
  if ($engroup !=1) {&changecolor();}
  
  print "<div style=float:left;width:160px;height:200px;padding:20px;margin:10px;font-size:0.8em;background:$color;overflow:hidden><span style=color:#FF8000;font-size:1.2em;font-weight:bold>$base</span><br><a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
  print "Fact_no:$no_facture<br>$fournisseur $nom<br><span style=color:#FF8000;>$marque</span><br>$montant Euros<br>Date facture:$date<br>";
  if (($date_mail ne "0000-00-00")&&($date_mail ne "")){
    print "Date mail:$date_mail";
  }
  else {
    print "<span style=color:red>mail non envoyé</span>";
  } 
  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=mail&mag=$mag&four=$fournisseur&mag=$mag&base=$base&pdf=$pdf><img border=0 src=http://image.oasix.fr/email.png></a>";
  print "</div>";
}
}
sub changecolor(){
 if ($color eq "#F2F2F2"){$color="#CEF6CE";}else{$color="#F2F2F2";}
}
;1