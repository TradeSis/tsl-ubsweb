/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */

def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.
def var hentrada   as handle.
def var hsaida     as handle.

def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vpromocavista as char.

def temp-table ttpromocavista serialize-name "promocAVista"
    field codigoFilial      as char
    field codigoPromocao    as char.

def temp-table ttretorno serialize-name "return"
    field promocAVista    as char. /* true/false */

hentrada = temp-table ttpromocavista:handle.
hsaida   = temp-table ttretorno:handle.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


vpromocavista = "false".

find first ttpromocavista no-error.
if avail ttpromocavista
then do:
        find first ctpromavista where 
                ctpromavista.etbcod     =     int(ttpromocavista.codigoFilial) and
                ctpromavista.sequencia  =   int(ttpromocavista.codigoPromocao)
                no-lock no-error.
        if not avail ctpromavista
        then do:
            find first ctpromavista where 
            ctpromavista.etbcod     =    0 and
            ctpromavista.sequencia  =   int(ttpromocavista.codigoPromocao)
            no-lock no-error.
        end.
        if avail   ctpromavista
        then do:
            vpromocavista = "true".
        end.    
end.

create ttretorno.
ttretorno.promocAVista = vpromocavista.



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

