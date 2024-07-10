<?php
/* medico na tela 042022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="buscaProdutos";  
$arqlog = "/ws/log/apimedico_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}
      $conteudoEntrada= json_encode($jsonEntrada);
      $progr = new chamaprogress();

      $retorno = $progr->executarprogress("medico/1/buscaprodutos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
      //cho $retorno;

fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");


      
      $jsonSaida = json_decode($retorno,true);
      
      if (!isJson($retorno)) {  
            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                    "retorno" => $retorno) 
                                    ), TRUE); 
            fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
      
      } 


fclose($arquivo);
