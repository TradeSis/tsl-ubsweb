/*
#1 TP 31929276 - Usar indice sem primary
*/
def input parameter par-arquivoentrada as char.

{/u/bsweb/progr/bsxml.i}
{/u/bsweb/progr/acha.i}

def var vetbcod as int.
def var xetbcod as int.
def var vetbnom as char.
def var vparam  as char.
def var vip as char.
def var vtotal as int.
def var par-data as date.

def temp-table tt-neuproposta no-undo
    field rec      as recid
    field etbcod  like neuproposta.etbcod
    field dtinclu like neuproposta.dtinclu
    field hrinclu like neuproposta.hrinclu
    
    index neuproposta etbcod dtinclu desc hrinclu desc.

input from value(par-arquivoentrada) no-echo.
import unformatted vparam.
input close.

vip = acha("IP",replace(vparam,"&","|")).
vetbcod  = 0.
vetbnom  = acha("FILIAL",replace(vparam,"&","|")).
par-data = today - 1 /*#1 20 */.

find first estab where estab.etbnom = vetbnom no-lock no-error.
vetbcod = if avail estab then estab.etbcod else 0.

xetbcod = vetbcod.

if num-entries(vip,".") = 4 and vetbcod = 0
then do:
    vetbcod = int(entry(3,vip,".")).
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then vetbcod = xetbcod.        
end.

/*if vip = "10.10.0.120" then vetbcod = 1. */

BSXml("ABREXML","").
bsxml("abretabela","return").

vtotal = 0.
for each estab where (if vetbcod <> 0 then estab.etbcod = vetbcod else true)
               no-lock.
    for each neuproposta where neuproposta.etbcod = estab.etbcod
                           and neuproposta.dtinclu >= par-data
              no-lock.
        find neuclien of neuproposta no-lock no-error.
        if not avail neuclien    
        then next. 

        vtotal = vtotal + 1.

        create tt-neuproposta.
        assign
            tt-neuproposta.etbcod  = neuproposta.etbcod
            tt-neuproposta.dtinclu = neuproposta.dtinclu
            tt-neuproposta.hrinclu = neuproposta.hrinclu
            tt-neuproposta.rec     = recid(neuproposta).
    end.
end.

BSXml("total",string(vtotal)).

for each tt-neuproposta use-index neuproposta no-lock.
    find neuproposta where recid(neuproposta) = tt-neuproposta.rec no-lock.
    find neuclien of neuproposta no-lock.

    BSXml("ABREREGISTRO","rows").
    bsxml("etbcod", string(neuproposta.etbcod)).
    bsxml("dtinclu",string(neuproposta.dtinclu,"99/99/9999")).
    bsxml("hrinclu",string(neuproposta.hrinclu,"HH:MM:SS")).
    bsxml("cpfcnpj",string(neuproposta.cpfcnpj)).

    if neuclien.clicod = ?
    then bsxml("clicod","0").
    else bsxml("clicod",string(neuclien.clicod)).
        
    bsxml("nome_pessoa",string(neuclien.nome_pessoa)).
    bsxml("etbcad",string(neuclien.etbcod,"999")).
    bsxml("sit_credito",string(neuclien.sit_credito)).

    if neuclien.vctolimite = ?
    then bsxml("vctolimite","00/00/0000").
    else bsxml("vctolimite",string(neuclien.vctolimite,"99/99/9999")).

    bsxml("vlrlimite",string(neuclien.vlrlimite,">>>>>>>9.99")).
        
    bsxml("tipoconsulta",neuproposta.tipoconsulta).
    bsxml("neu_cdoperacao",neuproposta.neu_cdoperacao).
    bsxml("neu_resultado",neuproposta.neu_resultado).

    BSXml("FECHAREGISTRO","rows").
end.
    
bsxml("fechatabela","return").
BSXml("FECHAXML","").

