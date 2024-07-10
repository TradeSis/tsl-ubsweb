<?php
/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */


//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="consultaCliente") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="atualizacaoDadosCliente") {
    $funcao=$parametro;
    $parametro=null;
  }
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

  case "consultaCliente":
    if (isset($jsonEntrada)){
       include 'consultaCliente.php';
     } else {
       $jsonSaida = json_decode(json_encode(
        array("erro" => "400",
            "retorno" => "conteudo JSON vazio 1")
          ), TRUE);
     }
break;
case "atualizacaoDadosCliente":
  if (isset($jsonEntrada)){
     include 'atualizacaoDadosCliente.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio 1")
        ), TRUE);
   }
break;
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
