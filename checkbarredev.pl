#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;

print $html->header();

if (&checkbarre(3348905600751)){print "ok";}

sub checkbarre {
	my($pr_codebarre)=$_[0];
	my($check)=$pr_codebarre%10;
	my($oper)=1;
	my($somme)=0;
	my($digit)=0;
	for (my($i)=12;$i>0;$i--){
		$digit=int($pr_codebarre/10**$i)%10;
		$somme+=$digit*$oper;
		if ($oper==1){$oper=3;}else{$oper=1;}
	}
	$somme%=10;
	$somme=(10-$somme)%10;
	print "$check $somme ";
	if ($check!=$somme){return(0);}else{return(1);}		
}