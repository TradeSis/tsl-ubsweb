<?php

$log_datahora_ini = date("dmYHis");
$acao="boletoemitir";  
$arqlog = "/ws/log/apiboleto_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n".$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
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
    fwrite($arquivo,$log_datahora_ini."$acao"."-FORMATADO->".$conteudoFormatado."\n");

  if ($hml==true) {$service_url = 'http://172.19.130.171:5555/gateway/lb-banrisul-boletos/1.0/cobranca/11271860000186/boletos/emite-boleto-simplificado'; } 
             else {$service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/cobranca/11271860000186/boletos/emite-boleto-simplificado';
}
 fwrite($arquivo,$log_datahora_ini."$acao"."-HML->".json_encode($hml)."\n");
 fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");
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
 fwrite($arquivo,$log_datahora_ini."$acao"."-RESPONSE->".json_encode($curl_response)."\n");
 $info = curl_getinfo($curl);

 fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");

 curl_close($curl); // close cURL handler

/*
 $curl_response = '{
  "retorno": "02",
  "titulo": {
    "nosso_numero": "0006445268",
    "seu_numero": "64452-1",
    "data_vencimento": "2021-05-05",
    "valor_nominal": "150.50",
    "especie": "99",
    "data_emissao": "2021-03-17",
    "valor_iof": null,
    "id_titulo_empresa": "0011000000000000000064452",
    "codigo_barras": "04198861100000150502100100000010000644524040",
    "linha_digitavel": "04192100180000001000906445240408886110000015050",
    "situacao_banrisul": null,
    "situacao_cip": null,
    "situacao_pagamento": null,
    "carteira": null,
    "beneficiario": {
      "codigo": "0010000001088",
      "tipo_pessoa": "J",
      "cpf_cnpj": "92702067000196",
      "nome": "BANRISUL COBRANCA-TESTE",
      "nome_fantasia": "BANRISUL"
    },
    "pagador": {
      "tipo_pessoa": "F",
      "cpf_cnpj": "00000000191",
      "nome": "PAGADOR FICTICIO",
      "endereco": "RUA CALDAS JUNIOR 120",
      "cep": "90010260",
      "cidade": "PORTO ALEGRE",
      "uf": "RS",
      "aceite": "A"
    },
    "instrucoes": {
      "juros": {
        "codigo": 3,
        "data": null,
        "valor": null,
        "taxa": null
      },
      "multa": {
        "codigo": 2,
        "data": "2021-05-06",
        "valor": null,
        "taxa": "0.4"
      },
      "desconto": {
        "codigo": 1,
        "data": "2021-05-03",
        "valor": "6.95",
        "taxa": null
      },
      "abatimento": {
        "valor": "6.80"
      },
      "protesto": {
        "codigo": 3,
        "prazo": null
      },
      "baixa": null
    },
    "pag_parcial": {
      "autoriza": 1,
      "codigo": 3,
      "quantidade": null,
      "tipo": null,
      "valor_min": null,
      "valor_max": null,
      "percentual_min": null,
      "percentual_max": null
    },
    "mensagens": null,
    "rateio": null,
    "hibrido": null,
    "operacoes": null
  }
}';
*/
 $result = json_decode($curl_response, true);
 fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".json_encode($result)."\n");
    

    if ($info['http_code']==201) {
        /* TRANSFORMA EM MODELO PROGRESS */
        $Entrada = (object) $result;
        $jsonEntradaTitulo = isset($Entrada->titulo) ? (object) $Entrada->titulo : null;
        $jsonEntradaBeneficiario = isset($jsonEntradaTitulo->beneficiario) ? (object) $jsonEntradaTitulo->beneficiario : null;
        $jsonEntradaPagador = isset($jsonEntradaTitulo->pagador) ? (object) $jsonEntradaTitulo->pagador : null;

        $jsonSaida     =  array("boleto"  => array(
                                        array(
                                        "retorno" => "REGISTRADO",
                                        "nosso_numero" => $jsonEntradaTitulo->nosso_numero,
                                        "seu_numero" => $jsonEntradaTitulo->seu_numero,
                                        "data_vencimento" => $jsonEntradaTitulo->data_vencimento,
                                        "valor_nominal" => $jsonEntradaTitulo->valor_nominal,
                                        "especie" => $jsonEntradaTitulo->especie,
                                        "data_emissao" => $jsonEntradaTitulo->data_emissao,
                                        "valor_iof" => $jsonEntradaTitulo->valor_iof,
                                        "id_titulo_empresa" => $jsonEntradaTitulo->id_titulo_empresa,
                                        "codigo_barras" => $jsonEntradaTitulo->codigo_barras,
                                        "linha_digitavel" => $jsonEntradaTitulo->linha_digitavel,
                                        "situacao_banrisul" => $jsonEntradaTitulo->situacao_banrisul,
                                        "situacao_cip" => $jsonEntradaTitulo->situacao_cip,
                                        "situacao_pagamento" => $jsonEntradaTitulo->situacao_pagamento,
                                        "carteira" => $jsonEntradaTitulo->carteira,
                                        "cpf_cnpj_beneficiario" => $jsonEntradaBeneficiario->cpf_cnpj,
                                        "cpf_cnpj_pagador" => $jsonEntradaPagador->cpf_cnpj
                                        )
                                      )
                                  );
    
    } else {
      fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
            $jsonSaida     = array(
                    "boleto"   => array(array(
                          "retorno" => "ERRO=".$info['http_code']))
                  );

    }

  
   fclose($arquivo);
  
  
    //echo json_decode(json_encode($jsonSaida))

    //echo $conteudoFormatado;
