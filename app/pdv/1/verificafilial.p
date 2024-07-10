/* helio 112022 - Venda O, que permite a venda para uma loja que está fechada. */

def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.
def var hentrada   as handle.
def var hsaida     as handle.

def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vemOperacao as char.

def temp-table ttentrada serialize-name "entrada"
    field codigoFilial      as char.

def temp-table ttretorno serialize-name "return"
    field codigoFilial      as char
    field emOperacao    as char. /* true/false */

hentrada = temp-table ttentrada:handle.
hsaida   = temp-table ttretorno:handle.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada.

vemOperacao = "false".

find estab where estab.etbcod = int(ttentrada.codigoFilial) no-lock no-error.
if avail estab
then do:
    if estab.emOperacao
    then vemOperacao = "true".
end.

create ttretorno.
ttretorno.codigoFilial = ttentrada.codigoFilial.
ttretorno.emOperacao = vemOperacao.



        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcsaida).
/*** 
def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.
          
varquivo  = "/u/bsweb/works/verificacaocarteiradestino" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".


lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
/*os-command value("rm -f " + varquivo)*/
***/

