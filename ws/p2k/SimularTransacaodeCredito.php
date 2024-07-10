<?php
        
$servidor->wsdl->addComplexType(
    'SimularTransacaodeCreditoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial'   => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv'   	=> array('name'=>'numero_pdv','type'=>'xsd:int'),
	'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:int'),
	'codigo_produto' => array('name'=>'codigo_produto','type'=>'xsd:int'),
	'valor_solicitado' => array('name'=>'valor_solicitado','type'=>'xsd:decimal'),
        'numero_parcelas' => array('name'=>'numero_parcelas','type'=>'xsd:int'),
        'plano_pagamento' => array('name'=>'plano_pagamento','type'=>'xsd:int'),        'percentual_seguro' => array('name'=>'percentual_seguro','type'=>'xsd:decimal'),
    )
);

$servidor->wsdl->addComplexType(
    'produtos_simula_listaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array('produtos' => array('name'=>'produtos','type'=>'tns:produtos_simulaType', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'produtos_simulaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
	'codigo_produto' => array('name'=>'codigo','type'=>'xsd:int'),
        'nome_produto' 	=> array('name'=>'nome','type'=>'xsd:string'),
        'saldo_produto' => array('name'=>'saldo','type'=>'xsd:decimal'),
	'valor_tfc'     => array('name'=>'tfc','type'=>'xsd:decimal'),
	'pede_token'	=> array('name'=>'token','type'=>'xsd:string'),
	'obriga_deposito_bancario'=> array('name'=>'deposito','type'=>'xsd:string'),
        'cet'             => array('name'=>'name','type'=>'xsd:decimal'),
        'cet_ano'         => array('name'=>'name','type'=>'xsd:decimal'),
        'tx_mes'          => array('name'=>'name','type'=>'xsd:decimal'),
        'valor_iof'     => array('name'=>'valor_iof','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'SimularTransacaodeCreditoRetorno', // the type's name
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
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
	'listaprodutos' => array('name'=>'listaprodutos','type'=>'tns:produtos_simula_listaType', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);

$servidor->register
(
    'SimularTransacaodeCredito',
    array('SimularTransacaodeCreditoEntrada' => "tns:SimularTransacaodeCreditoEntrada"),
    array('return'=> "tns:SimularTransacaodeCreditoRetorno"),
    $ns, 
    $ns.'#SimularTransacaodeCredito',
    'document',
    'literal',
    ''
);

function SimularTransacaodeCredito($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("SimularTransacaodeCredito",$parametro);
    return $array2;
}

?>
