<?php

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="simular") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="simular-v2") {
    $funcao=$parametro;
    $parametro=null;
  }
  
  if ($parametro=="buscaPlanos") {
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
   case "simular":
      if (isset($jsonEntrada)){
         include 'simular.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
   case "simular-v2":
      if (isset($jsonEntrada)){
         include 'simular-v2.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
  

  case "buscaPlanos":
   
       include 'buscaPlanos.php';
   
break;


   default:
      $jsonSaida = json_decode(json_encode(
       array("erro" => "400",
           "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida")
         ), TRUE);
      break;
}
