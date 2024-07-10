<?php
/* helio 082022 - Acordo Online  */
/*
echo "metodo=".$metodo."\n";
echo "funcao=".$funcao."\n";
echo "parametro=".$parametro."\n";
*/
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
if ($parametro=="GravaPromessa"||$parametro=="GravaAcordo"||$parametro=="GeraBoleto") {
  $funcao=$parametro;
  $parametro = "";
}

if ($funcao=="parcelas"&&$parametro2=="boleto") {
  $funcao=$funcao.$parametro2;
}
if ($funcao=="parcelas"&&$parametro2=="confirmar-pagamento") {
  $funcao=$funcao.$parametro2;
}

if ($funcao=="negociacao"&&$parametro3=="boleto") {
  $funcao=$funcao.$parametro3;
}
if ($funcao=="negociacao"&&$parametro3=="confirmar-pagamento") {
  $funcao=$funcao.$parametro3;
}
if ($parametro=="renegociacaoCrediario") {
  $funcao=$parametro;
  $parametro = "";
}
if ($parametro=="numeracaoCrediario") {
  $funcao=$parametro;
  $parametro = "";
}


/*
echo "\n";
echo "funcao=".$funcao."\n";
echo "parametro=".$parametro."\n";
echo "parametro2=".$parametro2."\n";
echo "parametro3=".$parametro3."\n";
*/

if ($metodo=="GET"){
  if (!isset($funcao)) {

    if (isset($parametro)) {
      $funcao = "getcliente";
    }
  }

  switch ($funcao) {
    case "getcliente":
      include 'getcliente.php';
    break;
    case "negociacoes":
      include 'getnegociacoes.php';
    break;
    case "parcelas":
      include 'getparcelas.php';
    break;
    case "negociacao":
      include 'getnegociacaodetalhada.php';
    break;
    case "acordo":
      include 'getacordo.php';
    break;
    
    default:
    $jsonSaida = json_decode(json_encode(
     array("status" => "400",
         "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida"." Metodo ".$metodo." Invalido ")
       ), TRUE);
    break;
  }
}


if ($metodo=="POST"){

  switch ($funcao) {
      case "parcelasboleto":
        include 'parcelasboleto.php';
      break; 
      case "negociacaoboleto":
        include 'negociacaoboleto.php';
      break; 
      case "parcelasconfirmar-pagamento":
        include 'parcelasconfirmar-pagamento.php';
      break; 
      case "negociacaoconfirmar-pagamento":
        include 'negociacaoconfirmar-pagamento.php';
      break; 
      case "GravaPromessa":
        include "cybgravapromessa.php";
      break; 
      case "GravaAcordo":
        include "cybgravaacordo.php";
      break; 
      case "GeraBoleto":
        include "cybgeraboleto.php";
      break; 
      case "renegociacaoCrediario":
        include "renegociacaoCrediario.php";
      break; 
      case "numeracaoCrediario":
        include "numeracaoCrediario.php";
      break; 
      default:
      $jsonSaida = json_decode(json_encode(
       array("status" => "400",
           "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida"." Metodo Invalido ".$metodo)
         ), TRUE);
      break;
  }

}


if ($metodo=="PUT"){
  switch ($funcao) {
    case "atualiza-contatos":
      include 'atualizacontatos.php';
    break;
    default:
    $jsonSaida = json_decode(json_encode(
     array("status" => "400",
         "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida"." Metodo ".$metodo." Invalido ")
       ), TRUE);
    break;
  }
}




?>