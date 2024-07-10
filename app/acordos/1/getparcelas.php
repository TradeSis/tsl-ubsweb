<?php
/* helio 082022 - Acordo Online  */

$log_datahora_ini = date("dmYHis");
$acao="getparcelas";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apiacordos_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}
fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");


$progr = new chamaprogress();

  $conteudoEntrada=json_encode(array('clientes' => array(array(
                          'cpfCnpj' => $parametro)
                          )));

      $retorno = $progr->executarprogress("acordos/1/getparcelas",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

if (!isJson($retorno)) {  
  $jsonSaida = json_decode(json_encode( array("status" => 500, 
                        "retorno" => $retorno) 
                        ), TRUE); 
  fwrite($arquivo,$identificacao."-ERRO\n");
} else {

  $conteudoSaida = (object) json_decode($retorno,true);


  if ($conteudoSaida->conteudoSaida["cliente"][0]) {
      $cliente       = (object) $conteudoSaida->conteudoSaida["cliente"][0];     

      $jsonSaida = array(
        "cliente" =>  $cliente
      );

  } else {
    
    $status = (object) $conteudoSaida->conteudoSaida[0];
   

    $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                             "retorno" => $status->descricaoStatus) 
                    ), TRUE); 


  }


}

    fclose($arquivo);
            
            
?>