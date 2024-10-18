<?php

$log_datahora_ini = date("dmYHis");
$acao = "ofertas";
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

$retorno = $progr->executarprogress("serasa/1/ofertas", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);
fwrite($arquivo, $identificacao . "-retorno->" . json_encode($retorno) . "\n");

  $dados = json_decode($retorno,true);
  if (isset($dados["conteudoSaida"][0])) { // Conteudo Saida - Caso de erro
      $dados = $dados["conteudoSaida"][0];
      $jsonSaida = $dados;
  } else {
      $conteudoSaida  = (object) json_decode($retorno,true);
      $offers    = $conteudoSaida->JSON["offers"]; 

      foreach ($offers as &$offer) {
        foreach ($offer['debts'] as &$debt) {
            if (is_array($debt['company']) && isset($debt['company'][0])) {
              $debt['company'] = $debt['company'][0];
            }
            if (is_array($debt['companyOrigin']) && isset($debt['companyOrigin'][0])) {
              $debt['companyOrigin'] = $debt['companyOrigin'][0];
            }
           
        }
    }

      $jsonSaida = $offers;
  }

fclose($arquivo);
