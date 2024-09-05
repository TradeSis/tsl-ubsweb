<?php

$log_datahora_ini = date("dmYHis");
$acao = "negociacao";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/serasa_negociacao_" . date("dmY") . ".log";
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
{"dadosEntrada":[{"document":"23599482020","offer_id":"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a"}]}
*/
$progr = new chamaprogress();

fwrite($arquivo, $identificacao . "-CONTEUDO->" . json_encode($conteudoEntrada) . "\n");

$retorno = $progr->executarprogress("serasa/1/negociacao", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);
//fwrite($arquivo, $identificacao . "-RETORNO->" . $retorno . "\n");
$conteudoSaida  = (object) json_decode($retorno,true);
$negociacao        = $conteudoSaida->JSON["negociacao"][0];
$instalments    = $conteudoSaida->JSON["instalments"];


fwrite($arquivo, $identificacao . "-CONTEUDO SAIDA->" . json_encode($conteudoSaida) . "\n");


$acordo = array(
  "offerId" => $negociacao["offerId"], //"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "type" => $negociacao["type"], //"EQUALS",
  "instalments" => $instalments, 
);

$jsonSaida = $acordo;


fclose($arquivo);
