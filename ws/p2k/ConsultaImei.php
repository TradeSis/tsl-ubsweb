<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaImeiEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'imei' => array('name'=>'numero_documento','type'=>'xsd:string')
    )
);

$servidor->wsdl->addComplexType(
    'ConsultaImeiRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'imei' => array('name'=>'name','type'=>'xsd:string')
    )
);

$servidor->register
(
    'ConsultaImei',
    array('ConsultaImeiEntrada' => "tns:ConsultaImeiEntrada"),
    array('return'=> "tns:ConsultaImeiRetorno"),
    $ns, 
    $ns.'#ConsultaImei', 
    'document',
    'literal',
    ''
);

function ConsultaImei($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("ConsultaImei",$parametro);
    return $array2;
}

?>
