<?php

include ("/u/bsweb/progr/php/funcoes_v1701.inc");

$POR=getvar('POR');
$IP=getvar('REMOTE_ADDR');
$IP=$_SERVER["REMOTE_ADDR"];


//
$FILIAL =getvar('FILIAL') ;

        include ("neurotech.php");

        $parametro="POR=".$POR."&IP=".$IP."&FILIAL=".$FILIAL."&PARAMETROS=".getvar('parametro');
        $neurotech = new neurotech();
        $array = $neurotech->executarprogress("neuproposta",$parametro);
        echo json_encode($array);

?>
