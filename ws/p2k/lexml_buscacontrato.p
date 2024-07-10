
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).


def shared temp-table parcelas 
    field seq_parcela as char
    field vlr_parcela as char
    field venc_parcela as char
    field numero_contrato as char.
 
def shared temp-table BuscaDadosContratoNf
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
 
def var vcodigo_cliente as char.
def var vnumero_contrato as char.
def var vseq_parcela as char.
def var vvlr_parcela as char.
def var vvenc_parcela as char.
    
create BuscaDadosContratoNf.

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
            if vh:name = "BuscaDadosContratoNf"
            then do:
                vtabela = "BuscaDadosContratoNf".
            end.
            if vh:name = "parcelas"
            then do:
                vtabela = "Parcelas".
            end.
        end.
    
        if hc:subtype = "text"
        then do:
            if vtabela = "BuscaDadosContratoNf"
            then do:
                case vh:name:
                when "tipo_documento" then
                        BuscaDadosContratoNf.tipo_documento = hc:node-value.
                when "numero_documento" then
                        BuscaDadosContratoNf.numero_documento = hc:node-value.
                when "codigo_operador" then
                        BuscaDadosContratoNf.codigo_operador = hc:node-value.
                when "codigo_filial"    then BuscaDadosContratoNf.codigo_filial = hc:node-value.
                when "numero_pdv"       then BuscaDadosContratoNf.numero_pdv = hc:node-value.
                when "valor_compra"     then BuscaDadosContratoNf.valor_compra = hc:node-value.

                when "nsu_venda" then
                        BuscaDadosContratoNf.nsu_venda = hc:node-value.

                when "vendedor"  then
                        BuscaDadosContratoNf.vendedor = hc:node-value.

                when "codigo_seguro_prestamista" then
                 BuscaDadosContratoNf.codigo_seguro_prestamista = hc:node-value.

                when "valor_seguro_prestamista>" then
                 BuscaDadosContratoNf.valor_seguro_prestamista = hc:node-value.
                end case.
             end.
            if vtabela = "parcelas"
            then do: 
                case vh:name:
                when "seq_parcela" then vseq_parcela = hc:node-value. 
                when "vlr_parcela" then vvlr_parcela = hc:node-value. 
                when "data_vencimento" then  do:
                      vvenc_parcela = hc:node-value.
                      create parcelas.
                      parcelas.seq_parcela     = vseq_parcela.         
                      parcelas.vlr_parcela     = vvlr_parcela.
                      parcelas.venc_parcela    = vvenc_parcela.
                end.                    
                end case.
            end.
                
        end.

        run obtemnode (input hc:handle).
    
    end.
    
    
end procedure.