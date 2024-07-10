/*
#1 Versao 02: junho/2017
#2 Versao 03: agosto/2017
#3 Versao   : Motor de Credito
#4 Versao 04: Nova Novacao
#7 Versao 07: agosto/18 - nova versao do motor (log), cheque sem fundos, 
                          feriado por municipio
*/

{/u/bsweb/progr/bsxml.i} 
def input parameter vacao as char.
def input parameter varquivoentrada as char.
def var xmltabela as char.

def new global shared var setbcod       as int.
def new global shared var vtime as int.

def new shared var vtiposervidor as char.
def new shared temp-table tt-estab
        field etbcod as int
        field etbnom as char.

def new shared temp-table ConsultaCliente
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field tipo_cadastro   as char.

def new shared temp-table AtualizacaoDadosCliente
    field codigo_filial as int
    field codigo_operador as char
    field numero_pdv    as int
    field codigo_cliente as char
    field cpf as char
    field nome as char
    field data_nascimento as char
    field codigo_senha as char
        field valor_limite as char
        field codigo_bloqueio as int
        field descricao_bloqueio as char
        field percentual_desconto as char
        field validade_desconto as char
        field valor_seguro as char
        field situacao_seguro_cliente as char
        field cep as char
        field endereco as char
        field numero as char
        field complemento as char
        field bairro as char
        field cidade as char
        field uf as char
        field pais as char
        field email as char
        field deseja_receber_email as char
        field ddd as char
                  field telefone as char
                  field tipo_pessoa as char
                  field credito as char
                  field tipo_credito as char
        field sexo as char
        field nacionalidade as char
        field identidade as char
        field estado_civil as char
        field naturalidade as char
        field cnpj as char
        field pai as char
        field mae as char
        field numero_dependentes as char
        field grau_de_instrucao as char
        field situacao_grau_de_instrucao as char
        field plano_saude as char
        field seguros as char
        field ponto_referencia as char
        field celular as char
        field tipo_residencia as char
        field tempo_na_residencia as char
        field data_cadastro as char
        field empresa as char
        field cnpj_empresa as char
        field telefone_empresa as char
        field data_admissao as char
        field profissao as char
        field renda_total as char
        field endereco_empresa as char
        field numero_empresa as char
        field complemento_empresa as char
         field bairro_empresa   as char 
         field cidade_empresa   as char 
         field estado_empresa   as char 
         field cep_empresa   as char 
         field nome_conjuge   as char 
         field cpf_conjuge   as char 
         field data_nascimento_conjuge   as char 
         field pai_conjuge   as char 
         field mae_conjuge   as char 
         field empresa_conjuge as char 
         field telefone_conjuge   as char 
         field profissao_conjuge as char 
         field data_admissao_conjuge  as char 
         field renda_mensal_conjuge as char
         field cartoes_de_credito  as char 
         field banco1 as char
         field tipo_conta_banco1 as char
         field ano_conta_banco1 as char
         field banco2 as char
         field tipo_conta_banco2 as char
         field ano_conta_banco2 as char
         field banco3 as char
         field tipo_conta_banco3 as char
         field ano_conta_banco3 as char
         field banco_outros as char
         field tipo_conta_outros as char
         field ano_banco_outros as char
         field referencias_comerciais1 as char
         field situacao_referencias_comerciais1 as char
         field referencias_comerciais2 as char
         field situacao_referencias_comerciais2 as char
         field referencias_comerciais3 as char
         field situacao_referencias_comerciais3 as char
         field referencias_comerciais4 as char
         field situacao_referencias_comerciais4 as char
         field referencias_comerciais5 as char
         field situacao_referencias_comerciais5 as char
         field  observacoes as char 
         field  possui_veiculo    as char         
         field  marca as char  
         field  modelo as char  
         field  ano as char   
         field  nome_ref1 as char  
         field  fone_comercial_ref1  as char 
         field  celular_ref1  as char 
         field  parentesco_ref1  as char 
         field  documentos_apresentados_rf1   as char 
                 field  nome_ref2  as char 
         field  fone_comercial_ref2   as char 
                 field  celular_ref2  as char 
         field  parentesco_ref2 as char 
         field  documentos_apresentados_rf2  as char 
         field  nome_ref3  as char 
         field  fone_comercial_ref3  as char 
         field  celular_ref3  as char 
         field  parentesco_ref3  as char 
         field  documentos_apresentados_rf3  as char 
         field  resultado_consulta_spc  as char 
         field  filial_efetuou_consulta  as char 
         field  data_consulta  as char 
         field  quantidade_consultas_realizadas   as char 
         field  registros_de_alertas as char 
         field  registro_do_credito  as char 
         field  registro_de_cheques  as char 
         field  registro_nacional  as char 
         field  spc_cod_motivo_cancelamento  as char 
         field  spc_descr_motivo  as char 
         field  resultado_consulta_serasa  as char 
         field  serasa_cod_motivo_cancelamento  as char 
         field  serasa_descr_motivo  as char 
         field  resultado_consulta_crediario  as char 
         field  crediario_cod_motivo_cancelament  as char 
         field  crediario_descr_motivo  as char 
         field  limite_cod_motivo_cancelamento  as char 
         field  limite_descr_motivo  as char 
         field  nota as char 
         field codigo_mae as char
         field categoria_profissional as char
             field tipo_cadastro   as char
    field neuro_id_operacao as char.                                 

