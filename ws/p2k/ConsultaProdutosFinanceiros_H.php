<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaProdutosFinanceirosEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial'   => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv'           => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'tipo_documento'  => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_documento' => array('name'=>'numero_documento','type'=>'xsd:string')
    )
);

$servidor->wsdl->addComplexType(
    'produtoslistaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array('produtos' => array('name'=>'produtos','type'=>'tns:produtosclienteType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'produtosclienteType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_produto' => array('name'=>'codigo','type'=>'xsd:int'),
        'nome_produto'          => array('name'=>'nome','type'=>'xsd:string'),
        'saldo_produto'  => array('name'=>'saldo','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'ConsultaProdutosFinanceirosRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:int'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'           => array('name'=>'name','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'name','type'=>'xsd:dateTime'),
        'valor_limite'          => array('name'=>'name','type'=>'xsd:decimal'),
        'listaprodutos'  => array('name'=>'listaprodutos','type'=>'tns:produtoslistaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

$servidor->register
(
    'ConsultaProdutosFinanceiros',
    array('ConsultaProdutosFinanceirosEntrada' => "tns:ConsultaProdutosFinanceirosEntrada"),
    array('return'=> "tns:ConsultaProdutosFinanceirosRetorno"),
    $ns, 
    $ns.'#ConsultaProdutosFinanceiros',
    'document',
    'literal',
    ''
);

function ConsultaProdutosFinanceiros($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("ConsultaProdutosFinanceiros_H",$parametro);
    return $array2;
}

?>
