<?php
   
$servidor->wsdl->addComplexType(
    'EfetivaEmprestimoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:int'),
        'numero_contrato' => array('name'=>'numero_contrato','type'=>'xsd:string'),
        'codigo_produto' => array('name'=>'codigo_produto','type'=>'xsd:int'),
        'valor_tfc'         => array('name'=>'valor_tfc','type'=>'xsd:decimal'),
        'valor_credito'  => array('name'=>'valor_credito','type'=>'xsd:decimal'),
        'parcelascet' => array('name'=>'parcelasEntrada','type'=>'tns:ParcelasCET', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded'),
        'nsu_venda' => array('name'=>'nsu_venda','type'=>'xsd:int'),
        'vendedor'  => array('name'=>'vendedor','type'=>'xsd:int'),
        'codigo_seguro_prestamista' => array('name'=>'codigo_seguro_prestamista','type'=>'xsd:int'),
        'valor_seguro_prestamista' => array('name'=>'valor_seguro_prestamista','type'=>'xsd:decimal'),
        'numero_bilhete' => array('name'=>'numero_bilhete','type'=>'xsd:string'),
        'numero_sorte'  => array('name'=>'numero_sorte','type'=>'xsd:int'),
        'data_emissao'  => array('name'=>'data_emissao','type'=>'xsd:dateTime')
    )
);

$servidor->wsdl->addComplexType(
    'EfetivaEmprestimoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:int'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'codigo_produto'  => array('name'=>'name','type'=>'xsd:int'),
        'valor_credito' => array('name'=>'name','type'=>'xsd:decimal'),
        'numero_bilhete' => array('name'=>'name','type'=>'xsd:string'),
        'numero_sorte'  => array('name'=>'name','type'=>'xsd:int')
    )
);

$servidor->register
(
    'EfetivaEmprestimo',
    array('EfetivaEmprestimoEntrada' => "tns:EfetivaEmprestimoEntrada"),
    array('return'=> "tns:EfetivaEmprestimoRetorno"),
    $ns,
    $ns.'#EfetivaEmprestimo',
    'document',
    'literal',
    ''
);

function EfetivaEmprestimo($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("EfetivaEmprestimo",$parametro);
    return $array2;
}

?>
