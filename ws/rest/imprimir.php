<?php
include ("funcoes_v1701.inc");
include ("chamaprogress.php");

$jsonentrada = getvar('jsonDados');

$progr = new chamaprogress(); 

echo $progr->executarprogress("imprimir",$jsonentrada); 
         
?>

