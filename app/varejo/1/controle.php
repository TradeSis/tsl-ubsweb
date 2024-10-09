<?php
/* helio 022023 insert nop crediario admcom */
/*
echo "metodo=".$metodo."\n";
echo "funcao=".$funcao."\n";
echo "parametro=".$parametro."\n";
*/

$explode = explode("/",$funcao);

if ($explode[0]) {
  $funcao = $explode[0];
}
if (isset($explode[1])) {
  $parametro2 = $explode[1];
}
if (isset($explode[2])) {
  $parametro3 = $explode[2];
}


/* echo "\ncontrole.php\n";
echo "funcao=".$funcao."\n";
echo "parametro=".$parametro."\n";
echo "parametro2=".$parametro2."\n";
echo "parametro3=".$parametro3."\n"; */


if ($parametro=="credito-pessoal") {
  $aux=$funcao;
  $funcao=$parametro;
  $parametro = $aux;
}
if ($parametro=="consultarcliente") {
  $aux=$funcao;
  $funcao=$parametro;
  $parametro = $aux;
}
if ($parametro=="elegivelrefin") {
  $aux=$funcao;
  $funcao=$parametro;
  $parametro = $aux;
}

if ($funcao=="credito-pessoal"&&$parametro3=="gera-segnum") {
  $funcao=$funcao."/".$parametro3;
  $parametro3 = "";
}
if ($funcao=="credito-pessoal"&&$parametro2=="gera-contnum") {
  $funcao=$funcao."/".$parametro2;
  $parametro2 = "";
}

/*
echo "\napostratar\n";
echo "funcao=".$funcao."\n";
echo "parametro=".$parametro."\n";
echo "parametro2=".$parametro2."\n";
echo "parametro3=".$parametro3."\n";
*/

if ($metodo=="GET"){

switch ($funcao) { 

    case "elegivelrefin":
      if (isset($jsonEntrada) || $parametro){
         include 'elegivelrefin.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
       break; 

    default:
    $jsonSaida = json_decode(json_encode(
      array("status" => "400",
          "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida"." Metodo Invalido ".$metodo)
        ), TRUE);
    break;
}

}

if ($metodo=="POST"){

  switch ($funcao) {
      case "credito-pessoal/gera-segnum":
        include 'cpgerasegnum.php';
      break; 
      case "credito-pessoal/gera-contnum":
        include 'geracontnum.php';
      break; 
      case "credito-pessoal":
        include 'cpgeracontrato.php';
      break; 
      case "consultarcliente":
        include 'consultarcliente.php';
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