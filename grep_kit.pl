print "<form>";
&form_hidden();
print "Recherche <input type=text name=recherche>";
print "<input type=submit>";
print "</form>";
$recherche=$html->param("recherche");
if ($recherche ne ""){
  foreach $base (@bases_client){
    print "<div class=titre style=\"clear:both;\"><span style=text-transform:uppercase>$base</span></div>";
    open (FILE,"grep -i \"$recherche\" /var/www/cgi-bin/$base.oasix/*.pl |");
    @liste=<FILE>;
    close(FILE);
    print "<div style=\"border:1px solid black\">";
    foreach (@liste){
      print "<pre>$_</pre>";
    }
    print "</div>";
  }  
} 
;1