<?php

$log_datahora_ini = date("dmYHis");
$acao="boletoconsultar";  
$arqlog = "/ws/log/apiboleto_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n".$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}

    /* TRANSFORMA EM MODELO BANRISUL */
    $jsonEntrada = (object) $jsonEntrada["dadosEntrada"][0];
  
    $codigo_barras = $jsonEntrada->codigo_barras;
    $tipo_codigo_barras=1;
    $codestabelecimento = $jsonEntrada->etbcod;

    //04192993800000200002100100000011594907534039?codigo_estabelecimento=188&tipo_codigo_barras=1

  if ($hml==true) 
  {
    $service_url = 'http://172.19.130.171:5555/gateway/lb-banrisul-boletos/1.0/pagamentos/11271860000186/boletos/'.$codigo_barras.'?codigo_estabelecimento='.$codestabelecimento.'&tipo_codigo_barras='.$tipo_codigo_barras; 
  } 
  else 
  {
    $service_url = 'http://10.2.0.133:5555/gateway/lb-banrisul-boletos/1.0/pagamentos/11271860000186/boletos/'.$codigo_barras.'?codigo_estabelecimento='.$codestabelecimento.'&tipo_codigo_barras='.$tipo_codigo_barras; 
  }
 fwrite($arquivo,$log_datahora_ini."$acao"."-HML->".json_encode($hml)."\n");
 fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");
 
 $curl = curl_init($service_url);
 curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
 curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
 curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
 //curl_setopt($curl, CURLOPT_HTTPHEADER, array(
 //  'Content-Type: application/json',
 //  'Content-Length: ' . strlen($conteudoFormatado))
 // );
 curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
 $curl_response = curl_exec($curl);
 fwrite($arquivo,$log_datahora_ini."$acao"."-RESPONSE->".json_encode($curl_response)."\n");
 $info = curl_getinfo($curl);

 fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");

 curl_close($curl); // close cURL handler

/*** fake
 $curl_response = '{
    "id_requisicao": 3592604,
    "retorno": {
        "boleto": {
            "codigo_barras": "04192993800000200002100100000011594907534039",
            "situacao_boleto": "A",
            "linha_digitavel": "04192100180000001159349075340395299380000020000",
            "dt_vcto_boleto": "22/12/2024",
            "dt_lim_pagto_bol": "20/02/2025",
            "vlr_orig_boleto": 200,
            "cod_esp_boleto": "2",
            "cod_moeda_cnab": "09",
            "ind_bloq_pagto": "N",
            "ind_pagto_parcial": "N",
            "qtd_pagto_parcial": "0",
            "qtd_pagto_parc_reg": "0",
            "tipo_aut_receb_div": "3",
            "vlr_minimo_bol_calculado": 0,
            "vlr_maximo_bol_calculado": 200,
            "cod_if": "41",
            "tipo_pes_ben_orig": "J",
            "cod_beneficiario_original": "92702067000196",
            "nom_rzsoc_ben_orig": "LMK TESTES",
            "nome_fant_ben_orig": "BANRISUL",
            "tipo_pes_ben_fin": null,
            "cod_beneficiario_final": null,
            "nom_rzsoc_ben_fin": null,
            "nome_fanta_ben_fin": null,
            "tipo_ident_sac_ava": "0",
            "ident_sac_ava": null,
            "nom_rzsoc_sac_ava": null,
            "tipo_pes_pagador": "F",
            "cod_pagador": "00076678635396",
            "nome_rzsoc_pagador": "LMK",
            "cod_beneficiario_original_format": "92.702.067/0001-96",
            "cod_beneficiario_final_format": null,
            "cod_pagador_format": "766.786.353-96",
            "ident_sac_ava_format": null,
            "descr_tipo_aut_receb_div": "Não Aceita Pagamento com Valor Divergente",
            "ind_vencido": "N",
            "ind_perm_alterar_valor": "N"
        },
        "dados_pagamento": {
            "data_referencia": "16/09/2024",
            "valor_calculado_juros": 0,
            "valor_calculado_multa": 0,
            "valor_calculado_desconto": 0,
            "valor_calculado_total": 200,
            "valor_calculado_abatimento": 0,
            "valor_desconto_abatimento": 0
        },
        "mensagem": "Dados do boleto consultados com sucesso."
    }
}';
**/
 $result = json_decode($curl_response, true);
 fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".json_encode($result)."\n");


    if (/*$info['http_code']*/ 200==200) {
        /* TRANSFORMA EM MODELO PROGRESS */
        $Entrada = (object) $result;
        $Boleto  = (object) $result["retorno"]["boleto"];
        $dados_pagamento  = (object) $result["retorno"]["dados_pagamento"];

        $jsonSaida     =  array("boletoconsulta"  => array(
                                        array(
                                        "retorno" => $result["retorno"]["mensagem"],
                                        "id_requisicao" => $Entrada->id_requisicao,
                                        "codigo_barras" => $Boleto->codigo_barras,
                                        "situacao_boleto" => $Boleto->situacao_boleto,
                                        "ind_bloq_pagto" => $Boleto->ind_bloq_pagto,
                                        "vlr_orig_boleto" => $Boleto->vlr_orig_boleto,
                                        "valor_calculado_total" => $dados_pagamento->valor_calculado_total,
                                        
                                        )
                                      )
                                  );
    
    } else {
      fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
            $jsonSaida     = array(
                    "boletoconsulta"   => array(array(
                          "retorno" => "ERRO=".$info['http_code']))
                  );

    }

  
   fclose($arquivo);
  
  
