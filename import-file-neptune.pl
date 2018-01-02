<?php


# initialisation des variables

error_reporting(E_ALL ^ E_NOTICE);

global $HTTP_GET_VARS ;
$fichier=$HTTP_POST_VARS['fichier'];

print "<body bgcolor=white text=black alink=black vlink=black link=black><center>";
?>
Importation d'un fichier csv des ventes neptune<br>
Creer un fichier dans excel avec cles zones le sauvegarder au format csv puis l'importer ici<br>
<?
$link = mysql_pconnect("192.168.1.87", "root", "") or die("Could not connect");
mysql_select_db("FLY") or die("Could not select database");
?>
<form enctype="multipart/form-data" method="POST">

<input name=file type=file ><br>
<input type=submit>
</form>

<?
$navire="MEGA 1";
$date="2005-07-24";

if ($handle = fopen($_FILES["file"]["tmp_name"], "r")){
	
	while ($ligne=fgets($handle,10000)){
		# print "$ligne<br>";
		$col=explode(";",$ligne);
		# print count($col)."<br>";
	
		$query="select nep_codebarre,pr_desi from neptune,produit where nep_cd_pr='$col[0]' and nep_codebarre=pr_cd_pr";
		# print "$query<br>";
		$result = mysql_query($query) or die("Query failed $query");
		$row=mysql_fetch_row($result);
		if ($row[0]==""){
			$barre="-";
			if ($col[0]==348){$barre=3360372061823;}
			if ($col[0]==7347){$barre=3595200501138;}
			$query="select pr_cd_pr from produit where pr_cd_pr='$barre'";
			$result = mysql_query($query) or die("Query failed $query");
			$row=mysql_fetch_row($result);
			if ($row[0]==""){
				print "<font color=red>".$col[0]." ".$col[1]."</font><br>";
			}
			else
			{
			print "<font color=black>".$col[0]." ".$col[1]."</font><br>";
				}
		}
		else{
			print "<font color=black>".$col[0]." ".$col[1]."</font><br>";
		}
		# $query="select nav_qte from navire2 where nav_nom='$nom' and nav_cd_pr='$produit' and nav_type=2 and nav_date='$date'";
		# $result = mysql_query($query) or die("Query failed $query");
		# $row=mysql_fetch_row($result);
		

	
		# $query="replace into $fichier values (";

		# for ($i=0;$i<count($col);$i++){
			
		#	$query.="'".ereg_replace("\"","",$col[$i])."',";
		# }
		# $query=ereg_replace(",$","",$query);
		
		# $query.=")";
		# print "$query<br>";
		# $result = mysql_query($query) or die("Query failed $query");
	}
}
# -E importation d'un format csv pour un  fichier de vente neptune
?>
