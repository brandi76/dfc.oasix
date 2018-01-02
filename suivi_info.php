<?php
header("Access-Control-Allow-Origin: *");
error_reporting(E_ALL);

$bdd=mysqli_connect('195.114.27.208','web','admin','dfc');
$postdata = file_get_contents("php://input");
$param = json_decode($postdata);
//$param->action="get_section";
//$param->inode=0;
if ($param->action=="get_section"){
	$inode=$param->inode;
	$query = "SELECT data from bloc where inode='$inode'";
	$result = mysqli_query($bdd,$query);
	$outp='';
	$sep='';
	$row = mysqli_fetch_array($result);
	$outp ='{"records":['.$row[0].']}';
	echo($outp);
}

if ($param->action=="addsection"){	
	$section = $param->section;
	$section=addslashes($section);
	$type=$param->type;
	$query = "select min(inode) from inode where etat=0";
	$result = mysqli_query($bdd,$query);
	$row=mysqli_fetch_array($result);
	$inode=$row[0]+0;
	if ($inode<1){
		$query = "insert into inode (etat) values (0)";
		mysqli_query($bdd,$query);
		$query = "select min(inode) from inode where etat=0";
		$result = mysqli_query($bdd,$query);
		$row=mysqli_fetch_array($result);
		$inode=$row[0];				
	}	
	$query = "update inode set etat=1 where inode='$inode'";
	mysqli_query($bdd,$query);
	$pwd=$param->pwd;
	$row=",{\"nom\":\"$section\",\"inode\":\"$inode\",\"type\":\"$type\"}";
	$query = "update bloc set data=concat(data,'$row') where inode='$pwd'";
	mysqli_query($bdd,$query);
	$row="";
	if ($type=="d"){
		$row="{\"nom\":\"..\",\"inode\":\"$pwd\",\"type\":\"d\"}";
	}	
	$query = "insert ignore into bloc (inode,data,type) value ('$inode','$row','$type')";
	mysqli_query($bdd,$query);
	echo($inode);
}

if ($param->action=="addelem"){	
	$inode = $param->inode;
	$texte=$param->texte;
	$texte=addslashes($texte);
	$query = "update bloc set data=\"$texte\" where inode='$inode'";
	print $query;
	mysqli_query($bdd,$query);
}

if ($param->action=="modifelem"){	
	$inode = $param->inode;
	$query = "select data from bloc where inode='$inode'";
	//print $query;
	$result=mysqli_query($bdd,$query);
	$row = mysqli_fetch_array($result);
	//$row[0]="juju";
	$texte=json_encode($row[0]);
	$texte=str_replace('<',"\u003C",$texte);
	$texte=str_replace('>',"\u003E",$texte);
	$outp ='{"records":'.$texte.'}';
	//$outp ='{"records":"'.$inode.'"}';
	print $outp;
}

if ($param->action=="supsection"){
	$inode = $param->pwd;
	$inode_sup = $param->section;
	$type= $param->type;
	$query = "select data from bloc where inode='$inode_sup'";
	$result = mysqli_query($bdd,$query);
	$row=mysqli_fetch_array($result);
	$json='['.$row[0].']';
	if ((sizeof((array)(json_decode($json)))==1)||($type == '-')){
		$query = "select data from bloc where inode='$inode'";
		$result = mysqli_query($bdd,$query);
		$row=mysqli_fetch_array($result);
		$json='['.$row[0].']';
		$json_array=(array)(json_decode($json));
		$index=-1;
		for ($i=0;$i<sizeof($json_array);$i++){
			if ($json_array[$i]->inode==$inode_sup){
				$index=$i;
			}	
		}	
		unset($json_array[$index]);
		$json_array = array_values($json_array);
		$json=json_encode($json_array);
		$json=str_replace("[","",$json);
		$json=str_replace("]","",$json);
		$query = "update bloc set data='$json' where inode='$inode'";
		$result = mysqli_query($bdd,$query);
		$query = "delete from bloc where inode='$inode_sup'";
		$result = mysqli_query($bdd,$query);
		$query = "update inode set etat=0 where inode='$inode_sup'";
		$result = mysqli_query($bdd,$query);
	}
	else {print "non vide";}
	
//	print "$query";
}


?> 
