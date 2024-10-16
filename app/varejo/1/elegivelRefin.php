<?php
$log_datahora_ini = date("dmYHis");
$acao = "elegivelrefin";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/apivarejo_elegivelrefin_" . date("dmY") . ".log";
$arquivo = fopen($arqlog, "a");
function isJson($string)
{
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

fwrite($arquivo, $identificacao . "-ENTRADA->" . json_encode($jsonEntrada) . "\n");

$progr = new chamaprogress();

if (isset($jsonEntrada)) {
  $conteudoEntrada = json_encode($jsonEntrada);
} else {
  $conteudoEntrada = json_encode(array('dadosEntrada' => array(
    array(
      'cpfCnpj' => $parametro
    )
  )));
}

fwrite($arquivo, $identificacao . "-ENTRADAFORMATADO->" . json_encode($conteudoEntrada) . "\n");
$retorno = $progr->executarprogress("varejo/1/elegivelrefin", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);
fwrite($arquivo, $identificacao . "-RETORNO->" . $retorno . "\n");

$conteudo = json_decode($retorno, true);
if (isset($conteudo["conteudoSaida"][0])) { 
  $jsonSaida = $conteudo["conteudoSaida"][0];
} else {
  $jsonSaida = array('dadosSaida' =>  $conteudo);
}

fwrite($arquivo, $identificacao . "-SAIDA->" . json_encode($jsonSaida) . "\n\n");
fclose($arquivo);
