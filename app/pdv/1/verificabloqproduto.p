/* #112022 Gestão de itens promocionais - 1 - bloqueio de descontos em itens promocionais */

def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.
def var hentrada   as handle.
def var hsaida     as handle.

def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vprodutobloqueio as char.

def temp-table ttentrada serialize-name "entrada"
    field codigoFilial      as char
    field codigoProduto     as char.

def temp-table ttretorno serialize-name "return"
    field codigoFilial      as char
    field codigoProduto     as char
    field produtobloqueio   as char. /* true/false */


hentrada = temp-table ttentrada:handle.
hsaida   = temp-table ttretorno:handle.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada.

vprodutobloqueio = "false".

find produBloq where 
    produBloq.etbcod = int(ttentrada.codigoFilial) and
    produBloq.procod = int(ttentrada.codigoProduto)     
    no-lock no-error.
if avail produBloq
then do:
    if (produBloq.dtivig = ? or produBloq.dtivig <= today) and
       (produBloq.dtfvig = ? or produBloq.dtfvig >= today) 
    then vprodutobloqueio = trim(string(produbloq.ativo,"true/false")).
end.
else do:
    find produBloq where 
    produBloq.etbcod = 0 and
    produBloq.procod = int(ttentrada.codigoProduto)     
    no-lock no-error.
    if avail produBloq
    then do:
        if (produBloq.dtivig = ? or produBloq.dtivig <= today) and
           (produBloq.dtfvig = ? or produBloq.dtfvig >= today) 
        then vprodutobloqueio = trim(string(produbloq.ativo,"true/false")).
     end.
    
end.

create ttretorno.
ttretorno.codigoFilial = ttentrada.codigoFilial.
ttretorno.codigoProduto = ttentrada.codigoProduto.
ttretorno.produtobloqueio = vprodutobloqueio.



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

