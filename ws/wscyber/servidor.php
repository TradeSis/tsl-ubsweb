<?php
        
        /**
         * Servidor.php
         * 
         */

        /**
         * Inclui a biblioteca do nusoap
         */
        require("funcoes.inc");

        include ("cyber.php");

        
        /**
         * Instância os objetos
         */
        $servidor = new soap_server ();
        
        $ns = 'http://localhost/ws.cyber';
        /**
         * Configura o WSDL do servidor
         */
        $servidor->configureWSDL('cyber', $ns , false, 'document');

       $servidor->wsdl->schemaTargetNamespace = $ns."?wsdl";
        
        /**
         * Registra os métodos disponíveis
         */

$servidor->wsdl->addComplexType(
    'consultasaldocpfEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'cpfcnpj' => array('name'=>'nome','type'=>'xsd:string')
    )

);


$servidor->wsdl->addComplexType(
    'consultasaldocontratoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'grupo' => array('name'=>'nome','type'=>'xsd:string'),
        'contrato' => array('name'=>'nome','type'=>'xsd:string')
    )
);


$servidor->wsdl->addComplexType(
    'parcelaLista', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'grupo' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'contrato' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'nrParcela' => array('name'=>'numero_documento','type'=>'xsd:int'),
        'vlParcJuros' => array('name'=>'codigo_filial','type'=>'xsd:double'),
        'vlParcMulta' => array('name'=>'codigo_operador','type'=>'xsd:double')
    )
);

$servidor->wsdl->addComplexType(
    'contratoLista', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'grupo' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'vlJuros' => array('name'=>'codigo_filial','type'=>'xsd:double'),
        'vlMulta' => array('name'=>'numero_documento','type'=>'xsd:double'),
        'parcelaLista' => array('name'=>'parcelas','type'=>'tns:parcelaLista', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);


$servidor->wsdl->addComplexType(
    'consultasaldocpfRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'wsNomeWebService' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'wsCodigoRetorno' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'wsException' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'wsNomeMetodo' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'wsQtdReg' => array('name'=>'numero_documento','type'=>'xsd:int'),
        'wsMensagemRetorno' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'contratoLista' => array('name'=>'parcelas','type'=>'tns:contratoLista', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);


$servidor->wsdl->addComplexType(
    'consultasaldocontratoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'wsNomeWebService' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'wsCodigoRetorno' => array('name'=>'tipo_documento','type'=>'xsd:int'),
        'wsException' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'wsNomeMetodo' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'wsQtdReg' => array('name'=>'numero_documento','type'=>'xsd:int'),
        'wsMensagemRetorno' => array('name'=>'codigo_filial','type'=>'xsd:string'),
        'contratoLista' => array('name'=>'parcelas','type'=>'tns:contratoLista', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);



      $servidor->register
        (
                'consultasaldocontrato',
                array('consultasaldocontratoEntrada' => "tns:consultasaldocontratoEntrada"),
                array('return'=> "tns:consultasaldocontratoRetorno"),
                $ns, 
                $ns.'#consultasaldocontrato', 
                'document',
                'literal',
                ''
        );



       function consultasaldocontrato($parametro)
        {
                $cyber = new cyber();
                $array2 = array();
                $array2 = $cyber->executarprogress("consultasaldocontrato",$parametro);
                return $array2;

        }


      $servidor->register
        (
                'consultasaldocpf',
                array('consultasaldocpfEntrada' => "tns:consultasaldocpfEntrada"),
                array('return'=> "tns:consultasaldocpfRetorno"),
                $ns, 
                $ns.'#consultasaldocpf', 
                'document',
                'literal',
                ''
        );



       function consultasaldocpf($parametro)
        {
                $cyber = new cyber();
                $array2 = array();
                $array2 = $cyber->executarprogress("consultasaldocpf",$parametro);
                return $array2;

        }


$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA)?$HTTP_RAW_POST_DATA : '';
$HTTP_RAW_POST_DATA = str_replace("&lt;","ABRE",$HTTP_RAW_POST_DATA);
$HTTP_RAW_POST_DATA = str_replace("&gt;","FECHA",$HTTP_RAW_POST_DATA);

        $servidor->service($HTTP_RAW_POST_DATA);
?>
