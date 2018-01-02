#!/usr/bin/perl
use CGI;

# $html=new CGI;
# print $html->header;
$nb=0;
$ligne=0;
$a=0;
$b=4;
$c=39;
$d=23;
$e=22;
$f=6;
$g=215;
$file="coca";
print $file."_bmp(x,y){\n";
print "int  a,b,c,d,e;\n";
print "a=$a;\n";
print "b=$b;\n";
print "c=$c;\n";
print "d=$d;\n";
print "e=$e;\n";
open (FILE, "</mnt/server-file/$file.csv");
@file=<FILE>;
foreach (@file){
	chop($_);
	while ($_=~s///){}
	while ($_=~s/\"//){}
	(@cel)=split(/;/,$_);
	$col=0;
	for ($i=0;$i<=$#cel;$i++){
	         # print "$ligne  $cel[$i] $nb $prec \n";
		if ($cel[$i] ne $prec)
		{
			if (($nb!=0)&&($prec ne "")){
				if ($prec eq "a"){$color=$a;}
				if ($prec eq "b"){$color=$b;}
				if ($prec eq "c"){$color=$c;}
				if ($prec eq "d"){$color=$d;}
				if ($prec eq "e"){$color=$e;}
				if ($prec eq "f"){$color=$f;}
				if ($prec eq "g"){$color=$f;}
				print "$nb,1,$prec,FALSE);\n";
				$nb=-1;
                        }
			if ($cel[$i] ne ""){
				print "hmiGraphicPixelFill (G_hmiHandle,x+$i-1,y+$ligne,";
				$nb=0;
			}
			$prec=$cel[$i];
		}
		$nb++;
	}

	if ($nb!=0){
				if ($prec eq "a"){$color=$a;}
				if ($prec eq "b"){$color=$b;}
				if ($prec eq "c"){$color=$c;}
				if ($prec eq "d"){$color=$d;}
				if ($prec eq "e"){$color=$e;}
				if ($prec eq "f"){$color=$f;}
				if ($prec eq "g"){$color=$f;}
		print "$nb,1,$prec,FALSE);\n";
		$nb=0;
 	}			
	$ligne++;
	$prec="";
}
print "}\n";
