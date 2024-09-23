<?php


//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="verificaCreditoVenda") {
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

case "verificaCreditoVenda":
  if (isset($jsonEntrada)){
     include 'verificaCreditoVenda.php';
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
