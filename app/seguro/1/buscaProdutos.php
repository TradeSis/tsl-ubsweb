<?php

$progr = new chamaprogress();

      $retorno = $progr->executarprogress("seguro/1/buscaprodutos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
      //echo $retorno ;
      $conteudo = json_decode($retorno, TRUE);
      $jsonSaida = $conteudo;
