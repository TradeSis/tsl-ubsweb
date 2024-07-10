<?php
$servidor->wsdl->addComplexType(
    'BuscaDadosClienteNomeEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'nome_cliente' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
      'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int')

    )
);

$servidor->wsdl->addComplexType(
    'clienteType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'name','type'=>'xsd:dateTime'),
        'pai' => array('name'=>'name','type'=>'xsd:string'),
        'mae' => array('name'=>'name','type'=>'xsd:string')
    )
);


$servidor->wsdl->addComplexType(
    'BuscaDadosClienteNomeRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'clientes' => array('name'=>'clientes','type'=>'tns:clienteType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')

    )
);


      $servidor->register
        (
                'BuscaDadosClienteNome',
                array('BuscaDadosClienteNomeEntrada' => "tns:BuscaDadosClienteNomeEntrada"),
                array('return'=> "tns:BuscaDadosClienteNomeRetorno"),
                $ns,
                $ns.'#BuscaDadosClienteNome',
                'document',
                'literal',
                ''
        );



       function BuscaDadosClienteNome($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("BuscaDadosClienteNome",$parametro);
                return $array2;

        }



?>
