<?php
        
$servidor->wsdl->addComplexType(
    'ConsultaEstoqueEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'filial' => array('name'=>'filial','type'=>'xsd:int'),
        'codigo' => array('name'=>'codigo','type'=>'xsd:string'),
        'descricao' => array('name'=>'descricao','type'=>'xsd:string'),
        'fornecedor' => array('name'=>'fornecedor','type'=>'xsd:string'),
        'mercadologico' => array('name'=>'mercadologico','type'=>'xsd:string')

    )
);



$servidor->wsdl->addComplexType(
    'estoquelistaType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',

    array(
'estoque' => array('name'=>'estoque','type'=>'tns:estoqueType', 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
)

);




$servidor->wsdl->addComplexType(
    'estoqueType', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',

    array(
        'codigo-produto' => array('name'=>'name','type'=>'xsd:string'),
        'loja' => array('name'=>'name','type'=>'xsd:int'),
        'quantidade-disponivel' => array('name'=>'name','type'=>'xsd:int'),
        'quantidade-reservada' => array('name'=>'name','type'=>'xsd:int'),
        'quantidade-em-transito' => array('name'=>'name','type'=>'xsd:int'),
        'quantidade-pendente' => array('name'=>'name','type'=>'xsd:int'),
        'quantidade-nao-conforme' => array('name'=>'name','type'=>'xsd:int'),
        'quantidade-total' => array('name'=>'name','type'=>'xsd:int')
    )

);





$servidor->wsdl->addComplexType(
    'ConsultaEstoqueRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    
    array( 
'estoques' => array('name'=>'estoques','type'=>'tns:estoquelistaType' , 'minOccurs'=>'0', 'maxOccurs'=>'unbounded')
 )    
     
);


      $servidor->register
        (
                'ConsultaEstoque',
                array('ConsultaEstoqueEntrada' => "tns:ConsultaEstoqueEntrada"),
                array('return'=> "tns:ConsultaEstoqueRetorno"),
                $ns, //'WS.p2k', //'WS.p2k.ConsultaEstoque', //'urn:servidor.ConsultaEstoque',
                $ns.'#ConsultaEstoque', //'WS.p2k#ConsultaEstoque', //'urn:servidor.p2k#ConsultaEstoque',
                'document',
                'literal',
                ''
        );



       function ConsultaEstoque($parametro)
        {
                $p2k = new p2k();
                //return $p2k->executarprogress("ConsultaEstoque",$parametro);
                $array2 = array();
                $array2 = $p2k->executarprogress("ConsultaEstoque",$parametro);
                return $array2;

        }


?>
