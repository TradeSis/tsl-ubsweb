<?php
function array_to_xml($template_info, &$xml_template_info) {
            foreach($template_info as $key => $value) {
                if(is_array($value)) {
                    if(!is_numeric($key)){
 
                        $subnode = $xml_template_info->addChild("$key");
 
                        if(count($value) >1 && is_array($value)){
                            $jump = false;
                            $count = 1;
                            foreach($value as $k => $v) {
                                if(is_array($v)){
                                    if($count++ > 1)
                                        $subnode = $xml_template_info->addChild("$key");
 
                                    array_to_xml($v, $subnode);
                                    $jump = true;
                                }
                            }
                            if($jump) {
                                goto LE;
                            }
                            array_to_xml($value, $subnode);
                        }
                        else
                            array_to_xml($value, $subnode);
                    }
                    else{
                        array_to_xml($value, $xml_template_info);
                    }
                }
                else {
                    $xml_template_info->addChild("$key","$value");
                }
 
                LE: ;
            }
        }

//$templateData =  $_POST['data'];
$json_data = '{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":[{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"},{"seq_parcela":"34","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}]}}';

//'{"codigo_filial":"1","codigo_operador":"1","data_futura_pagamento":"2015-04-30T00:00:00","contratos":{"codigo_cliente":"167","numero_contrato":"1999100000","parcelas":{"seq_parcela":"33","vlr_parcela":"9.90","venc_parcela":"2015-04-27T00:00:00"}}}';
$templateData = json_decode($json_data, true);

 
// initializing or creating array
$template_info =  $templateData;
 
// creating object of SimpleXMLElement
$xml_template_info = new SimpleXMLElement("<?xml version=\"1.0\"?><template></template>");
 
// function call to convert array to xml
array_to_xml($template_info,$xml_template_info);
 
//saving generated xml file
 $xml_template_info->asXML("manifest.xml") ;
 

?>
