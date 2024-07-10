<?php

$servidor->wsdl->addComplexType(
    'parcelasPagType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:int'),
        'codigo_contrato' => array('name'=>'codigo_contrato','type'=>'xsd:string'),
        'numero_comprovante' => array('name'=>'numero_comprovante','type'=>'xsd:int'),
        'numero_cupom_fiscal' => array('name'=>'numero_cupom_fiscal','type'=>'xsd:int'),
        'valor_prestacao' => array('name'=>'valor_prestacao','type'=>'xsd:decimal'),
        'valor_acrescimos' => array('name'=>'valor_acrescimos','type'=>'xsd:decimal'),
        'valor_desconto' => array('name'=>'valor_desconto','type'=>'xsd:decimal'),
        'cpf' => array('name'=>'cpf','type'=>'xsd:string'),
        'data_vencimento_parcela' => array('name'=>'data_vencimento_parcela','type'=>'xsd:dateTime'),
        'seq_parcela' => array('name'=>'seq_parcela','type'=>'xsd:string'),
        'valor_pago' => array('name'=>'valor_pago','type'=>'xsd:decimal'),
        'parcial' => array('name'=>'parcial','type'=>'xsd:string'),
        'modalidade' => array('name'=>'modalidade','type'=>'xsd:string'),
        'inf_compl' => array('name'=>'inf_compl','type'=>'xsd:string')
    )
);

                
$servidor->wsdl->addComplexType(
    'parcelasPagArray', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
      'parcelas' => array('name'=>'parcelasPag','type'=>'tns:parcelasPagType', 'minOccurs'=>'1', 'maxOccurs'=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'EfetivaPagamentoPrestacaoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'data_operacao' => array('name'=>'data_operacao','type'=>'xsd:dateTime'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:int'),
        'parcelasPag' => array('name'=>'parcelasPag','type'=>'tns:parcelasPagArray', 'minOccurs'=>'0', 'maxOccurs'=>'1')
    )
);

$servidor->wsdl->addComplexType(
    'EfetivaPagamentoPrestacaoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status' => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv' => array('name'=>'name','type'=>'xsd:int'),
        'listabonus' => array('name'=>'listabonus','type'=>'tns:bonuslistaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')

    )
);


$servidor->register
(
    'EfetivaPagamentoPrestacao',
    array('EfetivaPagamentoPrestacaoEntrada' => "tns:EfetivaPagamentoPrestacaoEntrada"),
       array('return'=> "tns:EfetivaPagamentoPrestacaoRetorno"),
       $ns,
       $ns.'#EfetivaPagamentoPrestacao',
       'document',
       'literal',
       ''
);


function EfetivaPagamentoPrestacao($parametro)
{
    $p2k = new p2k();
    $array2 = array();
    $array2 = $p2k->executarprogress("EfetivaPagamentoPrestacao_03",$parametro);
    return $array2;
}

?>
