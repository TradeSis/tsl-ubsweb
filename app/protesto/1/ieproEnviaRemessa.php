<?php

$log_datahora_ini = date("dmYHis");
$acao="ieproEnviaRemessa";  
$arqlog = "/ws/log/apiiepro_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");

fwrite($arquivo,"\n");

    $Entrada = str_replace("\/", "/", json_encode($jsonEntrada));

    
    //var_dump($Entrada);
    $Entrada = json_decode($Entrada, TRUE);
    
  //  var_dump($Entrada);

    $conteudoEntrada = array("dadosEntrada" => 
                            array("nome_arquivo" => $Entrada["dadosEntrada"][0]["nome_arquivo"],
                                  "dadosXml" =>  $Entrada["dadosEntrada"][0]["dadosXml"]
                                            ));

   
    
    $operacaoSol  = $Entrada["dadosEntrada"][0]["operacao"];
    $nome_arquivo = $Entrada["dadosEntrada"][0]["nome_arquivo"];                                        
 
      
    $conteudoFormatado = json_encode($conteudoEntrada);
    fwrite($arquivo,$log_datahora_ini."$acao"."-FORMATADO->".$conteudoFormatado."\n");
    
    
    //var_dump($conteudoFormatado);


    fwrite($arquivo,$log_datahora_ini."$acao"."-HML->".$hml."\n");

if ($hml==true) {
    $service_url = 'http://172.19.130.11:5555/gateway/lebesIEPRO/1.0/protestos/' . $operacaoSol;
} else {    
    $service_url = 'http://172.19.130.5:5555/gateway/lebesIEPRO/1.0/protestos/' . $operacaoSol;
 }

 fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");


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
    fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$curl_response."\n");


    //var_dump($curl_response);
    
    $info = curl_getinfo($curl);

    $erro = null;
    if (curl_errno($curl)) {
        $errno= curl_errno($curl);
        $erro = curl_error($curl);
    }
    curl_close($curl); // close cURL handler
    
    $retorno = json_decode($curl_response,true);
    

    //var_dump($retorno);
   
    $operacao = "";
    $array = array();

    //var_dump($retorno);
    if ($operacaoSol == "remessas") {
        /*
        $jsonEntrada = $retorno;
        $ocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["comarca"]["ocorrencia"];
        $codocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["comarca"]["codigo"];
        if (!isset($ocorrencia)) {
            $ocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["ocorrencia"];
            $codocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["codigo"];
        }
        */
        //
        //var_dump($retorno["xmlRetorno"]);
        $new = simplexml_load_string($retorno["xmlRetorno"]);

        // Convert into json
        $con = json_encode($new);
        $newArr = json_decode($con, true);
        $arraytr = array();
        $atributo = array();
        
        //var_dump($newArr);
        
        $ocorrencia = $newArr["ocorrencia"];
        $codocorrencia = $newArr["codigo"];
        if (isset($ocorrencia)) {
            $atributo["nome_arquivo"] = $nome_arquivo;
            $atributo["operacaoSol"]  = $operacaoSol;
            $atributo['Comarca'] = null;
            $atributo['codocorrencia'] = $codocorrencia;
            $atributo['ocorrencia'] = $ocorrencia;

            array_push($arraytr,$atributo);

        } else {

        
     

        //var_dump($newArr);
       

        foreach($newArr as $indice => $valor)  {
            //  echo "(0)  -- ".$indice." -> ".$valor."\n";
              if (is_array($valor["@attributes"]))
             {
                $atributo["nome_arquivo"] = $nome_arquivo;
                $atributo["operacaoSol"]  = $operacaoSol;
                $atributo['Comarca'] = $valor["@attributes"]["CodMun"];
                $atributo['total_registros'] = $valor["total_registros"];
                $atributo['codocorrencia'] = $valor["codocorrencia"];
                $atributo['ocorrencia'] = $valor["ocorrencia"];
                array_push($arraytr,$atributo);
              } else {
  
              
  
                  foreach($valor as $indice1 => $valor1) {
                    
                      $atributo["nome_arquivo"] = $nome_arquivo;
                      $atributo["operacaoSol"]  = $operacaoSol;
                      foreach($valor1 as $indice2 => $valor2) {
                          if ($indice2=="@attributes") {
                            $atributo['Comarca'] = $valor2["CodMun"];
                          } else {
                              if ($indice2=="total_registros") {
                                  $atributo['total_registros'] = $valor2;
                              }
                              if ($indice2=="codigo") {
                                  $atributo['codocorrencia'] = $valor2;
                              }
                              if ($indice2=="ocorrencia") {
                                  $atributo['ocorrencia'] = $valor2;
                              }
                          }
                      }
                      array_push($arraytr,$atributo);
                      
                    }
              }
          }
        } 
        $array = array("jsonSoapResponse" => $arraytr);

        //

        //$jsonEntrada = json_decode($fixoJson, true);
        //var_dump($retorno);
    } else 
   /* if ($operacaoSol == "desistencia")*/ {
        $jsonEntrada = $retorno;
        $ocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["titulo"]["ocorrencia"];
        $codocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["titulo"]["codigo"];
        if (!isset($ocorrencia)) {
            $ocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["ocorrencia"];
            $codocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["codigo"];
        }
        $array = array("jsonSoapResponse" =>array(array(
            "nome_arquivo" => $nome_arquivo,
            "operacaoSol" => $operacaoSol,
            "codocorrencia" => $codocorrencia,
            "ocorrencia" => $ocorrencia)));
        //$jsonEntrada = json_decode($fixoJson, true);
        //var_dump($retorno);
    } 

    
   /* $arrayhd = array();
    $arraytr = array();
    $arraytl = array();
    $valor   = array();
    */
  

  



    
  //  $dados["dadosEntrada"] = array($array); 
    

    $jsonSaida = $array;
    
    fclose($arquivo);

?>
