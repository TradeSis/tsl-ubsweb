<?php
        

$servidor->wsdl->addComplexType(
    'EfetivaPagamentoTedEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'idted' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'dtefetivacao' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'statusted' => array('name'=>'tipo_documento','type'=>'xsd:string')

    )
);

$servidor->wsdl->addComplexType(
    'EfetivaPagamentoTedRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'NomeMetodo' => array('name'=>'name','type'=>'xsd:string'),
        'NomeWebService' => array('name'=>'name','type'=>'xsd:string')
         
    )    
);



      $servidor->register
        (
                'EfetivaPagamentoTed',
                array('EfetivaPagamentoTedEntrada' => "tns:EfetivaPagamentoTedEntrada"),
                array('EfetivaPagamentoTedRetorno'=> "tns:EfetivaPagamentoTedRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#EfetivaPagamentoTed', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function EfetivaPagamentoTed($parametro)
        {


                $boleto = new boleto();
                $array2 = array();

                $array2 = $boleto->executarprogress("efetivapagamentoted_v1701",$parametro);

                return $array2;


        }


?>
