<?php


if ($versao==""){$versao="1";}

if (!isset($funcao)) {
  if ($parametro=="geraarquivo") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="imprimir") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="geraarquivommix") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="imprimirmmix") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaimpressoras") {
    $funcao=$parametro;
    $parametro=null;
  }
}

switch ($funcao) {
   case "buscaimpressoras":
      if ($metodo=="GET"){
         include 'buscaimpressoras.php';
      } else {
        $jsonSaida = json_decode(json_encode(
         array("erro" => "400",
             "retorno" => "Metodo Invalido")
           ), TRUE);
      }
    break;
       case "geraarquivo":
          if (isset($jsonEntrada)){
             include 'geraarquivo.php';
           } else {
             $jsonSaida = json_decode(json_encode(
              array("erro" => "400",
                  "retorno" => "conteudo JSON vazio")
                ), TRUE);
           }
   break;
   case "geraarquivommix":
      if (isset($jsonEntrada)){
        if ($metodo=="POST"){
           include 'geraarquivommix.php';
        } else {
          $jsonSaida = json_decode(json_encode(
           array("erro" => "400",
               "retorno" => "Metodo Invalido")
             ), TRUE);
        }

       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio")
            ), TRUE);
       }
       break;
   case "imprimir":
      if (isset($jsonEntrada)){
         include 'imprimir.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
  case "imprimirmmix":
     if (isset($jsonEntrada)){
        include 'imprimirmmix.php';
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
