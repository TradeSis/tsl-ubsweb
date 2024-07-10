<?php
function toXml($data, $rootNodeName = 'root', $xml = null) {
     
    // desligamos essa opç para evitar bugs
    if (ini_get('zend.ze1_compatibility_mode') == 1) {
        ini_set('zend.ze1_compatibility_mode', 0);
    }
 
    if ($xml == null) {
        $xml = simplexml_load_string("<?xml version='1.0' encoding='utf-8'?><$rootNodeName />");
    }
 
    // faz o loop no array
    foreach ($data as $key => $value) {
        // se for indice numerico ele renomeia o indice
        if (is_numeric($key)) {
            $key = "" . (string) $key;
        }
 
        // substituir qualquer coisa nãalfa numéco
        //$key = preg_replace('/[^a-z]/i', '', $key);
 
         
        if (is_array($value)) {
            $node = $xml->addChild($key);
            toXml($value, $rootNodeName, $node);
        } else {
            $value = htmlentities($value);
            $xml->addChild($key, $value);
        }
    }
    return $xml->asXML();
}

$json_data = '{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":[{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"},{"seq_parcela":"34","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}]}}';

$data = json_decode($json_data,true);

echo toXml($data);


?>
