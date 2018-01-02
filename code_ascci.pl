#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
$texte=$html->param("texte");

print "<form>*";
print "<input type=text name=texte>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";

if ($texte ne ""){
    for ($i=0;$i<length($texte);$i++){
		if ((ord(substr($texte,$i,1))==35)&&($trouve)){$confirme=1;}
		if (ord(substr($texte,$i,1))==38){$trouve=1;}else{$trouve=0;}
		
		if ((! $confirme)&& (ord(substr($texte,$i,1))!=38)){
			# print substr($texte,$i,1),":",ord(substr($texte,$i,1))," conf:$confirme trouv:$trouve:<br>";
			print substr($texte,$i,1);
		}
		if ((ord(substr($texte,$i,1))==59)&&($confirme)){$trouve=0;$confirme=0;print "e";}
	}
}	
