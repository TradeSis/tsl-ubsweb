<?php

$log_datahora_ini = date("dmYHis");
$acao="ofertas";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/serasa_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");

$conteudoEntrada = json_encode($jsonEntrada);

$progr = new chamaprogress();

fwrite($arquivo,$identificacao."-CONTEUDO->".json_encode($conteudoEntrada)."\n");

$retorno = $progr->executarprogress("serasa/1/ofertas",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

fwrite($arquivo, $identificacao . "-SAIDA->" . $retorno . "\n");
$dados = json_decode($retorno, false);
fwrite($arquivo, $identificacao . "-DADOS->" . $dados . "\n");
if (isset($dados["conteudoSaida"][0])) { // Conteudo Saida - Caso de erro
  $dados = $dados["conteudoSaida"][0];
}else{
  $dados = $dados[0];
}

$jsonSaida = $dados;


fclose($arquivo);
      
      
?>

