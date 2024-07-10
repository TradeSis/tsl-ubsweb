<?php

$produto = htmlspecialchars($_REQUEST['produto']);

include ("funcoes_v1701.inc");
include ("chamaprogress.php");

 
$jsonentrada=json_encode(array('produtos' => array(array( 
                        'produto' => $produto) 
                        )));

$progr = new chamaprogress(); 

echo $progr->executarprogress("buscaproduto",$jsonentrada); 
        
?>
