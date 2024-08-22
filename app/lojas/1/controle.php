<?php
/* helio 092022 - Reversa Lojas  */


//echo "metodo=".$metodo."\n";
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


$explode = explode("/",$funcao);

if ($explode[0]) {
  $funcao = $explode[0];
}
if (isset($explode[1])) {
  $parametro2 = $explode[1];
}
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
    case "reversa-resgatacaixa":
      include 'reversa-resgatacaixa.php';
    break; 
    case "reversa-abertas":
      include 'reversa-abertas.php';
    break; 
    case "bag-abertas":
      include 'bag-abertas.php';
    break; 
    case "bag-resgata":
      include 'bag-resgata.php';
    break; 
    case "bag-fechadas":
      include 'bag-fechadas.php';
    break; 
    case "consultaCupomB2b":
      include 'cupomb2b-consulta.php';
    break; 
    case "cotasPlanoVerifica":
      include 'cotasPlanoVerifica.php';
    break; 
    case "cotasPlanoUtiliza":
      include 'cotasPlanoUtiliza.php';
    break; 
    case "cotasPlanoSupUtiliza":
      include 'cotasPlanoSupUtiliza.php';
    break; 
    case "previsaoEntrega":
      include 'previsaoEntrega.php';
    break; 
    case "comboDesPlanCalcula":
      include 'comboDesPlanCalcula.php';
    break; 
    case "cliente":
      include 'clienteconsultar.php';
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
      case "reversa-abrecaixa":
        include 'reversa-abrecaixa.php';
      break; 
      case "reversa-salvacaixa":
        include 'reversa-salvacaixa.php';
      break; 
      case "reversa-fechacaixa":
        include 'reversa-fechacaixa.php';
      break; 
      case "bag-abre":
        include 'bag-abre.php';
      break; 
      case "bag-salva":
        include 'bag-salva.php';
      break; 
      case "bag-fecha":
        include 'bag-fecha.php';
      break; 
      case "bag-fechavenda":
        include 'bag-fechavenda.php';
      break; 
      case "marcaCupomB2b":
        include 'cupomb2b-marcauso.php';
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
    case "cliente":
      include 'clientecadastrar.php';
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