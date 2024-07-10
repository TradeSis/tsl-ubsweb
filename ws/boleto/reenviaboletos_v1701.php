<?php
        
$servidor->wsdl->addComplexType(
    'BoletosClienteType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'Boleto' => array('name'=>'Boleto','type'=>'tns:boletoType', minOccurs=>'1', maxOccurs=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'ReenviaBoletosEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'banco' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'nossonumero' => array('name'=>'codigo_filial','type'=>'xsd:string')
    )
);

$servidor->wsdl->addComplexType(
    'ReenviaBoletosRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'NomeMetodo' => array('name'=>'name','type'=>'xsd:string'),
        'NomeWebService' => array('name'=>'name','type'=>'xsd:string'),
        'BoletosCliente' => array('name'=>'Boleto','type'=>'tns:BoletosClienteType', minOccurs=>'1', maxOccurs=>'1')
         
    )    
);


$servidor->wsdl->addComplexType(
    'boletoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'Banco' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'Agencia' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigoCedente' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'contaCorrente' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'Carteira' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'nossoNumero' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'DVnossoNumero' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'dtEmissao' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'dtVencimento' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'fatorVencimento' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'numeroDocumento' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'sacadoNome' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'sacadoEndereco' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'sacadoCEP' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'linhaDigitavel' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'codigoBarras' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'VlPrincipal' => array('name'=>'codigo_filial','type'=>'xsd:decimal')
    )
);




      $servidor->register
        (
                'ReenviaBoletos',
                array('ReenviaBoletosEntrada' => "tns:ReenviaBoletosEntrada"),
                array('ReenviaBoletosRetorno'=> "tns:ReenviaBoletosRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#ReenviaBoletos', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function ReenviaBoletos($parametro)
        {


                $boleto = new boleto();
                $array2 = array();

                $array2 = $boleto->executarprogress("reenviaboletos_v1701",$parametro);

                return $array2;


        }


?>
