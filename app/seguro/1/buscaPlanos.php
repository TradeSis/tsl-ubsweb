<?php

$progr = new chamaprogress();
$conteudoEntrada= json_encode($jsonEntrada);
    // echo "ENTRADA=".$conteudoEntrada;
      $retorno = $progr->executarprogress("seguro/1/buscaplanos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    //  echo "\nRETORNO=".$retorno ;

    //  $jsonSaida = json_decode($retorno, TRUE);
    //  echo "\nJSON=".$jsonSaida ;

      $jsonSaida  =  json_decode($retorno, TRUE);
