<?php


$log_datahora_ini = date("dmYHis");
$acao="efetivaEmprestimo";  
$arqlog = "/ws/log/apipdv_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");


fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");

$dadosEntrada = $jsonEntrada["dadosEntrada"];
if (!isset($dadosEntrada)) {
  
    $dadosEntrada = (object) $jsonEntrada["efetivaEmprestimo"];
    

   $conteudoEntrada = json_encode(
    array("dadosEntrada" => array(
            "efetivaEmprestimo"  =>  array(array(
              "codigo_filial" => $dadosEntrada->codigo_filial,
              "codigo_operador" => $dadosEntrada->codigo_operador,
              "numero_pdv" => $dadosEntrada->numero_pdv,
              "codigo_cliente" => $dadosEntrada->codigo_cliente,
              "numero_contrato" => $dadosEntrada->numero_contrato,
              "codigo_produto" => $dadosEntrada->codigo_produto,
              "valor_tfc"   => $dadosEntrada->valor_tfc,
              "valor_credito" => $dadosEntrada->valor_credito,
              "nsu_venda" => $dadosEntrada->nsu_venda,
              "vendedor" => $dadosEntrada->vendedor,
              "codigo_seguro_prestamista" => $dadosEntrada->codigo_seguro_prestamista,
              "valor_seguro_prestamista" => $dadosEntrada->valor_seguro_prestamista,
              "numero_bilhete" => $dadosEntrada->numero_bilhete,
              "numero_sorte" => $dadosEntrada->numero_sorte,
              "data_emissao" => $dadosEntrada->data_emissao)),    
            "parcelas"  => $dadosEntrada->parcelas)
    ));
    



} else {
    $conteudoEntrada = json_encode($jsonEntrada);
 
}


$progr = new chamaprogress();
//$conteudoEntrada= json_encode($conteudoEntrada);
    
fwrite($arquivo,$log_datahora_ini."$acao"."-conteudoEntrada->".$conteudoEntrada."\n");
  
   $retorno = $progr->executarprogress("pdv/1/efetivaemprestimo",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
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

