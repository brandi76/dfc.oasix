#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'outils_perl.lib';

print $html->header;  
print "<HTML>\n";
&body();
&tete("Statistique sur les ventes","","");

print <<"eof";
<center>
<form method=post action=facdata.pl>

<table width=80% border=2 cellspacing=0 cellpadding=8 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >
<tr>
<td bgcolor=#E0E0E0>
<b>Tapez ici le(s) code(s) recherché(e)</b>
</td>
<td bgcolor=#E0E0E0>
<b>Type du Code & année de recherche.</b>
</td>
<td bgcolor=#E0E0E0>
&nbsp;
</td>
</tr>
<tr>
<td align=center>
Code <input type=text size=15 name=code>
</td>
<td>
<input type=radio name=type_code value="fournisseur" CHECKED>Fournisseur<br>
<input type=radio name=type_code value="produit">Produit
</td>
<td bgcolor=#E0E0E0>
&nbsp;
</td>
</tr>
<tr>
<td align=center>
Premier Client : <input type=text size=10 name=premier><br>
Dernier Client : <input type=text size=10 name=dernier>
</td>
<td>
<input type=radio name=annee value=2001 checked> 2001<br>
<input type=radio name=annee value=2000> 2000<br>
<input type=radio name=annee value=1999> 1999<br>
<input type=radio name=annee value=1998> 1998<br>
<input type=radio name=annee value=1997> 1997<br>
</td>

<td>
<input type=reset value="Effacer"><br>
<input type=submit value="Valider">
</td>
</tr>

</form></BODY>
</HTML>

eof

