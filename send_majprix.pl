#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$sujet="Mise a jour prix ";
#$mail="sb\@dutyfreeconcept.com";
&init();
$titre="Prix d'achat à valider";
$message=$head;
$query="select * from suivi_importation where action='Importation prix' and date>='2017-01-01'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$date,$nom,$libelle,$action,$base)=$sth->fetchrow_array){
	$check=&get("select id from suivi_importation_prac where id='$id'")+0;
	if ($check==0){
		$titre="";
		$texte="";
		foreach (split(/:/,$base)){
		 		$titre.=&get("select base_lib from base where base_id=$_"). " ";
				if ($_ eq "dutyfreeambassade"){$gille=1;}else{$isa=1;}
		}
		$texte="</b> $libelle  prix à valider<br>";
		$lien="<a href=http://dfc.oasix.fr/cgi-bin/upload_prix_excel.pl?action=compare&id=$id>Voir le contenu de la liste</a>";
		$message.=<<EOF;
	                            <table class="w580"  width="580" cellpadding="0" cellspacing="0" border="0">
                                                        <tbody>                                                            
                                                            <tr>
                                                                <td class="w580"  width="580">
                                                                    <h2 style="color:#0E7693; font-size:22px; padding-top:12px;">
                                                                        $titre </h2>
                                                                    <div align="left" class="article-content">
                                                                        <p>
                                                                            $texte $lien
                                                                        </p>
                                                                      </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="w580"  width="580" height="1" bgcolor="#c7c5c5"></td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
EOF
                        
	}
}
$message.=$tail;
$mail="sylvainbrandicourt\@gmail.com";
if ($gille==1){
	$mail.=",gis.dfa\@gmail.com";
}
if ($isa==1){
	$mail.=",il\@dutyfreeconcept.com,pp\@dutyfreeconcept.com" ;
}

if (($gille==1)||($isa==1)){&mail_joint_pdf("$message","$sujet","$mail");}

$titre="Prix d'achat à modifier";
$message=$head;
$query="select * from suivi_importation where action='Importation prix' and date>='2017-01-01'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$date,$nom,$libelle,$action,$base)=$sth->fetchrow_array){
		$check=&get("select id from suivi_importation_prac where id='$id' and fait='0000-00-00'")+0;
		if ($check>0){
			$check=&get("select count(*) from produit_prac where id='$id' and date<=curdate()","af")+0;
			if ($check>0){
				$titre="";
				$texte="";
				foreach (split(/:/,$base)){
						$titre.=&get("select base_lib from base where base_id=$_"). " ";
				}
				$pass=1;
				$texte="</b> $libelle  prix à mettre à jour<br>";
				$lien="<a href=http://dfc.oasix.fr/cgi-bin/maj_prac.pl?liste=$id>Lancer la mise à jour</a>";
				$message.=<<EOF;
										<table class="w580"  width="580" cellpadding="0" cellspacing="0" border="0">
																<tbody>                                                            
																	<tr>
																		<td class="w580"  width="580">
																			<h2 style="color:#0E7693; font-size:22px; padding-top:12px;">
																				$titre </h2>
																			<div align="left" class="article-content">
																				<p>
																					$texte $lien
																				</p>
																			  </div>
																		</td>
																	</tr>
																	<tr>
																		<td class="w580"  width="580" height="1" bgcolor="#c7c5c5"></td>
																	</tr>
																</tbody>
															</table>
EOF
                        
			}
	}		
}
$message.=$tail;
$mail="sylvainbrandicourt\@gmail.com";
if ($pass==1){&mail_joint_pdf("$message","$sujet","$mail");}



sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
$user="6192_infodfc";
$pass="5q6h5d";
my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', $user, $pass );

#MIME::Lite->send('smtp','smtp.dutyfreeconcept.com',Debug=>1);
my $mime = MIME::Lite->new(
            From       => 'info_dfc@dutyfreeconcept.com',
            To         => "$to",
            Subject    => "$sujet",
            "X-Mailer" => 'moncourriel.pl v2.0',
            Type       => 'multipart/mixed'
            );
