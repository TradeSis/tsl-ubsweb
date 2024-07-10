<?php

$log_datahora_ini = date("dmYHis");
$acao="consultar-lista-pep";  
$arqlog = "/ws/log/apicliente_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}


$pessoa = $jsonEntrada["pessoa"][0];

$parametros = "";

if (isset($pessoa["cpfCnpj"])) {
  $parametros = "?cpfCnpj=".$pessoa["cpfCnpj"];
}
if (isset($pessoa["nomePessoa"])) {
  if ($parametros == "") {
    $parametros = $parametros . "?";
  } else {
    $parametros = $parametros . "&";
  }
  $parametros = $parametros . "nomePessoa=" . $pessoa["nomePessoa"];
}

if ($parametros == "") {
  
  $jsonSaida     = array(
      "return"   => array(array(
            "status" => "Sem Parametros")),
            "status" => "400",
            "erro" => "Sem Parametros"
        
    );
  return;
}


if ($hml==true) {
  $url = 'http://172.19.130.11:5555';
} else {
  $url = 'http://172.19.130.5:5555'; // Helio 280228
}
 $service_url = $url . "/gateway/lebes-eguardian/1.0/consultar-lista-pep".$parametros;

 fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
    //curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
      'Content-Type: application/json')
    );
//    curl_setopt($curl, CURLOPT_HEADER, true);
//    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 0); 
    curl_setopt($ch, CURLOPT_TIMEOUT, 5 * 60); //timeout in seconds

    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    $curl_response = curl_exec($curl);
    $result = json_decode($curl_response, true);
    
    
    //var_dump($result);

    $info = curl_getinfo($curl);
    fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");
    fwrite($arquivo,$log_datahora_ini."$acao"."-RETORNO_API->".json_encode($result)."\n");

    curl_close($curl); // close cURL handler


    if ($info['http_code']==200) {
      $jsonSaida     = array(
                  
                  "pessoaPEP"    => $result["pessoaPEP"],
                  "status" => "200",
                  "erro" => "OK"
              );
    } else {
      fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
            $jsonSaida     = array(
                 
                    "return"   => array(array(
                          "status" => "ERRO=".$info['http_code'])),
                          "status" => $info['http_code'],
                          "erro" => "ERRO=".$info['http_code']
                  );

    }

    fwrite($arquivo,$log_datahora_ini."$acao"."-jsonSaida->".json_encode($jsonSaida)."\n");

   fclose($arquivo);
  
  
    //echo json_decode(json_encode($jsonSaida))

    //echo $conteudoFormatado;
