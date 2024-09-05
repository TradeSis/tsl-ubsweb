<?php

$log_datahora_ini = date("dmYHis");
$acao = "acordos";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/serasa_acordos_" . date("dmY") . ".log";
$arquivo = fopen($arqlog, "a");
function isJson($string)
{
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

fwrite($arquivo, $identificacao . "-ENTRADA->" . json_encode($jsonEntrada) . "\n");
fwrite($arquivo, $identificacao . "-PARAMETRO->" . json_encode($parametro) . "\n");

$conteudoEntrada = json_encode($jsonEntrada);
/* 
{"dadosEntrada":[{"document":"23599482020","offerId":"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a","dueDate":"2024-08-19","id":"2"}]}
*/
$progr = new chamaprogress();

fwrite($arquivo, $identificacao . "-CONTEUDO->" . json_encode($conteudoEntrada) . "\n");

$retorno = $progr->executarprogress("serasa/1/acordos", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);

$conteudoSaida  = (object) json_decode($retorno,true);
$acordos        = $conteudoSaida->JSON["acordos"][0];
$instalments    = $conteudoSaida->JSON["instalments"]; 
$taxes          = $conteudoSaida->JSON["taxes"][0]; 

//fwrite($arquivo, $identificacao . "-CONTEUDO SAIDA->" . json_encode($conteudoSaida) . "\n");
//fwrite($arquivo, $identificacao . "-ACORDOS->" . json_encode($acordos) . "\n");
//fwrite($arquivo, $identificacao . "-INSTALMENTS->" . json_encode($instalments) . "\n");
//fwrite($arquivo, $identificacao . "-TAXES->" . json_encode($taxes) . "\n");

$iof = array(
  "percentage" => $taxes["iof_percentage"], //0
  "totalValue" => $taxes["iof_totalValue"], //0
);

$cet = array(
  "yearPercentage" => $taxes["cet_yearPercentage"], //0,
  "monthPercentage" => $taxes["cet_monthPercentage"], //0,
  "totalValue" => $taxes["cet_totalValue"] //0
);

$interest = array(
  "yearPercentage" => $taxes["interest_yearPercentage"], //0,
  "monthPercentage" => $taxes["interest_monthPercentage"], //0,
  "totalValue" => $taxes["interest_totalValue"] //0
);

$taxes = array(
  "iof" => $iof,
  "cet" => $cet,
  "interest" => $interest
);

$acordo = array(
  "offerId" => $acordos["offerId"], //"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "agreementId" => $acordos["agreementId"], //"123456",
  "total" => $acordos["total"], //300,
  "totalWithoutInterest" => $acordos["totalWithoutInterest"], //300,
  "discountValue" => $acordos["discountValue"], //100,
  "discountPercentage" => $acordos["discountPercentage"], //25,
  "instalments" => $instalments,
  "taxes" => $taxes,
);

$jsonSaida = $acordo;


fclose($arquivo);
