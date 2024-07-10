<?php
        
$servidor->wsdl->addComplexType(
    'DataFuturaPagamentoPrestacaoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'data_futura_pagamento' => array('name'=>'codigo_operador','type'=>'xsd:dateTime', 'minOccurs'=>'0', 'nillable'=>'true'),
        'contratos' => array('name'=>'contratosEntrada','type'=>'tns:contratosEntradaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'parcelasEntradaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'seq_parcela' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'vlr_parcela' => array('name'=>'tipo_documento','type'=>'xsd:decimal'),
        'data_vencimento' => array('name'=>'numero_documento','type'=>'xsd:dateTime')
    )
);

$servidor->wsdl->addComplexType(
    'contratosEntradaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cliente' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'parcelas' => array('name'=>'parcelasEntrada','type'=>'tns:parcelasEntradaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')


    )
);

$servidor->wsdl->addComplexType(
    'parcelasSaidaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'seq_parcela' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'data_vencimento' => array('name'=>'numero_documento','type'=>'xsd:dateTime'),
        'vlr_parcela' => array('name'=>'tipo_documento','type'=>'xsd:decimal'),
        'valor_encargos_data_futura' => array('name'=>'tipo_documento','type'=>'xsd:decimal'),
        'vlr_parcela_data_futura' => array('name'=>'tipo_documento','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'contratosSaidaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cliente' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'parcelas' => array('name'=>'parcelasEntrada','type'=>'tns:parcelasSaidaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')


    )
);

$servidor->wsdl->addComplexType(
    'DataFuturaPagamentoPrestacaoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'contratos' => array('name'=>'contratos','type'=>'tns:contratosSaidaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')

    )
);



      $servidor->register
        (
                'DataFuturaPagamentoPrestacao',
                array('DataFuturaPagamentoPrestacaoEntrada' => "tns:DataFuturaPagamentoPrestacaoEntrada"),
                array('return'=> "tns:DataFuturaPagamentoPrestacaoRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#DataFuturaPagamentoPrestacao', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function DataFuturaPagamentoPrestacao($parametro)
        {
                $p2k = new p2k();

//                return $p2k->executarprogress("ConsultaParcelas",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("DataFuturaPagamentoPrestacao",$parametro);
                return $array2;

        }



?>
