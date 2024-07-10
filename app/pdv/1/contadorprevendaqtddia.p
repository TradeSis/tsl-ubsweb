/* helio 11052022 - Contador de Pre-vendas  */

def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.
def var hentrada   as handle.
def var hsaida     as handle.

def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vok as log.

def temp-table ttpreVendas serialize-name "preVendas"
    field codigoFilial      as char
    field data    as char
    field qtdPreVendas as char.

def temp-table ttretorno serialize-name "return"
    field mensagem    as char. /* true/false */

hentrada = temp-table ttpreVendas:handle.
hsaida   = temp-table ttretorno:handle.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


vok = no.
def var vdata as date.
def var vetbcod as int.

for each ttpreVendas.
    
        
    vetbcod = int(ttpreVendas.codigofilial).
    vdata   = date(int(entry(2,ttprevendas.data,"-")),
                   int(entry(3,ttprevendas.data,"-")),
                   int(entry(1,ttprevendas.data,"-"))).
    
                   
       
    find contadorpreVendas where 
            contadorpreVendas.etbcod       = vetbcod and
            contadorprevendas.data         = vdata 
            no-error.
    if not avail contadorprevendas
    then do:
        create contadorprevendas.
        contadorpreVendas.etbcod = vetbcod.
        contadorprevendas.data         = vdata.
        contadorprevendas.qtdPreVendas = int(ttpreVendas.qtdPreVendas). 
    end.
    if vdata >= today - 5
    then do:
        contadorprevendas.qtdPreVendas = int(ttpreVendas.qtdPreVendas).  /* substitui */
    end.
    
    vok = yes.
end.

create ttretorno.
if vok
then ttretorno.mensagem = "OK".
else ttretorno.mensagem = "Erro".


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