def new shared temp-table BuscaDadosContratoNf
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field valor_compra as char
    field nsu_venda as char
    field vendedor  as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char.

def new shared temp-table EfetivaVenda
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_cliente as char
    field codigo_contrato as char
    field numero_comprovante as char
    field numero_cupom_fiscal as char
    field valor_total_contrato as char
    field valor_acrescimos as char
    field valor_iof as char
    field valor_desconto as char
    field codigo_operador as char.

def new shared temp-table ConsultaParcelas
    field tipo_documento as char
    field funcionalidade as char
    field numero_documento as char
    field codigo_contrato as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char .

def new shared temp-table EfetivaPagamentoPrestacao
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_operador as char.

def new shared temp-table ParcelasPag
    field codigo_cliente as char
    field codigo_contrato as char
    field numero_comprovante as char
    field numero_cupom_fiscal as char
    field valor_prestacao as char
    field valor_acrescimos as char
    field valor_desconto as char
    field cpf as char
    field data_vencimento_parcela as char
    field seq_parcela   as char
    field valor_pago    as char
    field parcial       as char
    field modalidade    as char
    field inf_compl     as char.

def new shared temp-table CancelamentoPagamentoPrestacao
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_cliente as char
    field codigo_contrato as char
    field numero_comprovante as char
    field numero_cupom_fiscal as char
    field valor_prestacao as char
    field codigo_operador as char
    field cpf as char
    field data_vencimento_parcela as char.

def new shared temp-table EfetivaPagamentoBonus
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_cliente as char
    field nome_bonus as char
    field codigo_filial_bonus as char
    field numero_bonus as char
    field venc_bonus as char
    field vlr_bonus as char.

def new shared temp-table BuscaDadosClienteNome
    field nome_cliente as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

def new shared temp-table CancelamentoCrediario
    field tipo_documento as char
    field numero_documento as char
    field numero_contrato as char
    field valor_cancelado as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

def new shared temp-table BuscaSenhaToken
    field usuario as char
    field senha as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

def new shared temp-table ConsultaSPC
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char
    field nome_pessoa     as char
    field data_nascimento as char.

def new shared temp-table parcelas 
    field seq_parcela as char
    field vlr_parcela as char
    field venc_parcela as char
    field numero_contrato as char.

def new shared temp-table produtosEntrada 
    field codigo_produto as char
    field descricao_produto as char
    field quantidade as char
    field preco_unitario as char
    field preco_total as char.

def new shared temp-table formapagamentoEntrada
    field codigo_forma_pagamento as char
    field codigo_plano_pagamento as char
    field data_primeira_parcela as char
    field valor_total_forma as char
    field valor_parcela as char
    field valor_entrada as char.

DEFINE new shared TEMP-TABLE contratos no-UNDO 
    FIELD codigo_cliente         AS CHARACTER 
    FIELD numero_contrato         AS CHARACTER .

Define new shared Temp-Table DataFuturaPagamentoPrestacao no-undo 
    field c_recid as recid XML-NODE-TYPE "Hidden"  
    field codigo_filial as character 
    field codigo_operador as character
    field data_futura_pagamento as char.

/*** Credito Pessoal ***/
def new shared temp-table ConsultaProdutosFinanceiros
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field tipo_documento    as char
    field numero_documento  as char.

def new shared temp-table SimularTransacaodeCredito
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field codigo_produto    as char
    field valor_solicitado  as char
    field numero_parcelas   as char
    field plano_pagamento   as char
    field percentual_seguro as char.

def new shared temp-table AutorizarEmprestimo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field codigo_produto    as char
    field valor_tfc         as char
    field valor_credito     as char
    field data_primeiro_vencimento  as char
    field valor_primeiro_vencimento as char
    field numero_parcelas   as char
    field nsu_venda         as char
    field vendedor          as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char
    field forma_pagamento   as char.

def new shared temp-table EfetivaEmprestimo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field numero_contrato   as char
    field codigo_produto    as char
    field valor_tfc         as char
    field valor_credito     as char
    field nsu_venda         as char
    field vendedor          as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char
    field numero_bilhete    as char
    field numero_sorte      as char
    field data_emissao      as char.

def new shared temp-table ConsultaEstoque
    field filial as int
    field codigo as char
    field descricao as char
    field fornecedor as char
    field mercadologico as char.

