
/* buscarplanopagamento */
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vchar as char.
def var vdec as dec.
def var vdata as date.
def var vvlcob as dec.
def var vdtven as date.
def var vvlacre as dec.
def var vvldes as dec.   
def var vcli as int.
 
def shared temp-table cancelamentopagamentoprestacao
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
  
find first cancelamentopagamentoprestacao no-lock no-error.

vstatus = if avail cancelamentopagamentoprestacao
          then "S"
          else "E".
vmensagem_erro = if avail cancelamentopagamentoprestacao
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     

{bsxml.i}

         
    vmensagem_erro = "Pagamento - " + cancelamentopagamentoprestacao.codigo_contrato + 
            " - Efetivado".
    
    
    BSXml("ABREXML","").
    bsxml("abretabela","return").
        
    vchar = cancelamentopagamentoprestacao.data_vencimento_parcela.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                     int(substring(vchar,9,2)),
                     int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then  vdtven = vdata.                                 
    end.        
    vvlcob = 0.
                                  
    if testavalido(cancelamentopagamentoprestacao.valor_prestacao)
    then do:
        vdec = dec(cancelamentopagamentoprestacao.valor_prestacao) no-error.
        if vdec <> ?
        then vvlcob = vdec.
    end.

    if testavalido(cancelamentopagamentoprestacao.codigo_cliente)
    then do:
        vdec = int(cancelamentopagamentoprestacao.codigo_cliente) no-error.
        if vdec <> ?
        then vcli = int(vdec).
    end.        

    find first titulo use-index iclicod where
        titulo.empcod = 19 and
        titulo.titnat = no and
        titulo.clifor = vcli and
        titulo.titnum = cancelamentopagamentoprestacao.codigo_contrato and
        (titulo.modcod = "CRE" or
         titulo.modcod = "CP0" or
         titulo.modcod = "CP1") and
        titulo.titdtpag <> ? and
        titulo.titdtven = vdtven and
        titulo.titvlcob = vvlcob
        exclusive no-error.
    if avail titulo
    then do:
        /**
        titulo.titsit = "LIB".
        titulo.titvlpag = 0.
        titulo.titdtpag = ?. /* SALDO CARTEIRA */
        **/
       vmensagem_erro = "SALDO_CARTEIRA - Solicite Estorno na Matriz".
 
end.
else do:    
    vmensagem_erro = "Pagamento - " + 
        cancelamentopagamentoprestacao.codigo_contrato + " - NAO Encontrado".
end.

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",string(cancelamentopagamentoprestacao.codigo_filial)).
bsxml("numero_pdv",string(cancelamentopagamentoprestacao.numero_pdv)).
  
bsxml("fechatabela","return").
BSXml("FECHAXML","").

