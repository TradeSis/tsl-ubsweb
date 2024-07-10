<?php

                        $log_datahora_ini = date("dmYHis");
                        $acao="verificaCreditoVenda_2_";  
                        $arqlog = "/ws/log/apipdv_"."$acao".date("dmY").".log";
                        
                        $arquivo = fopen($arqlog,"a");


$dadosEntrada = $jsonEntrada["dadosEntrada"];

                        fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");


   
if (!isset($dadosEntrada)) {
  
    $dadosEntrada = (object) $jsonEntrada;
   // var_dump($dadosEntrada);

    $conteudoEntrada = json_encode(
      array("dadosEntrada" => array(
              )
      ));



} else {
    $conteudoEntrada = json_encode($jsonEntrada);
 
}

   




  //echo "ENTRADA=".$conteudoEntrada;


    $progr = new chamaprogress();
    $conteudoEntrada= json_encode($jsonEntrada);
    
  
   $retorno = $progr->executarprogress("pdv/2/verificacreditovenda",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
                        fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");
                        
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

