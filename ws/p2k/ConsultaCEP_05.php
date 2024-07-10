<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaCEPEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int', 'minOccurs'=>'1'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'CEP' => array('name'=>'cpf','type'=>'xsd:string')
    )
);

$servidor->wsdl->addComplexType(
    'ConsultaCEPRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'CEP' => array('name'=>'name','type'=>'xsd:string'),
        'Logradouro' => array('name'=>'name','type'=>'xsd:string'),
        'Bairro' => array('name'=>'name','type'=>'xsd:string'),
        'Cidade' => array('name'=>'name','type'=>'xsd:string'),
        'UF' => array('name'=>'name','type'=>'xsd:string'),
        'CEPGeral' => array('name'=>'name','type'=>'xsd:string')

    )
);

$servidor->register
(
        'ConsultaCEP',
        array('ConsultaCEPEntrada' => "tns:ConsultaCEPEntrada"),
        array('return'=> "tns:ConsultaCEPRetorno"),
                $ns,
                $ns.'#ConsultaCEP', 
                'document',
                'literal',
                ''
);

function ConsultaCEP($parametro)
{
        $p2k = new p2k();
        $array2 = array();
        $array2 = $p2k->executarprogress("ConsultaCEP_05",$parametro);
        return $array2;
}
?>
