<?php


$log_datahora_ini = date("dmYHis");
$acao="nossoNumero";  
$arqlog = "/ws/log/apiboleto_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}


  $conteudo = json_decode(json_encode($jsonEntrada["dadosEntrada"]));

  if (isset($conteudo)) {

      $conteudoEntrada = json_encode(array('dadosEntrada' => array($conteudo)));


  } else {
    $conteudo = json_decode(json_encode($jsonEntrada));

    $conteudoEntrada=json_encode(array('dadosEntrada' => $jsonEntrada));

  }

/**
  {"dadosEntrada":{
	"cpfCliente": "00315554037",
	"dataVencimentoBoleto": "2021-05-15",
	"valorTotalBoleto": "99.90",
	"taxaEmissaoBoleto": "1.00",
	"banco": "104"
}
}
**/

  // formata para o Progress
  /**
  $conteudoEntrada=json_encode(
    array('dadosEntrada' =>array(array(
                          'cpfCliente' => $conteudo->cpfCliente,
                          'dataVencimentoBoleto' => $conteudo->dataVencimentoBoleto,
                          'valorTotalBoleto' => $conteudo->valorTotalBoleto,
                          'taxaEmissaoBoleto' => $conteudo->taxaEmissaoBoleto,
                          'banco' => $conteudo->banco
                        ))));
**/

  $progr = new chamaprogress();

  $retorno       = $progr->executarprogress("nossonumero",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

  fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");


  $conteudoSaida = json_decode($retorno, TRUE);
  
  if (isset($conteudoSaida["return"][0])) {

    $jsonSaida     = $conteudoSaida["return"][0];
  } else {
    echo "\nERRO ".$retorno."\n";
  }

  if (!isJson($retorno)) {  
    fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
  } 

  fclose($arquivo);


/*

$jsonSaida = json_decode(json_encode(
     array("status" => "200",
         "descricaoStatus" => "tudo Certo",
         "nossoNumero" => rand())
       ), TRUE);
*/

//$jsonSaida = json_decode($conteudoEntrada, TRUE);
