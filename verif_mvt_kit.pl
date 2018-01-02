#!/usr/bin/perl
require "../oasix/outils_perl2.pl";
require "../dfca.oasix/outils_corsica.pl";

$option=$html->param("option");
$four=$html->param("four");

$moins_0=$moins_25=$moins_50=$moins_6=$plus_0=$plus_25=$plus_50=$plus_6=$zero=0;
if ($option eq ""){
	print "<h4>Ecart stock Corsica</h4>";
	print "<form>";
	&form_hidden();
	print "Ecart inventaire debut fin d'année depot<br>";
	$datetime_debut='2016-01-04';
	$datetime_fin='2016-12-20';
	print "entre $datetime_debut et $datetime_fin<br>";
	print "Parfum dfc <input type=radio name=option value=1><br>";
	print "Parfum corse <input type=radio name=option value=2><br>";
	print "Divers <input type=radio name=option value=3><br>";
	print "Fournisseur (optionnel) <input type=texte name=four><br>";
	print "<input type=hidden name=action value=depot>";
	print "<input type=submit>";
	print "</form>";
	$datetime_debut='2016-01-04';
	$datetime_fin='2017-01-04';
	print "<form>";
	&form_hidden();
	print "Ecart inventaire debut fin d'année Ajaccio<br>";
	print "entre $datetime_debut et $datetime_fin<br>";
	print "Parfum dfc <input type=radio name=option value=1><br>";
	print "Parfum corse <input type=radio name=option value=2><br>";
	print "Divers <input type=radio name=option value=3><br>";
	print "Fournisseur (optionnel) <input type=texte name=four><br>";
	print "<input type=hidden name=action value=ajaccio>";
	print "<input type=submit>";
	print "</form>";
	$datetime_debut='2016-05-30';
	$datetime_fin='2017-01-03';
	print "<form>";
	&form_hidden();
	print "Ecart inventaire debut fin d'année Bastia<br>";
	print "entre $datetime_debut et $datetime_fin<br>";
	print "Parfum dfc <input type=radio name=option value=1><br>";
	print "Parfum corse <input type=radio name=option value=2><br>";
	print "Divers <input type=radio name=option value=3><br>";
	print "Fournisseur (optionnel) <input type=texte name=four><br>";
	print "<input type=hidden name=action value=bastia>";
	print "<input type=submit>";
	print "</form>";
}
if ($action eq "depot"){
	$entrepot="Depot";
	$datetime_debut='2016-01-04';
	$datetime_fin='2016-12-20';
	if ($option==1){$mes="Cosmetique dfc";}
	if ($option==2){$mes="Cosmetique corse";}
	if ($option==3){$mes="Divers";}
	$check=&get("select count(*) from corsica.enso where (date(es_dt)='$datetime_debut' or date(es_dt)='$datetime_fin') and (es_type=10 or es_type=5)")+0;
	if ($check>0){print "Donnée dans corsica.enso à la date d'inventaire<br>";}
	$check=&get("select count(*) from corsica.mouvement_b,corsica.mouvement_h where  livb_no=livh_id and livh_etat>0 and (livh_date_out='$datetime_debut' or livh_date_out='$datetime_fin')")+0;
	if ($check>0){print "Donnée dans mouvement à  la date d'inventaire<br>";}
	&save("create temporary table mvt_tmp (code bigint(13),depart int(8),in_ int(8),out_ int(8),fin int(8), primary key (code))");
	$query="select code,qte from corsica.inventaire_manu where date(date)='$datetime_debut' and qte!=0 and pdv='$entrepot' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,$qte,0,0,0)");
	}
	$query="select es_cd_pr,sum(es_qte_en)/100 from corsica.enso where es_dt>='$datetime_debut' and es_dt<='$datetime_fin' and es_type=10 group by es_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set in_=$qte where code=$code");
	}
	$query="select es_cd_pr,sum(es_qte)/100 from corsica.enso where es_dt>='$datetime_debut' and es_dt<='$datetime_fin' and es_type=5 group by es_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=$qte where code=$code");
	}
	$query="select code,sum(qte) from corsica.mouvement_b,corsica.mouvement_h where  livb_no=livh_id and livh_etat>0 and livh_date_out>='$datetime_debut' and livh_date_out<='$datetime_fin' and livh_out like '$entrepot' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=out_+$qte where code=$code");
	}
	$query="select code,sum(qte) from corsica.mouvement_b,corsica.mouvement_h where livb_no=livh_id and livh_etat>0 and livh_date_in>='$datetime_debut' and livh_date_in<='$datetime_fin' and livh_in like '$entrepot' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=out_-$qte where code=$code");
	}
	$query="select code,qte from corsica.inventaire_manu where date(date)='$datetime_fin' and qte!=0 and pdv='$entrepot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set fin=$qte where code=$code");
	}
	print "<h3>Depot</h3>";
	$total_depart=$total_in=$total_out=$total_fin=$total_ecart=0;
	print "<table border=1 cellspacing=0><tr><td>Code</td><td>corsica.produit</td><td>$datetime_debut</td><td>Entree</td><td>Sortie</td><td>$datetime_fin</td><td>Ecart</td><td>Prix achat</td><td>Valeur</td></tr>";
	$query="select * from mvt_tmp";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$depart,$in,$out,$fin)=$sth->fetchrow_array){
		($pr_desi,$pr_four)=&get("select pr_desi,pr_four from corsica.produit where pr_cd_pr='$code'");
		if (($four ne "")&&($pr_four != $four)){next;}
		$pr_prac=&prac_corsica($code);
		$famille=&get("select pr_famille from corsica.produit_plus where pr_cd_pr=$code");
		$local=&get("select fo2_identification from corsica.fournis inner join corsica.produit on pr_four=fo2_cd_fo where pr_cd_pr=$code")+0;
		if (($local==1)&&($option==1)){next;}
		if (($local==0)&&($option!=1)){next;}
		
		if ((($famille<1)or($famille>5))&&($option<3)){next;}
		if ($pr_prac==0){next;}
		if ((($famille>=1)and($famille<=5))&&($option==3)){next;}
		$fin_theo=$depart+$in-$out;
		$ecart=$fin-$fin_theo;
		$val=$pr_prac*$ecart;
		print "<tr><td>$code $local</td><td>$pr_desi</td><td align=right>$depart</td><td align=right>$in</td><td align=right>$out</td><td align=right>$fin</td><td align=right>$ecart</td><td align=right>$pr_prac</td><td align=right>$val</td></tr>";
		$total+=$val;
		$nb++;
		$total_depart+=$depart*$pr_prac;
		$total_in+=$in*$pr_prac;
		$total_out+=$out*$pr_prac;
		$total_fin+=$fin*$pr_prac;
		$total_ecart+=$ecart*$pr_prac;
		
		if ($ecart <-25){$moins_50+=1;}
		#if (($ecart >=-50)&&($ecart<-25)){$moins_25+=1;}
		if (($ecart >=-25)&&($ecart<-6)){$moins_6+=1;}
		if (($ecart >=-6)&&($ecart<0)){$moins_0+=1;}
		if ($ecart==0){$zero+=1;}
		if (($ecart >0)&&($ecart<=6)){$plus_0+=1;}
		if (($ecart >6)&&($ecart<=25)){$plus_6+=1;}
		#if (($ecart >25)&&($ecart<=50)){$plus_25+=1;}
		if (($ecart >25)){$plus_50+=1;}

	} 
	print "<tr><td colspan=2><strong>Total</strong></td><td align=right>$total_depart</td><td align=right>$total_in</td><td align=right>$total_out</td><td align=right>$total_fin</td><td align=right>$total_ecart</td></tr>";
	print "</table>";
	print "Total:$total";
}		

