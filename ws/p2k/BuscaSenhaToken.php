<?php
        
$servidor->wsdl->addComplexType(
    'BuscaSenhaTokenEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'usuario' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'senha' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int')

    )
);


$servidor->wsdl->addComplexType(
    'BuscaSenhaTokenRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'usuario' => array('name'=>'name','type'=>'xsd:string'),
        'resposta' => array('name'=>'name','type'=>'xsd:string')

    )
);


      $servidor->register
        (
                'BuscaSenhaToken',
                array('BuscaSenhaTokenEntrada' => "tns:BuscaSenhaTokenEntrada"),
                array('return'=> "tns:BuscaSenhaTokenRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#BuscaSenhaToken', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function BuscaSenhaToken($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
		$array2 = array();
		$array2 = $p2k->executarprogress("BuscaSenhaToken",$parametro);
		return $array2;

        }


?>
