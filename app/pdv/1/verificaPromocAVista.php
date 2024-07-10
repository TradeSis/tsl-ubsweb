<?php
/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */


    $conteudoEntrada = json_encode($jsonEntrada);
   // var_dump($conteudoEntrada);
    
    $progr = new chamaprogress();

   $retorno = $progr->executarprogress("pdv/1/verificapromocavista",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
//  echo "\nRETORNO=".$retorno ;

  $jsonSaida  =  json_decode($retorno, TRUE);
