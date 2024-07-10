<?php
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

$log_datahora_ini = date("dmYHis");
$acao="buscaParametros";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apiprestamista_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");

$progr = new chamaprogress();
$conteudoEntrada= json_encode($jsonEntrada);

    // echo "ENTRADA=".$conteudoEntrada;
    
      $retorno = $progr->executarprogress("prestamista/1/buscaparametros",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
      //echo "\nRETORNO=".$retorno ;

    //  $jsonSaida = json_decode($retorno, TRUE);
    //  echo "\nJSON=".$jsonSaida ;

      
      
                fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

                function isJson($string) {
                           json_decode($string);
                              return json_last_error() === JSON_ERROR_NONE;
                }

                $jsonSaida = json_decode($retorno,true);
      
                if (!isJson($retorno)) {  
                         $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                    "retorno" => $retorno) 
                                    ), TRUE); 
                          fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
      
                }    
                fclose($arquivo);
      
