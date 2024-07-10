<?php


$log_datahora_ini = date("dmYHis");
$acao="consultaProdutosFinanceiros";  
$arqlog = "/ws/log/apipdv_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");


fwrite($arquivo,$log_datahora_ini."$acao"."-jsonEntrada->".json_encode($jsonEntrada)."\n");

$dadosEntrada = $jsonEntrada["consultaProdutosFinanceiros"][0];
if (!isset($dadosEntrada)) {
  
    $dadosEntrada = (object) $jsonEntrada;
    
  

   $conteudoEntrada = json_encode(
        array(
            "consultaProdutosFinanceiros"  =>  
                array($dadosEntrada->consultaProdutosFinanceiros )
        )
    );
    



} else {
    $conteudoEntrada = json_encode($jsonEntrada);
 
}

fwrite($arquivo,$log_datahora_ini."$acao"."-conteudoEntrada->".$conteudoEntrada."\n");


$progr = new chamaprogress();
//$conteudoEntrada= json_encode($conteudoEntrada);
    
  
   $retorno = $progr->executarprogress("pdv/1/consultaprodutosfinanceiros",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
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
            
            $dados      = $conteudoSaida["return"]["dados"][0];
            
            $produtos      = $conteudoSaida["return"]["produtos"];
            $dados["produtos"] = $produtos;
            
            $conteudoFormatado =
                array("return" => $dados);
            
                fwrite($arquivo,$log_datahora_ini."$acao"."-conteudoFormatado->".json_encode($conteudoFormatado)."\n");                
                            
            $jsonSaida = $conteudoFormatado;

      }
      

                        fclose($arquivo);

