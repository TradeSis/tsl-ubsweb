<?php
/* helio 102022 - BAG  */

$log_datahora_ini = date("dmYHis");
$acao="bag-fecha";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apilojas_bag".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");

$progr = new chamaprogress();

$conteudoEntrada = (object) $jsonEntrada["dadosEntrada"]["bag"][0];
   
if ("$conteudoEntrada->estabOrigem"<>$parametro) {
    $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "Filial Origem do parametro <> Filial Origem do JSON") 
                    ), TRUE); 
    return;
}
   
if ("$conteudoEntrada->cpf"<>$parametro2) {
    $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "CPF do parametro <> CPF do JSON") 
                    ), TRUE); 
    return;
}
    
    $conteudoEntrada = json_encode($jsonEntrada);

      $retorno = $progr->executarprogress("lojas/1/bag-fecha",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

        if (!isJson($retorno)) {  
            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
            fwrite($arquivo,$identificacao."-ERRO\n");
        } else {

            $conteudoSaida = (object) json_decode($retorno,true);
        
             
            if ($conteudoSaida->conteudoSaida["bag"]) {

                // pega o retorno no admcom, e envia para o barramento.
                $conteudo = (object) $conteudoSaida->conteudoSaida["bag"][0];
                $cliente  = (object) $conteudoSaida->conteudoSaida["cliente"][0];
                
                $conteudoFormatado = json_encode(array("bag" =>
                array("codigoLoja" =>  "$conteudo->estabOrigem",
                      "consultor"  =>  "$conteudo->consultor",
                      "dataCriacao"  =>  $conteudo->datacriacao,
                      "dataSaida"  =>  $conteudo->datasaida,
                      "cliente" => array(
                        "codigoCliente" =>  "$cliente->codigoCliente",
                        "cpfCnpj" =>  "$cliente->cpf",
                        "nome" =>  $cliente->nome,
                        "celular" =>  $cliente->celular,
                        "email" =>  $cliente->email,
                        "endereco" => array(
                            "cep" =>  $cliente->cep,
                            "logradouro" =>  $cliente->logradouro,
                            "numero" =>  $cliente->numero,
                            "complemento" =>  $cliente->complemento,
                            "bairro" =>  $cliente->bairro,
                            "cidade" =>  $cliente->cidade,
                            "uf" =>  $cliente->estado,
                        )
                        ),
                      "itens" => $conteudoSaida->conteudoSaida["itens"]
                        )
                    ));

                // envia para barramento
               
                if ($hml==true) {
                    $service_url = 'http://172.19.130.11:5555/gateway/lebes-bag/1.0/bags'; // hml
                } else {    
                 $service_url = 'http://172.19.130.5:5555/gateway/lebes-bag/1.0/bags'; // prd era .5 mudou em 18/04/2022
                 }
                  
               //  echo $service_url;
               
               fwrite($arquivo,$identificacao."-service_url->".$service_url."\n");
               fwrite($arquivo,$identificacao."-CONTEUDOFORMATADO->".$conteudoFormatado."\n"); 
                         
                 $curl = curl_init($service_url);
                 curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
                 curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
                 curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
                 curl_setopt($curl, CURLOPT_HTTPHEADER, array(
                   'Content-Type: application/json'
                   ,'Content-Length: ' . strlen($conteudoFormatado))
                 );
             //   curl_setopt($curl, CURLOPT_HEADER, true);
             //    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
                 curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
                 $curl_response = curl_exec($curl);
                 $retorno = $curl_response;
                 $info = curl_getinfo($curl);
             
                 fwrite($arquivo,$identificacao."-http_code->".$info['http_code']."\n");
                 fwrite($arquivo,$identificacao."-->curl_response".$curl_response."\n");
             
                 curl_close($curl); // close cURL handler
                 //var_dump($retorno);
 
                 $conteudoBarramento = json_decode($retorno, true);
             
                // pega retorno barramento
              
                
//                $retornoBarramento = '{"idPedidoGerado": "","pedido": {},"erros": 
//                            [{"code": "290",
//                            "mensagem": "erro do sap"
//                        }
//                    ]
//                }';

//$retornoBarramento = '{ "bag": { "idBag": "70"} }';
//$conteudoBarramento = json_decode($retornoBarramento,true);
                

                $idBag = $conteudoBarramento["bag"]["idBag"];        
                fwrite($arquivo,$identificacao."-RETORNOBARRAMENTO->".json_encode($conteudoBarramento)."\n");                       
                fwrite($arquivo,$identificacao."-idBag->".$idBag."\n");

                if ($conteudoBarramento["erros"][0]||$info['http_code']<>200) {
                    if ($info['http_code']==200) {
                        $code = 400;
                    } else 
                    {
                        $code = $info['http_code'];
                    }
                    $mensagem = "ERRO INTEGRACAO COM SAP.";
                    if($conteudoBarramento["erros"][0]) {
                        $mensagem="";
                        foreach($conteudoBarramento["erros"] as $indice => $valor)  {    
                            $mensagem = $mensagem . $valor["mensagem"] . " - ";
                        }
                    }
                    $jsonSaida = json_decode(json_encode( array("status" => $code, 
                        "retorno" => $mensagem) //$conteudoBarramento["erros"][0]["code"] . " - ". $conteudoBarramento["erros"][0]["mensagem"]) 
                        ), TRUE); 

                } else {

                        // envia para admcom o retorno
                        $jsonEntrada["dadosEntrada"]["bag"][0]["idBag"] = $idBag;
                        fwrite($arquivo,$identificacao."-ENTRADA2->".json_encode($jsonEntrada)."\n");

                        $conteudoEntrada2 = json_encode($jsonEntrada);
                        

                        $retorno2 = $progr->executarprogress("lojas/1/bag-fechabag",$conteudoEntrada2,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
                        fwrite($arquivo,$identificacao."-SAIDA2->".$retorno2."\n");

                        if (!isJson($retorno2)) {  
                            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                                "retorno" => $retorno2) 
                                                ), TRUE); 
                            fwrite($arquivo,$identificacao."-ERRO\n");
                        } else {
                
                            $conteudoSaida = (object) json_decode($retorno2,true);
                        
                            
                            if ($conteudoSaida->conteudoSaida["bag"]) {
                                // retora para loja

                                    $jsonSaida = json_decode($retorno2,true);

                            } else {
                    
                                $status = (object) $conteudoSaida->conteudoSaida[0];
                                
                    
                                $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                                                        "retorno" => $status->descricaoStatus) 
                                                ), TRUE); 
                    
                    
                                }

                    }
                } 

            } else {
            
            $status = (object) $conteudoSaida->conteudoSaida[0];
            

            $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                                    "retorno" => $status->descricaoStatus) 
                            ), TRUE); 


            }


        }

    fclose($arquivo);
            
            
?>
