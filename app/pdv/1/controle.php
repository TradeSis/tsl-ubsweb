<?php
/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */


//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="atualizaNeuProposta") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="consultaCliente") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="atualizacaoDadosCliente") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="preAutorizacao") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="verificaCreditoVenda") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="verificacaoCarteiraDestino") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="verificaPromocAVista") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="contadorPrevendaQtdDia") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaTermos") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="verificaFilial") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="verificaBloqProduto") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="verificaPromQtd") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaDadosContratoNf") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="consultaProdutosFinanceiros") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="simularTransacaodeCredito") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="autorizarEmprestimo") {
    $funcao=$parametro;
    $parametro=null;
  }
  
  if ($parametro=="efetivaEmprestimo") {
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
   case "atualizaNeuProposta":
      if (isset($jsonEntrada)){
         include 'atualizaNeuProposta.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
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

case "buscaTermos":
  if (isset($jsonEntrada)){
     include 'buscaTermos.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio buscaTermos")
        ), TRUE);
   }
break;

case "verificaFilial":
  if (isset($jsonEntrada)){
     include 'verificaFilial.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio buscaTermos")
        ), TRUE);
   }
break;


case "verificaBloqProduto":
  if (isset($jsonEntrada)){
     include 'verificaBloqProduto.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio verificaBloqProduto")
        ), TRUE);
   }
break;

case "verificaPromQtd":
  if (isset($jsonEntrada)){
     include 'verificaPromQtd.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio verificaPromQtd")
        ), TRUE);
   }
break;

case "buscaDadosContratoNf":
  
  if (isset($jsonEntrada)){
   
     include 'buscaDadosContratoNf.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio BuscaDadosContratoNf")
        ), TRUE);
   }
break;

case "consultaProdutosFinanceiros":
  
  if (isset($jsonEntrada)){
   
     include 'consultaProdutosFinanceiros.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio consultaProdutosFinanceiros")
        ), TRUE);
   }
break;




case "simularTransacaodeCredito":
  
  if (isset($jsonEntrada)){
   
     include 'simularTransacaodeCredito.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio simularTransacaodeCredito")
        ), TRUE);
   }
break;

case "autorizarEmprestimo":
  
  if (isset($jsonEntrada)){
   
     include 'autorizarEmprestimo.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio autorizarEmprestimo")
        ), TRUE);
   }
break;



case "efetivaEmprestimo":
  
  if (isset($jsonEntrada)){
   
     include 'efetivaEmprestimo.php';
   } else {
     $jsonSaida = json_decode(json_encode(
      array("erro" => "400",
          "retorno" => "conteudo JSON vazio efetivaEmprestimo")
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
