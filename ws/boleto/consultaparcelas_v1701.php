<?php
        
$servidor->wsdl->addComplexType(
    'ClienteContratoEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_cpfcnpj' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string')

    )
);

$servidor->wsdl->addComplexType(
    'parcelaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'seq_parcela' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'venc_parcela' => array('name'=>'tipo_documento','type'=>'xsd:dateTime'),
        'vlr_parcela' => array('name'=>'numero_documento','type'=>'xsd:decimal'),
        'valor_encargos' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'possui_boleto' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'possui_ted' => array('name'=>'numero_documento','type'=>'xsd:string')




    )
);

$servidor->wsdl->addComplexType(
    'contratoType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'filial_contrato' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'modalidade' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'data_emissao_contrato' => array('name'=>'codigo_filial','type'=>'xsd:dateTime'),
        'valor_contrato' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_total_pago' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_total_pendente' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'valor_total_encargo' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'tp_contrato' => array('tp_contrato','type'=>'xsd:string'),
        'parcelas' => array('name'=>'parcelas','type'=>'tns:parcelaType', minOccurs=>'0', maxOccurs=>'unbounded'),
    )
);

$servidor->wsdl->addComplexType(
    'ParcelasRetorno', // the type's name
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
        'situacao_cliente'          => array('name'=>'name','type'=>'xsd:string'),
        'contratos' => array('name'=>'contratos','type'=>'tns:contratoType', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);


$servidor->register
(
        'ConsultaParcelas',
        array('ClienteContratoEntrada' => "tns:ClienteContratoEntrada"),
        array('ParcelasRetorno'=> "tns:ParcelasRetorno"),
        $ns, 
        $ns.'#ConsultaParcelas', 
        'document',
        'literal',
        ''
);



function ConsultaParcelas($parametro)
{
        $boleto = new boleto();

                $array2 = array();
                $array2 = $boleto->executarprogress("consultaparcelas_v1701",$parametro);
                return $array2;

        }



?>
