<?php
/*VERSAO 2 23062021*/

if (!isset($funcao)) {
  if ($parametro=="comportamento") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="limite") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="limite-bag") {
    $funcao=$parametro;
    $parametro=null;
  }
  

  if ($parametro=="acionaNeurotech") {
    $funcao=$parametro;
    $parametro=null;
  }
}

switch ($funcao) {
   case "comportamento":

   if ($metodo=="GET" && (isset($jsonEntrada) || isset($parametro)) ) {

   } else {
       $jsonSaida = json_decode(json_encode(
        array("status" => 405,
            "retorno" => "conteudo JSON vazio ou Metodo Invalido")
          ), TRUE);

   }

   break;
   case "limite":

    if ($metodo=="GET" && (isset($jsonEntrada) || isset($parametro)) ) {
 
    } else {
        $jsonSaida = json_decode(json_encode(
         array("status" => 405,
             "retorno" => "conteudo JSON vazio ou Metodo Invalido")
           ), TRUE);
 
    }
 
    break;
   case "limite-bag":

    if ($metodo=="GET" && (isset($jsonEntrada) || isset($parametro)) ) {
 
    } else {
        $jsonSaida = json_decode(json_encode(
         array("status" => 405,
             "retorno" => "conteudo JSON vazio ou Metodo Invalido")
           ), TRUE);
 
    }
 
    break;
    
 
   default:
       if ($metodo=="GET"){
           if (!isset($jsonEntrada)){
              if (!isset($funcao)&&isset($parametro)) {
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

        if ($metodo=="POST"||$metodo=="PUT"){

            if (!isset($jsonEntrada)){

               if (!isset($funcao)&&isset($parametro)) {
                  //$parametro = $funcao;
                  $funcao = "atualizar";
                } else {
                  $jsonSaida = json_decode(json_encode(
                   array("status" => 401,
                       "retorno" => "Parametro Nao Setado")
                     ), TRUE);
                }
            } else {
              if ($funcao=="acionaNeurotech") {
              //  $funcao=$parametro;
              //  $parametro=null;
              } else {
                  $funcao = "cadastrar";
            } }
        }

      break;
}

if (!isset($jsonSaida)) {
    switch ($funcao) {
      case "atualizar":
            include 'atualizar.php';
      break;
      case "consultar":

        include 'consultar.php';

      break;
      case "limite":

        include 'limite.php';

      break;

      case "limite-bag": /* 15042024 562981 - CARÊNCIA DE 15 DIAS PARA CLIENTES INADIMPLENTES ABRIREM A BAG */

        include 'limite-bag.php';

      break;
      

      case "comportamento":

           include 'comportamento.php';

      break;
      case "acionaNeurotech":

           include 'acionaNeurotech.php';

      break;

      case "alterar":
          if (isset($jsonEntrada)){
             include 'alterar.php';
           } else {
             $jsonSaida = json_decode(json_encode(
              array("status" => 400,
                  "retorno" => "conteudo JSON vazio")
                ), TRUE);
           }

      break;
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
      default:
         $jsonSaida = json_decode(json_encode(
          array("status" => 405,
              "retorno" => "Aplicacao " . $aplicacao . " Metodo ".$metodo. " Funcao  '".$funcao."'  Invalida")
            ), TRUE);
         break;
    }
}
