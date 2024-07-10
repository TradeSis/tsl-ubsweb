<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaAcordoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int', 'minOccurs'=>'1'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:string')
    )
);


$servidor->wsdl->addComplexType(
    'ParcelaAcordoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'seq_parcela' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'venc_parcela' => array('name'=>'tipo_documento','type'=>'xsd:dateTime'),
        'vlr_parcela' => array('name'=>'numero_documento','type'=>'xsd:decimal')       
    )
);


$servidor->wsdl->addComplexType(
    'acordoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'modalidade' => array('name'=>'tipo_documento','type'=>'xsd:string'),
                'data_emissao' => array('name'=>'data_emissao','type'=>'xsd:dateTime'),
                'valor_total' => array('name'=>'valor_total','type'=>'xsd:decimal'),
        'parcelas' => array('name'=>'parcelas','type'=>'tns:ParcelaAcordoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')       
    )
);


$servidor->wsdl->addComplexType(
    'ConsultaAcordoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status' => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv' => array('name'=>'name','type'=>'xsd:int'),
                'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf' => array('name'=>'name','type'=>'xsd:string'),
        'nome' => array('name'=>'name','type'=>'xsd:string'),
                'contratos' => array('name'=>'contratos','type'=>'tns:contratoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded'),
                'acordo' => array('name'=>'acordo','type'=>'tns:acordoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

$servidor->register
(
    'ConsultaAcordo',
    array('ConsultaAcordoEntrada' => "tns:ConsultaAcordoEntrada"),
    array('return'=> "tns:ConsultaAcordoRetorno"),
    $ns,
    $ns.'#ConsultaAcordo', 
    'document',
    'literal',
    ''
);

function ConsultaAcordo($parametro)
{
    $p2k = new p2k();
    $array2 = array();
        $array2 = $p2k->executarprogress("ConsultaAcordo_07",$parametro);
        return $array2;
}

?>
