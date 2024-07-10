<?php
        
$servidor->wsdl->addComplexType(
    'parcelaBoletoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'seq_parcela' => array('name'=>'seq_parcela','type'=>'xsd:string'),
        'venc_parcela' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'vlr_parcela_pago' => array('name'=>'vlr_parcela','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'GeraBoletoContratoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'venc_boleto' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'vlr_boleto' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'vlr_servicos' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'parcelas' => array('name'=>'parcelas','type'=>'tns:parcelaBoletoType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'GeraBoletoRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'NomeMetodo' => array('name'=>'name','type'=>'xsd:string'),
        'NomeWebService' => array('name'=>'name','type'=>'xsd:string'),
        'Boleto' => array('name'=>'Boleto','type'=>'tns:boletoType', minOccurs=>'1', maxOccurs=>'1')
         
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
                'GeraBoletoContrato',
                array('GeraBoletoContratoEntrada' => "tns:GeraBoletoContratoEntrada"),
                array('GeraBoletoRetorno'=> "tns:GeraBoletoRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaCliente', //'urn:servidor.ConsultaCliente',
                $ns.'#GeraBoletoContrato', //'WS.p2k#ConsultaCliente', //'urn:servidor.p2k#ConsultaCliente',
                'document',
                'literal',
                ''
        );



       function GeraBoletoContrato($parametro)
        {


                $boleto = new boleto();
                $array2 = array();

                $array2 = $boleto->executarprogress("geraboletocontrato_v1701",$parametro);

                return $array2;


        }


?>
