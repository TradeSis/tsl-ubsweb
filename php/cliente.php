<?php
        /* Biblioteca Funcoes Basicas PHP */
         include("/u/bsweb/progr/php/funcoes.inc");


	$ws = getvar('servidor');
        $xmlEntrada = getvar('xml');
        $chamar     = getvar('chamar');
              
        $saida = RodaWebServices($ws,$chamar,$xmlEntrada);
        echo $saida; 
?>