if ($action eq "ajaccio"){
	$total_depart=$total_in=$total_out=$total_fin=$total_ecart=0;
	$entrepot="Boutique1";
	$datetime_debut='2016-01-04';
	$datetime_fin='2017-01-04';
	if ($option==1){$mes="Cosmetique dfc";}
	if ($option==2){$mes="Cosmetique corse";}
	if ($option==3){$mes="Divers";}
	$check=&get("select count(*) from corsica.mouvement_b,corsica.mouvement_h where  livb_no=livh_id and livh_etat>0 and (livh_date_out='$datetime_debut' or livh_date_out='$datetime_fin')")+0;
	if ($check>0){print "Donnée dans mouvement à  la date d'inventaire<br>";}
	&save("create temporary table mvt_tmp (code bigint(13),depart int(8),in_ int(8),out_ int(8),fin int(8), primary key (code))");
	$query="select code,qte from corsica.inventaire_manu where date(date)='$datetime_debut' and qte!=0 and pdv='$entrepot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,$qte,0,0,0)");
	}
	$query="select code,sum(qte) from corsica.mouvement_b,corsica.mouvement_h where  livb_no=livh_id and livh_etat>0 and livh_date_out>='$datetime_debut' and livh_date_out<='$datetime_fin' and livh_out like '$entrepot' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=out_+$qte where code=$code");
	}
	$query="select code,sum(qte) from corsica.mouvement_b,corsica.mouvement_h where livb_no=livh_id and livh_etat>0 and livh_date_in>='$datetime_debut' and livh_date_in<='$datetime_fin' and livh_in like '$entrepot' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set in_=in_+$qte where code=$code");
	}
	$query="select code,sum(qte) from corsica.panier_caisse,corsica.ticket_caisse where pdv like 'Caisse 1%'  and ticket_pdv=pdv and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and addtime(ticket_date,ticket_heure)>='$datetime_debut'  and addtime(ticket_date,ticket_heure)<='$datetime_fin' and ticket_sup=0 and vendeuse!='sylvain' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=out_+$qte where code=$code");
	}
	
	$query="select code,qte from corsica.inventaire_manu where date(date)='$datetime_fin' and qte!=0 and pdv='$entrepot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set fin=$qte where code=$code");
	}
	print "<h3>Ajaccio</h3>";
	print "<table border=1 cellspacing=0><tr><td>Code</td><td>corsica.produit</td><td>$datetime_debut</td><td>Entree</td><td>Sortie</td><td>$datetime_fin</td><td>Ecart</td><td>Prix achat</td><td>Valeur</td></tr>";
	$query="select * from mvt_tmp";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$depart,$in,$out,$fin)=$sth->fetchrow_array){
		($pr_desi,$pr_four)=&get("select pr_desi,pr_four from corsica.produit where pr_cd_pr='$code'");
		if (($four ne "")&&($pr_four != $four)){next;}
		$pr_prac=&prac_corsica($code);
		$famille=&get("select pr_famille from corsica.produit_plus where pr_cd_pr=$code");
		$local=&get("select fo2_identification from corsica.fournis inner join corsica.produit on pr_four=fo2_cd_fo where pr_cd_pr=$code")+0;
		if (($local==1)&&($option==1)){next;}
		if (($local==0)&&($option!=1)){next;}
		
		if ((($famille<1)or($famille>5))&&($option<3)){next;}
		if ($pr_prac==0){next;}
		if ((($famille>=1)and($famille<=5))&&($option==3)){next;}
		$fin_theo=$depart+$in-$out;
		$ecart=$fin-$fin_theo;
		$val=$pr_prac*$ecart;
		print "<tr><td>$code $local</td><td>$pr_desi</td><td align=right>$depart</td><td align=right>$in</td><td align=right>$out</td><td align=right>$fin</td><td align=right>$ecart</td><td align=right>$pr_prac</td><td align=right>$val</td></tr>";
		$total+=$val;
		$nb++;
		$total_depart+=$depart*$pr_prac;
		$total_in+=$in*$pr_prac;
		$total_out+=$out*$pr_prac;
		$total_fin+=$fin*$pr_prac;
		$total_ecart+=$ecart*$pr_prac;
	
		if ($ecart <-25){$moins_50+=1;}
		#if (($ecart >=-50)&&($ecart<-25)){$moins_25+=1;}
		if (($ecart >=-25)&&($ecart<-6)){$moins_6+=1;}
		if (($ecart >=-6)&&($ecart<0)){$moins_0+=1;}
		if ($ecart==0){$zero+=1;}
		if (($ecart >0)&&($ecart<=6)){$plus_0+=1;}
		if (($ecart >6)&&($ecart<=25)){$plus_6+=1;}
		#if (($ecart >25)&&($ecart<=50)){$plus_25+=1;}
		if (($ecart >25)){$plus_50+=1;}
	 } 
	print "<tr><td colspan=2><strong>Total</strong></td><td align=right>$total_depart</td><td align=right>$total_in</td><td align=right>$total_out</td><td align=right>$total_fin</td><td align=right>$total_ecart</td></tr>";
	 print "</table>";
	 print "Total:$total";
}		
if ($action eq "bastia"){
	$total_depart=$total_in=$total_out=$total_fin=$total_ecart=0;
	$entrepot="Boutique2";
	$datetime_debut='2016-05-30';
	$datetime_fin='2017-01-03';
	if ($option==1){$mes="Cosmetique dfc";}
	if ($option==2){$mes="Cosmetique corse";}
	if ($option==3){$mes="Divers";}
	$check=&get("select count(*) from corsica.mouvement_b,corsica.mouvement_h where  livb_no=livh_id and livh_etat>0 and (livh_date_out='$datetime_debut' or livh_date_out='$datetime_fin')")+0;
	if ($check>0){print "Donnée dans mouvement à  la date d'inventaire<br>";}
	&save("create temporary table mvt_tmp (code bigint(13),depart int(8),in_ int(8),out_ int(8),fin int(8), primary key (code))");
	$query="select code,qte from corsica.inventaire_manu where date(date)='$datetime_debut' and qte!=0 and pdv='$entrepot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,$qte,0,0,0)");
	}
	$query="select code,sum(qte) from corsica.mouvement_b,corsica.mouvement_h where  livb_no=livh_id and livh_etat>0 and livh_date_out>='$datetime_debut' and livh_date_out<='$datetime_fin' and livh_out like '$entrepot' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=out_+$qte where code=$code");
	}
	$query="select code,sum(qte) from corsica.mouvement_b,corsica.mouvement_h where livb_no=livh_id and livh_etat>0 and livh_date_in>='$datetime_debut' and livh_date_in<='$datetime_fin' and livh_in like '$entrepot' group by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set in_=in_+$qte where code=$code");
	}
	$query="select code,sum(qte) from corsica.panier_caisse,corsica.ticket_caisse where pdv like 'Caisse 2%'  and ticket_pdv=pdv and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and addtime(ticket_date,ticket_heure)>='$datetime_debut'  and addtime(ticket_date,ticket_heure)<='$datetime_fin' and ticket_sup=0 and vendeuse!='sylvain' group by code";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
	   # if ($code==8435415001083){print "**** $qte ***";}
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set out_=out_+$qte where code=$code");
	}
	
	$query="select code,qte from corsica.inventaire_manu where date(date)='$datetime_fin' and qte!=0 and pdv='$entrepot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte)=$sth->fetchrow_array){
		&save("insert ignore into mvt_tmp values ($code,0,0,0,0)");
		&save("update mvt_tmp set fin=$qte where code=$code");
	}
	print "<h3>Bastia</h3>";
	print "<table border=1 cellspacing=0><tr><td>Code</td><td>corsica.produit</td><td>$datetime_debut</td><td>Entree</td><td>Sortie</td><td>$datetime_fin</td><td>Ecart</td><td>Prix achat</td><td>Valeur</td></tr>";
	$query="select * from mvt_tmp";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$depart,$in,$out,$fin)=$sth->fetchrow_array){
		($pr_desi,$pr_four)=&get("select pr_desi,pr_four from corsica.produit where pr_cd_pr='$code'");
		if (($four ne "")&&($pr_four != $four)){next;}
		$pr_prac=&prac_corsica($code);
		$famille=&get("select pr_famille from corsica.produit_plus where pr_cd_pr=$code");
		$local=&get("select fo2_identification from corsica.fournis inner join corsica.produit on pr_four=fo2_cd_fo where pr_cd_pr=$code")+0;
		if (($local==1)&&($option==1)){next;}
		if (($local==0)&&($option!=1)){next;}
		
		if ((($famille<1)or($famille>5))&&($option<3)){next;}
		if ($pr_prac==0){next;}
		if ((($famille>=1)and($famille<=5))&&($option==3)){next;}
		$fin_theo=$depart+$in-$out;
		$ecart=$fin-$fin_theo;
		$val=$pr_prac*$ecart;
		print "<tr><td>$code $local</td><td>$pr_desi</td><td align=right>$depart</td><td align=right>$in</td><td align=right>$out</td><td align=right>$fin</td><td align=right>$ecart</td><td align=right>$pr_prac</td><td align=right>$val</td></tr>";
		$total+=$val;
		$nb++;
		$total_depart+=$depart*$pr_prac;
		$total_in+=$in*$pr_prac;
		$total_out+=$out*$pr_prac;
		$total_fin+=$fin*$pr_prac;
		$total_ecart+=$ecart*$pr_prac;
	
		if ($ecart <-25){$moins_50+=1;}
		#if (($ecart >=-50)&&($ecart<-25)){$moins_25+=1;}
		if (($ecart >=-25)&&($ecart<-6)){$moins_6+=1;}
		if (($ecart >=-6)&&($ecart<0)){$moins_0+=1;}
		if ($ecart==0){$zero+=1;}
		if (($ecart >0)&&($ecart<=6)){$plus_0+=1;}
		if (($ecart >6)&&($ecart<=25)){$plus_6+=1;}
		#if (($ecart >25)&&($ecart<=50)){$plus_25+=1;}
		if (($ecart >25)){$plus_50+=1;}
	} 
	print "<tr><td colspan=2><strong>Total</strong></td><td align=right>$total_depart</td><td align=right>$total_in</td><td align=right>$total_out</td><td align=right>$total_fin</td><td align=right>$total_ecart</td></tr>";
	print "</table>";
	print "Total:$total";

}		

