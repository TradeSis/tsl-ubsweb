<?php
        
$servidor->wsdl->addComplexType(
    'EfetivaPagamentoBonusEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'data_operacao' => array('name'=>'tipo_documento','type'=>'xsd:dateTime'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'nome_bonus' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'codigo_filial_bonus' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'numero_bonus' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'venc_bonus' => array('name'=>'tipo_documento','type'=>'xsd:dateTime'),
        'vlr_bonus' => array('name'=>'numero_documento','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'EfetivaPagamentoBonusRetorno', // the type's name
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
                'EfetivaPagamentoBonus',
                array('EfetivaPagamentoBonusEntrada' => "tns:EfetivaPagamentoBonusEntrada"),
                array('return'=> "tns:EfetivaPagamentoBonusRetorno"),
                $ns,
                $ns.'#EfetivaPagamentoBonus',
                'document',
                'literal',
                ''
        );



       function EfetivaPagamentoBonus($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("EfetivaPagamentoBonus",$parametro);
                return $array2;

        }



?>
