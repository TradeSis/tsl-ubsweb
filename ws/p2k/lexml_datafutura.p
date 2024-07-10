
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

/*def var vnivel as integer.
*/

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).

/*def temp-table tt-nivel
    field nivel as integer
    field campo as char
        index idx01 nivel.

def buffer b1tt-nivel for tt-nivel.
def buffer b2tt-nivel for tt-nivel.
def buffer b3tt-nivel for tt-nivel.
def buffer b4tt-nivel for tt-nivel.
*/

def shared temp-table parcelas 
    field seq_parcela as char
    field vlr_parcela as char
    field venc_parcela as char
    field numero_contrato as char.
DEFINE shared TEMP-TABLE contratos no-UNDO 
    FIELD codigo_cliente         AS CHARACTER 
    FIELD numero_contrato         AS CHARACTER .

Define shared Temp-Table DataFuturaPagamentoPrestacao no-undo 
    field c_recid as recid XML-NODE-TYPE "Hidden"  
    field codigo_filial as character 
    field codigo_operador as character
    field data_futura_pagamento as char.

def var vcodigo_cliente as char.
def var vnumero_contrato as char.
def var vseq_parcela as char.
def var vvlr_parcela as char.
def var vvenc_parcela as char.
    
create DataFuturaPagamentoPrestacao.

/*assign vnivel = 0.
*/
run obtemnode (input hroot).

/*
for each contratos.
disp contratos.
end.
for each parcelas.
disp parcelas.
end.
*/


procedure obtemnode.
    
/*    assign vnivel = vnivel + 1.
*/
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
            
    create x-noderef hc.
                   
    do loop = 1 to vh:num-children.
    
        vh:get-child(hc,loop).
    
/*        find first tt-nivel where tt-nivel.nivel = vnivel
                        no-error.
        if not avail tt-nivel
        then create tt-nivel.
                          
        assign tt-nivel.nivel = vnivel
               tt-nivel.campo = vh:name.
*/
    /*
    disp tt-nivel.
    */
    
/*        find first b1tt-nivel where b1tt-nivel.nivel = vnivel - 1 no-error.
    
        find first b2tt-nivel where b2tt-nivel.nivel = vnivel - 2 no-error.

        find first b3tt-nivel where b3tt-nivel.nivel = vnivel - 3 no-error.
    
        find first b4tt-nivel where b4tt-nivel.nivel = vnivel - 4 no-error.
*/        
    /*
     disp
      vh:name format "x(30)"
      hc:node-value format "X(20)"  
      tt-nivel.nivel 
      tt-nivel.campo      
      hc:subtype
      b1tt-nivel.nivel when avail b1tt-nivel                
      b1tt-nivel.campo when avail b1tt-nivel format "x(10)" 
      b2tt-nivel.nivel when avail b2tt-nivel                
      b2tt-nivel.campo when avail b2tt-nivel format "x(10)" 
      b3tt-nivel.nivel when avail b3tt-nivel                
      b3tt-nivel.campo when avail b3tt-nivel format "x(10)" 
      b4tt-nivel.nivel when avail b4tt-nivel                
      b4tt-nivel.campo when avail b4tt-nivel format "x(10)" 
          with frame mostra down.
    */
    
        if hc:subtype = "Element"
        then do:
            if vh:name = "DataFuturaPagamentoPrestacao"
            then do:
                vtabela = "DataFuturaPagamentoPrestacao".
            end.
            if vh:name = "Contratos"
            then do:
                vtabela = "Contratos".
            end.
            if vh:name = "Parcelas"
            then do:
                vtabela = "Parcelas".
            end.
        
        end.
    
        if hc:subtype = "text"
        then do:
            if vtabela = "DataFuturaPagamentoPrestacao"
            then do:
                case vh:name:
                when "codigo_filial"        then  DataFuturaPagamentoPrestacao.codigo_filial = hc:node-value.
                when "codigo_operador"      then  DataFuturaPagamentoPrestacao.codigo_operador = hc:node-value.
                when "data_futura_pagamento" then DataFuturaPagamentoPrestacao.data_futura_pagamento = hc:node-value.
                end case.
            end.
            if vtabela = "Contratos"
            then do:
                case vh:name:
                when "codigo_cliente"  then  vcodigo_cliente  = hc:node-value.
                when "numero_contrato" then  do:
                        vnumero_contrato = hc:node-value.
                        create contratos.
                        contratos.codigo_cliente  = vcodigo_cliente.
                        contratos.numero_contrato = vnumero_contrato.
                end.                    
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
                      parcelas.numero_contrato = contratos.numero_contrato.
                      parcelas.seq_parcela     = vseq_parcela.         
                      parcelas.vlr_parcela     = vvlr_parcela.
                      parcelas.venc_parcela    = vvenc_parcela.
                end.                    
                end case.
            end.
                
        end.

        run obtemnode (input hc:handle).
    
    end.
    
/*    assign vnivel = vnivel - 1.
*/
        
    
end procedure.