<?php
        
$servidor->wsdl->addComplexType(
    'ParcelasCET', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'parcelas' => array('name'=>'parcelasEntrada','type'=>'tns:parcelasEntradaType', minOccurs=>'0', maxOccurs=>'unbounded')
    )
);

$servidor->wsdl->addComplexType(
    'BuscaDadosContratoNfEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'tipo_documento' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'numero_documento' => array('name'=>'numero_documento','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'valor_compra' => array('name'=>'numero_pdv','type'=>'xsd:decimal'),
        'parcelascet' => array('name'=>'parcelasEntrada','type'=>'tns:ParcelasCET', minOccurs=>'0', maxOccurs=>'unbounded'),
        'nsu_venda' => array('name'=>'nsu_venda','type'=>'xsd:int'),
        'vendedor' => array('name'=>'vendedor','type'=>'xsd:int'),
        'codigo_seguro_prestamista' => array('name'=>'codigo_seguro_prestamista','type'=>'xsd:int'),
        'valor_seguro_prestamista' => array('name'=>'valor_seguro_prestamista','type'=>'xsd:decimal')
    )
);

$servidor->wsdl->addComplexType(
    'BuscaDadosContratoNfRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
        'numero_contrato' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'tipo_operacao' => array('name'=>'name','type'=>'xsd:string'),
        'cet' => array('name'=>'name','type'=>'xsd:decimal'),
        'cet_ano' => array('name'=>'name','type'=>'xsd:decimal'),
        'tx_mes' => array('name'=>'name','type'=>'xsd:decimal'),
        'valor_iof' => array('name'=>'name','type'=>'xsd:decimal'),
        'numero_bilhete' => array('name'=>'name','type'=>'xsd:string'),
        'numero_sorte'   => array('name'=>'name','type'=>'xsd:int')
    )
);



      $servidor->register
        (
                'BuscaDadosContratoNf',
                array('BuscaDadosContratoNfEntrada' => "tns:BuscaDadosContratoNfEntrada"),
                array('return'=> "tns:BuscaDadosContratoNfRetorno"),
                $ns,
                $ns.'#BuscaDadosContratoNf',
                'document',
                'literal',
                ''
        );



       function BuscaDadosContratoNf($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaCliente",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("BuscaDadosContratoNf",$parametro);
                return $array2;

        }



?>
