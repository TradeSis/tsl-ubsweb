{bsxml.i}

def shared temp-table MargemDesconto
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field valor_venda    as dec
    field valor_desconto as dec.

def var vstatus as char.   
def var vmensagem_erro as char.
def var vliberar as log init yes.
def var vetbcod  as int.
def var vltotven like plani.platot.
def var vltotdes like plani.platot.
def var vpercmed like plani.platot.
def var vdtveni  as date.
def var vdtvenf  as date.
def var vdesconto as dec.
def var vokc as log.                    

find first MargemDesconto no-lock no-error.
if avail MargemDesconto
then do.
    assign
        vstatus = "S"
        vdtvenf = today
        vdtveni = today - 30
        vetbcod = int(MargemDesconto.codigo_filial)
        vltotven = dec(MargemDesconto.valor_venda)
        vltotdes = dec(MargemDesconto.valor_desconto).

    if vetbcod = 0
    then assign
            vstatus = "E"
            vmensagem_erro = "Estabelecimento invalido".
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos".

if vstatus = "S"
then do.
    find first ctdesven where ctdesven.etbcod = vetbcod no-lock no-error.    

    for each plani where plani.movtdc = 5
                     and plani.etbcod = vetbcod
                     and plani.pladat >= vdtveni
                     and plani.pladat <= vdtvenf
                   no-lock:
        vokc = yes.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                                    no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            if produ.catcod <> 31
            then do:
                vokc = no.
                leave.
            end.
        end.
        if vokc = no then next.
        vltotven = vltotven + (if plani.biss > 0
                               then plani.biss
                               else plani.platot - plani.vlserv).

        if plani.notobs[2] <> "" and
           substr(plani.notobs[2],1,1) <> "J"
        then do.
            vdesconto = dec(plani.notobs[2]) no-error.
            if vdesconto <> ?
            then vltotdes = vltotdes + vdesconto.
        end.
    end.
    vpercmed = ((vltotdes / vltotven) * 100).

    if avail ctdesven
    then
        if vpercmed > ctdesven.descmed
        then vliberar = no.
end.

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",string(vetbcod)).
bsxml("numero_pdv",MargemDesconto.numero_pdv).
bsxml("liberar",if vliberar then "Sim" else "Nao").
bsxml("fechatabela","return").
BSXml("FECHAXML","").

