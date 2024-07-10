<?php

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="buscaParametros") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="calculaSeguroPrestamista") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="calculaLoteSeguroPrestamista") {
    $funcao=$parametro;
    $parametro=null;
  }

} else {
  
    if ($parametro=="buscaSeguros") {
      $jsonEntrada= array("seguro" => array(array(
                                   "idSeguro" =>$funcao)));
      //var_dump($jsonEntrada);

      }
    

        $funcao=$parametro;
}
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


switch ($funcao) {

  case "buscaParametros":

            include 'buscaParametros.php';

 break;

 case "calculaSeguroPrestamista":
  if (isset($jsonEntrada)){
     include 'calculaSeguroPrestamista.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio 1")
        ), TRUE);
   }
break;

case "calculaLoteSeguroPrestamista":
  if (isset($jsonEntrada)){
     include 'calculaLoteSeguroPrestamista.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio calculaLoteSeguroPrestamista")
        ), TRUE);
   }
break;

   default:
      $jsonSaida = json_decode(json_encode(
       array("erro" => "400",
           "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida")
         ), TRUE);
      break;
}
