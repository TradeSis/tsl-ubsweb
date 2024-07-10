<?php

/**/


/***/
$log_datahora_ini = date("dmYHis");
$acao="ieproBuscaArquivos";  
$arqlog = "/ws/log/apiiepro_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");

fwrite($arquivo,"\n");

    $ocorrencia = "";

    $operacaoSol = "";
    $nome_arquivo = $jsonEntrada["dadosEntrada"][0]["nome_arquivo"];
    $tipo_arquivo  = substr($nome_arquivo, 0, 1);
    switch ($tipo_arquivo) {
        case "C":
            $operacaoSol = "confirmacao";
        break;
        case "R":
            $operacaoSol = "retorno";
        break;
       default:
       break;
    }

    if ($operacaoSol==""){
        $array = array("jsonSoapResponse" =>array(array(
            "operacao" => $operacao,
            "nome_arquivo" => $nome_arquivo,
            "operacaoSol" => $operacaoSol,
            "codocorrencia" => $codocorrencia,
            "ocorrencia" => "Arquivo Invalido")),
            "hd" => $arrayhd,
            "tr" => $arraytr,
            "tl" => $arraytl);



        $dados["dadosEntrada"] = array($array); 


        $jsonSaida = $dados;
        return;
    }

    $Entrada = $jsonEntrada;
     
    //ar_dump($Entrada);


    $conteudoEntrada = array("dadosEntrada" => $Entrada["dadosEntrada"][0]);

  
    $conteudoFormatado = json_encode($conteudoEntrada);
    fwrite($arquivo,$log_datahora_ini."$acao"."-REQUEST->".$conteudoFormatado."\n");

 

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

    fwrite($arquivo,$log_datahora_ini."$acao"."-RESPONSE IEPRO->".$curl_response."\n");

    $info = curl_getinfo($curl);

    $erro = null;
    if (curl_errno($curl)) {
        $errno= curl_errno($curl);
        $erro = curl_error($curl);
    }
    curl_close($curl); // close cURL handler
    
    $retorno = json_decode($curl_response,true);


    //var_dump($retorno);
   
        $jsonEntrada = $retorno;
   
    
    $operacao = "";
    $array = array();
    $arrayhd = array();
    $arraytr = array();
    $arraytl = array();
    $valor   = array();
    
    $ocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["ocorrencia"];
    $codocorrencia = $jsonEntrada["jsonSoapResponse"]["relatorio"]["codigo"];

    $confirmacao = $jsonEntrada["jsonSoapResponse"]["confirmacao"];
    if (isset($confirmacao)) {
       
        $operacao = "confirmacao";
    }
    $retorno = $jsonEntrada["jsonSoapResponse"]["retorno"];
    if (isset($retorno)) {
        $operacao = "retorno";
    }
    if (!isset($ocorrencia)){
        if(!isset($codocorrencia)) {
            $codocorrencia=0;
            $ocorrencia="";
        }
        if ($operacaoSol!=$operacao) {
      
            $ocorrencia = "Solicitando ".$operacaoSol." e arquivo é ".$operacao;
        }
   
    }
    

    //

    //

    if ( ($operacao=="retorno" && $operacaoSol=="retorno") || ($operacao=="confirmacao" && $operacaoSol=="confirmacao")) {
         
        $new = simplexml_load_string($jsonEntrada["xmlRetorno"]);

        // Convert into json
        $con = json_encode($new);
            
        // Convert into associative array
        $newArr = json_decode($con, true);
       // var_dump($newArr);
        foreach($newArr as $indice => $valor)  {
           // echo "(0)  -- ".$indice." -> ".$valor."\n";
            foreach($valor as $indice1 => $valor1) {
              //  echo "  (1)  -- ".$indice1." -> ".$valor1."\n";
                if (is_array($valor1["@attributes"])) {
                    $arraytr[] = $valor1["@attributes"];
                }

                foreach($valor1 as $indice2 => $valor2) {
                  //  echo "      (2)  -- ".$indice2." -> ".$valor2."\n";
                    
                    if (is_array($valor2["@attributes"])) {
                        $arraytr[] = $valor2["@attributes"];
                    }
                  /*  if($indice2=="tr"){

                      //  var_dump($valor2);
                      if(isset($valor2["@attributes"])) {
                   
                      } else { 
                        
                        $arraytr[] = $valor2;

                      }*/ 
                    foreach($valor2 as $indice3 => $valor3) {
                      //  echo "          (3)  -- ".$indice3." -> ".$valor3."\n";
                        if (is_array($valor3["@attributes"])) {
                            $arraytr[] = $valor3["@attributes"];
                        } else {
    
                       //  var_dump($valor3["@attributes"]);
                      
                       // $arraytr[] = $valor3["@attributes"];
                        foreach($valor3 as $indice4 => $valor4) {
                          //  echo "              (4)  -- ".$indice4." -> ".$valor4."\n";
                           
                            foreach($valor4 as $indice5 => $valor5) {
                            //  echo "                  (5)  -- ".$indice5." -> ".$valor5."\n";
                            }
                        }}

                    }
                    
                }
            } 
        }

      foreach($newArr as $indice => $valor)  {
        //    echo "(0)  -- ".$indice." -> ".$valor."\n";
            $teste = $valor[0];
            
          //  var_dump($teste["tr"]);
           foreach($valor as $indice1 => $valor1) {
        //    echo " (1) -- --- ".$indice1." -> ".$valor1."\n";
                 if($indice1=="hd") {
                   
                    if (isset($valor1["hd"]["@attributes"])) {
                        $arrayhd[] = $valor1["hd"]["@attributes"];
                    }
                 }
                 if($indice1=="tr") {
                  
                     foreach($valor1 as $indice2 => $valor2) {
                       //var_dump($indice2);
                       if ($indice2=="tr") {
                         //  var_dump($valor2);
                           foreach($valor2 as $indice3 => $valor3) {
                           //    var_dump($valor3["@attributes"]);
                             //  $arraytr[] = $valor3["@attributes"];
                           }
                       }
                        
                     }
                   
                 }
                 if($indice1=="tl") {
                    if (isset($valor1["tl"]["@attributes"])) {
                     $arraytl[] = $valor1["tl"]["@attributes"];
                    }
                 }

               
            
         }
     }
/****      
        foreach($newArr as $indice => $valor)  {
          //  echo "(0)  -- ".$indice." -> ".$valor."\n";
            foreach($valor as $indice1 => $valor1) {
          //   echo " (1) -- --- ".$indice1." -> ".$valor1."\n";
             foreach($valor1 as $indice2 => $valor2) {
                echo "   (2) -- --- ".$indice2." -> ".$valor2."\n";
                if($indice2=="hd") {
                    $arrayhd[] = $valor2["@attributes"];
                }
                if($indice2=="tr") {

                  //  var_dump($valor2);
                   // $arraytr[] = $valor2;
                    foreach($valor2 as $indice4 => $valor4)
                    {
                //     echo "  (4) -- --- --- ".$seqindice."-".$indice4." -> ".$valor4."\n";
                        
                                $arraytr[] = $valor4["@attributes"];
                        
                        
                    }
                }
                if($indice2=="tl") {
                    $arraytl[] = $valor2["@attributes"];
                }

            }
   
            }

        }
*** */        
    }


    if ($operacao=="retornoxxxxx desativado" && $operacaoSol=="retorno") {
        /* era ate 20042022
        $new = simplexml_load_string($jsonEntrada["xmlRetorno"]);
        // Convert into json
        $con = json_encode($new);
        // Convert into associative array
        $newArr = json_decode($con, true);
    
        foreach($newArr as $indice => $valor)  {
           //   echo "(0)  -- ".$indice." -> ".$valor."\n";

              foreach($valor as $indice1 => $valor1) {
           //    echo " (1) -- --- ".$indice1." -> ".$valor1."\n";
                    if($indice1=="hd") {
                        $arrayhd[] = $valor1["@attributes"];
                    }
                    if($indice1=="tr") {
                     
                        foreach($valor1 as $indice2 => $valor2) {
                            $arraytr[] = $valor2["@attributes"];
                        }
                      
                    }
                    if($indice1=="tl") {
                        $arraytl[] = $valor1["@attributes"];
                    }

                  
               
            }
        }
            ***/
            $new = simplexml_load_string($jsonEntrada["xmlRetorno"]);
            // Convert into json
            $con = json_encode($new);
            // Convert into associative array
            $newArr = json_decode($con, true);
            
            $arraytr = array();
            $atributo = array();
          //  var_dump($newArr);
        
          foreach($newArr as $indice => $valor)  {
            //   echo "(0)  -- ".$indice." -> ".$valor."\n";
                fwrite($arquivo,$log_datahora_ini."$acao"."-LENDO XML->"."(0)  -- ".$indice." -> ".$valor."\n");

              // var_dump($valor);
               foreach($valor as $indice1 => $valor1) {
           //         echo "  (1)  -- ".$indice1." -> ".$valor1."\n";
                    fwrite($arquivo,$log_datahora_ini."$acao"."-LENDO XML->"."  (1)  -- ".$indice1." -> ".$valor1."\n");
           
                    //var_dump($valor1);
                    foreach($valor1 as $indice2 => $valor2) {
          //              echo "      (2)  -- ".$indice2." -> ".$valor2."\n";
                          fwrite($arquivo,$log_datahora_ini."$acao"."-LENDO XML->"."      (2)  -- ".$indice2." -> ".$valor2."\n");

                          fwrite($arquivo,$log_datahora_ini."$acao"."-LENDO XML->"."      (2)  -- ".$indice2." = tr "."\n");
                        if ($indice2=="@attributes"&&$indice1=="tr") {
                             fwrite($arquivo,$log_datahora_ini."$acao"."-PEGANDO->"."      (2.1)  -- ".$indice2." -> ".$valor2["@attributes"]."\n");
                              $arraytr[] = $valor2["@attributes"];
                             
                        }
                         else {
                            if($indice2=="tr"||$indice1=="tr") {
                                foreach($valor2 as $indice3 => $valor3) {

                                fwrite($arquivo,$log_datahora_ini."$acao"."-LENDO XML->"."        (3)  -- ".$indice3." -> ".$valor3."\n");
   
                                    if (is_array($valor3["@attributes"])) {
                                    $arraytr[] = $valor3["@attributes"];
                                fwrite($arquivo,$log_datahora_ini."$acao"."-PEGANDO  ->"."        (3)  -- ".$indice3." -> ".$valor3["@attributes"]."\n");
                                    
                                    } else {
                                        $arraytr[] = $valor3;
                                fwrite($arquivo,$log_datahora_ini."$acao"."-PEGANDO  ->"."        (3)  -- ".$indice3." -> ".$valor3."\n");
                                        
                                    }
        
                                }
                                //array_push($arraytr,$atributo);
                            }
                        }
                    }
               }
          }
        
    }

   
    $array = array("jsonSoapResponse" =>array(array(
        "operacao" => $operacao,
        "nome_arquivo" => $nome_arquivo,
        "operacaoSol" => $operacaoSol,
        "codocorrencia" => $codocorrencia,
        "ocorrencia" => $ocorrencia)),
        "hd" => $arrayhd,
        "tr" => $arraytr,
        "tl" => $arraytl);


    $dados["dadosEntrada"] = $array; 
    
    fwrite($arquivo,$log_datahora_ini."$acao"."-JSON API->".json_encode($dados)."\n");

    $jsonSaida = $dados;
    fclose($arquivo);
    
    
?>
