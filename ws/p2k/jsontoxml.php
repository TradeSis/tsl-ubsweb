<?php

function array_complex_to_xml($array, $depth = 0 , $tag= ""){
    $indent = '';
    $return = '';
    for($i = 0; $i < $depth; $i++)
        $indent .= "\t";
    foreach($array as $key => $item){
        if(is_array($item)) {
		if (is_numeric($key)) {
	            $return .= "{$indent}<{$tag}>\n";
		} 
		else {
                    if (!array_key_exists("0", $item)) {
		        $return .= "{$indent}<{$key}>\n";
                    }
		    $tag=$key;
		}
                $return .= array_complex_to_xml($item, $depth + 1 ,$tag);
	        if (is_numeric($key)) {
                    $return .= "{$indent}<\\{$tag}>\n";
                }
                else {
                    if (!array_key_exists("0", $item)) {
                       $return .= "{$indent}<\\{$key}>\n";
                    }
                    $tag="";
                }
	}
        else {
            $return .= "{$indent}<{$key}>";
            $return .= "{$item}";
            //$return .= "\n";
            $return .= "<\\{$key}>\n";
        }
	//$return .= "{$indent}<\\{$key}>\n";
    }
    return $return;
}
//$json_data = file_get_contents('http://djekldev.co.uk/card/json.php?tag=djekl');
//$json_data = '{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":[{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"},{"seq_parcela":"34","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}]}}';

//$json_data='{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}}}';

$json_data='{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-07-15T00:00:00","contratos":[{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":[{"seq_parcela":"33","vlr_parcela":"9,90","venc_parcela":"2015-04-27T00:00:00"},{"seq_parcela":"34","vlr_parcela":"9,90","venc_parcela":"2015-05-27T00:00:00"}]},{"codigo_cliente":"167","numero_contrato":"2","parcelas":[{"seq_parcela":"2.33","vlr_parcela":"9,90","venc_parcela":"2015-04-27T00:00:00"},{"seq_parcela":"2.34","vlr_parcela":"9,90","venc_parcela":"2015-05-27T00:00:00"}]}]}';

$data = json_decode($json_data, true);
//var_dump($data);
//@header("Content-Type: text/xml");
print array_complex_to_xml($data);
?>

