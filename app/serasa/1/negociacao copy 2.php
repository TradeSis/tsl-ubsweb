<?php

$log_datahora_ini = date("dmYHis");
$acao = "negociacao";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/serasa_NEGOCIACAO_" . date("dmY") . ".log";
$arquivo = fopen($arqlog, "a");
function isJson($string)
{
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

fwrite($arquivo, $identificacao . "-ENTRADA->" . json_encode($jsonEntrada) . "\n");
fwrite($arquivo, $identificacao . "-PARAMETRO->" . json_encode($parametro) . "\n");

$conteudoEntrada = json_encode($jsonEntrada);

$progr = new chamaprogress();

fwrite($arquivo, $identificacao . "-CONTEUDO->" . json_encode($conteudoEntrada) . "\n");

$retorno = $progr->executarprogress("serasa/1/negociacao", $conteudoEntrada, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);
//$dados = json_decode($retorno, true);
$conteudoSaida  = (object) json_decode($retorno,true);
$negociacao        = $conteudoSaida->JSON["negociacao"][0];
$instalments    = $conteudoSaida->JSON["instalments"];
$dueDate    = $conteudoSaida->JSON["dueDate"]; 
$values    = $conteudoSaida->JSON["values"]; 
$taxes          = $conteudoSaida->JSON["taxes"][0]; 

//fwrite($arquivo, $identificacao . "-CONTEUDO SAIDA->" . json_encode($conteudoSaida) . "\n");
//fwrite($arquivo, $identificacao . "-NEGOCIACAO->" . json_encode($negociacao) . "\n");
fwrite($arquivo, $identificacao . "-INSTALMENTS->" . json_encode($instalments) . "\n");
//fwrite($arquivo, $identificacao . "-DUEDATE->" . json_encode($dueDate) . "\n");
//fwrite($arquivo, $identificacao . "-VALUES->" . json_encode($values) . "\n");
//fwrite($arquivo, $identificacao . "-TAXES->" . json_encode($taxes) . "\n");

/* $dados = json_decode($retorno, true);
if (isset($dados["conteudoSaida"][0])) { // Conteudo Saida - Caso de erro
  $dados = $dados["conteudoSaida"][0];
} else {
  $dados = $dados["acordos"][0];
} */

foreach ($instalments as $instalmentsolo) {
  fwrite($arquivo, $identificacao . "-INSTALMENTSSOLO->" . json_encode($instalmentsolo) . "\n");
}
// converte array para lista
$dueDatesList = array_map(function($date) {
  return $date["dueDate"];
}, $dueDate);


/* $values =
  array(
    "values2" => array(
     array(
        "0" => "2024-08-19",
        "1" => "2024-08-20"
    )
    )
  ); */
 

 

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

/* $instalments = array(
  "id" => "1",
  "total" => 300,
  "dueDate" => $dueDate,
  "taxes" => $taxes
); */

$instalment = array(
      array(
        /* "id" => $instalments["id"], //"1",
        "total" => $instalments["total"], //300,
        "totalWithoutInterest" => $instalments["totalWithoutInterest"], //300,
        "discountValue" => $instalments["discountValue"], //100,
        "discountPercentage" => $instalments["discountPercentage"], //25,
        "instalment" => $instalments["instalment"], //1, */ 
        "instalments" => $instalments,
        "dueDate" => $dueDatesList,
        "values" => $values,
        "taxes" => $taxes
      ),
      array(
        /* "id" => $instalments["id"], //"1",
        "total" => $instalments["total"], //300,
        "totalWithoutInterest" => $instalments["totalWithoutInterest"], //300,
        "discountValue" => $instalments["discountValue"], //100,
        "discountPercentage" => $instalments["discountPercentage"], //25,
        "instalment" => $instalments["instalment"], //1, */ 
        "instalments" => $instalments,
        "dueDate" => $dueDatesList,
        "values" => $values,
        "taxes" => $taxes
      )
  );

$acordo = array(
  "offerId" => $negociacao["offerId"], //"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "type" => $negociacao["type"], //"EQUALS",
  "instalments" => $instalment, 
 // "taxes" => $taxes,
);

$jsonSaida = $acordo;


fclose($arquivo);
