<?php
/* #082022 helio bau */

$log_datahora_ini = date("dmYHis");
$acao="vincularCliente";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apibau_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");

fwrite($arquivo,$identificacao."-PARAMETRO->".$parametro."\n");
fwrite($arquivo,$identificacao."-PARAMETRO2->".$parametro2."\n");
fwrite($arquivo,$identificacao."-PARAMETRO3->".$parametro3."\n");

$CPF = $parametro;
$CARNE = $parametro2."/".$parametro3;
    
//    $IP = "hmlsacbau";
//    $service_url = "https://".$IP.".jequiti.com.br/api/cliente/";
  

if ($hml==true) {
    $IP = "172.19.130.11:5555";
} else {    
    $IP = "172.19.130.175:5555";
 }
    $service_url = "http://".$IP."/gateway/lebes-jequiti-api/1.0/cliente/".$CPF."/vincular-carne/$CARNE";
    

  // http://172.19.130.11:5555/gateway/lebes-jequiti-api/1.0/cliente

    fwrite($arquivo,$identificacao."-service_url->".$service_url."\n");
    //$Bearer = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjM5ODczNjgiLCJub21lIjoiQ3Jpc2xlaSAiLCJzb2JyZW5vbWUiOiJTYW50b3MiLCJsb2dpbiI6IkxlYmVzIiwiZW1haWwiOiJjcmlzbGVpLnNhbnRvc0BsZWJlcy5jb20uYnIiLCJyb2xlIjoiMiIsImlzcyI6IkplcXVpdGkiLCJleHAiOjE2NjI5OTM2MjQsIm5iZiI6MTY2MTI2NTYyNH0.2nwk9wGej2OXPxea3MAY8Phtitr9whnAqsN4gVEL2uE';

    $conteudoFormatado = json_encode(array());

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
    curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json'  )
    );
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    $curl_response = curl_exec($curl);

    
    
    //  var_dump($result);

    $info = curl_getinfo($curl);
    fwrite($arquivo,$identificacao."-http_code->".$info['http_code']."\n");
    fwrite($arquivo,$identificacao."-->curl_response".$curl_response."\n");

    curl_close($curl); // close cURL handler

    $retorno = json_decode($curl_response,true);
    //var_dump ($retorno);
 
  


fclose($arquivo);
