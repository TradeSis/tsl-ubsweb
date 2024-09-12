]<?php

$log_datahora_ini = date("dmYHis");
$acao = "ofertas-motor";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/serasa_" . date("dmY") . ".log";
$arquivo = fopen($arqlog, "a");
function isJson($string)
{
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

fwrite($arquivo, $identificacao . "-ENTRADA->" . json_encode($jsonEntrada) . "\n");
fwrite($arquivo, $identificacao . "-PARAMETRO->" . json_encode($parametro) . "\n");
fwrite($arquivo, $identificacao . "-PARAMETRO2->" . json_encode($parametro2) . "\n");


 $conteudoEntrada = json_encode(array(
        "dadosEntrada" => array(array(
                "cnpj_raiz" =>  $parametro,
                "document" => $parametro2
            ))));

$progr = new chamaprogress();

fwrite($arquivo, $identificacao . "-CONTEUDO->" . json_encode($conteudoEntrada) . "\n");

$retorno = $progr->executarprogress("serasa/1/ofertas-motor", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);

$conteudoSaida  = (object) json_decode($retorno,true);
$offers    = $conteudoSaida->JSON["offers"]; 

$acordo = array();
$novoarray = array();
foreach ($offers  as $instalment ) {

    $instalment["debts"][0]["company"] = $instalment["debts"][0]["company"][0];
    $instalment["debts"][0]["companyOrigin"] = $instalment["debts"][0]["companyOrigin"][0];

  array_push($novoarray, $instalment);
  
}

$acordo["offers"] = $novoarray;

$jsonSaida = $acordo;


fclose($arquivo);
