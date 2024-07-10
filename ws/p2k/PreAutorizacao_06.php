<?php
        
$servidor->wsdl->addComplexType(
    'PreAutorizacaoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int', 'minOccurs'=>'1'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'cpf' => array('name'=>'cpf','type'=>'xsd:string'),
        'tipo_pessoa' => array('name'=>'name','type'=>'xsd:string'),
        'nome_pessoa' => array('name'=>'nome_pessoa','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'data_nascimento','type'=>'xsd:dateTime'),
        'mae' => array('name'=>'mae','type'=>'xsd:string'),
        'codigo_mae' => array('name'=>'codigo_mae','type'=>'xsd:string'),
        'categoria_profissional' => array('name'=>'categoria_profissional','type'=>'xsd:string'),
        'tipo_cadastro' => array('name'=>'tipo_cadastro','type'=>'xsd:string')

    )
);

$servidor->wsdl->addComplexType(
    'PreAutorizacaoRetorno', // the type's name
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
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_credito' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_cadastro' => array('name'=>'tipo_cadastro','type'=>'xsd:string')

    )
);

$servidor->register
(
        'PreAutorizacao',
        array('PreAutorizacaoEntrada' => "tns:PreAutorizacaoEntrada"),
        array('return'=> "tns:PreAutorizacaoRetorno"),
                $ns,
                $ns.'#PreAutorizacao', 
                'document',
                'literal',
                ''
);

function PreAutorizacao($parametro)
{
        $p2k = new p2k();
        $array2 = array();
        $array2 = $p2k->executarprogress("PreAutorizacao_06",$parametro);
        return $array2;
}
?>
