<?php
        
$servidor->wsdl->addComplexType(
    'VerificaCreditoVendaEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int', 'minOccurs'=>'1'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'tipo_venda' => array('name'=>'produtos','type'=>'xsd:string'),
        'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:int'),
        'produtos_valores' => array('name'=>'produtos','type'=>'xsd:string'),
        'qtde_parcelas' => array('name'=>'valor_compra','type'=>'xsd:decimal'),
        'vlr_acrescimo' => array('name'=>'valor_compra','type'=>'xsd:decimal'),
        'vlr_entrada' => array('name'=>'valor_compra','type'=>'xsd:decimal'),
        'vlr_prestacao' => array('name'=>'valor_prestacao','type'=>'xsd:decimal'),
        'dt_primvcto' => array('name'=>'valor_compra','type'=>'xsd:dateTime'),
        'dt_ultivcto' => array('name'=>'valor_compra','type'=>'xsd:dateTime'),
        'vdaterceiros' => array('name'=>'produtos','type'=>'xsd:string')
        
                )
);

$servidor->wsdl->addComplexType(
    'VerificaCreditoVendaRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
                'sit_credito' => array('name'=>'name','type'=>'xsd:string'),
                'credito' => array('name'=>'name','type'=>'xsd:decimal'),
                'valor_limite' => array('name'=>'name','type'=>'xsd:decimal'),
                'vcto_credito' => array('name'=>'name','type'=>'xsd:dateTime'),
                'mensagem_credito' => array('name'=>'name','type'=>'xsd:string')
    )
);

$servidor->register
(
    'VerificaCreditoVenda',
    array('VerificaCreditoVendaEntrada' => "tns:VerificaCreditoVendaEntrada"),
    array('return'=> "tns:VerificaCreditoVendaRetorno"),
        $ns,
        $ns.'#VerificaCreditoVenda', 
        'document',
        'literal',
                ''
);

function VerificaCreditoVenda($parametro)
{
    $p2k = new p2k();
    $array2 = array();
        $array2 = $p2k->executarprogress("VerificaCreditoVenda_05",$parametro);
        return $array2;
}
?>
