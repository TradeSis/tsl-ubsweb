<?php
/*VERSAO 2 23062021*/
$defaultTimeZone='UTC';
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

if ($dados["ambiente"]=="HML"||$dados["ambiente"]=="hml") {
  $service_url = 'https://dr-lebes-hml.neurotech.com.br/services/rest/workflow/submit';
} else {
  $service_url = 'https://dr-lebes-prd.neurotech.com.br/services/rest/workflow/submit';
}

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
         
         $arqlog= "/ws/log/NeurotechERRO.log";
         $arquivo = fopen($arqlog,"a");
         fwrite($arquivo,"\nNOVA REQUISICAO http_code=".$info['http_code']."\nENTRADA\n".json_encode($jsonEntrada));
         fwrite($arquivo,"\nCONTEUDO FORMATADO\n".$conteudoFormatado);
         fwrite($arquivo,"\nRESPONSE\n".$curl_response);
            if (isset($erro)) {
             fwrite($arquivo,"\nTEM ERRO".$errno);
             }
         fwrite($arquivo,"\nERRO\n".$erro);
         fwrite($arquivo,"\nFINAL\n");
         fclose($arquivo);

        $jsonSaida     = array(
              "dadosSaida"   => array(
                    "dados" => array(array(
                        "DsMensagem" => "ERRO=".$info['http_code']." ".$erro,
                        "Resultado"  => "ERRO"))
                  ));
         

    }

  //  var_dump($retorno);

    //echo json_decode(json_encode($jsonSaida))

    //echo $conteudoFormatado;
