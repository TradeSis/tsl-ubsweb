<?php

$log_datahora_ini = date("dmYHis");
$acao="boletopagar";  
$arqlog = "/ws/log/apiboleto_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n\n".$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

    /* TRANSFORMA EM MODELO BANRISUL */
    $jsonEntrada = (object) $jsonEntrada["dadosEntrada"][0];
  
    $codigo_barras = $jsonEntrada->codigo_barras;
    $nsu = $jsonEntrada->nsu;
    $tipo_codigo_barras=1;
    $codestabelecimento = $jsonEntrada->etbcod;
    $dtPagamento = $jsonEntrada->dtPagamento;
    $valor_movimento = $jsonEntrada->valor_movimento;

    //04192993800000200002100100000011594907534039?codigo_estabelecimento=188&tipo_codigo_barras=1
    $pagamentoEntrada = json_encode(array(
      "cod_forma_pagamento" => $jsonEntrada->cod_forma_pagamento,
      "valor_movimento"     => $jsonEntrada->valor_movimento,
      "titulo_barra" => array(
        "tipo_codigo_barra" => $tipo_codigo_barras,
        "data_vencimento"   => $jsonEntrada->data_vencimento,
        "tipo_pessoa_pagador_final" => "F",
        "cpf_cnpj_pagador_final" => $jsonEntrada->cpf_cnpj_pagador_final,
        "nome_pagador_final" => $jsonEntrada->nome_pagador_final
        )
      ));


    fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADAPAGAMENTO->".$pagamentoEntrada."\n");

  if ($hml==true) 
  {               // hml= 172.19.130.171
    $service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/pagamentos/11271860000186/boletos/'.$codigo_barras.'?codigo_estabelecimento='.$codestabelecimento.'&nsu='.$nsu; 
  } 
  else 
  {
    $service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/pagamentos/11271860000186/boletos/'.$codigo_barras.'?codigo_estabelecimento='.$codestabelecimento.'&nsu='.$nsu; 
  }
 fwrite($arquivo,$log_datahora_ini."$acao"."-HML->".json_encode($hml)."\n");
 fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");
 fwrite($arquivo,$log_datahora_ini."$acao"."-METODO->POST\n");
 
 $curl = curl_init($service_url);
 curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
 curl_setopt($curl, CURLOPT_POSTFIELDS, $pagamentoEntrada);
 curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
 curl_setopt($curl, CURLOPT_HTTPHEADER, array(
   'Content-Type: application/json',
   'Content-Length: ' . strlen($pagamentoEntrada))
  );
 curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
 $curl_response = curl_exec($curl);
 //fwrite($arquivo,$log_datahora_ini."$acao"."-RESPONSE->".json_encode($curl_response)."\n");
 $info = curl_getinfo($curl);

 fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");

 curl_close($curl); // close cURL handler

 /** fake
 $curl_response = '{
    "id_requisicao": 3589845,
    "retorno": {
        "versao": "03",
        "servico": "002",
        "canal_entrada": "76",
        "ind_confirma": "",
        "numero_origem": "00101880000001",
        "id_rastreabilidade": "DX50876002122249",
        "numero_banrisul": "00000179021",
        "numero_autenticacao": "000079",
        "agencia_origem": "0010",
        "maquina_cadastro": "9998",
        "data_pagamento": "16/09/2024",
        "cod_documento": "21",
        "cod_forma_pagamento": "19",
        "valor_movimento": 200,
        "situacao_movimento": "",
        "titulo_barra": {
            "data_vencimento": "22/12/2024",
            "nome_cedente": "LMK TESTES",
            "valor_desconto": 0,
            "valor_multa": 0,
            "valor_abatimento": 0,
            "valor_juros": 0,
            "cpf_cnpj_cedente": "92702067000196",
            "tipo_pessoa_cedente": "J",
            "cpf_cnpj_sacado": "00076678635396",
            "tipo_pessoa_sacado": "F",
            "nome_sacado": "LMK",
            "criptograma": "03D7D89090BD6F4CA817F156468A4850C218",
            "nome_fantasia_cedente": "BANRISUL",
            "cpf_cnpj_avalista": "00000000000000",
            "tipo_pessoa_avalista": "",
            "nome_avalista": "",
            "cpf_cnpj_pagador_final": "00076678635396",
            "tipo_pessoa_pagador_final": "F",
            "nome_pagador_final": "NOME PAGADOR TESTE"
        },
        "mensagem": "Solicitação de pagamento recebida com sucesso. Aguardando confirmação."
    }
}';
 **/
 
 $result = json_decode($curl_response, true);
 fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".json_encode($result)."\n");


    if ($info['http_code']==201) {
    
        // chamada a url de confirmação
        if ($hml==true) 
        {
          $service_url = 'http://172.19.130.171:5555/gateway/lb-banrisul-boletos/1.0/pagamentos/11271860000186/boletos/'.$codigo_barras.'?codigo_estabelecimento='.$codestabelecimento; 
        } 
        else 
        {
          $service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/pagamentos/11271860000186/boletos/'.$codigo_barras.'?codigo_estabelecimento='.$codestabelecimento; 
        }
        fwrite($arquivo,$log_datahora_ini."$acao"."-HML->".json_encode($hml)."\n");
        fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");
        fwrite($arquivo,$log_datahora_ini."$acao"."-METODO->PATCH\n");

        /* TRANSFORMA EM MODELO PROGRESS */
        $Entrada = (object) $result;
        $Boleto  = (object) $result["retorno"];
        $confirmacaoEntrada = json_encode(array(
          "numero_banrisul" => $Boleto->numero_banrisul,
          "data_pagamento" => $dtPagamento,
          "cod_forma_pagamento" => $jsonEntrada->cod_forma_pagamento,
          "id_rastreabilidade" => $Boleto->id_rastreabilidade,
          "ind_confirma" => "S",
          "titulo_barra" => array("tipo_codigo_barra" => 1 )
        ));

        fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADACONFIRMACAO->".$confirmacaoEntrada."\n");
          
          $curl = curl_init($service_url);
          curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PATCH");
          curl_setopt($curl, CURLOPT_POSTFIELDS, $confirmacaoEntrada);
          curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
          curl_setopt($curl, CURLOPT_HTTPHEADER, array(
            'Content-Type: application/json',
            'Content-Length: ' . strlen($confirmacaoEntrada))
           );
          curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
          $curl_response = curl_exec($curl);
          //fwrite($arquivo,$log_datahora_ini."$acao"."-RESPONSE->".json_encode($curl_response)."\n");
          $info = curl_getinfo($curl);

          fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");

          curl_close($curl); // close cURL handler
          
          /** fake
          $curl_response = '{
    "id_requisicao": 3592667,
    "retorno": {
        "numero_banrisul": "00000179021",
        "data_pagamento": "16/09/2024",
        "cod_forma_pagamento": "19",
        "id_rastreabilidade": "DX50876002122249",
        "ind_confirma": "S",
        "mensagem": "Indicação de confirmação/cancelamento de pagamento recebida com sucesso."
    }
}';
        **/
        $result = json_decode($curl_response, true);
        fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".json_encode($result)."\n");
       
       
        if ($info['http_code']==200) {
          $Entrada = (object) $result;
          $Boleto  = (object) $result["retorno"];
          $jsonSaida     =  array("boletopagamento"  => array(
                                        array(
                                        "retorno" => "",
                                        "id_requisicao" => $Entrada->id_requisicao,
                                        "codigo_barras" => $codigo_barras,
                                        "numero_banrisul" => $Boleto->numero_banrisul,
                                        "cod_forma_pagamento" => $Boleto->cod_forma_pagamento,
                                        "id_rastreabilidade" => $Boleto->id_rastreabilidade
                                        
                                        )
                                      )
                                  );
    
        }  else {
          fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO API CONFIRMACAO\n");
                $jsonSaida     = array(
                        "boletopagamento"   => array(array(
                              "retorno" => "boleto " . $codigo_barras . " api confirmar ERRO=".$info['http_code']))
                      );
    
        }
      }  else {
              fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO API pagamento\n");
              $jsonSaida     = array(
                      "boletopagamento"   => array(array(
                            "retorno" => "boleto " . $codigo_barras . " api pagar ERRO=".$info['http_code']))
                    );
  
      }
  
   fclose($arquivo);
  
  