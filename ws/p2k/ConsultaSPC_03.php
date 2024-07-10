<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaSPCEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int', 'minOccurs'=>'1'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'codigo_cliente','type'=>'xsd:string'),
        'cpf' => array('name'=>'cpf','type'=>'xsd:string'),
        'tipo_pessoa' => array('name'=>'tipo_pessoa','type'=>'xsd:string'),
        'nome_pessoa' => array('name'=>'nome_pessoa','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'data_nascimento','type'=>'xsd:dateTime') 
    )
);


$servidor->wsdl->addComplexType(
    'ConsultaSPCRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'name','type'=>'xsd:dateTime'),
        'resultado_consulta_spc' => array('name'=>'name','type'=>'xsd:string'),
        'filial_efetuou_consulta' => array('name'=>'name','type'=>'xsd:string'),
        'data_consulta' => array('name'=>'name','type'=>'xsd:dateTime', 'minOccurs'=>'0'),
        'quantidade_consultas_realizadas' => array('name'=>'name','type'=>'xsd:string'),
        'registros_de_alertas' => array('name'=>'name','type'=>'xsd:string'),
        'registro_do_credito' => array('name'=>'name','type'=>'xsd:string'),
        'registro_de_cheques' => array('name'=>'name','type'=>'xsd:string'),
        'registro_nacional' => array('name'=>'name','type'=>'xsd:string'),
        'spc_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'spc_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'resultado_consulta_serasa' => array('name'=>'name','type'=>'xsd:string'),
        'serasa_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'serasa_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'resultado_consulta_crediario' => array('name'=>'name','type'=>'xsd:string'),
        'crediario_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'crediario_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'limite_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'limite_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'nota' => array('name'=>'name','type'=>'xsd:string')
    )
);


      $servidor->register
        (
                'ConsultaSPC',
                array('ConsultaSPCEntrada' => "tns:ConsultaSPCEntrada"),
                array('return'=> "tns:ConsultaSPCRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaSPC', //'urn:servidor.ConsultaSPC',
                $ns.'#ConsultaSPC', //'WS.p2k#ConsultaSPC', //'urn:servidor.p2k#ConsultaSPC',
                'document',
                'literal',
                ''
        );


       function ConsultaSPC($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaSPC",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("ConsultaSPC",$parametro);
                return $array2;

        }

?>
