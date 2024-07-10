
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).


def shared temp-table formapagamentoEntrada
    field codigo_forma_pagamento as char
    field codigo_plano_pagamento as char
    field data_primeira_parcela as char
    field valor_total_forma as char
    field valor_parcela as char
    field valor_entrada as char.

    def var vcodigo_forma_pagamento as char   .
    def var vcodigo_plano_pagamento as char   .
    def var vdata_primeira_parcela as char    .
    def var vvalor_total_forma as char        .
    def var vvalor_parcela as char            .
    def var vvalor_entrada as char.


def shared temp-table produtosEntrada 
    field codigo_produto as char
    field descricao_produto as char
    field quantidade as char
    field preco_unitario as char
    field preco_total as char.

    def var vcodigo_produto as char      .
    def var vdescricao_produto as char   .
    def var vquantidade as char          .
    def var vpreco_unitario as char      .
    def var vpreco_total as char.


def shared temp-table EfetivaVenda
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

 
    
create EfetivaVenda.

run obtemnode (input hroot).


procedure obtemnode.
    
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
            
    create x-noderef hc.
                   
    do loop = 1 to vh:num-children.
    
        vh:get-child(hc,loop).
    
        if hc:subtype = "Element"
        then do:
            if vh:name = "EfetivaVenda"
            then do:
                vtabela = "EfetivaVenda".
            end.
            if vh:name = "produtos"
            then do:
                vtabela = "produtosEntrada".
            end.
            if vh:name = "formapagamento"
            then do:
                vtabela = "formapagamentoEntrada".
            end.
            
        end.
    
        if hc:subtype = "text"
        then do:
            if vtabela = "EfetivaVenda"
            then do:
                case vh:name:
                when "data_operacao"        then EfetivaVenda.data_operacao = hc:node-value.
                when "codigo_cliente"       then EfetivaVenda.codigo_cliente = hc:node-value.
                when "codigo_operador"      then EfetivaVenda.codigo_operador = hc:node-value.
                when "codigo_filial"        then EfetivaVenda.codigo_filial = hc:node-value.
                when "numero_pdv"           then EfetivaVenda.numero_pdv = hc:node-value.
                when "codigo_contrato"      then EfetivaVenda.codigo_contrato = hc:node-value.
                when "numero_comprovante"   then EfetivaVenda.numero_comprovante = hc:node-value.
                when "numero_cupom_fiscal"  then EfetivaVenda.numero_cupom_fiscal = hc:node-value.
                when "valor_total_contrato" then EfetivaVenda.valor_total_contrato = hc:node-value.
                when "valor_acrescimos"     then EfetivaVenda.valor_acrescimos = hc:node-value.
                when "valor_iof"            then EfetivaVenda.valor_iof = hc:node-value.
                when "valor_desconto"       then EfetivaVenda.valor_desconto = hc:node-value.

                end case.
            end.
            if vtabela = "produtosEntrada"
            then do: 
                case vh:name:
                when "codigo_produto"       then vcodigo_produto = hc:node-value. 
                when "descricao_produto"    then vdescricao_produto = hc:node-value. 
                when "quantidade"           then vquantidade = hc:node-value. 
                when "preco_unitario"       then vpreco_unitario = hc:node-value. 
                
                when "preco_total" then  do:
                      vpreco_total = hc:node-value.
                      create produtosEntrada.
                      produtosEntrada.codigo_produto  = vcodigo_produto.
                      produtosEntrada.descricao_produto  = vdescricao_produto.
                      produtosEntrada.quantidade  = vquantidade.
                      produtosEntrada.preco_unitario  = vpreco_unitario.
                      produtosEntrada.preco_total  = vpreco_total.
                end.                    
                end case.
            end.

            if vtabela = "formapagamentoEntrada"
            then do: 
                case vh:name:
                when "codigo_forma_pagamento"       then vcodigo_forma_pagamento = hc:node-value. 
                when "codigo_plano_pagamento"    then vcodigo_plano_pagamento = hc:node-value. 
                when "data_primeira_parcela"           then vdata_primeira_parcela = hc:node-value. 
                when "valor_total_forma"       then vvalor_total_forma = hc:node-value. 
                when "valor_parcela"       then vvalor_parcela = hc:node-value. 
                
                when "valor_entrada" then  do:
                      vvalor_entrada = hc:node-value.
                      create formapagamentoEntrada.
                      formapagamentoEntrada.codigo_forma_pagamento  = vcodigo_forma_pagamento.
                      formapagamentoEntrada.codigo_plano_pagamento  = vcodigo_plano_pagamento .
                      formapagamentoEntrada.data_primeira_parcela  = vdata_primeira_parcela .
                      formapagamentoEntrada.valor_total_forma  = vvalor_total_forma .
                      formapagamentoEntrada.valor_parcela  = vvalor_parcela .
                      formapagamentoEntrada.valor_entrada  = vvalor_entrada .
                end.                    
                end case.
            end.
            
        end.

        run obtemnode (input hc:handle).
    
    end.
    
    
end procedure.