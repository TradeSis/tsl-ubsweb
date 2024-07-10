<?php
/* helio 092022 - Reversa Lojas  */


$log_datahora_ini = date("dmYHis");
$acao="reversa-fechacaixa";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apilojas_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");

$progr = new chamaprogress();

$conteudoEntrada = (object) $jsonEntrada["dadosEntrada"]["reversa"][0];
   
if ($conteudoEntrada->estabOrigem<>$parametro) {
    $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "Filial Origem do parametro <> Filial Origem do JSON") 
                    ), TRUE); 
    return;
}
   
if ($conteudoEntrada->codCaixa<>$parametro2) {
    $jsonSaida = json_decode(json_encode( array("status" => 400, 
                    "retorno" => "codigo Caixa do parametro <> codigo Caixa do JSON") 
                    ), TRUE); 
    return;
}
    
    $conteudoEntrada = json_encode($jsonEntrada);

      $retorno = $progr->executarprogress("lojas/1/reversa-fechacaixa",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

        if (!isJson($retorno)) {  
            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
            fwrite($arquivo,$identificacao."-ERRO\n");
        } else {

            $conteudoSaida = (object) json_decode($retorno,true);
        
             
            if ($conteudoSaida->conteudoSaida["pedido"]) {

                // pega o retorno no admcom, e envia para o barramento.
                $conteudo = (object) $conteudoSaida->conteudoSaida["pedido"][0];
                $conteudoFormatado = json_encode(array("pedido" =>
                array("compCod" =>  $conteudo->compCod,
                      "tipoPedido"  =>  $conteudo->tipoPedido,
                      "dataPedido"  =>  $conteudo->dataPedido,
                      "estabOrigem"  =>  $conteudo->estabOrigem,
                      "organizacaoCompras"  =>  $conteudo->organizacaoCompras,
                      "grupoCompradores"  =>  $conteudo->grupoCompradores,
                      "observacaoPedido"  =>  $conteudo->observacaoPedido,
                       "itens" => $conteudoSaida->conteudoSaida["itens"]
                        )
                    ));

                // envia para barramento
               
                if ($hml==true) {
                    $service_url = 'http://172.19.130.11:5555/gateway/backoffice-loja/1.0/gerar-transferencia'; // hml
                } else {    
                 $service_url = 'http://172.19.130.5:5555/gateway/backoffice-loja/1.0/gerar-transferencia'; // prd era .5 mudou em 18/04/2022
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
//                $retornoBarramento = '{"idPedidoGerado": "0400001002","pedido": {} }';
//              $conteudoBarramento = json_decode($retornoBarramento,true);
                
                $idPedidoGerado = $conteudoBarramento["idPedidoGerado"];               

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
                        $jsonEntrada["dadosEntrada"]["reversa"][0]["idPedidoGerado"] = $idPedidoGerado;
                        fwrite($arquivo,$identificacao."-ENTRADA2->".json_encode($jsonEntrada)."\n");

                        $conteudoEntrada2 = json_encode($jsonEntrada);
                        

                        $retorno2 = $progr->executarprogress("lojas/1/reversa-fechacaixapedido",$conteudoEntrada2,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
                        fwrite($arquivo,$identificacao."-SAIDA2->".$retorno2."\n");

                        if (!isJson($retorno2)) {  
                            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                                "retorno" => $retorno2) 
                                                ), TRUE); 
                            fwrite($arquivo,$identificacao."-ERRO\n");
                        } else {
                
                            $conteudoSaida = (object) json_decode($retorno2,true);
                        
                            
                            if ($conteudoSaida->conteudoSaida["pedidofechado"]) {
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
