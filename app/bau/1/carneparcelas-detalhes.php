<?php
/* #082022 helio bau */

$log_datahora_ini = date("dmYHis");
$acao="carneparcelas-detalhes";  

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

//{"dadosEntrada":[{"codigoFilial":"188","CodigoBarras":"12345"}]}

    $jsonEntrada = explode("/", $parametro);
    $CodigoBarras   = $jsonEntrada[0];

//    $IP = "hmlsacbau";
//    $service_url = "https://".$IP.".jequiti.com.br/api/carnes/".$CodigoBarras."/carneparcelas-detalhes";


if ($hml==true) {
    $IP = "172.19.130.11:5555";
} else {    
    $IP = "172.19.130.175:5555";
 }

    

    $service_url = "http://".$IP."/gateway/lebes-jequiti-api/1.0/carnes/".$CodigoBarras."/carneparcelas-detalhes";

    fwrite($arquivo,$identificacao."-service_url->".$service_url."\n");
    $Bearer = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjM5ODczNjgiLCJub21lIjoiQ3Jpc2xlaSAiLCJzb2JyZW5vbWUiOiJTYW50b3MiLCJsb2dpbiI6IkxlYmVzIiwiZW1haWwiOiJjcmlzbGVpLnNhbnRvc0BsZWJlcy5jb20uYnIiLCJyb2xlIjoiMiIsImlzcyI6IkplcXVpdGkiLCJleHAiOjE2NjMyNzI4MDQsIm5iZiI6MTY2MTU0NDgwNH0.Ty0YScHc93uqul-ZeJM5E9NjGkhsWUvdnSsYcg1sblc';

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json' /*,
        'Authorization: '.$Bearer*/ )
    );
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    $curl_response = curl_exec($curl);
   
    $retorno = json_decode($curl_response,true); 
    
    //  var_dump($result);

    $info = curl_getinfo($curl);
    fwrite($arquivo,$identificacao."-http_code->".$info['http_code']."\n");
    fwrite($arquivo,$identificacao."-->curl_response".$curl_response."\n");

    curl_close($curl); // close cURL handler

    if ($info['http_code']==200) {
       
        //var_dump ($retorno);
        $parcelas = array();
    
        foreach($retorno["parcelas"] as $indice => $valor)  {
    
            $parcelas[$indice]["valor"]             = $valor["valor"];
            $parcelas[$indice]["codigoBarras"]      = $valor["codigoBarras"];
            $parcelas[$indice]["dataVencimento"]    = $valor["dataVencimento"];
            $parcelas[$indice]["pagamento"] = $valor["pagamento"]["data"];
            $parcelas[$indice]["numero"]    = $valor["numero"];
            $parcelas[$indice]["idCarne"]    = $valor["idCarne"];
    /*
            echo "(0)  -- ".$indice." -> ".$valor."\n";
            if ($indice=="pagamento") {
                $parcelas[$indice] = $valor["data"];
            } else {
                $parcelas[$indice] = $valor;
            }
      */      
        }
    //var_dump($parcelas);
    
        $conteudoFormatado = json_encode(
            array("getParcelas" => array(
                    "carne"  =>  array(array(
                        "codBarrasCarne" => $retorno["codBarrasCarne"],
                        "nomeCli" => $retorno["nomeCli"],
                        "telefoneCli" => $retorno["telefoneCli"],
                        "cpfClie" => $retorno["cpfClie"],
                        "situacaoCarne" => $retorno["situacaoCarne"])),
                    "parcelas"  =>  $parcelas
                    )
                ));
    
        $jsonSaida = json_decode($conteudoFormatado,true);
     //   fwrite($arquivo,$identificacao."-SAIDA->".$conteudoFormatado."\n");
    
    }
    else {

            $jsonSaida = 
                                    array("status" => $info['http_code'], 
                                    "erro" => substr($retorno,0,80)."\n"
            );

            fwrite($arquivo,$identificacao."-ERRO".substr($retorno,0,80)."\n");
      
      } 


fclose($arquivo);
