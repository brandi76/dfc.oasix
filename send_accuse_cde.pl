#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
require "../oasix/outils_perl2.pl";
require("./src/connect.src");

$to=$ARGV[0];
$no_cde=$ARGV[1];
$query="select * from dutyfreeambassade.client_web where mail='$to'";
$sth=$dbh->prepare($query);
$sth->execute();
($null,$null,$civilite,$lastname,$firstname,$organisation,$rue,$postcode,$city,$pays,$phone)=$sth->fetchrow_array;
$lastname=ucfirst(lc($lastname));
$firstname=ucfirst(lc($firstname));
$info=&get("select info from cmd_site_v2_info where cmd_id='$no_cde'");
# open(FILE,">/tmp/debug");
# print FILE "$to $no_cde\n";
# close FILE;
# exit;

my $html = <<"END_HTML";  
<html><head></head>
<body bgcolor='#FFFFFF' style='font-size:14px;text-align:justify;'>
<table style='border:1px solid #4575B6;max-width:600px; width:100%;' align='center' cellpadding==0 cellspacing=0>
<tr height='46'>
<td align='left' bgcolor='#4575B6'>
<font face='arial' size='2'>
<a href='http://www.dutyfreeambassade.com' target='_blank'>
<img src='http://www.dutyfreeambassade.com/images/logo-footer.png' border='0' height='46' alt='Dfa' />
</a>
</font>
</td>
<td bgcolor='#4575B6' valign='middle' style='font-style: italic;color:#FFFFFF;text-align:right;font-size:12px;padding-right:10px;font-weight:bold;'>
<font face='arial' size='2'>
</font>
</td>
</tr>
<tr>
<td colspan='2' style='padding:10px 20px 5px 10px;'>
<font face='arial' size='2'>Bonjour $lastname $firstname,
<br />  
<br />  
<br />  Votre commande N° 
<span style='font-weight:bold; color:#2a5a9f'>$no_cde
</span> a bien été enregistrée et nous vous en remercions.
<br />    
</span>.
<br />   
<br />  Nous préparons votre commande et nous l’expédierons dans les meilleurs délais.
<br />  
<br />  
<span style='font-weight:bold; text-decoration:underline;'>Récapitulatif de votre commande :   
</span>
<br>
<br>
<table style='border:1px solid #000000;border-collapse:collapse;' width='100%' border=0 cellpadding='5' cellspacing='0' align='center'>
<tr bgcolor='#C0C0C0' align='center'>
<td width='85%' align='left' style='border:1px solid #000000;font-weight:bold;'>
<font face='arial' size='2'>Produit
</font>
</td>
<td width='13%' style='border:1px solid #000000;font-weight:bold;'>
<font face='arial' size='2'>Prix
</font>
</td>
<td width='13%' style='border:1px solid #000000;font-weight:bold;'>
<font face='arial' size='2'>Quantité
</font>
</td>
<td width='13%' style='border:1=px solid #000000;font-weight:bold;'>
<font face='arial' size='2'>Prix total
</font>
</td>
</tr>
END_HTML

$query="select produit_web.code,qte,cmd_site_v2.prix,designation,marque,categorie,sous_categorie,flacon_degree,contenance from dutyfreeambassade.cmd_site_v2,dutyfreeambassade.produit_web where cmd_id='$no_cde' and cmd_site_v2.code=produit_web.code";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$qte,$prix,$designation,$marque,$categorie,$sous_categorie,$flacon_degree,$contenance)=$sth->fetchrow_array) {
$valeur=$qte*$prix;
$html.="
<tr>
<td style='border:1px solid #000000;'>
<font face='arial' size='2'>$code $designation $marque $categorie $sous_categorie $flacon_degree $contenance
</font>
</td>
<td align='right' style='border:1px solid #000000;'>
<font face='arial' size='2'>$prix €
</font>
</td>
<td align='center' style='border:1px solid #000000;'>
<font face='arial' size='2'>$qte
</font>
</td>
<td align='right' style='border:1px solid #000000;'>
<font face='arial' size='2'>$valeur €
</font>
</td>
</tr>
";
$total+=$valeur;
}
$html .= <<"END_HTML";  

</table>

<table width='100%' border=0 cellpadding='0' cellspacing='0' align='center'>
<tr>
<td width='58%' align='right'>
<font face='arial' size='2'>Montant total de votre commande : 
</font>
</td>	
<td width='13%' align='right' style='padding-right:5px;'>
<font face='arial' size='2'>
<span style='font-weight:bold; font-size:18px; color:#2a5a9f; '> $total €
</span> 
</font>
</td>
</tr>
</table>
<br />  
<br />  
<span style='font-=weight:bold; text-decoration:underline;'>Rappel de votre adresse de livraison : 
</span>
<br>
<br>$organisation
<br>$rue
<br>$postcode
<br>$city
<br>
<p style=color:'#4575B6'>
$info
</p>
</a>Notre Service Client est à votre disposition au 04 26 70 70 77 pour toutes vos questions.
</font>
</td>
</tr>
<tr>
<td style='text-align:right; padding:10px 20px 5px 10px;' colspan=2>
<font face='arial' size='2'>
<strong=>Chantal Potez
</strong>
<br />Responsable du Service Client
<br>
</font>
</td>
</tr>
<tr height='46'>
<td colspan='2' bgcolor='#4575B6'>
<font face='arial'= size='2'>
<table border='0' style='color:#FFFFFF; foint-size:16px; font-weight:bold; text-align:center; max-width:600px; width:100%;' cellpadding='0' cellspacing='0'>
<tr>
<td width='17%'>
<font face='arial' size='2'>&nbsp;
</font>
</td>
<td width='13%'>
<font face='arial' size='2'>Rapidité
</font>
</td>
<td width='13%;'>
<font face='arial' size='2'>&nbsp;
</font>
</td>
<td width='13%'>
<font face='arial' size='2'>Sérieux
</font>
</td>
<td width='13%'>
<font face='arial' size='2'>&nbsp;
</font>
</td>
<td width='13%'>
<font face='arial' size='2'>Efficacité
</font>
</td>
<td width='17%'>
<font face='arial' size='2'>&nbsp;
</font>
</td>
</tr>
</tr>
</table>
</font>
</td>
</tr>
</table>
</body>
</html>


END_HTML

my $text = <<"END_TEXT";  
Votre commande N° $no_cde\n
a bien été enregistrée et nous vous en remercions.\n
Nous préparons votre commande et nous l’expédierons dans les meilleurs délais.\n
Notre Service Client est à votre disposition au +33 (0) 232 140 391 pour toutes vos questions.\n
Chantal Potez Responsable du Service Client\n

END_TEXT


$from="supply_dfc\@dutyfreeconcept.com";
$sujet="Confirmation de votre commande";
$copie="orders\@dutyfreeambassade.com";
$copie="";

MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $msg = MIME::Lite->new(
 From     => $from,
 To       => $to,
 Cc       => $copie,
 Type     => 'multipart/alternative',
 Subject  => $sujet,
 );

 my $att_text = MIME::Lite->new(
   Type     => 'text',
   Data     => $text,
   Encoding => 'quoted-printable',
 );
 $att_text->attr('content-type'
   => 'text/plain; charset=iso-8859-1');
 $msg->attach($att_text); 

 my $att_html = MIME::Lite->new(  
  Type     => 'text',
  Data     => $html,  
  Encoding => 'quoted-printable', 
 );  
 $att_html->attr('content-type'   
   => 'text/html; charset=iso-8859-1');  
 $msg->attach($att_html);  

 $msg->send;