def new shared temp-table ConsultaImei
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field imei as char.

def new shared temp-table MargemDesconto
    field codigo_filial  as char
    field codigo_operador as char
    field numero_pdv     as char
    field valor_venda    as dec
    field valor_desconto as dec.

def new shared temp-table ConsultaAcordo
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char.

/*** Motor de Credito #3 ***/
def new shared temp-table PreAutorizacao
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char 
    field nome_pessoa     as char
    field data_nascimento as char
    field mae             as char
    field codigo_mae      as char
    field categoria_profissional as char
    field tipo_cadastro   as char.

def new shared temp-table VerificaCreditoVenda
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field tipo_venda       as char 
    field codigo_cliente  as char
    field produtos_valores as char
    field qtde_parcelas    as char
    field vlr_acrescimo as char
    field vlr_entrada as char
    field vlr_prestacao as char
    field dt_primvcto as char
    field dt_ultivcto as char
    field vdaterceiros as char
    field neuro_id_operacao as char.

def new shared temp-table ConsultaCEP
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field CEP             as char.

def var varqlog as char.
varqlog = "/ws/log/p2k07_" + string(today, "99999999") + ".log".

output to value(varqlog) append.
put unformatted skip
    string(time, "hh:mm:ss")
    " acao=" vacao skip
    " arquivo=" varquivoentrada skip.
output close.

run value(vacao) (varquivoentrada).

run value(vacao + ".p"). /* chama programa relativo a funcao no webservice */


procedure ConsultaCliente_07. /* #6 #7 */
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaCliente:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure ConsultaCliente1.
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaCliente:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure AtualizacaoDadosCliente_07. /* #6 #7 */
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE AtualizacaoDadosCliente:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure BuscaDadosContratoNf_03.
    def input parameter varquivoentrada as char.

    run ws/p2k/lexml_buscacontrato.p (input varquivoentrada).

end procedure.


procedure EfetivaVenda.
    def input parameter varquivoentrada as char.

    run ws/p2k/lexml_efetivavenda.p (input varquivoentrada).

end procedure.


procedure ConsultaParcelas_H. /* #4 #7 */
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaParcelas:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure efetivaPagamentoPrestacao_07. /* #2 #7 */
    def input parameter varquivoentrada as char.

    run ws/p2k/lexml_efetivapagamentoprestacao_03.p (input varquivoentrada).

end procedure.


procedure cancelamentopagamentoPrestacao.
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE cancelamentopagamentoPrestacao:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure efetivaPagamentobonus.
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE EfetivaPagamentobonus:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure BuscaDadosClienteNome_06.
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE BuscaDadosClienteNome:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure BuscaSenhaToken.
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE BuscaSenhaToken:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure cancelamentocrediario.
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE cancelamentocrediario:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure DataFuturaPagamentoPrestacao.
    def input parameter varquivoentrada as char.

    run ws/p2k/lexml_datafutura.p (input varquivoentrada).
end procedure.


procedure ConsultaSPC_07. /* # 07 */

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaSPC:READ-XML("FILE", 
                                        varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


/*** Credito Pessoal ***/
procedure ConsultaProdutosFinanceiros_H.

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaProdutosFinanceiros:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ? ).
end procedure.


procedure SimularTransacaodeCredito.

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE SimularTransacaodeCredito:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure AutorizarEmprestimo_H. /* #2 */
    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE AutorizarEmprestimo:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).

end procedure.


procedure EfetivaEmprestimo.

    def input parameter varquivoentrada as char.

    run ws/p2k/lexml_efetivaemprestimo.p (input varquivoentrada).

end procedure.


procedure ConsultaEstoque.

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaEstoque:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure ConsultaImei.

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaImei:READ-XML("FILE", 
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure MargemDesconto.

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE MargemDesconto:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
end procedure.


procedure ConsultaAcordo_07. /* #1 #7 */

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = 
        TEMP-TABLE ConsultaAcordo:READ-XML("FILE",
                                  varquivoentrada, "EMPTY", ?, ?, ?, ?).
    
end procedure.


procedure PreAutorizacao_07. /* #3 #6 #7 */

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = 
        TEMP-TABLE PreAutorizacao:READ-XML("FILE", varquivoentrada, "EMPTY", 
                                  ?, ?, ?, ?).
end procedure.


procedure VerificaCreditoVenda_07. /* #3 #6 #7 */

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE VerificaCreditoVenda:READ-XML("FILE",
                            varquivoentrada, "EMPTY",  ?, ?, ?, ?).
end procedure.


procedure ConsultaCEP_05. /* #3 */

    def input parameter varquivoentrada as char.

    def var v-return-mode as log no-undo.

    v-return-mode = TEMP-TABLE ConsultaCEP:READ-XML("FILE", varquivoentrada,
                            "EMPTY",  ?, ?, ?, ?).
end procedure.

