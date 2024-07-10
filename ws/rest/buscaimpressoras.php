<?php

$entrada = htmlspecialchars($_REQUEST['busca']);

include ("funcoes_v1701.inc");
include ("chamaprogress.php");

 
$jsonentrada=json_encode(array('entradas' => array(array( 
                        'entrada' => $entrada) 
                        )));

$progr = new chamaprogress(); 

header('Content-Type: application/json;charset=utf-8');

echo $progr->executarprogress("buscaimpressoras",$jsonentrada); 
        
?>
