
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).

def shared temp-table EfetivaPagamentoPrestacao
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_operador as char .

def shared temp-table ParcelasPag
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

 
create EfetivaPagamentoPrestacao.

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
            if vh:name = "EfetivaPagamentoPrestacao"
            then do:
                vtabela = "EfetivaPagamentoPrestacao".
            end.
            if vh:name = "parcelas"
            then do:
                vtabela = "parcelasPag".
            end.
        end.
    
        if hc:subtype = "text"          
        then do:
            if vtabela = "EfetivaPagamentoPrestacao"
            then do:
                case vh:name:

                when "data_operacao"
                then EfetivaPagamentoPrestacao.data_operacao = hc:node-value.

                when "codigo_filial"
                then EfetivaPagamentoPrestacao.codigo_filial = hc:node-value.

                when "numero_pdv"
                then EfetivaPagamentoPrestacao.numero_pdv = hc:node-value.

                when "codigo_operador"
                then EfetivaPagamentoPrestacao.codigo_operador = hc:node-value.
                end case.
            end.

            if vtabela = "parcelasPag"
            then do: 
                case vh:name:
                when "codigo_cliente"
                then do:
                    create parcelasPag.
                    parcelasPag.codigo_cliente = hc:node-value.
                end.    
                when "codigo_contrato"
                then parcelasPag.codigo_contrato = hc:node-value.

                when "numero_comprovante"
                then parcelasPag.numero_comprovante = hc:node-value.

                when "numero_cupom_fiscal"
                then parcelasPag.numero_cupom_fiscal = hc:node-value.

                when "valor_prestacao"
                then parcelasPag.valor_prestacao = hc:node-value.

                when "valor_acrescimos"
                then parcelasPag.valor_acrescimo = hc:node-value.

                when "valor_desconto"
                then parcelasPag.valor_desconto = hc:node-value.

                when "cpf"
                then parcelasPag.cpf = hc:node-value.

                when "data_vencimento_parcela"
                then parcelasPag.data_vencimento_parcela = hc:node-value.

                when "seq_parcela"
                then parcelasPag.seq_parcela = hc:node-value.

                when "valor_pago"
                then parcelasPag.valor_pago = hc:node-value.

                when "parcial"
                then parcelasPag.parcial = hc:node-value.

                when "modalidade"
                then parcelasPag.modalidade = hc:node-value.

                when "inf_compl"
                then parcelasPag.inf_compl = hc:node-value.
                
                end case.
            end.                
        end.

        run obtemnode (input hc:handle).
    end.
    
end procedure.