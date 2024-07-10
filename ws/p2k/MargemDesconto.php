<?php
        
$servidor->wsdl->addComplexType(
    'MargemDescontoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'valor_venda' => array('name'=>'valor_venda','type'=>'xsd:decimal'),
        'valor_desconto' => array('name'=>'valor_desconto','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'MargemDescontoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'liberar' => array('name'=>'name','type'=>'xsd:string')
    )
);

$servidor->register
(
    'MargemDesconto',
    array('MargemDescontoEntrada' => "tns:MargemDescontoEntrada"),
    array('return'=> "tns:MargemDescontoRetorno"),
    $ns, 
    $ns.'#MargemDesconto', 
    'document',
    'literal',
    ''
);

function MargemDesconto($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("MargemDesconto",$parametro);
    return $array2;
}

?>
