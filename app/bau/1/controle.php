<?php
/* #082022 helio bau */


//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

$explode = explode("/",$funcao);

if ($explode[0]) {
  $funcao = $explode[0];
}
if ($explode[1]) {
  $parametro2 = $explode[1];
}
if ($explode[2]) {
  $parametro3 = $explode[2];
}



if ($metodo=="GET"){

  if (!isset($funcao)) {

    if ($parametro=="buscaProdutos") {
      $funcao=$parametro;
      $parametro=null;
    }   
    else {
      if (isset($parametro)) {
        $parametro = $funcao;
        $funcao = "cliente";
      } else {
        $jsonSaida = json_decode(json_encode(
          array("status" => 401,
              "retorno" => "conteudo JSON vazio - 1")
            ), TRUE);
      }
  
    }
  } else {
    if ($parametro=="carneparcelas-detalhes") {
      $aux = $funcao;
      $funcao=$parametro;
      $parametro = $aux;
    }   
    if ($parametro=="carnes") {
      $aux = $funcao;
      $funcao=$parametro;
      $parametro = $aux;
    }   
    if ($parametro=="cliente") {
      $aux = $funcao;
      $funcao="getcliente";
      $parametro = $aux;
    }   
    if ($parametro=="buscaTermos") {
      $aux = $funcao;
      $funcao="buscaTermos";
      $parametro = $aux;
    }   

  }
}
if ($metodo=="POST"){
  if ($parametro=="cliente"){
    $funcao="postcliente";
    $parametro=null;
  }
  if ($parametro=="Proposta"){
    $funcao="postproposta";
    $parametro=null;
  }
  if ($parametro=="efetivaPagamento"){
    $funcao="efetivaPagamento";
    $parametro=null;
  }
}
if ($metodo=="PUT"){
  if ($parametro=="vincular-carne"){
    $aux = $funcao;
    $funcao="vincularCarne";
    $parametro = $aux;
  }
}

//echo "metodo=".$metodo."\n";
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";
//echo "parametro2=".$parametro2."\n";
//echo "parametro3=".$parametro3."\n";



switch ($funcao) {
  case "postcliente":
    include 'postcliente.php';
  break;
  case "postproposta":
    include 'postproposta.php';
  break;
  case "efetivaPagamento":
    include 'efetivaPagamento.php';
  break;
  case "getcliente":
    include 'getcliente.php';
  break;
  case "carneparcelas-detalhes":
    include 'carneparcelas-detalhes.php';
  break;
  case "carnes":
    include 'carnes.php';
  break;
  case "buscaProdutos":
    include 'buscaProdutos.php';
  break;
  case "buscaTermos":
    include 'buscaTermos.php';
  break;
  case "vincularCarne":
    include 'vincularCarne.php';
  break;

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
case "preAutorizacao":
  if (isset($jsonEntrada)){
     include 'preAutorizacao.php';
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
case "verificacaoCarteiraDestino":
  if (isset($jsonEntrada)){
     include 'verificacaoCarteiraDestino.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio 1")
        ), TRUE);
   }
break;

case "verificaPromocAVista":
  if (isset($jsonEntrada)){
     include 'verificaPromocAVista.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio 1")
        ), TRUE);
   }
break;

case "contadorPrevendaQtdDia":
  if (isset($jsonEntrada)){
     include 'contadorPrevendaQtdDia.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio contadorPrevendaQtdDia")
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
