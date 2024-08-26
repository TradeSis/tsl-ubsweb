<?php

$log_datahora_ini = date("dmYHis");
$acao="Boletagem";  
$arqlog = "/ws/log/apiboletagem_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}
    /* TRANSFORMA EM MODELO BANRISUL */
    $jsonEntrada = (object) $jsonEntrada["dadosEntrada"];
    $jsonEntradaTitulo = isset($jsonEntrada->titulo[0]) ? (object) $jsonEntrada->titulo[0] : null;
    $jsonEntradaPagador = isset($jsonEntrada->pagador[0]) ? (object) $jsonEntrada->pagador[0] : null;

    $conteudoFormatado= json_encode(
                              array("titulo"  => array(
                                        "nosso_numero" => $jsonEntradaTitulo->nosso_numero,
                                        "seu_numero" => $jsonEntradaTitulo->seu_numero,
                                        "data_vencimento" => $jsonEntradaTitulo->data_vencimento,
                                        "valor_nominal" => $jsonEntradaTitulo->valor_nominal,
                                        "data_emissao" => $jsonEntradaTitulo->data_emissao,
                                        "id_titulo_empresa" => $jsonEntradaTitulo->id_titulo_empresa,
                                        "pagador"  =>  array(
                                            "tipo_pessoa" => $jsonEntradaPagador->tipo_pessoa,
                                            "cpf_cnpj" => $jsonEntradaPagador->cpf_cnpj,
                                            "nome" => $jsonEntradaPagador->nome,
                                            "endereco" => $jsonEntradaPagador->endereco,
                                            "cep" => $jsonEntradaPagador->cep,
                                            "cidade" => $jsonEntradaPagador->cidade,
                                            "uf" => $jsonEntradaPagador->uf
                                        ),
                                    ),
                                    "mensagens"  => $jsonEntrada->mensagens ,
                                  )
                                );

  if ($hml==true) {$service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/cobranca/11271860000186/boletos/emite-boleto-simplificado'; } 
             else {$service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/cobranca/11271860000186/boletos/emite-boleto-simplificado';
}
 /*fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");
 $curl = curl_init($service_url);
 curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
 curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
 curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
 curl_setopt($curl, CURLOPT_HTTPHEADER, array(
   'Content-Type: application/json',
   'Content-Length: ' . strlen($conteudoFormatado))
  );
 curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
 $curl_response = curl_exec($curl);
 $result = json_decode($curl_response, true);
    
  //  var_dump($result);

 $info = curl_getinfo($curl);
 fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");
 fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".json_encode($result)."\n");

 curl_close($curl); // close cURL handler


    if ($info['http_code']==201) {
      $jsonSaida     = array(
              "boleto"   => array(array(
                    "retorno" => "REGISTRADO",
                    "linhaDigitavel" => $result["boleto"]["linhaDigitavel"],
                    "codigoBarras"    => $result["boleto"]["codigoBarras"],
                    "DVNossoNumero"    =>  ""))
            );
    } else {
      fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
            $jsonSaida     = array(
                    "boleto"   => array(array(
                          "retorno" => "ERRO=".$info['http_code']))
                  );

    }

  
   fclose($arquivo);
  
  
    //echo json_decode(json_encode($jsonSaida)) */

    echo $conteudoFormatado; 