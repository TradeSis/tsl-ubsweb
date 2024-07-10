<?php
        
$servidor->wsdl->addComplexType(
    'GravaPromessaEntrada', // the type's name
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
        'ContatosPromessa' => array('name'=>'contratospromessa','type'=>'tns:contratosPromessaListaType', minOccurs=>'1', maxOccurs=>'1')
        
        
    )
);

$servidor->wsdl->addComplexType(
    'contratosPromessaListaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'Contrato' => array('name'=>'bonus','type'=>'tns:contratosPromessaType', minOccurs=>'1', maxOccurs=>'unbounded')

    )
);

$servidor->wsdl->addComplexType(
    'contratosPromessaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'grupo' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'NumeroContrato' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'ParcelasPromessa'=> array('name'=>'parcelaspromessa','type'=>'tns:parcelasPromessaListaType', minOccurs=>'1', maxOccurs=>'1')

    )
);



$servidor->wsdl->addComplexType(
    'parcelasPromessaListaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'Parcela' => array('name'=>'parcelaspromessa','type'=>'tns:parcelasPromessaType', minOccurs=>'1', maxOccurs=>'unbounded')

    )
);


$servidor->wsdl->addComplexType(
    'parcelasPromessaType', // the type's name
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
    'GravaPromessaRetorno', // the type's name
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
                'GravaPromessa',
                array('GravaPromessaEntrada' => "tns:GravaPromessaEntrada"),
                array('GravaPromessaRetorno'=> "tns:GravaPromessaRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#GravaPromessa', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function GravaPromessa($parametro)
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
 
                $array2 = $boleto->executarprogress("cybgravapromessa_v2101",$parametro);

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"executou progress\n");
                        fclose($arquivo);
                 
                return $array2;




        }


?>
