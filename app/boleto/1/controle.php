<?php

if (!isset($funcao)) {
  if ($parametro=="nossoNumero") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="incluirBoletoParcela") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="barramentoEmitir") {
    $funcao=$parametro;
    $parametro=null;
  }
  
}

switch ($funcao) {
   case "nossoNumero":
      if (isset($jsonEntrada)){
         include 'nossoNumero.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio")
            ), TRUE);
       }
    break;
       case "incluirBoletoParcela":
          if (isset($jsonEntrada)){
             include 'incluirBoletoParcela.php';
           } else {
             $jsonSaida = json_decode(json_encode(
              array("erro" => "400",
                  "retorno" => "conteudo JSON vazio")
                ), TRUE);
           }
   break;
   case "barramentoEmitir":
      if (isset($jsonEntrada)){
         include 'barramentoEmitir.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
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