my $att_text =MIME::Lite->new(			
            Type       => 'TEXT',
            Encoding   => 'quoted-printable',
            Data       => $message
);
$att_text->attr('content-type'
   => 'text/html; charset=iso-8859-1');
$mime->attach($att_text); 
$mime->send();
}



sub init{
$head=<<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Mailing Serveur</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style type="text/css">
    /* Fonts and Content */
    body, td { font-family: 'Helvetica Neue', Arial, Helvetica, Geneva, sans-serif; font-size:14px; }
    body { background-color: #2A374E; margin: 0; padding: 0; -webkit-text-size-adjust:none; -ms-text-size-adjust:none; }
    h2{ padding-top:12px; /* ne fonctionnera pas sous Outlook 2007+ */color:#0E7693; font-size:22px; }

    </style>
   
</head>
<body style="margin:0px; padding:0px; -webkit-text-size-adjust:none;">

    <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:rgb(42, 55, 78)" >
        <tbody>
            <tr>
                <td align="center" bgcolor="#2A374E">
                    <table  cellpadding="0" cellspacing="0" border="0">
                        <tbody>                            
                            <tr>
                                <td class="w640"  width="640" height="10"></td>
                            </tr>

                            <tr>
                                <!-- <td align="center" class="w640"  width="640" height="20"> <a style="color:#ffffff; font-size:12px;" href="#"><span style="color:#ffffff; font-size:12px;">Voir le contenu de ce mail en ligne</span></a> </td>-->
                            </tr>
                            <tr>
                                <td class="w640"  width="640" height="10"></td>
                            </tr>

                            <!-- entete -->
                            <tr class="pagetoplogo">
                                <td class="w640"  width="640">
                                    <table  class="w640"  width="640" cellpadding="0" cellspacing="0" border="0" bgcolor="#F2F0F0">
                                        <tbody>
                                            <tr>
                                                <td class="w30"  width="30"></td>
                                                <td  class="w580"  width="580" valign="middle" align="left">
                                                    <div class="pagetoplogo-content">
													    <span  style="text-decoration: none; display: block; color:#476688; font-size:30px;"> $titre<span>
                                                    </div>
                                                </td> 
                                                <td class="w30"  width="30"></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>

                            <!-- separateur horizontal -->
                            <tr>
                                <td  class="w640"  width="640" height="1" bgcolor="#d7d6d6"></td>
                            </tr>

                             <!-- contenu -->
                            <tr class="content">
                                <td class="w640" class="w640"  width="640" bgcolor="#ffffff">
                                    <table class="w640"  width="640" cellpadding="0" cellspacing="0" border="0">
                                        <tbody>
                                            <tr>
                                                <td  class="w30"  width="30"></td>
                                                <td  class="w580"  width="580">
                                                    <!-- une zone de contenu -->
EOF
$tail=<<EOF;
													
                                                    <!-- fin zone -->                                                   
                                                </td>
                                                <td class="w30" class="w30"  width="30"></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>

                            <!--  separateur horizontal de 15px de  haut-->
                            <tr>
                                <td class="w640"  width="640" height="15" bgcolor="#ffffff"></td>
                            </tr>

                            <!-- pied de page -->
                            <tr class="pagebottom">
                                <td class="w640"  width="640">
                                    <table class="w640"  width="640" cellpadding="0" cellspacing="0" border="0" bgcolor="#c7c7c7">
                                        <tbody>
                                            <tr>
                                                <td colspan="5" height="10"></td>
                                            </tr>
                                            <tr>
                                                <td class="w30"  width="30"></td>
                                                <td class="w580"  width="580" valign="top">
                                                    <p align="right" class="pagebottom-content-left">
                                                        <a style="color:#255D5C;" href=""><span style="color:#255D5C;">Envoyé automatiquement par le serveur DFC</span></a>
                                                    </p>
                                                </td>

                                                <td class="w30"  width="30"></td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" height="10"></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td class="w640"  width="640" height="60"></td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
</body>
</html>
EOF
}

