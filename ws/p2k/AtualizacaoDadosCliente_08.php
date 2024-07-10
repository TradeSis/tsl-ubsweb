<?php
/* helio 22122021 - Cadastro P2k - Campos Optin */

$servidor->wsdl->addComplexType(
    'AtualizacaoDadosClienteEntrada', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'codigo_filial' => array('name'=>'name','type'=>'xsd:int'),
        'codigo_operador' => array('name'=>'codigo_operador','type'=>'xsd:string'),
        'numero_pdv'    => array('name'=>'name','type'=>'xsd:int'),
        'codigo_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cpf'           => array('name'=>'name','type'=>'xsd:string'),
        'nome'          => array('name'=>'name','type'=>'xsd:string'),
        'data_nascimento' => array('name'=>'name','type'=>'xsd:dateTime'),
        'codigo_senha' => array('name'=>'name','type'=>'xsd:string'),
        'valor_limite' => array('name'=>'name','type'=>'xsd:decimal'),
        'codigo_bloqueio' => array('name'=>'name','type'=>'xsd:int'),
        'descricao_bloqueio' => array('name'=>'name','type'=>'xsd:string'),
        'percentual_desconto' => array('name'=>'name','type'=>'xsd:decimal'),
        'validade_desconto' => array('name'=>'name','type'=>'xsd:string'),
        'valor_seguro' => array('name'=>'name','type'=>'xsd:decimal'),
        'situacao_seguro_cliente' => array('name'=>'name','type'=>'xsd:string'),
        'cep' => array('name'=>'name','type'=>'xsd:string'),
        'endereco' => array('name'=>'name','type'=>'xsd:string'),
        'numero' => array('name'=>'name','type'=>'xsd:string'),
        'complemento' => array('name'=>'name','type'=>'xsd:string'),
        'bairro' => array('name'=>'name','type'=>'xsd:string'),
        'cidade' => array('name'=>'name','type'=>'xsd:string'),
        'uf' => array('name'=>'name','type'=>'xsd:string'),
        'pais' => array('name'=>'name','type'=>'xsd:string'),
        'email' => array('name'=>'name','type'=>'xsd:string'),
        'deseja_receber_email' => array('name'=>'name','type'=>'xsd:string'),
        'ddd' => array('name'=>'name','type'=>'xsd:string'),
        'telefone' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_pessoa' => array('name'=>'name','type'=>'xsd:string'),
        'credito' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_credito' => array('name'=>'name','type'=>'xsd:string'),
        'sexo' => array('name'=>'name','type'=>'xsd:string'),
        'nacionalidade' => array('name'=>'name','type'=>'xsd:string'),
        'identidade' => array('name'=>'name','type'=>'xsd:string'),
        'estado_civil' => array('name'=>'name','type'=>'xsd:string'),
        'naturalidade' => array('name'=>'name','type'=>'xsd:string'),
        'cnpj' => array('name'=>'name','type'=>'xsd:string'),
        'pai' => array('name'=>'name','type'=>'xsd:string'),
        'mae' => array('name'=>'name','type'=>'xsd:string'),
        'numero_dependentes' => array('name'=>'name','type'=>'xsd:string'),
        'grau_de_instrucao' => array('name'=>'name','type'=>'xsd:string'),
        'situacao_grau_de_instrucao' => array('name'=>'name','type'=>'xsd:string'),
        'plano_saude' => array('name'=>'name','type'=>'xsd:string'),
        'seguros' => array('name'=>'name','type'=>'xsd:string'),
        'ponto_referencia' => array('name'=>'name','type'=>'xsd:string'),
        'celular' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_residencia' => array('name'=>'name','type'=>'xsd:string'),
        'tempo_na_residencia' => array('name'=>'name','type'=>'xsd:string'),
        'data_cadastro' => array('name'=>'name','type'=>'xsd:string'),
        'empresa' => array('name'=>'name','type'=>'xsd:string'),
        'cnpj_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'telefone_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'data_admissao' => array('name'=>'name','type'=>'xsd:dateTime'),
        'profissao' => array('name'=>'name','type'=>'xsd:string'),        
        'renda_total' => array('name'=>'name','type'=>'xsd:decimal'),
        'endereco_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'numero_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'complemento_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'bairro_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'cidade_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'estado_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'cep_empresa' => array('name'=>'name','type'=>'xsd:string'),
        'nome_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'cpf_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'data_nascimento_conjuge' => array('name'=>'name','type'=>'xsd:dateTime'),
        'pai_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'mae_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'empresa_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'telefone_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'profissao_conjuge' => array('name'=>'name','type'=>'xsd:string'),
        'data_admissao_conjuge' => array('name'=>'name','type'=>'xsd:dateTime'),
        'renda_mensal_conjuge' => array('name'=>'name','type'=>'xsd:decimal'),
        'cartoes_de_credito' => array('name'=>'name','type'=>'xsd:string'),
        'banco1' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_conta_banco1' => array('name'=>'name','type'=>'xsd:string'),
        'ano_conta_banco1' => array('name'=>'name','type'=>'xsd:string'),
        'banco2' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_conta_banco2' => array('name'=>'name','type'=>'xsd:string'),
        'ano_conta_banco2' => array('name'=>'name','type'=>'xsd:string'),
        'banco3' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_conta_banco3' => array('name'=>'name','type'=>'xsd:string'),
        'ano_conta_banco3' => array('name'=>'name','type'=>'xsd:string'),
        'banco_outros' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_conta_outros' => array('name'=>'name','type'=>'xsd:string'),
        'ano_banco_outros' => array('name'=>'name','type'=>'xsd:string'),
        'referencias_comerciais1' => array('name'=>'name','type'=>'xsd:string'),
        'situacao_referencias_comerciais1' => array('name'=>'name','type'=>'xsd:string'),
        'referencias_comerciais2' => array('name'=>'name','type'=>'xsd:string'),
        'situacao_referencias_comerciais2' => array('name'=>'name','type'=>'xsd:string'),
        'referencias_comerciais3' => array('name'=>'name','type'=>'xsd:string'),
        'situacao_referencias_comerciais3' => array('name'=>'name','type'=>'xsd:string'),
        'referencias_comerciais4' => array('name'=>'name','type'=>'xsd:string'),
        'situacao_referencias_comerciais4' => array('name'=>'name','type'=>'xsd:string'),
        'referencias_comerciais5' => array('name'=>'name','type'=>'xsd:string'),
        'situacao_referencias_comerciais5' => array('name'=>'name','type'=>'xsd:string'),
        'observacoes' => array('name'=>'name','type'=>'xsd:string'),
        'possui_veiculo' => array('name'=>'name','type'=>'xsd:string'),
        'marca' => array('name'=>'name','type'=>'xsd:string'),
        'modelo' => array('name'=>'name','type'=>'xsd:string'),
        'ano' => array('name'=>'name','type'=>'xsd:string'),
        'nome_ref1' => array('name'=>'name','type'=>'xsd:string'),
        'fone_comercial_ref1' => array('name'=>'name','type'=>'xsd:string'),
        'celular_ref1' => array('name'=>'name','type'=>'xsd:string'),
        'parentesco_ref1' => array('name'=>'name','type'=>'xsd:string'),
        'documentos_apresentados_rf1' => array('name'=>'name','type'=>'xsd:string'),
        'nome_ref2' => array('name'=>'name','type'=>'xsd:string'),
        'fone_comercial_ref2' => array('name'=>'name','type'=>'xsd:string'),
        'celular_ref2' => array('name'=>'name','type'=>'xsd:string'),
        'parentesco_ref2' => array('name'=>'name','type'=>'xsd:string'),
        'documentos_apresentados_rf2' => array('name'=>'name','type'=>'xsd:string'),
        'nome_ref3' => array('name'=>'name','type'=>'xsd:string'),
        'fone_comercial_ref3' => array('name'=>'name','type'=>'xsd:string'),
        'celular_ref3' => array('name'=>'name','type'=>'xsd:string'),
        'parentesco_ref3' => array('name'=>'name','type'=>'xsd:string'),
        'documentos_apresentados_rf3' => array('name'=>'name','type'=>'xsd:string'),
        'resultado_consulta_spc' => array('name'=>'name','type'=>'xsd:string'),
        'filial_efetuou_consulta' => array('name'=>'name','type'=>'xsd:string'),
        'data_consulta' => array('name'=>'name','type'=>'xsd:dateTime'),
        'quantidade_consultas_realizadas' => array('name'=>'name','type'=>'xsd:string'),
        'registros_de_alertas' => array('name'=>'name','type'=>'xsd:string'),
        'registro_do_credito' => array('name'=>'name','type'=>'xsd:string'),
        'registro_de_cheques' => array('name'=>'name','type'=>'xsd:string'),
        'registro_nacional' => array('name'=>'name','type'=>'xsd:string'),
        'spc_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'spc_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'resultado_consulta_serasa' => array('name'=>'name','type'=>'xsd:string'),
        'serasa_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'serasa_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'resultado_consulta_crediario' => array('name'=>'name','type'=>'xsd:string'),
        'crediario_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'crediario_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'limite_cod_motivo_cancelamento' => array('name'=>'name','type'=>'xsd:string'),
        'limite_descr_motivo' => array('name'=>'name','type'=>'xsd:string'),
        'nota' => array('name'=>'name','type'=>'xsd:string'),
        'codigo_mae' => array('name'=>'codigo_mae','type'=>'xsd:string'),
        'categoria_profissional' => array('name'=>'categoria_profissional','type'=>'xsd:string'),

        'optinWhatsApp' => array('name'=>'optinWhatsApp','type'=>'xsd:string'), /* helio 22122021 - Cadastro P2k - Campos Optin */
        'optinSMS'      => array('name'=>'optinSMS','type'=>'xsd:string'),      /* helio 22122021 - Cadastro P2k - Campos Optin */
        
        'tipo_cadastro' => array('name'=>'tipo_cadastro','type'=>'xsd:string'),
        'neuro_id_operacao' => array('name'=>'neuro_id_operacao','type'=>'xsd:string')
    )
);


