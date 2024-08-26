<?php
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";


if (!isset($funcao)) {
  if ($parametro=="nossoNumero") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="incluirBoletoParcela") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="barramentoEmitir") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="boletoemitir") {
    $funcao=$parametro;
    $parametro=null;
  }
  
}
//echo "funcao=".$funcao;
switch ($funcao) {
   case "nossoNumero":
      if (isset($jsonEntrada)){
         include 'nossoNumero.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio")
            ), TRUE);
       }
    break;
       case "incluirBoletoParcela":
          if (isset($jsonEntrada)){
             include 'incluirBoletoParcela.php';
           } else {
             $jsonSaida = json_decode(json_encode(
              array("erro" => "400",
                  "retorno" => "conteudo JSON vazio")
                ), TRUE);
           }
   break;
   case "barramentoEmitir":
      if (isset($jsonEntrada)){
         include 'barramentoEmitir.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
   case "boletoemitir":
      if (isset($jsonEntrada)){
         include 'boletoemitir.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
  
  case "boletagem":
      if (isset($jsonEntrada)){
         include 'boletagem.php';
       } else {
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio 1")
            ), TRUE);
       }
  break;
  case "boletagemv2":
      if (isset($jsonEntrada)){
         include 'boletagemv2.php';
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
