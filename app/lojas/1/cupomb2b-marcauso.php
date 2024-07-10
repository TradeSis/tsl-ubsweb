<?php
/* #012023 helio cupom desconto b2b */
/* programa php - api marcausocupomb2b */

$log_datahora_ini = date("dmYHis");
$acao="marcausocupomb2b";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apilojas_cupomb2b".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");

$progr = new chamaprogress();

$conteudoEntrada = (object) $jsonEntrada["dadosEntrada"]["cupomb2b"][0];
   
if ("$conteudoEntrada->estabOrigem"<>$parametro) {
    $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "Filial Origem do parametro <> Filial Origem do JSON") 
                    ), TRUE); 
    fwrite($arquivo,$identificacao."-ERRO1->"."Filial Origem do parametro <> Filial Origem do JSON"."\n");                    
    return;
}
   
if ("$conteudoEntrada->idCupom"<>$parametro2) {
    $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "IDCupom do parametro <> IDCupom do JSON") 
                    ), TRUE); 
    fwrite($arquivo,$identificacao."-ERRO1->"."IDCupom do parametro <> IDCupom do JSON"."\n");                    
    return;
}
    
    $conteudoEntrada = json_encode($jsonEntrada);

      $retorno = $progr->executarprogress("lojas/1/cupomb2b-marcauso",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

        if (!isJson($retorno)) {  
            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
            fwrite($arquivo,$identificacao."-ERRO\n");
        } else {

            $conteudoSaida = (object) json_decode($retorno,true);
        
            

            if ($conteudoSaida->cupomb2b[0]["idCupom"]) {

                $jsonSaida = json_decode($retorno,true);

            } else {
            
            $status = (object) $conteudoSaida->conteudoSaida[0];
            
            fwrite($arquivo,$identificacao."-ERRO->".$status->descricaoStatus."\n");

            $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                                    "retorno" => $status->descricaoStatus) 
                            ), TRUE); 


            }


        }

    fclose($arquivo);
            
            
?>