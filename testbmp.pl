#!/usr/bin/perl
use CGI;

open (FILE, "<caddie.bmp");
@file=<FILE>;
print $#file;
