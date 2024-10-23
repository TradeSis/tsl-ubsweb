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
  if ($parametro=="boletoconsultar") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="boletopagar") {
    $funcao=$parametro;
    $parametro=null;
  }
  /* helio 231024 - serasa */
  if ($parametro=="barramentoEmitir2") {
    $funcao=$parametro;
    $parametro=null;
  }
  
}
//echo "funcao=".$funcao;
if ($metodo=="POST" ) {

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
      case "boletopagar":
          include 'boletopagar.php';
    break;
    
    /* helio 23102024 - serasa */
      case "barramentoEmitir2":
          if (isset($jsonEntrada)){
            include 'barramentoEmitir2.php';
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
  }


  if ($metodo=="GET" ) {

    switch ($funcao) {
      case "boletoconsultar":
            include 'boletoconsultar.php';
      break;
      default:
          $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Funcao ".$funcao." Invalida")
            ), TRUE);
          break;
    }

}
