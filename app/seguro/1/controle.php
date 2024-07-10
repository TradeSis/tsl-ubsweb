<?php

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="buscaSeguros") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaPerfil") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaProdutos") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaAdesao") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaPlanos") {
    $funcao=$parametro;
    $parametro=null;
  }

} else {
  //{"seguro":[{"idSeguro":"6"}]}
    if ($parametro=="buscaSeguros") {
      $jsonEntrada= array("seguro" => array(array(
                                   "idSeguro" =>$funcao)));
      //var_dump($jsonEntrada);

      }
      if ($parametro=="buscaPerfil") {
        $jsonEntrada= array("perfil" => array(array(
                                     "idPerfil" =>$funcao)));
        //var_dump($jsonEntrada);

        }
        /*if ($parametro=="buscaPlanos") {
          $jsonEntrada= array("planos" => array(array(
                                       "filial" =>$funcao)));
          //var_dump($jsonEntrada);

        }*/

        $funcao=$parametro;
}
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


switch ($funcao) {
   case "buscaSeguros":
      if (isset($jsonEntrada)){
         include 'buscaSeguros.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
  case "buscaPerfil":
     if (isset($jsonEntrada)){
        include 'buscaPerfil.php';
      } else {
        $jsonSaida = json_decode(json_encode(
         array("erro" => "400",
             "retorno" => "conteudo JSON vazio 2")
           ), TRUE);
      }
  break;
  case "buscaAdesao":
     if (isset($jsonEntrada)){
        include 'buscaAdesao.php';
      } else {
        $jsonSaida = json_decode(json_encode(
         array("erro" => "400",
             "retorno" => "conteudo JSON vazio 3")
           ), TRUE);
      }
  break;
  case "buscaProdutos":

            include 'buscaProdutos.php';

 break;
 case "buscaPlanos":
    if (isset($jsonEntrada)){
       include 'buscaPlanos.php';
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
