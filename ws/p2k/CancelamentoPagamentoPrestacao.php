<?php
        
$servidor->wsdl->addComplexType(
    'CancelamentoPagamentoPrestacaoEntrada', // the type's name
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
        'valor_prestacao' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'codigo_operador' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'cpf' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'data_vencimento_parcela' => array('name'=>'numero_pdv','type'=>'xsd:dateTime')
    )
);

$servidor->wsdl->addComplexType(
    'CancelamentoPagamentoPrestacaoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int')

    )
);



      $servidor->register
        (
                'CancelamentoPagamentoPrestacao',
                array('CancelamentoPagamentoPrestacaoEntrada' => "tns:CancelamentoPagamentoPrestacaoEntrada"),
                array('return'=> "tns:CancelamentoPagamentoPrestacaoRetorno"),
                $ns,
                $ns.'#CancelamentoPagamentoPrestacao',
                'document',
                'literal',
                ''
        );



       function CancelamentoPagamentoPrestacao($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("CancelamentoPagamentoPrestacao",$parametro);
                return $array2;

        }



?>
