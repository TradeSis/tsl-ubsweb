/* #082022 helio bau */

def input  parameter vlcentrada as longchar.

{/admcom/progr/bau/baudefs.i new}

def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field codigoFilial as char.


def var vlcsaida   as longchar.

def var vsaida as char.

def var lokjson as log.
def var hsaida   as handle.
def var hentrada   as handle.


FUNCTION acha2 returns character
    (input par-oque as char,
     input par-onde as char).
    def var vx as int.
    def var vret as char.
    vret = ?.
    do vx = 1 to num-entries(par-onde,"|").
        if num-entries( entry(vx,par-onde,"|"),"#") = 2 and
           entry(1,entry(vx,par-onde,"|"),"#") = par-oque
        then do:
            vret = entry(2,entry(vx,par-onde,"|"),"#").
            leave.
        end.
    end.
    return vret.
END FUNCTION.

hentrada = temp-table ttentrada:handle.
lokJSON = hEntrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.


for each bauprodu no-lock.
    find produ of bauprodu no-lock.
    create ttbauprodu.
    ttbauprodu.procod     = produ.procod.
    ttbauprodu.pronom     = produ.pronom.
    run trata_caract_esp.p (input produ.pronom, output ttbauprodu.pronom).
    ttbauprodu.tipoServico   = bauprodu.tipoServico.

    for each bauplan of bauprodu no-lock.
        create ttplanos.
        ttplanos.tipoServico= bauplan.tipoServico.
        ttplanos.fincod = bauplan.fincod.
        find finan of bauplan no-lock.
        ttplanos.qtdvezes = finan.finnpc.
        ttplanos.finnom = finan.finnom.
        ttplanos.moedaspdv = bauplan.moedaspdv.
    end.
end.

hsaida  = dataset bauSaida:handle.

/*lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcsaida).*/


def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apibaubuscaprodutos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
os-command value("rm -f " + varquivo)

