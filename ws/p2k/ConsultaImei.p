{/u/bsweb/progr/bsxml.i}

def shared temp-table ConsultaImei
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field imei as char.    

def var vstatus as char.   
def var vmensagem_erro as char.

find first ConsultaImei no-lock no-error.
if avail ConsultaImei
then do.
    assign
        vstatus = "S".

    find tbprice where tbprice.tipo   = "" and
                       tbprice.serial = ConsultaImei.Imei
                 no-lock no-error.
    if not avail tbprice
    then assign
            vstatus = "E"
            vmensagem_erro = "Numero de SERIAL nao cadastrado".
    else if tbprice.nota_venda > 0
    then assign
            vstatus = "E"
            vmensagem_erro = "Ja exite venda com numero de SERIAL informado".
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos".

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",ConsultaImei.codigo_filial).
bsxml("numero_pdv",ConsultaImei.numero_pdv).
bsxml("imei",ConsultaImei.imei).
bsxml("fechatabela","return").
BSXml("FECHAXML","").

