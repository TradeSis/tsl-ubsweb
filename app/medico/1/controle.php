<?php
/* medico na tela 042022 - helio */

//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if (!isset($funcao)) {
  if ($parametro=="buscaProdutos") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="enviaProposta") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="efetivaAdesao") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="buscaTermos") {
    $funcao=$parametro;
    $parametro=null;
  }
  if ($parametro=="cancelaAdesao") {
    $funcao=$parametro;
    $parametro=null;
  }
  

} else {
        if ($parametro=="buscaTermos") {
          $parametro=$funcao;
          $funcao="buscaTermos";
          
        } else {
          $funcao=$parametro;
        }
      
        
}
//echo "funcao=".$funcao."\n";
//echo "parametro=".$parametro."\n";

if ($metodo=="POST") {
    switch ($funcao) {
      case "enviaProposta":
        if (isset($jsonEntrada)){
            include 'enviaProposta.php';
          } else {
            $jsonSaida = json_decode(json_encode(
            array("erro" => "400",
                "retorno" => "conteudo JSON vazio 3")
              ), TRUE);
          }
      break;
      case "efetivaAdesao":
        if (isset($jsonEntrada)){
          include 'efetivaAdesao.php';
        } else {
          $jsonSaida = json_decode(json_encode(
            array("erro" => "400",
                "retorno" => "conteudo JSON vazio 3")
              ), TRUE);
        }
    break;
    case "buscaProdutos":

                include 'buscaProdutos.php';

    break;
    case "cancelaAdesao":
      if (isset($jsonEntrada)){
        include 'cancelaAdesao.php';
      } else {
        $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "conteudo JSON vazio cancelaAdesao")
            ), TRUE);
      }
  break;

      default:
          $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Metodo ".$metodo." Funcao ".$funcao." Invalida")
            ), TRUE);
          break;
    }
  }
 

  if ($metodo=="GET") {
    
        switch ($funcao) {
          case "buscaTermos":
            if (isset($jsonEntrada)){
                include 'buscaTermos.php';
              } else {
                if (isset($parametro)) {
                  //$parametro = $funcao;
                  include 'buscaTermos.php';
                } else {
                $jsonSaida = json_decode(json_encode(
                array("erro" => "400",
                    "retorno" => "Sem Parametros de Entrada")
                  ), TRUE);}
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