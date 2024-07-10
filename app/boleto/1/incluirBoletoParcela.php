<?php


$log_datahora_ini = date("dmYHis");
$acao="incluirBoletoParcela";  
$arqlog = "/ws/log/apiboleto_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

    $conteudo = json_decode(json_encode($jsonEntrada["dadosEntrada"]));


    $conteudoEntrada=
        json_encode(array("dadosEntrada" => array("boleto" => array(array(
                            "banco"         => $conteudo->boleto->banco,
                            "nossoNumero"   => $conteudo->boleto->nossoNumero,
                            "situacao"      => $conteudo->boleto->situacao,
                            "taxaEmissaoBoleto" => $jsonEntrada["taxaEmissaoBoleto"])),
                            "parcelas"      => $conteudo->parcelas
                          )));


$progr = new chamaprogress();

$retorno       = $progr->executarprogress("incluirboletoparcela",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
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

