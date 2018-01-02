#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;
&tete("VERIF CA");

open(FILE2,"/var/spool/uucppublic/fly/caisse.txt");
@caisse_dat=<FILE2>;
close(FILE2);

# %vente_idx = &get_index_num("fly/caisse",0);
close(FILE2);
foreach (@caisse_dat) {
	($ca_code,$ca_rot,$ca_fly,$ca_pnc)=split(/;/,$_);
	print "$ca_code $ca_rot  $v_ca  $v_dest <br>";
	}

# -E verification des vol