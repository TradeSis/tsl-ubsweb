<?php

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="consultar-lista-pep") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="consultar-listas-restritivas") {
    $funcao=$parametro;
    $parametro=null;
  }
}
switch ($funcao) {

  case "consultar-lista-pep":
    if (isset($jsonEntrada)){
       include 'consultar-lista-pep.php';
     } else {
       $jsonSaida = json_decode(json_encode(
        array("erro" => "400",
            "retorno" => "conteudo JSON vazio 1")
          ), TRUE);
     }
  break;
  case "consultar-listas-restritivas":
    if (isset($jsonEntrada)){
       include 'consultar-listas-restritivas.php';
     } else {
       $jsonSaida = json_decode(json_encode(
        array("erro" => "400",
            "retorno" => "conteudo JSON vazio 1")
          ), TRUE);
     }
  break;

   default:
       if ($metodo=="GET"){
           if (!isset($jsonEntrada)){
              if (isset($parametro)) {
                 //$parametro = $funcao;
                 $funcao = "consultar";
               } else {
                 $jsonSaida = json_decode(json_encode(
                  array("status" => 401,
                      "retorno" => "conteudo JSON vazio")
                    ), TRUE);
               }
           } else {
             $funcao = "consultar";
           }
        }

        if ($metodo=="POST"){
            if (isset($jsonEntrada)){
                  $funcao = "cadastrar";
                } else {
              $jsonSaida = json_decode(json_encode(
               array("status" => 402,
                   "retorno" => "conteudo JSON vazio")
                 ), TRUE);

            }
        }

      break;
}

if (!isset($jsonSaida)) {
    switch ($funcao) {
      case "cadastrar":
          if (isset($jsonEntrada)){
             include 'cadastrar.php';
           } else {
             $jsonSaida = json_decode(json_encode(
              array("status" => 400,
                  "retorno" => "conteudo JSON vazio")
                ), TRUE);
           }
      break;
      case "consultar":

        include 'consultar.php';

      break;

      default:
         $jsonSaida = json_decode(json_encode(
          array("status" => 400,
              "retorno" => "Aplicacaox " . $aplicacao . "Metodo ".$metodo. " Funcao  '".$funcao."'  Invalida")
            ), TRUE);
         break;
    }
}
