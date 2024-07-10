<?php

function arraytoxml2($array, $depth, $tag){
    $indent = '';
    $return = '';
    for($i = 0; $i < $depth; $i++)
        $indent .= "\t";



}
function ARRAYtoXML($array, $depth = 0 , $chave = -1, $tag= ""){
    echo "ENTREI - DEPTH=$depth PARAM=$array CHAVE=$chave TAG=$tag \n";
    $indent = '';
    $return = '';
    for($i = 0; $i < $depth; $i++)
        $indent .= "\t";
    
    foreach($array as $key => $item){
//        $return .= "{$indent}<{$key}>";
        if(is_array($item)) {
            echo "   $key - $item chave=$chave tag=$tag \n";

            if ($key=="parcelas"){
		$tag="parcelas";
            }
            if ($key=="contratos"){
                $tag="contratos";
            }

       echo "   $key - $item chave=$chave tag=$tag \n";

if (!$tag=="" && !$key=="parcelas") {
$return .= "{$indent}<{$tag}>";
$fecha = 1;
}

            $return .= ARRAYtoXML($item, $depth + 1 , $chave + 1, $tag);
if (!$tag=="" && $fecha==1) {
$return .= "{$indent}<\\{$tag}>";
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
$json_data = '{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":[{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"},{"seq_parcela":"34","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}]}}';

//'{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}}}';
$data = json_decode($json_data, true);
var_dump($data);
echo "N\n";
print_r(array_keys($data));
@header("Content-Type: text/xml");
print '< ?xml version="1.0" ?>' . "\n";
print ARRAYtoXML($data);
?>