if ($option ne ""){
	$bon=int($zero*100/$nb);
	print " Pourcentage de produits sans erreur :$bon %<br>";

print <<EOF;
  <script type="text/javascript" src="/bower_components/jquery/dist/jquery.js"></script>
<script type='text/javascript'>

\$(function () {
Highcharts.chart('container', {
        chart: {
            type: 'column',
        },
        title: {
            text: '$troltype ratio ecart' ,
        },
       xAxis: {
            categories: [
                '>-25',
                'entre -25 et -6',
                'entre -6 et zero',
                'zero',
                'entre zero et +6',
                'entre 6 et 25',
                '>25',
            ],
            crosshair: true
        },
		plotOptions: {
            column: {
                dataLabels: {
                    enabled: true
                }
            }
        },
		yAxis: {
            min: 0,
            title: {
                text: 'Nombre de piece en ecart sur 1 an'
            }
        },
        series: [{
			name: '$mes',
            data: [
EOF
	$pour=$moins_50;
	print "$pour,";
	$pour=$moins_6;
	print "$pour,";
	$pour=$moins_0;
	print "$pour,";
	$pour=$zero;
	print "$pour,";
	$pour=$plus_0;
	print "$pour,";
	$pour=$plus_6;
	print "$pour,";
	$pour=$plus_50;
	print "$pour]";

print <<EOF;			
        }]
    });
});


</script>

  

  <script src="/bower_components/highcharts/highcharts.js"></script>
<script src="/bower_components/highcharts/modules/exporting.js"></script>
<script src="/bower_components/highcharts/highcharts-more.js"></script>
<script src="/bower_components/highcharts/modules/diti.js"></script>

<div id="container" style="min-width: 310px; max-width: 100%; margin: 0 auto"></div>
EOF

 
}
;1