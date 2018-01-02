require "./src/connect.src";
@base_client=(	"dfc","camairco","togo","aircotedivoire","tacv");
$action=$html->param("action");
$code=$html->param("code");
$client_bon=$html->param("client");

if ($action eq "maj"){
    foreach $client (@base_client){
      if ($client eq $client_bon){next;}
      &save ("replace into $client.fournis select * from $client_bon.fournis where fo2_cd_fo='$code'","aff");
    }
    $action="";
}
if ($action eq "sup"){
    foreach $client (@base_client){
      &save ("delete from $client.fournis where fo2_cd_fo='$code'","aff");
    }
    $action="";
}
  

if ($action eq ""){
&save("create temporary table four_tmp (code int(11),primary key (code))");

foreach $client (@base_client){
    &save("insert ignore into four_tmp select fo2_cd_fo from $client.fournis");
}
$query="select * from four_tmp order by code";
$nbprod++;
$sth=$dbh->prepare($query);
$sth->execute();
while (($code)=$sth->fetchrow_array){
$nbprod++;
  $ko=0;
  $first=1;
  foreach $client (@base_client){
      $query="select fo2_add,fo2_telph,fo2_contact,fo2_email from $client.fournis where fo2_cd_fo='$code'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($fo2_add,$fo2_telph,$fo2_contact,$fo2_email)=$sth2->fetchrow_array;
      if (! $first){
	if ($fo2_add ne $desi_tamp){$ko=1;}
	if ($fo2_telph ne $tel_tamp){$ko=1;}
	if ($fo2_contact ne $contact_tamp){$ko=1;}
	if ($fo2_email ne $email_tamp){$ko=1;}
	
      }
      $first=0;
      $desi_tamp=$fo2_add;
      $tel_tamp=$fo2_telph;
      $contact_tamp=$fo2_contact;
      $email_tamp=$fo2_email;
  }     
  if ($ko){
    $nb++;
    print "<hr></hr>";
    foreach $client (@base_client){
      $query="select fo2_add,fo2_telph,fo2_contact,fo2_email from $client.fournis where fo2_cd_fo='$code'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($fo2_add,$fo2_telph,$fo2_contact,$fo2_email)=$sth2->fetchrow_array;
      
      print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=maj&code=$code&client=$client>$client</a><br>$code<br>$fo2_add<br>$fo2_telph<br>$fo2_contact<br>$fo2_email<br>";
      # <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&code=$code&client=$client>sup</a><br>";
    }
  }
}
print "<br>Nombre de fournisseer:$nbprod nombre de fournisseur en erreur:$nb<br>";

}


;1
