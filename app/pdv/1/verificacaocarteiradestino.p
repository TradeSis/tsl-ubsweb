/* helio 17022022 - 263458 - Revisão da regra de novações  */

def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vok as log. 
def var vqtdParcelas as int.
def var vvalorTotalSeguroPrestamista as dec.
def var vvalorTotalSeguroPrestamistaEntrada as dec.
def var vvalorParcelaSeguroPrestamista as dec.
def var vvalorTotal as dec.
def var vvalorAcrescimo as dec.
def var vvalorEntrada as dec.   

def var pcobcod as int.

{/admcom/progr/api/jsoncarteira.i NEW}

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

    create ttcobparam.
    ttcobparam.carteira                      = "lebes".
    
    vok = no.
    find first ttpedidoCartaoLebes no-error.
    if avail ttpedidoCartaoLebes
    then do:
        vvalorTotal     = dec(ttpedidoCartaoLebes.valorTotal).
    end.
    find first ttcartaoLebes no-error.
    if avail ttcartaoLebes
    then do:
        vvalorEntrada   = dec(ttcartaoLebes.valorEntrada).
        vqtdParcelas    = int(ttcartaoLebes.qtdParcelas).  
        vvalorAcrescimo    = dec(ttcartaoLebes.valorAcrescimo).  
    end.
    find first ttparcelas no-error.
/*    find first ttprodutos no-error. */
    if  avail ttpedidoCartaoLebes and
        avail ttcartaoLebes and
/*        avail ttprodutos and  */
        avail ttparcelas 
    then do: 

                                    
        
                    find first ttparcelas.
                    run api/verificacarteira.p (ttpedidoCartaoLebes.tipoOperacao,
                                                dec(ttparcelas.valorParcela),
                                                vqtdParcelas,
                                                vvalorAcrescimo,
                                                output pcobcod ).
                    find cobra where cobra.cobcod = pcobcod no-lock no-error.
                    if avail cobra
                    then ttcobparam.carteira = cobra.cobnom.
                
                
    end.



    /*    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
          message string(vlcsaida).*/

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
os-command value("rm -f " + varquivo).
