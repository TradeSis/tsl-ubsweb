<?php
        
$servidor->wsdl->addComplexType(
    'parcelaBoletoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'seq_parcela' => array('name'=>'seq_parcela','type'=>'xsd:string'),
        'venc_parcela' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'vlr_parcela_pago' => array('name'=>'vlr_parcela','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'AvisoPagamentoTedEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'banco' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'idted' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'parcelas' => array('name'=>'parcelas','type'=>'tns:parcelaBoletoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'AvisoPagamentoTedRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'NomeMetodo' => array('name'=>'name','type'=>'xsd:string'),
        'NomeWebService' => array('name'=>'name','type'=>'xsd:string')
         
    )    
);



      $servidor->register
        (
                'AvisoPagamentoTed',
                array('AvisoPagamentoTedEntrada' => "tns:AvisoPagamentoTedEntrada"),
                array('AvisoPagamentoTedRetorno'=> "tns:AvisoPagamentoTedRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#AvisoPagamentoTed', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function AvisoPagamentoTed($parametro)
        {


                $boleto = new boleto();
                $array2 = array();

                $array2 = $boleto->executarprogress("avisopagamentoted_v1801",$parametro);

                return $array2;


        }


?>
