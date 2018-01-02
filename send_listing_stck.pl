#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
use Net::SMTP_auth;
use Spreadsheet::WriteExcel;

require "../oasix/outils_perl2.pl";
require("./src/connect.src");

$lieu=$ARGV[0];
$mail=$ARGV[1];
$date=&get("select now()");
$date=~s/ /_/g;
$file="../../$base_rep/doc/inventaire_".$date.".xls";
# $fich=$four."_".$nocde.".xls";
if (-f $file){unlink ($file);}
$workbook = Spreadsheet::WriteExcel->new("$file");
$worksheet = $workbook->add_worksheet();
$col = $row = 0;
$worksheet->write($row, $col, "$date");
$row++;
$worksheet->write($row, $col, "$lieu");
$row++;
$worksheet->write($row,$col,"Produit");
$col++;
$worksheet->write($row,$col,"Désignation");
$col++;
$worksheet->write($row,$col,"Prix de vente");
$col++;
$worksheet->write($row,$col,"Famille");
$col++;
$worksheet->write($row,$col,"Prix d'achat");
$col++;
$worksheet->write($row,$col,"Stock Théorique");
$col++;
$worksheet->write($row,$col,"Valeur");
$row++;

$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();

while (($code,$pr_desi,$prac)=$sth->fetchrow_array){
	$pr_famille=&get("select pr_famille from produit_plus where pr_cd_pr='$code'");
	$famille=&get("select fa_desi from famille where fa_id='$pr_famille'");
	%stock=&stock($code,'',"quick");
	$stck=$stock{"pr_stre"};
	$valeur=$stck*$prac;
	if ($valeur==0){next;}
	$col = 0;
	$worksheet->write($row,$col,"$code");
	$col++;
	$worksheet->write($row,$col,"$pr_desi");
	$col++;
	$worksheet->write($row,$col,"");
	$col++;
	$worksheet->write($row,$col,"$pr_famille $famille");
	$col++;
	$worksheet->write($row,$col,"$prac");
	$col++;
	$worksheet->write($row,$col,"$stck");
	$col++;
	$row_for=$row+1;
	$worksheet->write($row,$col,"=E$row_for*F$row_for");
	$row++;
}
$worksheet->write($row,6,"=SUM(G4:G$row_for)");
$workbook->close();
$fichier="inventaire_".$date.".xls";

$message="Bonjour,\n
Ci-joint listing stock\n
Cordialement\n
Le serveur\n
";
$sujet="Listing stock $lieu";
&mail_joint_pdf("$message","$sujet","$mail","","$fichier","/var/www/$base_rep/doc");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];
my ($file)=$_[4];
my ($path)=$_[5];
$type="pdf";
if (grep /xls$/,$fichier){$type="vnd.ms-excel";}

my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', '6192_sb', 'passe123' );

# MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'supply_dfc@dutyfreeconcept.com',
            To         => "$to",
            Cc         => "$cc",
            Subject    => "$sujet",
            "X-Mailer" => 'moncourriel.pl v2.0',
            Type       => 'multipart/mixed'
            );
$mime->attach(
            Type       => 'TEXT',
            Encoding   => 'quoted-printable',
            Data       => $message
);
$mime->attr("content-type.charset" => "utf-8");

$mime->attach(
           Type       => "application/$type",
           Encoding   => 'base64',
           Path       => "$path/$file",
           Filename   => "$file"
);
$mime->send();
}
