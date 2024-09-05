<?php

$log_datahora_ini = date("dmYHis");
$acao = "ofertas-motor";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/serasa_ofertas-motor_" . date("dmY") . ".log";
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
{"dadosEntrada":[{"cnpj_raiz":"29939269", "document":"23599482020"}]}
*/
$progr = new chamaprogress();

fwrite($arquivo, $identificacao . "-CONTEUDO->" . json_encode($conteudoEntrada) . "\n");

$retorno = $progr->executarprogress("serasa/1/ofertas-motor", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);
fwrite($arquivo, $identificacao . "-RETORNO->" . $retorno . "\n");

$conteudoSaida  = (object) json_decode($retorno,true);
$offers        = $conteudoSaida->JSON["offers"];


//fwrite($arquivo, $identificacao . "-CONTEUDO SAIDA->" . json_encode($conteudoSaida) . "\n");
//fwrite($arquivo, $identificacao . "-OFFERS->" . json_encode($offers) . "\n");

$ofertas = array(
  "offers" => $offers,
);

$jsonSaida = $ofertas;


fclose($arquivo);