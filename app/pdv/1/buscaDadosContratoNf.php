<?php


$log_datahora_ini = date("dmYHis");
$acao="buscaDadosContratoNf";  
$arqlog = "/ws/log/apipdv_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");


fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");

$dadosEntrada = $jsonEntrada["dadosEntrada"];
if (!isset($dadosEntrada)) {
  
    $dadosEntrada = (object) $jsonEntrada["buscaDadosContratoNf"];
    

   $conteudoEntrada = json_encode(
    array("dadosEntrada" => array(
            "buscaDadosContratoNf"  =>  array(array(
              "tipo_documento" => $dadosEntrada->tipo_documento,
              "numero_documento" => $dadosEntrada->numero_documento,
              "codigo_filial" => $dadosEntrada->codigo_filial,
              "codigo_operador" => $dadosEntrada->codigo_operador,
              "numero_pdv" => $dadosEntrada->numero_pdv,
              "valor_compra" => $dadosEntrada->valor_compra,
              "plano_pagamento" => $dadosEntrada->plano_pagamento,
              "nsu_venda" => $dadosEntrada->nsu_venda,
              "vendedor" => $dadosEntrada->vendedor,
              "codigo_seguro_prestamista" => $dadosEntrada->codigo_seguro_prestamista,
              "valor_seguro_prestamista" => $dadosEntrada->valor_seguro_prestamista,
              "plano_pagamento" => $dadosEntrada->plano_pagamento,
              "id_acordo" => $dadosEntrada->id_acordo)),
            "parcelas"  => $dadosEntrada->parcelas)
    ));
    



} else {
    $conteudoEntrada = json_encode($jsonEntrada);
 
}


$progr = new chamaprogress();
//$conteudoEntrada= json_encode($conteudoEntrada);
    
  
   $retorno = $progr->executarprogress("pdv/1/buscadadoscontratonf",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
                        fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");
                        
                function isJson($string) {
                           json_decode($string);
                              return json_last_error() === JSON_ERROR_NONE;
                              }
      
      if (!isJson($retorno)) {  
                 $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                    "retorno" => $retorno) 
                                    ), TRUE); 
                        fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
      
      } else {
            
        $conteudoSaida = json_decode($retorno,true);
        
        $dados      = $conteudoSaida["return"][0];
        
     
    
        
        $conteudoFormatado =
            array("return" => $dados);
        
            fwrite($arquivo,$log_datahora_ini."$acao"."-conteudoFormatado->".json_encode($conteudoFormatado)."\n");                
                        
        $jsonSaida = $conteudoFormatado;

  }
      

                        fclose($arquivo);

