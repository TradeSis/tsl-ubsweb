<?php

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="buscaTermos") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaRascunho") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaTermoTeste") {
    $funcao=$parametro;
    $parametro=null;
  }
  
} else {
    $aux=$parametro;
    $parametro=$funcao;
    $funcao=$aux;
}
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


switch ($funcao) {
   case "buscaTermos":
      if (isset($jsonEntrada)){
         include 'buscaTermos.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio buscaTermos")
            ), TRUE);
       }
  break;
   case "buscaRascunho":
      if (isset($jsonEntrada)){
         include 'buscaRascunho.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio buscaRascunho")
            ), TRUE);
       }
  break;
   case "buscaTermoTeste":
      if (isset($jsonEntrada)){
         include 'buscaTermoTeste.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio buscaTermoTeste")
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
