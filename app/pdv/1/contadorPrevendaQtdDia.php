<?php
/* helio 11052022 - Contador de Pre-vendas  */
function isJson($string) {
    json_decode($string);
       return json_last_error() === JSON_ERROR_NONE;
       }


    $conteudoEntrada = json_encode($jsonEntrada);
   // var_dump($conteudoEntrada);
    
    $progr = new chamaprogress();

   $retorno = $progr->executarprogress("pdv/1/contadorprevendaqtddia",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
  //   echo "\nRETORNO=".$retorno ;

     $jsonSaida = json_decode($retorno,true);
      
     if (!isJson($retorno)) {  
                $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                   "retorno" => $retorno) 
                                   ), TRUE); 
                      
     } else {
         if ($jsonSaida["return"][0]["mensagem"]=="Erro")
         {
            $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "ERRO") 
            ), TRUE); 

         }
     }

  
