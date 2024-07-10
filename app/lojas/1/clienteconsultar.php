<?php
/* Helio 012024 - CADASTRO RÁPIDO NA PRÉ-VENDA */


$log_datahora_ini = date("dmYHis");
$acao="cliente_consultar";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apilojas_cliente_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");

$conteudoEntrada = json_encode($jsonEntrada);

$progr = new chamaprogress();

fwrite($arquivo,$identificacao."-CONTEUDO->".json_encode($conteudoEntrada)."\n");

$retorno = $progr->executarprogress("lojas/1/clienteconsultar",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

  if (!isJson($retorno)) {  
      $jsonSaida = json_decode(json_encode( array("status" => 500, 
                          "retorno" => $retorno) 
                          ), TRUE); 
      fwrite($arquivo,$identificacao."-ERRO\n");
  } else {

      $conteudoSaida = (object) json_decode($retorno,true);
      
       
      if (isset($conteudoSaida->cliente)) {

          $jsonSaida = json_decode($retorno,true);

      } else {
      
      $status = (object) $conteudoSaida->conteudoSaida[0];
      

      $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                              "retorno" => $status->descricaoStatus) 
                      ), TRUE); 


      }


  }

fclose($arquivo);
      
      
?>
