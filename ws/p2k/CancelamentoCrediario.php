<?php
        
$servidor->wsdl->addComplexType(
    'CancelamentoCrediarioEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'tipo_documento' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'numero_documento' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'valor_cancelado' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int')
    )
);

$servidor->wsdl->addComplexType(
    'CancelamentoCrediarioRetorno', // the type's name
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
                'CancelamentoCrediario',
                array('CancelamentoCrediarioEntrada' => "tns:CancelamentoCrediarioEntrada"),
                array('return'=> "tns:CancelamentoCrediarioRetorno"),
                $ns,
                $ns.'#CancelamentoCrediario',
                'document',
                'literal',
                ''
        );



       function CancelamentoCrediario($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("CancelamentoCrediario",$parametro);
                return $array2;

        }



?>
