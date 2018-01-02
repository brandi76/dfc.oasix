#!/usr/bin/perl

open(FILE,"inventario.csv");
@tab=<FILE>;
foreach (@tab) {
	($code,$qte)=split(/;/,$_);
	while($code=~s/ //){}
	print "$code\n$qte";
}

