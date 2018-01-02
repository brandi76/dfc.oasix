$client=$html->param("client");

if ($action eq ""){
  foreach $client (@bases_client){
    print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&client=$client&action=go>$client</a><br>";
  }
}

else
{
  open (FILE,"grep $client /etc/httpd/logs/error_log|");
  @tab=<FILE>;
  close(FILE);
  $color="black";
  foreach (@tab){
    ($date,$notice,$client,$texte)=split(/\]/,$_,4);
    if ($date ne $date_tamp){
      if ($color eq "blue"){$color="black";}else{$color="blue";}
      $date_tamp=$date;
    }
    print "<span style=color:$color>";
    print "$date  $notice  $texte</span><br>";
  }
}

;1
