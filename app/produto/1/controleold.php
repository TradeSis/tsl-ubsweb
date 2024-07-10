<?php

include "config.php";

switch ($versao) {

    case null:
      $parametro = null;
      if ($metodo=="GET"){
        $funcao = "consultar sem parametro";
        //$funcao    = "consultar";
      }
      if ($metodo=="POST"){
        $funcao    = "cadastrar";
      }

    break;

    default:
      $parametro = $versao;
      if (isset($funcao)){
        //
      } else {
        if ($metodo=="GET"){
          $funcao    = "consultar";
        }
        if ($metodo=="PUT"){
          $funcao    = "alterar";
        }

      }

    break;
}


switch ($funcao) {
  case "cadastrar":
      if (isset($jsonEntrada)){
         include 'cadastrar.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio")
            ), TRUE);
       }
  break;
  case "consultar":
    include 'consultar.php';
  break;
  case "pesquisar":

    if (isset($jsonEntrada)){
       include 'pesquisar.php';
     } else {
       $jsonSaida = json_decode(json_encode(
        array("erro" => "400",
            "retorno" => "conteudo JSON vazio")
          ), TRUE);
     }
  break;
  case "alterar":
      if (isset($jsonEntrada)){
         include 'alterar.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio")
            ), TRUE);
       }

  break;
  default:
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "Aplicacao " . $aplicacao . "Metodo ".$metodo. " Funcao  '".$funcao."'  Invalida")
        ), TRUE);
     break;
}
