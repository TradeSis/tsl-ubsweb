
/* buscarplanopagamento */
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vjuros as dec.   
def var vsaldojur as dec.
def var vchar as char.
def var vdata as date.
def var vrec as recid.   
   
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


find first DataFuturaPagamentoPrestacao no-error.

vstatus = if avail DataFuturaPagamentoPrestacao
          then "S"
          else "E".
vmensagem_erro = if avail DataFuturaPagamentoPrestacao
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     


{bsxml.i}

        vchar = datafuturapagamentoprestacao.data_futura_pagamento.
        if testavalido(vchar)
        then do:
            vdata = date(int(substring(vchar,6,2)),
                         int(substring(vchar,9,2)),
                         int(substring(vchar,1,4))) no-error.
            if vdata = ?
            then  vdata = today.
        end.                                  
     
     
    BSXml("ABREXML","").
    bsxml("abretabela","return").

    bsxml("status",vstatus).
    bsxml("mensagem_erro",vmensagem_erro).
    bsxml("funcionalidade",vmensagem_erro).
    find first contratos no-error.
        if avail contratos 
        then
                bsxml("codigo_cliente",string(contratos.codigo_cliente)).
    
    for each contratos.

                BSXml("ABREREGISTRO","contratos"). 
                bsxml("codigo_cliente",string(contratos.codigo_cliente)).
                bsxml("numero_contrato",string(contratos.numero_contrato)).
                for each parcelas where parcelas.numero_contrato = contratos.numero_contrato.

                    vrec = ?.
                    for each estab no-lock.
                     find first titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = estab.etbcod and
                        titulo.clifor = int(contratos.codigo_cliente) and
                        titulo.modcod = "CRE" and
                        titulo.titnum = string(int(contratos.numero_contrato)) and
                        titulo.titpar = int(parcelas.seq_parcela)
                        no-lock no-error.
                        if avail titulo then do:
                            VREC = recid(titulo).
                            leave.
                        end.    
                    end.
                    find titulo where recid(titulo) = vrec no-lock no-error.
                    if avail titulo
                    then do:
                        BSXml("ABREREGISTRO","parcelas"). 
                    
                        bsxml("seq_parcela",string(parcelas.seq_parcela)).
                        bsxml("data_vencimento",string(parcelas.venc_parcela)).
                        bsxml("vlr_parcela",string(parcelas.vlr_parcela)).

            /** BASE MATRIZ 
            */
            run bstitjuro.p (input recid(titulo),
                             input vdata,
                             output vjuros,
                             output vsaldojur).
            
            /** BASE LOJA
            
            run p2kcalcjur.p (input recid(titulo),
                             input vdata,
                             output vjuros,
                             output vsaldojur).

            */
            

                        bsxml("valor_encargos_data_futura",string(vjuros,">>>>>>>>>>9.99")).
                        bsxml("vlr_parcela_data_futura",string(titulo.titvlcob + vjuros,">>>>>>>>>9.99")).
                    
                        BSXml("FECHAREGISTRO","parcelas"). 
                    end.               
                   
                end.   

                BSXml("FECHAREGISTRO","contratos"). 

    end.


    bsxml("fechatabela","return").
    BSXml("FECHAXML","").












