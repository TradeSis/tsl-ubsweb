<?php
/*VERSAO 2 23062021*/

$progr = new chamaprogress();

if (isset($jsonEntrada)){

  $conteudo = json_decode(json_encode($jsonEntrada["dadosEntrada"]));

  if (isset($conteudo)) {
    $conteudoEntrada=json_encode(array('clientes' => array(array(
                            'cpfCnpj' => $conteudo->cpfCliente)
                            )));
  } else {
    $conteudo = json_decode(json_encode($jsonEntrada));

    $conteudoEntrada=json_encode(array('clientes' => array(array(
                            'cpfCnpj' => $conteudo->cpfCliente)
                            )));

  }


} else {
  $conteudoEntrada=json_encode(array('clientes' => array(array(
                          'cpfCnpj' => $parametro)
                          )));
}



  if(isset($conteudoEntrada)){
      $retorno = $progr->executarprogress("limites/1/limite",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
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
