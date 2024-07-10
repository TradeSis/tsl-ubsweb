<?php
/* #082022 helio bau */

$log_datahora_ini = date("dmYHis");
$acao="getcliente";  

$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apibau_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");

//fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}


    $jsonEntrada = explode("/", $parametro);
    $cpf   = $jsonEntrada[0];


    if ($hml==true) {
        $IP = "172.19.130.11:5555";
    } else {    
        $IP = "172.19.130.175:5555";
     }
    
   // $service_url = "https://".$IP.".jequiti.com.br/api/cliente/".$cpf;
    $service_url = "http://".$IP."/gateway/lebes-jequiti-api/1.0/cliente/".$cpf;
    //http://172.19.130.11:5555/gateway/lebes-jequiti-api/1.0/cliente/84542814017

    fwrite($arquivo,$identificacao."-service_url->".$service_url."\n");
    $Bearer = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjM5ODczNjgiLCJub21lIjoiQ3Jpc2xlaSAiLCJzb2JyZW5vbWUiOiJTYW50b3MiLCJsb2dpbiI6IkxlYmVzIiwiZW1haWwiOiJjcmlzbGVpLnNhbnRvc0BsZWJlcy5jb20uYnIiLCJyb2xlIjoiMiIsImlzcyI6IkplcXVpdGkiLCJleHAiOjE2NjMxOTA4MjAsIm5iZiI6MTY2MTQ2MjgyMH0.OYHtP-iL4pd9dHXJ44Z-JY7oTlfw525To3bKV_VtYBE';

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json' /*,
        'Authorization: '.$Bearer*/ )
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
 
    if ($info['http_code']==200) {
        $conteudoFormatado = json_encode(
        array("getCliente" => array($retorno)
            )
        );

        fwrite($arquivo,$identificacao."-SAIDA->".$conteudoFormatado."\n");
        $jsonSaida = json_decode($conteudoFormatado,true);

    } else {
        $jsonSaida = 
        array("status" => $info['http_code'], 
        "erro" => substr($retorno,0,80)."\n"
        );
        fwrite($arquivo,$identificacao."-ERRO\n");

    }
    ;


fclose($arquivo);
