#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;


require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';

$jour = `date +%d`;
$mois1 = `date +%m`;
$annee = `date +%Y`;

if( -e "/home/var/spool/uucppublic/formule1.txt"){
	$copy = `cp /home/var/spool/uucppublic/formule1.txt /home/var/spool/uucppublic/formule1_last.txt`;
	$sup = `rm /home/var/spool/uucppublic/formule1.txt`;
}else{


}


open(FILE,"< /home/var/spool/uucppublic/formule1_last.txt");
@fiche=<FILE>;
close(FILE);
$mois1+=0;
$mois = &cal($mois1,'l');
%produit_idx = &get_index_num("produit",1);             
open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits 
@produit_dat = <FILE2>; 
# print "<font color=red>@produit_dat[$produit_idx{220650}]</font>";

foreach(@fiche){
	@tmp = split(/;/,$_);
		$ambassade = $tmp[1];	
		$nom = $tmp[2];
		$rue = $tmp[3];
		$ville = $tmp[4];
		#$cp = $tmp[5];
}



print <<"eof"; 
<html xmlns:o='urn:schemas-microsoft-com:office:office'
xmlns:w='urn:schemas-microsoft-com:office:word'
xmlns='http://www.w3.org/TR/REC-html40'>

<head>
<meta http-equiv=Content-Type content='text/html; charset=windows-1252'>
<meta name=ProgId content=Word.Document>
<meta name=Generator content='Microsoft Word 9'>
<meta name=Originator content='Microsoft Word 9'>
<link rel=File-List
href='./MINISTERE%20DES%20AFFAIRES%20ETRANGERES_fichiers/filelist.xml'>
<title>Demande de franchise . . .</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author></o:Author>
  <o:LastAuthor></o:LastAuthor>
  <o:Revision>62</o:Revision>
  <o:TotalTime>383</o:TotalTime>
  <o:LastPrinted>2002-07-03T07:28:00Z</o:LastPrinted>
  <o:Created>2002-07-02T15:19:00Z</o:Created>
  <o:LastSaved>2002-07-03T09:33:00Z</o:LastSaved>
  <o:Pages>2</o:Pages>
  <o:Words>423</o:Words>
  <o:Characters>2414</o:Characters>
  <o:Company>-</o:Company>
  <o:Lines>20</o:Lines>
  <o:Paragraphs>4</o:Paragraphs>
  <o:CharactersWithSpaces>2964</o:CharactersWithSpaces>
  <o:Version>9.2812</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Normal</w:View>
  <w:ActiveWritingStyle Lang='FR' VendorID='9' DLLVersion='512' NLCheck='0'>1</w:ActiveWritingStyle>
  <w:HyphenationZone>21</w:HyphenationZone>
 </w:WordDocument>
