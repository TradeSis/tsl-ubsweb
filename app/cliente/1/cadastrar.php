<?php


$progr = new chamaprogress();



  $conteudo = json_decode(json_encode($jsonEntrada["cliente"]));

  if (isset($conteudo)) {
      $conteudoEntrada=json_encode(array('clienteEntrada' => $jsonEntrada));
  } else {

    $conteudoEntrada=null;

  }



  if(isset($conteudoEntrada)){
      $retorno = $progr->executarprogress("cliente/1/cadastrar",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    //  echo $retorno;
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
         "retorno" => "conteudo JSON invalido")
       ), TRUE);

  }
