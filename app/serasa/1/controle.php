<?php
/* helio 092022 - Reversa Lojas  */


//echo "metodo=".$metodo."\n";
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


$explode = explode("/",$funcao);

if ($explode[0]) {
  $funcao = $explode[0];
}
/* if ($explode[1]) {
  $parametro2 = $explode[1];
} */
/*if ($explode[2]) {
  $parametro3 = $explode[2];
}*/

/*
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
*/
if ($parametro=="cliente") {
  $funcao=$parametro;
  $parametro=null;
}


//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";
//echo "parametro2=".$parametro2."\n";
//echo "parametro3=".$parametro3."\n";


if ($metodo=="GET"){
/*  if (!isset($funcao)) {

    if (isset($parametro)) {
      $funcao = "getcliente";
    }
  }
*/
  switch ($funcao) {
    case "saude":
      include 'saude.php';
    break;

    case "ofertas":
      include 'ofertas.php';
    break;

    case "ofertas-motor":
      include 'ofertas-motor.php';
    break;

    case "negociacao":
      include 'negociacao.php';
    break;

    case "negociacao-motor":
      include 'negociacao-motor.php';
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
    case "pagamento":
      include 'pagamento.php';
    break;

    case "cancela-acordo":
      include 'cancela-acordo.php';
      break;

    case "acordos":
      include 'acordos.php';
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

    default:
    $jsonSaida = json_decode(json_encode(
     array("status" => "400",
         "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida"." Metodo ".$metodo." Invalido ")
       ), TRUE);
    break;
  }
}




?>