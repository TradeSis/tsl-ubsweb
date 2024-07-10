
/* buscarplanopagamento */
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
   


def shared temp-table cancelamentocrediario
    field tipo_documento as char
    field numero_documento as char
    field numero_contrato as char
    field valor_cancelado as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

  
find first cancelamentocrediario no-error.

vstatus = if avail cancelamentocrediario
          then "S"
          else "E".
vmensagem_erro = if avail cancelamentocrediario
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     


{bsxml.i}


    
    vmensagem_erro = "Cancelamento - " + cancelamentocrediario.numero_contrato + 
            " - Efetivado".
    
    
    BSXml("ABREXML","").
    bsxml("abretabela","return").


       bsxml("status",vstatus).
       bsxml("mensagem_erro",vmensagem_erro).
        bsxml("codigo_filial",cancelamentocrediario.codigo_filial).
        bsxml("numero_pdv",cancelamentocrediario.numero_pdv).

    bsxml("fechatabela","return").
    BSXml("FECHAXML","").














