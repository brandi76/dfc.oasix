#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
$CGI::POST_MAX = 1024 * 5000;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$action=$html->param("action");
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "/var/www/dfc.oasix/doc";
my $safe_filename_characters = "a-zA-Z0-9_.-";
if ($action eq ""){
	print "<form method=post>";
	print "<form  method=POST enctype=multipart/form-data>";
	require ("form_hidden.src");
	print "Ficher excel code prix<br>";
	print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<input type=file name=fichier accept=text/* maxlength=2097152>";
    print " <input type=hidden name=action value=upload>";
	print " <input type=submit></form>";
}

if ($action eq "upload"){
	$fic=$html->param("fichier");
	print $fic;
 	while (read($fic, $data, 4192)){
 		$texte=$texte.$data;
 	}
	@lignes=split(/\n/,$texte);
	foreach (@lignes){
	  print "*<br>";
	}
}
if ($action eq "upload2"){
	my $filename = $html->param("fichier");
	if ( !$filename )
	{
	print "There was a problem uploading your file (try a smaller file).";
	exit;
	}
	print "$filename";
 	
	my $upload_filehandle = $html->upload("fichier");
	
	open ( UPLOADFILE, ">$upload_dir/prix_tmp.xls" ) or die "$!";
	binmode UPLOADFILE;
	while (read($filename, $data, 4192)){
		print "*";
 		print UPLOADFILE $data;
 	}
	close (UPLOADFILE);
	print "<style>";
	print "tr:nth-child(even){background:lavender;}";
	print "</style>";
	my $book  = ReadData ("$upload_dir/prix_tmp.xls");
	$i=1;
	$nb_col=$book->[$i]{maxcol};
	$nb_ligne=$book->[$i]{maxrow};
	print "<table border=1;cellspacing=0,callpadding=0>";
	print "<tr bgcolor=orange>";
	for ($l=1;$l<=$nb_ligne;$l++){
		$code=$book->[$i]{cell}[1][$l];
		$prix=$book->[$i]{cell}[1][$l];
		if ($code=~m/[a-z]/i){next}
		if (length($code)<5){next;}
		print "<tr>";
		print "<td>";
		print $code;
		print "</td><td>";
		print $prix;
		print "</td><td></tr>";
	}
	print "</table>";

}
;1