<?php

include ("/u/bsweb/progr/php/funcoes_v1701.inc");

$POR=getvar("POR");
$IP=getvar("REMOTE_ADDR");

$IP=$_SERVER["REMOTE_ADDR"];

//
$LOJA = '';

include ("bszoom.php");

	$novoparametro="IP=".$IP."&POR=".$POR;

        $bszoom = new bszoom();
        $array = $bszoom->executarprogress("estab",$novoparametro);
        $array2 = $array["rows"]; 
        echo json_encode($array2);

?>
