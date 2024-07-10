<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaParcelasEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'tipo_documento' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'funcionalidade' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'codigo_contrato' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_documento' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int')

    )
);

$servidor->wsdl->addComplexType(
    'parcelaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'seq_parcela' => array('name'=>'seq_parcela','type'=>'xsd:string'),
        'venc_parcela' => array('name'=>'venc_parcela','type'=>'xsd:dateTime'),
        'vlr_parcela' => array('name'=>'vlr_parcela','type'=>'xsd:decimal'),
        'valor_encargos' => array('name'=>'valor_encargos','type'=>'xsd:decimal'),
        'percentual_encargo_dia' => array('name'=>'percentual_encargo_dia','type'=>'xsd:decimal'),
        'data_pagamento' => array('name'=>'data_pagamento','type'=>'xsd:dateTime', 'minOccurs'=>'0', 'nillable'=>'true'),
       'valor_desconto' => array('name'=>'valor_desconto','type'=>'xsd:decimal'),
       'inf_compl' => array('inf_compl','type'=>'xsd:string')
    )
);

$servidor->wsdl->addComplexType(
    'produtoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_produto' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'descricao_produto' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'quantidade' => array('name'=>'numero_documento','type'=>'xsd:int'),
        'preco_unitario' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'preco_total' => array('name'=>'codigo_operador','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'contratoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'filial_contrato' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'modalidade' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'data_emissao_contrato' => array('name'=>'codigo_filial','type'=>'xsd:dateTime'),
        'valor_contrato' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_total_pago' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_total_pendente' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_total_encargo' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'tp_contrato' => array('tp_contrato','type'=>'xsd:string'),
        'parcelas' => array('name'=>'parcelas','type'=>'tns:parcelaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded'),
        'produtos' => array('name'=>'produtos','type'=>'tns:produtoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded'),
    )
);

$servidor->wsdl->addComplexType(
    'ConsultaParcelasRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'funcionalidade' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'name','type'=>'xsd:dateTime'),
        'tipo_cartao' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'valor_limite' => array('name'=>'name','type'=>'xsd:decimal'),
        'credito' => array('name'=>'name','type'=>'xsd:string'),
        'contratos' => array('name'=>'contratos','type'=>'tns:contratoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded'),
        'aviso'    => array('name'=>'name','type'=>'xsd:string'),
        'bloqueia' => array('name'=>'name','type'=>'xsd:string')
    )
);


$servidor->register
(
        'ConsultaParcelas',
        array('ConsultaParcelasEntrada' => "tns:ConsultaParcelasEntrada"),
        array('return'=> "tns:ConsultaParcelasRetorno"),
        $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
        $ns.'#ConsultaParcelas', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
        'document',
        'literal',
        ''
);


function ConsultaParcelas($parametro)
{
        $p2k = new p2k();
        $array2 = array();
        $array2 = $p2k->executarprogress("ConsultaParcelas_H",$parametro);
        return $array2;
}
?>
