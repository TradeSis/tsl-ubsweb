<?php
        
$servidor->wsdl->addComplexType(
    'formapagamentoType', // the type's name                                                               
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_forma_pagamento' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'codigo_plano_pagamento' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'data_primeira_parcela' => array('name'=>'data_primeira_parcela','type'=>'xsd:dateTime', 'minOccurs'=>'0', 'nillable'=>'true'),
        'valor_total_forma' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_parcela' => array('name'=>'numero_documento','type'=>'xsd:decimal'),
        'valor_entrada' => array('name'=>'codigo_filial','type'=>'xsd:decimal')

    )
);

        
$servidor->wsdl->addComplexType(
    'produtoEntradaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'produtos' => array('name'=>'produtosEntrada','type'=>'tns:produtoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

        
$servidor->wsdl->addComplexType(
    'formapagamentoEntradaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'formapagamento' => array('name'=>'formapagamentoEntrada','type'=>'tns:formapagamentoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);



$servidor->wsdl->addComplexType(
    'EfetivaVendaEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'data_operacao' => array('name'=>'tipo_documento','type'=>'xsd:dateTime'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_contrato' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'numero_comprovante' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'numero_cupom_fiscal' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'valor_total_contrato' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'valor_acrescimos' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'valor_iof' => array('name'=>'numero_pdv','type'=>'xsd:double'),
        'valor_desconto' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'codigo_operador' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'produtosLista' => array('name'=>'produtosEntrada','type'=>'tns:produtoEntradaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded'),
        'formapagamentoLista' => array('name'=>'formapagamentoEntrada','type'=>'tns:formapagamentoEntradaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')


    )
);


$servidor->wsdl->addComplexType(
    'campanhaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'tipo_campanha' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'descricao_campanha' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'valor' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'codigo_campanha' => array('name'=>'numero_documento','type'=>'xsd:int')

    )
);


$servidor->wsdl->addComplexType(
    'campanhaslistaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'campanha' => array('name'=>'bonus','type'=>'tns:campanhaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')

    )
);



$servidor->wsdl->addComplexType(
    'EfetivaVendaRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'campanhasLista' => array('name'=>'campanhas','type'=>'tns:campanhaslistaType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
        
    )
);




      $servidor->register
        (
                'EfetivaVenda',
                array('EfetivaVendaEntrada' => "tns:EfetivaVendaEntrada"),
                array('return'=> "tns:EfetivaVendaRetorno"),
                $ns,
                $ns.'#EfetivaVenda',
                'document',
                'literal',
                ''
        );



       function EfetivaVenda($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("EfetivaVenda",$parametro);
                return $array2;

        }



?>
