#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;







use GD::Graph::pie;
my @labels;
my @values;
while(<>) {
  next unless m#^\s*(.+?)\s+(.+)#;
  push @labels, $2;
  push @values, $1;
}
my @data = ( [@labels], [@values] );
my $graph = GD::Graph::pie->new(400,400);
$graph->set(
             start_angle => 90,
             '3d'        => 0,
             label       => 'OS',
           );
my $gd = $graph->plot(\@data);
open(PNG, '>', "gd1.png") || die "Cannot write to 1.png: $!";
print PNG $gd->png;
close PNG;
=cut