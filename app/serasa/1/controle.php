<?php
/* helio 092022 - Reversa Lojas  */


//echo "metodo=".$metodo."\n";
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";
$muda = $funcao;
$funcao = $parametro;
$parametro = $muda; 

$explode = explode("/",$parametro);

if ($explode[0]) {
  $parametro = $explode[0];
}
if ($explode[1]) {
  $parametro2 = $explode[1];
} 
if ($explode[2]) {
  $parametro3 = $explode[2];
}

if ($funcao == "saude" || $funcao == "health-check") {
  $funcao = "saude"; 
}
if ($funcao == "ofertas" || $funcao == "offers" || $funcao == "ofertas-motor" || $funcao == "offers-motor") {
  $funcao = "ofertas"; 
}
if ($funcao == "negociacao" || $funcao == "instalments" || $funcao == "negociacao-motor" || $funcao == "instalments-motor") {
  $funcao = "negociacao"; 
}
if ($funcao == "acordos" || $funcao == "agreements") {
  $funcao = "acordos"; 
}
if ($funcao == "cancela-acordo" || $funcao == "agreements-cancel") {
  $funcao = "cancela-acordo"; 
}
if ($funcao == "pagamento" || $funcao == "payments") {
  $funcao = "pagamento"; 
}


//echo "2 funcao=".$funcao."\n";
//echo "2 parametro=".$parametro."\n";
//echo "2 parametro2=".$parametro2."\n";
//echo "2 parametro3=".$parametro3."\n";
//echo "2 metodo=".$metodo."\n";



if ($metodo=="GET"){

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