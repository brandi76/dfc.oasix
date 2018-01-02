@base_afrique=("corsica","cameshop");

print <<EOF;
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	<style>
            
            /* Position et couleur bulle */
            a span{ 
                position:absolute;
                margin-top:25px; 
                margin-left:-25px;
                color:#fff; 
                background:rgba(0, 0, 0, 0.5); 
                padding:25px; 
                border-radius:3px; 
                
                /* Faire disparaire infobulle par défaut */
                /* On determine l'origine de la rotation */ 
                transform:scale(0) rotate(-180deg);
                /* Faire durer l'effet */
                transition:all .25s;
                /* Effet sur la transparence */ 
                opacity:0;
            }
            
            /* Apparition de la bulle avec le scale à 1 */ 
            a:hover span, a:focus span{ 
                transform:scale(1) rotate(0);
                /* Effet sur la transparence */ 
                opacity:1;
            }
        
        </style>  
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
$ajust=$html->param("ajust");
if ($ajust eq ""){$ajust=87.50;}
$maxi=&get("select month(curdate())");
$an=&get("select year(curdate())");
if ($action eq "rentree"){
	$base=$html->param("base");
	for ($mois=1;$mois<=$maxi;$mois++){
		$montant=$html->param("$mois");
		&save("replace into rentree value ('$base','$an','$mois','$montant')","af");
	}
}
# &save("create temporary table cde_tmp (base varchar(20),four int(8),id int(8),facture varchar(30),date_entree date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2))");
&save("truncate table cde_tmp");
$query="select * from livraison_h where livh_date >='2015-06-01' order by livh_date_facture";
$sth=$dbh->prepare($query);
$sth->execute();
$total=0;
while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
	$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
	if (&get("select year(adddate('$livh_date_facture',$fo_delai))")+0<$an){next;};
	$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	$montant=int($montant*100)/100;
	$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	$montant+=$frais;
#	$reglement=&get("select sum(montant) from dfc.reglement where reg_id='$livh_id'")+0;
#	if ($reglement==$montant){next;}
	$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'");
	if ($date_entree eq ""){$date_entree="0000-00-00";}else{
		$date_entree=&julian($date_entree,"YYYY-MM-DD");}
	if ($livh_base eq "corsica"){
		$local=&get("select fo2_identification from corsica.fournis where fo2_cd_fo='$livh_four'");
		if ($local==1){next;}
	}	
	&save("insert into cde_tmp values ('$livh_base','$livh_four','$livh_id','$livh_facture','$date_entree',adddate('$livh_date_facture','$fo_delai'),'$montant','$fo_delai','$reglement')","af");
}


&save("create  temporary table if not exists situation_tmp (type char(2),base varchar(20),mois int(5), entree int(10), sortie int(10),vfly int(10),stim int(10),com int(10),chargement int(10),ecart int(10))");
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	$base_client_code=&get("select v_cd_cl from $client.vol order by v_date_sql desc limit 1");
    $query="select cl_nom,cl_com1/100,cl_com2/100 from $client.client where cl_cd_cl='$base_client_code'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
    $cl_com1=int($cl_com1*100)/100;
	for ($mois=1;$mois<=$maxi;$mois++){
		$mois_ca=$mois-1;
		$an_ca=$an;
		if ($mois_ca==0){$mois_ca=12;$an_ca=$an-1;}
		$ca=0;
		&ca();
		# $ca=&get("select sum(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_ca and month(v_date_sql)='$mois_ca'","af");
		# $achat=&get("select sum(es_qte*pr_prac/10000) from enso_$client where year(es_dt)=$an and month(es_dt)='$mois'");
		$achat=&get("select sum(montant) from cde_tmp where base='$client' and year(date_echance)=$an and month(date_echance)='$mois'")+0;
		&save("insert ignore into situation_tmp values ('AE','$client','$mois','$ca','$achat','$total_vfly','$total_stim','$total_com','$total_chargement','$total_ecart')","af");
	}
}
##### BOUTIQUE 
foreach $client (@base_afrique){
	for ($mois=1;$mois<=$maxi;$mois++){
		$mois_ca=$mois-1;
		$an_ca=$an;
		if ($mois_ca==0){$mois_ca=12;$an_ca=$an-1;}
		$ca=0;
		$total_vfly=0;
		$total_com=0;
		$total_chargement=0;
		$total_ecart=0;
		$achat=&get("select sum(montant) from cde_tmp where base='$client' and year(date_echance)=$an and month(date_echance)='$mois'")+0;
		&save("insert ignore into situation_tmp values ('BO','$client','$mois','$ca','$achat','$total_vfly','$total_stim','$total_com','$total_chargement','$total_ecart')","af");
	}
}

