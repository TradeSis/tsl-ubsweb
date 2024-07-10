<?php
   
$servidor->wsdl->addComplexType(
    'AutorizarEmprestimoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:int'),
	'codigo_produto' => array('name'=>'codigo_produto','type'=>'xsd:int'),
	'valor_tfc'	 => array('name'=>'valor_tfc','type'=>'xsd:decimal'),
	'valor_credito'  => array('name'=>'valor_credito','type'=>'xsd:decimal'),
        'data_primeiro_vencimento' => array('name'=>'data_primeiro_vencimento','type'=>'xsd:dateTime'),
        'valor_primeiro_vencimento' => array('name'=>'valor_primeiro_vencimento','type'=>'xsd:decimal'),
        'numero_parcelas' => array('name'=>'numero_parcelas','type'=>'xsd:int'),
        'nsu_venda' => array('name'=>'nsu_venda','type'=>'xsd:int'),
        'vendedor' => array('name'=>'vendedor','type'=>'xsd:int'),
        'codigo_seguro_prestamista' => array('name'=>'codigo_seguro_prestamista','type'=>'xsd:int'),
        'valor_seguro_prestamista' => array('name'=>'valor_seguro_prestamista','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'AutorizarEmprestimoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'         => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro'  => array('name'=>'name','type'=>'xsd:string'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:int'),
        'cpf'            => array('name'=>'name','type'=>'xsd:string'),
        'nome'           => array('name'=>'name','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial'  => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'     => array('name'=>'name','type'=>'xsd:int'),
        'tipo_operacao'  => array('name'=>'name','type'=>'xsd:string'),
	'codigo_produto' => array('name'=>'name','type'=>'xsd:int'),
        'valor_credito'  => array('name'=>'name','type'=>'xsd:decimal'),
        'cet' 		 => array('name'=>'name','type'=>'xsd:decimal'),
        'cet_ano'	 => array('name'=>'name','type'=>'xsd:decimal'),
        'tx_mes' 	 => array('name'=>'name','type'=>'xsd:decimal'),
        'valor_iof' 	 => array('name'=>'name','type'=>'xsd:decimal'),
        'numero_bilhete' => array('name'=>'name','type'=>'xsd:string'),
        'numero_sorte'   => array('name'=>'name','type'=>'xsd:int'),
        'data_emissao'   => array('name'=>'name','type'=>'xsd:dateTime')
    )
);

$servidor->register
(
    'AutorizarEmprestimo',
    array('AutorizarEmprestimoEntrada' => "tns:AutorizarEmprestimoEntrada"),
    array('return'=> "tns:AutorizarEmprestimoRetorno"),
    $ns,
    $ns.'#AutorizarEmprestimo',
    'document',
    'literal',
    ''
);

function AutorizarEmprestimo($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("AutorizarEmprestimo",$parametro);
    return $array2;
}

?>
