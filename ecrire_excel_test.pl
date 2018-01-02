#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
 use Spreadsheet::WriteExcel;

    # Create a new Excel workbook
    my $workbook = Spreadsheet::WriteExcel->new('perl.xls');

    # Add a worksheet
    $worksheet = $workbook->add_worksheet();


    # Write a formatted and unformatted string, row and column notation.
    $col = $row = 0;
    $worksheet->write($row, $col, 'Hi Excel!');
   $workbook->close();
;1