def input  parameter vlcentrada as longchar.

def var vetbcod as int.
def var vprocod as int.
def var vlcsaida   as longchar.
def var vsaida as char.

def var lokjson as log.
def var hentrada   as handle.

def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "planos"
    field produto as char
    field filial as char.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def temp-table ttplanos  no-undo serialize-name "planos"
    field fincod        as char serialize-name "codigoPlano"
    field finnom        as char serialize-name "nomePlano"
    field qtdvezes      as char.


hentrada = temp-table ttentrada:handle.
lokJSON = hEntrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.
if not avail ttentrada
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

function Troca-Letra returns character
    (input par-texto as char).

    def var mletrade   as int  extent 6 init [199, 195, 138, 142, 166, 186].
    def var mletrapara as char extent 6 init ["C", "A", "C", "A", "A", "O"].
    def var vtexto as char.
    def var vletra as char.
    def var vct    as int.
    def var vi     as int.

    par-texto = caps(trim(replace(par-texto, "~\"," "))).
    do vi = 1 to length(par-texto).
        vletra = substring(par-texto, vi, 1).
        if asc(vletra) > 127
        then
            do vct = 1 to 6.
                if asc(vletra) = mletrade[vct]
                then vletra = mletrapara[vct].
            end.

        if      vletra = "<" then vtexto = vtexto + "&lt;".
        else if vletra = ">" then vtexto = vtexto + "&gt;".
        else if vletra = "&" then vtexto = vtexto + "&amp;".
        else if asc(vletra) = 34 then vtexto = vtexto + "&quot;". /* " */
        else if asc(vletra) = 39 then vtexto = vtexto + "&#39;".  /* ' */
        else
            if length(vletra) = 1 and
               asc(vletra) >  31 and
               asc(vletra) < 127
            then vtexto = vtexto + vletra.
    end.
    return vtexto.

end function.

vetbcod = int(ttentrada.filial) no-error.
vprocod = int(ttentrada.produto) no-error.

for each segplan where
  segplan.procod = vprocod and
  segplan.ativo = yes and
  segplan.etbcod   = 0
  no-lock.

    find finan of segplan no-lock.

    create ttplanos.
    ttplanos.fincod = string(segplan.fincod).
    ttplanos.finnom = troca-letra(finan.finnom).
    ttplanos.qtdvezes = string(finan.finnpc + if finan.finent then 1 else 0).

end.

for each segplan where
  segplan.procod = vprocod and
  segplan.ativo = yes and
  segplan.etbcod   = vetbcod
  no-lock.

    find finan of segplan no-lock.

    find ttplanos where ttplanos.fincod = string(finan.fincod) no-error.
    if avail ttplanos then next.
    create ttplanos.
    ttplanos.fincod = string(segplan.fincod).
    ttplanos.finnom = troca-letra(finan.finnom).
    ttplanos.qtdvezes = string(finan.finnpc + if finan.finent then 1 else 0).

end.



hsaida  = temp-table ttplanos:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).


/*vsaida  = replace(replace(string(vlcsaida),"[",""),"]","").*/

message string(vlcsaida).
