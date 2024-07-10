<?php
        
$servidor->wsdl->addComplexType(
    'ClienteEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string')

    )
);

$servidor->wsdl->addComplexType(
    'ClienteRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf_cnpj'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
        'celular' => array('name'=>'name','type'=>'xsd:string'),
        'telefone_profissional' => array('name'=>'name','type'=>'xsd:string')




    )
);


      $servidor->register
        (
                'ConsultaCliente',
                array('ClienteEntrada' => "tns:ClienteEntrada"),
                array('ClienteRetorno'=> "tns:ClienteRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#ConsultaCliente', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function ConsultaCliente($parametro)
        {
                $boleto = new boleto();
		$array2 = array();
		$array2 = $boleto->executarprogress("consultacliente_v1701",$parametro);
		return $array2;

        }


?>
