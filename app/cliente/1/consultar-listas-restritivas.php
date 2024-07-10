<?php

$log_datahora_ini = date("dmYHis");
$acao="consultar-listas-restritivas";  
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
  $parametros = "0?cpfCnpj=".$pessoa["cpfCnpj"];
} else {
    if (isset($pessoa["nomePessoa"])) {
       $parametros = "1?nomePessoa=" . $pessoa["nomePessoa"];
    }
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
  $url = 'http://172.19.130.5:5555'; // Helio - 28022024
}
 $service_url = $url . "/gateway/lebes-eguardian/1.0/consultar-listas-restritivas/".$parametros;

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
    
    
    $new = simplexml_load_string($result["result"]);
    $con = json_encode($new);
    $EGUARDIAN = json_decode($con, true);
    $listas = array();

    fwrite($arquivo,$log_datahora_ini."$acao"."-ARRAY->".json_encode($EGUARDIAN["LISTADO"]["TB_LV"])."\n");

    if (isset($EGUARDIAN["LISTADO"]["TB_LV"]["DE_LISTADO"])) {

            $atributo["DE_LISTADO"]     = $EGUARDIAN["LISTADO"]["TB_LV"]["DE_LISTADO"];
            $atributo["DE_TP_LISTA"]    = $EGUARDIAN["LISTADO"]["TB_LV"]["DE_TP_LISTA"];
            array_push($listas,$atributo);
     
    } else {
      foreach ($EGUARDIAN["LISTADO"] as $LISTADO) {
    
        if (isset($LISTADO["TB_LV"]["DE_TP_LISTA"])) {        
            $atributo["DE_LISTADO"] = $LISTADO["TB_LV"]["DE_LISTADO"];
            $atributo["DE_TP_LISTA"] = $LISTADO["TB_LV"]["DE_TP_LISTA"];
            array_push($listas,$atributo);
        }
      }
    } 
    /*
    else {
    foreach ($EGUARDIAN["LISTADO"] as $LISTADO) {
        $nomes = explode("-", $LISTADO["TB_LV"]["DE_LISTADO"]);
        $nome = trim($nomes[0]);
       if ($nome == $pessoa["nomePessoa"]) {
          $atributo["DE_LISTADO"] = $nome;
          $atributo["DE_TP_LISTA"] = $LISTADO["TB_LV"]["DE_TP_LISTA"];
          array_push($listas,$atributo);
        }
      }
    }
    */
  

    $info = curl_getinfo($curl);
    fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");
    fwrite($arquivo,$log_datahora_ini."$acao"."-RETORNO_API->".json_encode($result)."\n");
    fwrite($arquivo,$log_datahora_ini."$acao"."-listas->".json_encode($listas)."\n");
    fwrite($arquivo,$log_datahora_ini."$acao"."-JSON_EGUARDIAN->".json_encode($EGUARDIAN)."\n");

    curl_close($curl); // close cURL handler


    if ($info['http_code']==200) {
      $jsonSaida     = array(
                  
                  "EGUARDIAN"    => $listas,
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
