<?php

$log_datahora_ini = date("dmYHis");
$acao = "negociacao";
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
                "document" =>  $parametro,
                "offer_id" => $parametro2
            ))));

$progr = new chamaprogress();

fwrite($arquivo, $identificacao . "-CONTEUDO->" . json_encode($conteudoEntrada) . "\n");

$retorno = $progr->executarprogress("serasa/1/negociacao", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);
fwrite($arquivo, $identificacao . "-retorno->" . json_encode($retorno) . "\n");
$dados = json_decode($retorno,true);
  if (isset($dados["conteudoSaida"][0])) { // Conteudo Saida - Caso de erro
      $dados = $dados["conteudoSaida"][0];
      $jsonSaida = $dados;
  } else {
      $conteudoSaida  = (object) json_decode($retorno, true);
      $negociacao        = $conteudoSaida->JSON["offers"][0];
      $instalments    = $conteudoSaida->JSON["instalments"];

      $acordo = array(
        "offerId" => $negociacao["offerId"],
        "type" => $negociacao["type"],
      );

      $novoarray = array();
      foreach ($instalments  as $instalment) {

        $dueDatenovo = array();
        // Transformar em lista
        foreach ($instalment["dueDate"] as $item) {
          list("dueDate" => $dueDate) = $item;
          array_push($dueDatenovo, $dueDate);
        }
        // remover o objeto dueDate
        unset($instalment["dueDate"]);
        // adiciona o objeto dueDate formatado
        $instalment["dueDate"] = $dueDatenovo;

        if (isset($instalment["taxes"][0])) {

          $iof = array(
            "percentage" => $instalment["taxes"][0]["iof_percentage"],
            "totalValue" => $instalment["taxes"][0]["iof_totalValue"]
          );

          $cet = array(
            "yearPercentage" => $instalment["taxes"][0]["cet_yearPercentage"],
            "monthPercentage" => $instalment["taxes"][0]["cet_monthPercentage"],
            "totalValue" => $instalment["taxes"][0]["cet_totalValue"]
          );

          $interest = array(
            "yearPercentage" => $instalment["taxes"][0]["interest_yearPercentage"],
            "monthPercentage" => $instalment["taxes"][0]["interest_monthPercentage"],
            "totalValue" => $instalment["taxes"][0]["interest_totalValue"]
          );

          $taxes = array(
            "iof" => $iof,
            "cet" => $cet,
            "interest" => $interest
          );

          $instalment["taxes"] =  $taxes;
        }
        array_push($novoarray, $instalment);
      }

      $acordo["instalments"] = $novoarray;

      $jsonSaida = $acordo;
    }

fclose($arquivo);
