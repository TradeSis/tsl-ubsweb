<?php
/* #082022 helio bau */
$log_datahora_ini = date("dmYHis");
$acao="buscaProdutos";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apibau_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}
      $conteudoEntrada= json_encode($jsonEntrada);
      $progr = new chamaprogress();

      $retorno = $progr->executarprogress("bau/1/buscaprodutos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
      //cho $retorno;

fwrite($arquivo,$log_datahora_ini."-PID".$mypid."-"."$acao"."-SAIDA->".$retorno."\n");


      
      $jsonSaida = json_decode($retorno,true);
      
      if (!isJson($retorno)) {  
           
           
            //json_decode(json_encode( 
            $jsonSaida = 
                                    array("status" => 500, 
                                    "erro" => "SAIDA->".substr($retorno,0,80)."\n"
            );
            //), TRUE); 
            fwrite($arquivo,$log_datahora_ini."-PID".$mypid."-"."$acao"."$acao"."-ERRO\n");
      
      } 


fclose($arquivo);