</xml><![endif]-->
<style>
<!--
 /* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:'';
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:'Times New Roman';
	mso-fareast-font-family:'Times New Roman';}
h1
	{mso-style-next:Normal;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	font-size:12.0pt;
	font-family:'Times New Roman';
	mso-font-kerning:0pt;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin-top:0cm;
	margin-right:260.25pt;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:'Times New Roman';
	mso-fareast-font-family:'Times New Roman';}
p.MsoBodyText2, li.MsoBodyText2, div.MsoBodyText2
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:'Times New Roman';
	mso-fareast-font-family:'Times New Roman';}
\@page Section1
	{size:595.3pt 841.9pt;
	margin:1.0cm 1.0cm 1.0cm 1.0cm;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
\@list l0
	{mso-list-id:187065117;
	mso-list-type:hybrid;
	mso-list-template-ids:-1714942598 -533721672 67895321 67895323 67895311 67895321 67895323 67895311 67895321 67895323;}
\@list l0:level1
	{mso-level-text:'\(%1\)';
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
\@list l1
	{mso-list-id:838740874;
	mso-list-type:hybrid;
	mso-list-template-ids:1548259566 67895319 67895321 67895323 67895311 67895321 67895323 67895311 67895321 67895323;}
\@list l1:level1
	{mso-level-number-format:alpha-lower;
	mso-level-text:'%1\)';
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
\@list l2
	{mso-list-id:1188835025;
	mso-list-type:hybrid;
	mso-list-template-ids:-1321567018 67895317 67895321 67895323 67895311 67895321 67895323 67895311 67895321 67895323;}
\@list l2:level1
	{mso-level-number-format:alpha-upper;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
\@list l3
	{mso-list-id:1353725586;
	mso-list-type:hybrid;
	mso-list-template-ids:364179118 67895311 67895321 67895323 67895311 67895321 67895323 67895311 67895321 67895323;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
-->
</style>
</head>

<body lang=FR style='tab-interval:35.45pt'>

<div class=Section1>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=728 style='width:545.65pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr>
  <td width=365 valign=top style='width:273.55pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
  <h1 style='margin-left:-3.5pt;tab-stops:right 176.1pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;font-weight:normal'>MINISTERE
  DES AFFAIRES ETRANGERES<o:p></o:p></span></h1>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Protocole<o:p></o:p></span></p>
  </td>
  <td width=363 valign=top style='width:272.1pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
  <h1><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;font-weight:normal'>MINISTERE
  DE L’ECONOMIE , DES FINANCES<o:p></o:p></span></h1>
  <h1><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;font-weight:normal'>ET
  DE L’INDUSTRIE<o:p></o:p></span></h1>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Direction général des
  douanes et droits indirects<o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<h1 align=left style='margin-right:224.25pt;text-align:left;tab-stops:right 486.0pt'><span
style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></h1>

<div align=center>

<table border=0 cellspacing=0 cellpadding=0 width=737 style='width:552.5pt;
 border-collapse:collapse;mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr>
  <td width=737 valign=top style='width:552.5pt;padding:0cm 3.5pt 0cm 3.5pt'>
  <h1 style='margin-right:-.75pt'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Formulaire n°1<o:p></o:p></span></h1>
  <p class=MsoNormal align=center style='margin-right:-.75pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-right:-.75pt'>CERTIFICAT D’EXONERATION DE
  LA TVA ET DES DROITS D’Accises</p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>(Article 15 par. 10 de la
  directive 77/388/CEE et article 23 par. 1 de la directive 92/12/CEE<o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=732 style='width:549.0pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr style='height:3.0cm'>
  <td width=732 valign=top style='width:549.0pt;border:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:3.0cm'>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
  0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-19.7pt;mso-list:
  l3 level1 lfo2;tab-stops:list 17.0pt 19.7pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>1.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>ORGANISME DEMANDEUR<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-right:-25.15pt;text-indent:-3.9pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
  0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Nom&nbsp;: $ambassade<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
  0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Nom et prénom du
  bénéficiaire&nbsp;: $ambassade<o:p></o:p></span></p>
  <div align=center>
  <table border=1 cellspacing=0 cellpadding=0 width=691 style='width:518.15pt;
   border-collapse:collapse;border:none;mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
   <tr style='height:5.55pt'>
    <td width=285 valign=top style='width:213.85pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
    height:5.55pt'>
    <p class=MsoNormal style='margin-right:-3.85pt'><span style='font-size:
    10.0pt;mso-bidi-font-size:12.0pt'>Type de la carte<o:p></o:p></span></p>
    </td>
    <td width=203 valign=top style='width:152.15pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
    height:5.55pt'>
    <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
    0cm;margin-left:-3.15pt;margin-bottom:.0001pt'><span style='font-size:10.0pt;
    mso-bidi-font-size:12.0pt'>Numéro de la carte<o:p></o:p></span></p>
    </td>
    <td width=203 valign=top style='width:152.15pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
    height:5.55pt'>
    <p class=MsoNormal style='margin-right:-25.15pt'><span style='font-size:
    10.0pt;mso-bidi-font-size:12.0pt'>Date de délivrance<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='height:5.55pt'>
    <td width=285 valign=top style='width:213.85pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
    height:5.55pt'>
    <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
    0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><![if !supportEmptyParas]>&nbsp;<![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>N/A<o:p></o:p></span></p>
    </td>
    <td width=203 valign=top style='width:152.15pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
    height:5.55pt'>
    <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
    0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><![if !supportEmptyParas]>&nbsp;<![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>N/A<o:p></o:p></span></p>
    </td>
    <td width=203 valign=top style='width:152.15pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
    height:5.55pt'>
    <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
    0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><![if !supportEmptyParas]>&nbsp;<![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>N/A<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
  0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Adresse (rue, n°)&nbsp;: $rue<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
  0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Code Poste,
  localité&nbsp;: $ville<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-25.15pt;margin-bottom:
  0cm;margin-left:19.7pt;margin-bottom:.0001pt;text-indent:-3.9pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Etat membre
  d’accueil&nbsp;: F R A N C E<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-right:-25.15pt;text-indent:-3.9pt'><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal style='margin-left:117.0pt'><span style='font-size:10.0pt;
mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=732 style='width:549.0pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr>
  <td width=732 valign=top style='width:549.0pt;border:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt'>
  <p class=MsoNormal style='margin-left:1.7pt;text-indent:0cm;mso-list:l3 level1 lfo2;
  tab-stops:list 16.75pt 19.7pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>2.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>AUTORITE FISCALE COMPETENTE POUR L’APPOSITION DU CACHET<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>DIRECTION GENERALE DES
  DOUANES ET DROITS INDIRECTS<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Bureau F/1<o:p></o:p></span></p>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal style='margin-left:144.0pt'><span style='font-size:10.0pt;
mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=732 style='width:549.0pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr style='height:441.45pt'>
  <td width=732 valign=top style='width:549.0pt;border:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:441.45pt'>
  <p class=MsoNormal style='margin-left:1.7pt;text-indent:0cm;mso-list:l3 level1 lfo2;
  tab-stops:list 16.75pt 28.7pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>3.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>DECLARATION DE L’ORGANISME<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.7pt'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt'>Par la présente, l’organisme exonérable
  déclare&nbsp;:<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:28.7pt;text-indent:-9.0pt;mso-list:
  l1 level1 lfo4;tab-stops:list 28.7pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>a)<span style='font:7.0pt 'Times New Roman''>
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>que les biens énumérés à la case 4 sont destinés à l’usage(1)&nbsp;:<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <div align=center>
  <table border=1 cellspacing=0 cellpadding=0 style='border-collapse:collapse;
   border:none;mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
   <tr>
    <td width=11 valign=top style='width:8.0pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><![if !supportEmptyParas]><![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><INPUT TYPE="CHECKBOX"><o:p></o:p></span></p>
    </td>
    <td width=297 valign=top style='width:223.05pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>D’une
    mission diplomatique étrangère<o:p></o:p></span></p>
    </td>
    <td width=11 valign=top style='width:8.05pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><![if !supportEmptyParas]><![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><INPUT TYPE="CHECKBOX"><o:p></o:p></span></p>
    </td>
    <td width=288 valign=top style='width:216.0pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>D’un
    organisme international<o:p></o:p></span></p>
    </td>
   </tr>
   <tr>
    <td width=11 valign=top style='width:8.0pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><![if !supportEmptyParas]><![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><INPUT TYPE="CHECKBOX"><o:p></o:p></span></p>
    </td>
    <td width=297 valign=top style='width:223.05pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>D’une
    représentation consulaire étrangère<o:p></o:p></span></p>
    </td>
    <td width=11 valign=top style='width:8.05pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><![if !supportEmptyParas]><![endif]><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><INPUT TYPE="CHECKBOX"><o:p></o:p></span></p>
    </td>
    <td width=288 valign=top style='width:216.0pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Des
    forces armées d’un Etat partie au Traité de l’Atlantique Nord (Forces OTAN)<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:28.7pt;text-indent:-9.0pt;mso-list:
  l1 level1 lfo4;tab-stops:list 28.7pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>b)<span style='font:7.0pt 'Times New Roman''>
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>que les biens décrits à la case 4 sont conformes aux conditions
  et aux restrictions applicables en matière d’exonération dans l’Etat membre
  mentionné à la case 1, et<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:18.3pt;margin-bottom:
  0cm;margin-left:28.7pt;margin-bottom:.0001pt;text-align:justify;text-indent:
  -9.0pt;mso-list:l1 level1 lfo4;tab-stops:list 28.7pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>c)<span style='font:7.0pt 'Times New Roman''>
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>que les informations figurant ci-dessus sont exactes et sincères.
  L’organisme exonérable s’engage par la présente déclaration à verser à l’Etat
  membre à partir duquel les biens ont été expédiés ou à partir duquel les biens
  ont été fournis la TVA ou/et les droits d’accises qui seraient exigibles si les
  biens n’étaient pas conformes aux conditions d’exonération ou s’ils n&nbsp;étaient
  pas utilisés de la façon prévue.<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>A Paris, le $jour $mois $annee<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Signature<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Nom et qualité du
  signataire<o:p></o:p></span></p>
  </td>
 </tr>
</table>


</div>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=727 style='width:544.9pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr style='height:80.25pt'>
  <td width=727 colspan=6 valign=top style='width:544.9pt;border:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:80.25pt'>
  <p class=MsoNormal style='margin-left:17.65pt;text-indent:-18.0pt;mso-list:
  l3 level1 lfo2;tab-stops:17.65pt list 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>4.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>DESCRIPTION DES BIENS POUR LESQUELS L’EXONERATION DE LA TVA ET/OU DES
  DROITS D’ACCISES EST DEMANDEE<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <ol style='margin-top:0cm' start=1 type=A>
   <li class=MsoNormal style='mso-list:l2 level1 lfo7;tab-stops:list 36.0pt'><span
       style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Informations
       relatives à l’assujetti/entrepositaire agréé<o:p></o:p></span></li>
  </ol>
  <p class=MsoNormal style='margin-left:35.65pt;text-indent:-18.0pt;mso-list:
  l3 level2 lfo2;tab-stops:list 35.65pt 72.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>1.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Nom et adresse(fournisseur) BIS France SA 76203 ZI ROUXMESNIL
  BOUTEILLES DIEPPE CEDEX<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:35.65pt;text-indent:-18.0pt;mso-list:
  l3 level2 lfo2;tab-stops:list 35.65pt 72.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>2.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Etat membre France<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:35.65pt;text-indent:-18.0pt;mso-list:
  l3 level2 lfo2;tab-stops:list 35.65pt 72.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>3.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Numéros d’identification TVA FR51433874708et ACCISES (alcool/vin)
  FR0116S0072<o:p></o:p></span></p>
  <ol style='margin-top:0cm' start=2 type=A>
   <li class=MsoNormal style='mso-list:l2 level1 lfo7;tab-stops:list 36.0pt'><span
       style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Informations
       relatives aux biens<o:p></o:p></span></li>
  </ol>
  </td>
 </tr>
 <tr style='height:17.9pt'>
  <td width=28 rowspan=2 valign=top style='width:21.15pt;border:solid windowtext .5pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:17.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>N°<o:p></o:p></span></p>
  </td>
  <td width=320 rowspan=2 valign=top style='width:239.65pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:17.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Description détaillée des
  biens (2)<o:p></o:p></span></p>
  </td>
  <td width=88 rowspan=2 valign=top style='width:66.35pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:17.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Quantité ou nombre<o:p></o:p></span></p>
  </td>
  <td width=211 colspan=2 valign=top style='width:158.4pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:17.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Valeur hors TVA et/ou
  droits d’accises<o:p></o:p></span></p>
  </td>
  <td width=79 valign=top style='width:59.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:17.9pt'>
  <p class=MsoNormal align=center style='margin-left:5.1pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Monnaie(3)<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='height:5.6pt'>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:5.6pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Valeur unitaire<o:p></o:p></span></p>
  </td>
  <td width=103 valign=top style='width:77.4pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:5.6pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Valeur totale<o:p></o:p></span></p>
  </td>
  <td width=79 style='width:59.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:5.6pt'>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>

eof

$nb=0;
$total = 0;
foreach(@fiche){
	$nb++;
	@tmp = split(/;/,$_);
		$code = $tmp[0];
		$ambassade = $tmp[1];	
		$nom = $tmp[2];
		$rue = $tmp[3];
		$ville = $tmp[4];
		# print "<font color=red>$code_prod</font>";
		$code_prod = $tmp[5]%1000000;
		$qte = $tmp[6];
		$prix = $tmp[7];
		$prix_total = $prix * $qte;
		$total += $prix_total;

($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) =split (/;/,@produit_dat[$produit_idx{$code_prod}]); 
# print "$code_prod @produit_dat[$produit_idx{$code_prod}]<br>";

print <<"eof";

 <tr style='height:8.55pt'>
  <td width=28 valign=top style='width:21.15pt;border:solid windowtext .5pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>$nb<o:p></o:p></span></p>
  </td>
  <td width=320 valign=top style='width:239.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>$pr_desi<o:p></o:p></span></p>
  </td>
  <td width=88 valign=top style='width:66.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>$qte<o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>$prix<o:p></o:p></span></p>
  </td>
  <td width=103 valign=top style='width:77.4pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>$prix_total<o:p></o:p></span></p>
  </td>
  <td width=79 valign=top style='width:59.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>EUR<o:p></o:p></span></p>
  </td>
 </tr>


eof


}

print <<"eof";
 <tr style='height:8.55pt'>
  <td width=28 valign=top style='width:21.15pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
  <td width=320 valign=top style='width:239.65pt;border:none;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:8.55pt'>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
  <td width=379 colspan=4 valign=top style='width:284.1pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.55pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Valeur
  totale en monnaie locale :<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='height:9.35pt'>
  <td width=28 valign=top style='width:21.15pt;border:none;padding:0cm 3.5pt 0cm 3.5pt;
  height:9.35pt'>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
  <td width=320 valign=top style='width:239.65pt;border:none;border-right:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:9.35pt'>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
  <td width=379 colspan=4 valign=top style='width:284.1pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:9.35pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Valeur
  totale en euros&nbsp;: $total <o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=727 style='width:544.9pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr>
  <td width=727 valign=top style='width:545.6pt;border:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt'>
  <p class=MsoNormal style='margin-left:18.0pt;text-indent:-18.0pt;mso-list:
  l3 level1 lfo2;tab-stops:list 18.0pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>5.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>CERTIFICAT DES AUTORITES COMPETENTES DE L’ETAT MEMBRE D’ACCUEIL<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.65pt'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt'>L’expédition/livraison des biens décrite à la case
  4 respecte les conditions d’exonération de la TVA et/ou des droits d’accises<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <table border=1 cellspacing=0 cellpadding=0 style='border-collapse:collapse;
   border:none;mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
   <tr>
    <td width=275 valign=top style='width:206.6pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoNormal align=center style='margin-left:4.75pt;text-align:center'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>MINISTERE DES AFFAIRES
    ETRANGERES<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Protocole<o:p></o:p></span></p>
    </td>
    <td width=442 valign=top style='width:331.2pt;border:none;padding:0cm 3.5pt 0cm 3.5pt'>
    <p class=MsoBodyText2>MINISTERE DE L’ECONOMIE, DES FINANCES ET DE
    L’INDUSTRIE</p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Direction générale des
    douanes et droits indirects<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=1 cellspacing=0 cellpadding=0 width=727 style='width:544.9pt;
 border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr>
  <td width=727 valign=top style='width:545.6pt;border:solid windowtext .5pt;
  padding:0cm 3.5pt 0cm 3.5pt'>
  <p class=MsoNormal style='margin-left:18.0pt;text-indent:-18.0pt;mso-list:
  l3 level1 lfo2;tab-stops:list 18.0pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>6.<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>DISPENCE DU CACHET<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>NEANT<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

<div align=center>

<table border=0 cellspacing=0 cellpadding=0 style='border-collapse:collapse;
 mso-padding-alt:0cm 3.5pt 0cm 3.5pt'>
 <tr>
  <td width=727 valign=top style='width:545.6pt;padding:0cm 3.5pt 0cm 3.5pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:18.0pt;text-indent:-18.0pt;mso-list:
  l0 level1 lfo10;tab-stops:list 18.0pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>(1)<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Cocher la case correspondante.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:18.0pt;text-indent:-18.0pt;mso-list:
  l0 level1 lfo10;tab-stops:list 18.0pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>(2)<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Présiser le numéro de chassis pour les véhicules. Annuler l’espace non
  utilisé. Joindre les originaux des factures qui seront restitués après
  décision ou une facture pro-forma pour les seuls produits soumis à accises.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:18.0pt;text-indent:-18.0pt;mso-list:
  l0 level1 lfo10;tab-stops:list 18.0pt 36.0pt'><![if !supportLists]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>(3)<span style='font:7.0pt 'Times New Roman''>&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span><![endif]><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'>Préciser la monnaie au moyen du ISO à 3 lettres<o:p></o:p></span></p>
  <p class=MsoNormal><![if !supportEmptyParas]>&nbsp;<![endif]><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><![if !supportEmptyParas]>&nbsp;<![endif]><o:p></o:p></span></p>

</div>

</body>

</html>


eof


