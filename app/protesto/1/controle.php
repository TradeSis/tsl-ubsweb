<?php

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="buscaParametros") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="selecionaParcelas") {
    $funcao=$parametro;
    $parametro=null;
  } 
  if ($parametro=="ieproBuscaArquivos") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="ieproEnviaRemessa") {
    $funcao=$parametro;
    $parametro=null;
  }
 
}
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


switch ($funcao) {

  case "selecionaParcelas":

            include 'selecionaParcelas.php';

 break;

 case "ieproBuscaArquivos":
  if (isset($jsonEntrada)){
     include 'ieproBuscaArquivos.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio 1")
        ), TRUE);
   }
break;
case "ieproEnviaRemessa":
  if (isset($jsonEntrada)){
     include 'ieproEnviaRemessa.php';
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