print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
print "<thead>";
print "<tr style=font-size:0.8em class=\"info\">";
print "<th colspan=2><h3>Aérien</h3></th>";
	
for ($mois=1;$mois<=$maxi;$mois++){
	print "<th>".&cal($mois)."</th>";
}
print "</tr>";
print "</thead>";
	
$lib="Rentrées";
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print "<tr><td>$lib</td><td>$client</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		# $in=&get("select entree from situation_tmp where base='$client' and mois='$mois'")+0;
		$query="select entree,vfly,stim,com,chargement,ecart from situation_tmp where base='$client' and mois='$mois'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($entree,$vfly,$stim,$com,$chargement,$ecart)=$sth->fetchrow_array;
		print "<td align=right><a href=# style=color:black;text-decoration:none>$entree<span>Ca:$vfly<br>Stim:$stim<br>Com:$com<br>Cout:$chargement<br>Ecart:$ecart</span></a></td>";
	}	
	print "</tr>";
}

print "<tr style=font-weight:bold><td></td><td>Total</td>";
for ($mois=1;$mois<=$maxi;$mois++){
	$in=&get("select sum(entree) from situation_tmp where mois='$mois' and type='AE'")+0;
	print "<td align=right>$in</td>";
}	
print "</tr>";
print "<tr style=font-weight:bold><td>Ajustement</td><td><form>";
&form_hidden();
print "<input type=text name=ajust value=$ajust> <input type=submit value=maj></form></td>";
for ($mois=1;$mois<=$maxi;$mois++){
	$in=&get("select sum(entree*$ajust/100) from situation_tmp where mois='$mois' and type='AE'");
	$in=int($in);
	print "<td align=right>$in</td>";
}	
print "</tr>";

### ACHAT ###
$lib="Sorties";
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print "<tr><td>$lib</td><td>$client</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		$out=&get("select sortie from situation_tmp where base='$client' and mois='$mois' and type='AE'")+0;
		print "<td align=right>$out</td>";
	}	
	print "</tr>";
}
print "<tr style=font-weight:bold><td></td><td>Total</td>";
for ($mois=1;$mois<=$maxi;$mois++){
	$out=&get("select sum(sortie) from situation_tmp where mois='$mois' and type='AE'")+0;
	print "<td align=right>$out</td>";
}
$lib="Frais fixes";
print "<tr><td>$lib</td><td></td>";
$lib="&nbsp;";
for ($mois=1;$mois<=$maxi;$mois++){
	print "<td align=right>40000</td>";
}	
print "</tr>";

$lib="Tresorerie mensuelle";
print "<tr><td>$lib</td><td>&nbsp;</td>";
$lib="&nbsp;";
for ($mois=1;$mois<=$maxi;$mois++){
	$in_out=&get("select sum(entree*$ajust/100-sortie) from situation_tmp where mois='$mois' and type='AE'")-40000;
	$in_out=int($in_out);
	print "<td align=right>$in_out</td>";
}	
print "</tr>";
$lib="Tresorerie cumulée";
print "<tr><td>$lib</td><td>&nbsp;</td>";
$lib="&nbsp;";
$in_out=0;
for ($mois=1;$mois<=$maxi;$mois++){
	$in_out+=&get("select sum(entree*$ajust/100-sortie) from situation_tmp where mois='$mois' and type='AE'")-40000;
	$in_out=int($in_out);
	print "<td align=right>$in_out</td>";
}	
print "</tr>";
$lib="Stock à financer";

foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print "<tr><td>$lib</td><td>$client</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		$mois_1=$mois-1;
		$an_1=$an;
		if($mois_1==0){$mois_1=12;$an_1-=1;}
		$stck=&get("select sum(qte*prac) from stock_mensuel where base='$client' and date=last_day('$an_1-$mois_1-01')")+0;
		$stck=int($stck);
		$achat=&get("select sum(montant) from cde_tmp where base='$client' and date_entree>'2012-01-01' and date_entree<=last_day('$an_1-$mois_1-01') and date_echance>last_day('$an_1-$mois_1-01')" )+0;
		$achat=int($achat);
		$stck_a=int($stck-$achat);
		print "<td align=right><a href=# style=color:black;text-decoration:none>$stck_a<span>Stock:$stck<br>Stock non à échéance:$achat</a></td>";
		$stock_echeance[$mois]+=$stck_a;
	}	
	print "</tr>";
}
print "<tr style=font-weight:bold><td></td><td>Total</td>";
for ($mois=1;$mois<=$maxi;$mois++){
	print "<td align=right>";
	print $stock_echeance[$mois];
	print "</td>";
}

print "</tr>";
print "</table>";

################ CORSICA CAMESHOP###################

foreach $client (@base_afrique){
	$frais=0;
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th colspan=2><h3>";
	print ucfirst($client);
	print "</h3></th>";
		
	for ($mois=1;$mois<=$maxi;$mois++){
		print "<th>".&cal($mois)."</th>";
	}
	print "</tr>";
	print "</thead>";
		
	$lib="Rentrées";
	print "<form>";
	&form_hidden();
	print "<input type=hidden name=action value=rentree>";
	print "<input type=hidden name=base value=$client>";
	print "<tr><td>Rentrées <input type=submit value=maj></td><td>$client</td>";
	for ($mois=1;$mois<=$maxi;$mois++){
		$val=&get("select montant from rentree where base='$client' and an=$an and mois=$mois")+0;
		print "<td align=right><input name=$mois value=$val size=2></td>";
	}
	print "</tr>";	
	print "</form>";

	$lib="Sorties corses";
	print "<tr><td>$lib</td><td>$client</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		$out=&get("select sortie from situation_tmp where base='$client' and mois='$mois'")+0;
		print "<td align=right>$out</td>";
	}	
	print "</tr>";
	$lib="Frais fixes";
	print "<tr><td>$lib</td><td>&nbsp;</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		print "<td align=right>$frais</td>";
	}	
	print "</tr>";

	$lib="Tresorerie mensuelle";
	print "<tr><td>$lib</td><td>&nbsp;</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		$in_out=&get("select sum(rentree.montant-sortie) from situation_tmp,rentree where situation_tmp.mois='$mois' and situation_tmp.base='$client' and  rentree.an=$an and situation_tmp.mois=rentree.mois and situation_tmp.base=rentree.base")-$frais;
		$in_out=int($in_out);
		print "<td align=right>$in_out</td>";
	}	
	print "</tr>";
	$lib="Tresorerie cumulée";
	print "<tr><td>$lib</td><td>&nbsp;</td>";
	$lib="&nbsp;";
	$in_out=0;
	for ($mois=1;$mois<=$maxi;$mois++){
		$in_out+=&get("select sum(rentree.montant-sortie) from situation_tmp,rentree where situation_tmp.mois='$mois' and situation_tmp.base='$client' and  rentree.an=$an  and  situation_tmp.mois=rentree.mois and situation_tmp.base=rentree.base")-$frais;
		$in_out=int($in_out);
		print "<td align=right>$in_out</td>";
	}	
	print "</tr>";
	$lib="Stock à financer";
	print "<tr><td>$lib</td><td>$client</td>";
	$lib="&nbsp;";
	for ($mois=1;$mois<=$maxi;$mois++){
		$mois_1=$mois-1;
		$an_1=$an;
		if($mois_1==0){$mois_1=12;$an_1-=1;}
		$stck=&get("select sum(qte*prac) from stock_mensuel where base='$client' and date=last_day('$an_1-$mois_1-01')","af")+0;
		# print "$stck<br>";
		$stck=int($stck);
		$achat=&get("select sum(montant) from cde_tmp where base='$client' and date_entree>'2012-01-01' and date_entree<=last_day('$an_1-$mois_1-01') and date_echance>last_day('$an_1-$mois_1-01')","af" )+0;
		$achat=int($achat);
		$stck_a=int($stck-$achat);
		print "<td align=right><a href=# style=color:black;text-decoration:none>$stck_a<span>Stock:$stck<br>Stock non à échéance:$achat</a></td>";
		$stock_echeance[$mois]+=$stck_a;
	}	
	print "</tr>";
	print "</table>";
}

