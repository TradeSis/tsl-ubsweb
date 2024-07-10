<?php
/*VERSAO 2 23062021*/

$progr = new chamaprogress();

if (isset($jsonEntrada)){

    $conteudoEntrada=json_encode(array('cliente' => array($jsonEntrada)));


}

  if(isset($conteudoEntrada)){
      $retorno = $progr->executarprogress("limites/1/cadastrar",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      //echo $retorno;
      $conteudo  =  json_decode($retorno, TRUE);
      //var_dump($conteudo);
      $jsonSaida = $conteudo["conteudoSaida"][0];
      if (!isset($jsonSaida)) {
        $jsonSaida = $conteudo["conteudoSaida"];
        if (!isset($jsonSaida)) {

             echo $retorno;

        }
      }



  } else {
    $jsonSaida = json_decode(json_encode(
     array("status" => 400,
         "retorno" => "conteudo JSON de entrada vazio")
       ), TRUE);

  }
