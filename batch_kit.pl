if ($action eq ""){
  print "<textarea name=champ></textarea>";
  print "<input type=submit>";
  print "<input type=hidden nam=action value=go>";
  print "</form>";
}

if ($action eq "go"){
  print $html->param("champ");
}
 
;1