print "		
		</div>
	</div>
</div>";

sub ca{
	$query="select v_code from $client.vol where v_cd_cl='$base_client_code' and year(v_date_sql)=$an_ca and month(v_date_sql)='$mois_ca' and v_rot=1 and v_troltype>100 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total_ca_com=0;
	$total_ca_marge=0;
	$total_chargement=0;
	$total_stim=0;
	$total_vfly=0;
	$total_ecart=0;
	$nbvol=0;
	while (($v_code)=$sth->fetchrow_array){
		$ca_papi=&get("select sum(ca_papi) from $client.caissesql where ca_code='$v_code' group by ca_code");
		$total_stim+=$ca_papi;
		$ca_recettes=&get("select sum(ca_total) from $client.caissesql where ca_code='$v_code' group by ca_code");
		$ca_fly=&get("select sum(ca_fly/100) from $client.caisse where ca_code='$v_code' group by ca_code");
		$total_vfly+=$ca_fly;
 	 	$total_ecart+=$ca_recettes-$ca_fly;
	}
	$total_com=($total_vfly-$total_stim)*$cl_com1/100;
	&cout();
	$ca=$total_vfly-$total_stim-$total_com-$total_chargement+$total_ecart;
	# print "$client $mois_ca $total_vfly<br>";
	# &save("insert into situation_tmp values ('$base','$total_vfly','$total_stim','$total_com','$total_ca_com','$nbvol','$total_chargement','$total_ecart')","af"); 
}
sub cout{
	%total=();
	$total_ca=0;
	$query="select v_code,v_vol,v_dest,v_date,v_troltype from $client.vol  where v_cd_cl='$base_client_code' and year(v_date_sql)=$an_ca and month(v_date_sql)='$mois_ca' and v_rot=1 and v_code >0 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$v_troltype)=$sth->fetchrow_array){
		$ca=&get("select sum(ca_total) from $client.caissesql where ca_code='$v_code'")+0;
		$cout=&get("select lot_cout from $client.lot where lot_nolot='$v_troltype'")+0;
		if ($ca!=0){$total{$cout}++;}
		$total_ca+=$ca;
	}
	foreach $cle (keys %total){
	  $px_total=$cle*$total{$cle};
	  $total_chargement+=$px_total;
	}
	$com=0;
	if ($base eq "togo"){$com=2;}
	if (($base eq "togo")&&($annee==14)){$com=1;}
	if ($base eq "camairco"){$com=1;}
	if ($com!=0){
	  $com=$com*$total_ca/100;
	  $total_chargement+=$com;
	}
}

;1
