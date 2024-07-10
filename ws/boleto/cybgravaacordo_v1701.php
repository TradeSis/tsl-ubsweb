<?php
        
$servidor->wsdl->addComplexType(
    'GravaAcordoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'CNPJ_CPF' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'IDAcordo' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'DataAcordo' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'QtdContratosOrigem' => array('name'=>'codigo_operador','type'=>'xsd:int'),
        'VlPrincipal' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'VlJuros' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'VlMulta' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'VlHonorarios' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'VlEncargos' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'VlTotalAcordo'=> array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'VlDesconto' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'OrigemAcordo' => array('name'=>'numero_pdv','type'=>'xsd:string'),
        'ContatosOrigem' => array('name'=>'contratosorigem','type'=>'tns:contratosListaType', minOccurs=>'1', maxOccurs=>'1'),
        'ParcelasAcordo'=> array('name'=>'parcelasacordo','type'=>'tns:parcelasacordoListaType', minOccurs=>'1', maxOccurs=>'1')
        
        
    )
);

$servidor->wsdl->addComplexType(
    'contratosListaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'Contrato' => array('name'=>'bonus','type'=>'tns:contratosType', minOccurs=>'1', maxOccurs=>'unbounded')

    )
);

$servidor->wsdl->addComplexType(
    'contratosType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'grupo' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'NumeroContrato' => array('name'=>'codigo_filial','type'=>'xsd:string')
    )
);



$servidor->wsdl->addComplexType(
    'parcelasacordoListaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'Parcela' => array('name'=>'parcelasacordo','type'=>'tns:parcelasacordoType', minOccurs=>'1', maxOccurs=>'unbounded')

    )
);


$servidor->wsdl->addComplexType(
    'parcelasacordoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'NumeroParcela' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'Vencimento' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'VlPrincipal' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'VlJuros' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'VlMulta' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'VlHonorarios' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'VlEncargos' => array('name'=>'codigo_filial','type'=>'xsd:decimal')
    )
);




$servidor->wsdl->addComplexType(
    'GravaAcordoRetorno', // the type's name
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
                'GravaAcordo',
                array('GravaAcordoEntrada' => "tns:GravaAcordoEntrada"),
                array('GravaAcordoRetorno'=> "tns:GravaAcordoRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#GravaAcordo', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function GravaAcordo($parametro)
        {

                        $arqlog  = "/u/bsweb/log/boleto".date("d").date("m").date("Y").".log";
                        
                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"INICIO\n");
                        fclose($arquivo);
                        


                $boleto = new boleto();

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"new boleto\n");
                        fclose($arquivo);
                 
                $array2 = array();

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"vai executarprogress\n");
                        fclose($arquivo);
 
                $array2 = $boleto->executarprogress("cybgravaacordo_v1701",$parametro);

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"executou progress\n");
                        fclose($arquivo);
                 
                return $array2;




        }


?>
