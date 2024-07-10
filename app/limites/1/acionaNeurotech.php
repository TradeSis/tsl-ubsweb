<?php
/*VERSAO 2 23062021*/
$defaultTimeZone='UTC';

                        $log_datahora_ini = date("dmYHis");
                        $acao="acionaNeurotech";  
                        $arqlog  = "/ws/log/apilimites_"."$acao".date("dmY").".log";
                        $arqerro = "/ws/log/apilimites_"."$acao".date("dmY")."ERRO.log";
                        


$dadosEntrada = $jsonEntrada["dadosEntrada"];

$dados = $dadosEntrada["dados"][0];
$parametros = $dadosEntrada["parametros"];

$Propriedade = array('Key' => 'USUARIO','Value' => 'USUARIO');
$Properties = array('Key' => 'FILIAL_ID','Value' => '0');
$Submit     = array(
                      "Policy" => $dados["politica"],
                      "Version" => "",
                      "ResultingVariable" => "FLX_PRINCIPAL",
                      "Id" => $dados["id"],
                      "Inputs" => $parametros
                    );


$arguments = array('Authentication' =>
                          array('Login' => "148",
                                'Password' => 'abcd@1234',
                                'Properties' => array($Properties))
                        ,'Submit' => $Submit
                        ,'Properties' => array($Propriedade));


$conteudoFormatado = json_encode($arguments);

         $arquivo = fopen($arqlog,"a");
         fwrite($arquivo,"\n\n".$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
         fwrite($arquivo,"\n\n".$log_datahora_ini."$acao"."-PAYLOAD->".json_encode($arguments)."\n");

         fclose($arquivo);

if ($dados["ambiente"]=="HML"||$dados["ambiente"]=="hml") {
  $service_url = 'https://dr-lebes-hml.neurotech.com.br/services/rest/workflow/submit';
} else {
  $service_url = 'https://dr-lebes-prd.neurotech.com.br/services/rest/workflow/submit';
}

         $arquivo = fopen($arqlog,"a");
         fwrite($arquivo,$log_datahora_ini."$acao"."-URL->".$service_url."\n");
         fclose($arquivo);

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 0);
    curl_setopt($curl, CURLOPT_TIMEOUT, 120); //timeout in seconds
    curl_setopt($curl, CURLOPT_FAILONERROR, true); // Required for HTTP error codes to be reported via our call to curl_error($ch)
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
      'Content-Type: application/json',
      'Content-Length: ' . strlen($conteudoFormatado))
    );
//    curl_setopt($curl, CURLOPT_HEADER, true);
//    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    $curl_response = curl_exec($curl);



//
    $info = curl_getinfo($curl);

    $erro = null;
    if (curl_errno($curl)) {
        $errno= curl_errno($curl);
        $erro = curl_error($curl);
    }
    curl_close($curl); // close cURL handler
    
    $retorno = json_decode($curl_response,true);
//
    /*echo "info".$info['http_code']."-"."trim=".trim($curl_response);    
    echo "\n---".isset($retorno["Result"]["Outputs"])."\n";
    echo "\n".isset($retorno["Result"]["Result"]);    
    echo isset($retorno["Result"]["Result"]) ? "OK" : "NAO" ;
    */
         $arquivo = fopen($arqlog,"a");
         fwrite($arquivo,$log_datahora_ini."$acao"."-HTTP_CODE->".$info['http_code']."\n");
         fclose($arquivo);

         $arquivo = fopen($arqlog,"a");
         fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$curl_response."\n");
         fclose($arquivo);

    if (!isset($erro) && $info['http_code']==200 && trim($curl_response)<>"" && isset($retorno["Result"]["Result"])) {


      $vi = 0;
      $retornoParametros = array();
      foreach ($retorno["Result"]["Outputs"] as $key=>$value) {
      //    var_dump($value);
        // echo "\n".$key."=".$value["Key"];


         switch ($value["Key"]) {
            case "RET_MOTIVOS":
                  $retornoParametros[$vi] = array('NmParametro'=>$value["Key"],'VlParametro'=>$value["Value"]);
                  $vi = $vi + 1;
                  break;
             case "RET_NOVOLIMITE":
                   $retornoParametros[$vi] = array('NmParametro'=>$value["Key"],'VlParametro'=>$value["Value"]);
                   $vi = $vi + 1;
                   break;
              case "RET_LIMITECOMPL":
                    $retornoParametros[$vi] = array('NmParametro'=>$value["Key"],'VlParametro'=>$value["Value"]);
                    $vi = $vi + 1;
                    break;
               case "RET_DTLIMITEVAL":
                     $retornoParametros[$vi] = array('NmParametro'=>$value["Key"],'VlParametro'=>$value["Value"]);
                     $vi = $vi + 1;
                     break;

          }



      }

      $jsonSaida     = array(
              "dadosSaida"   => array(
                    "dados" => array(array(
                        "IdOperacao" => $retorno["OperationCode"],
                        "CdOperacao" => $retorno["StatusCode"],
                        "DsMensagem" => $retorno["Message"],
                        "Resultado"  => $retorno["Result"]["Result"])),
                    "parametros"   => $retornoParametros
                  ));

    } else {
         /**
         $arquivo = fopen($arqlog,"a");
         fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
         fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$curl_response."\n");
         fclose($arquivo);
         **/
         
         $arquivo = fopen($arqerro,"a");
         fwrite($arquivo,"\n".$log_datahora_ini."NOVA REQUISICAO http_code=".$info['http_code']."\nENTRADA\n".json_encode($jsonEntrada));
         fwrite($arquivo,"\n".$log_datahora_ini."CONTEUDO FORMATADO\n".$conteudoFormatado);
         fwrite($arquivo,"\n".$log_datahora_ini."RESPONSE\n".$curl_response);
            if (isset($erro)) {
             fwrite($arquivo,"\n".$log_datahora_ini."TEM ERRO".$errno);
             }
         fwrite($arquivo,"\n".$log_datahora_ini."ERRO\n".$erro);
         fwrite($arquivo,"\n".$log_datahora_ini."FINAL\n");
         fclose($arquivo);
            
        $jsonSaida     = array(
              "dadosSaida"   => array(
                    "dados" => array(array(
                        "DsMensagem" => "ERRO=".$info['http_code']." ".$erro,
                        "Resultado"  => "ERRO"))
                  ));
         

    }




