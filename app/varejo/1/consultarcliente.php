<?php
$log_datahora_ini = date("dmYHis");
$acao="consultacliente";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apivarejo_consultacliente_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");

$progr = new chamaprogress();

$conteudoEntrada=json_encode(array('cliente' => array($jsonEntrada)));

 //echo $conteudoEntrada;
      fwrite($arquivo,$identificacao."-ENTRADAFORMATADO->".json_encode($conteudoEntrada)."\n");
      $retorno = $progr->executarprogress("varejo/1/consultarcliente",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
      fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

      if (!isJson($retorno)) {  
        $jsonSaida = json_decode(json_encode( array("status" => 500, 
                            "retorno" => $retorno) 
                            ), TRUE); 
        fwrite($arquivo,$identificacao."-ERRO\n");
    } else {
      $conteudo = json_decode($retorno,true);

      $jsonSaida = $conteudo["cliente"][0];
    }

    fclose($arquivo);


?>