$servidor->wsdl->addComplexType(
    'AtualizacaoDadosClienteRetorno', // the type's name
    'complexType',
    'struct',
    'sequence',
    '',
    array(
        'status'        => array('name'=>'name','type'=>'xsd:string'),
        'mensagem_erro' => array('name'=>'mensagem_erro','type'=>'xsd:string'),
        'codigo_filial' => array('name'=>'codigo_filial','type'=>'xsd:int'),
        'numero_pdv' => array('name'=>'numero_pdv','type'=>'xsd:int'),
        'credito' => array('name'=>'name','type'=>'xsd:string'),
        'sit_credito' => array('name'=>'name','type'=>'xsd:string'),
        'vcto_credito' => array('name'=>'name','type'=>'xsd:dateTime'), 
        'mensagem_credito' => array('name'=>'name','type'=>'xsd:string'),
        'tipo_cadastro' => array('name'=>'tipo_cadastro','type'=>'xsd:string'),
        'neuro_id_operacao' => array('name'=>'neuro_id_operacao','type'=>'xsd:string')        
    )
);

      $servidor->register
        (
                'AtualizacaoDadosCliente',
                array('AtualizacaoDadosClienteEntrada' => "tns:AtualizacaoDadosClienteEntrada"),
                array('return'=> "tns:AtualizacaoDadosClienteRetorno"),
                $ns,
                $ns.'#AtualizacaoDadosCliente', 
                'document',
                'literal',
                ''
        );



       function AtualizacaoDadosCliente($parametro)
        {
                $p2k = new p2k();
                $array2 = array();
                $array2 = $p2k->executarprogress("AtualizacaoDadosCliente_08",$parametro);
                return $array2;

        }


?>
