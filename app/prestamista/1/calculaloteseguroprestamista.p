/* helio 112022 - campanha seguro prestamista gratis */
/* helio 17062022 - (Gabriela) PreVenda - Tela de simulação de parcelas */

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

def var vcatnom as char.


{/admcom/progr/seg/jsonloteprestamista.i NEW}

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

    find segtipo where segtipo.tpseguro = 1 no-lock no-error.    /* seguro prestamista */
    
    create ttsegprestpar.
    ttsegprestpar.elegivel                      = "false".
    ttsegprestpar.campanhaGratis                = "false".

    vok = no.
    find first ttpedidoCartaoLebes no-error.
    if avail ttpedidoCartaoLebes
    then do:
        vvalorTotal     = dec(ttpedidoCartaoLebes.valorTotal).
    end.
    vcatnom = "".
    for each ttprodutos.
        if vcatnom <> "" then leave.
        find produ where produ.procod = int(ttprodutos.codigoProduto) no-lock no-error.
        if avail produ
        then do:
            find categoria of produ no-lock no-error.
            if avail categoria
            then do:
                if produ.catcod = 31 or produ.catcod = 41
                then vcatnom = trim(categoria.catnom).
            end.
        end.         
    end.
    

    for each ttparcelas by int(ttparcelas.qtdParcelas) :

        vvalorEntrada   = dec(ttparcelas.valorEntrada).
        vqtdParcelas    = int(ttparcelas.qtdParcelas).  
        vvalorAcrescimo = int(ttparcelas.valorAcrescimo).  

        if  avail ttpedidoCartaoLebes and
           avail segtipo and
            vcatnom <> ""
        then do: 
            find first segprestpar where 
                        segprestpar.tpseguro  = segtipo.tpseguro and
                        segprestpar.categoria = vcatnom and
                        segprestpar.etbcod    = int(ttpedidocartaolebes.codigoLoja)
                    no-lock no-error.
            if not avail segprestpar
            then do:
                find first segprestpar where 
                        segprestpar.tpseguro  = segtipo.tpseguro and
                        segprestpar.categoria = vcatnom and
                        segprestpar.etbcod    = 0
                    no-lock no-error.
            end.     
            
                    
            if avail segprestpar
            then do:
                vok = yes.
                    /*
                    for each ttparcelas.
                        if dec(ttparcelas.valorParcela) < segprestpar.valMinParc
                        then do:
                            vok = no.

                        end.    
                    end.
                    if vqtdparcelas < qtdMinParc
                    then do:
                    
                        vok = no.
                    end.    
                    */
                if vok
                then do:

                    vvalorTotalSeguroPrestamista    = 0.
                    vvalorTotalSeguroPrestamistaEntrada  = 0.                      
                        /*
                        if segprestpar.considerarEntrada = yes
                        then do:
                            if segprestpar.valorPorParcela > 0
                            then vvalorTotalSeguroPrestamistaEntrada = segprestpar.valorPorParcela.
                            else vvalorTotalSeguroPrestamistaEntrada = vvalorEntrada * segprestpar.percentualSeguro / 100.
                        end.
                        */

                    if segprestpar.valorPorParcela > 0
                    then vvalorTotalSeguroPrestamista = (vqtdparcelas * segprestpar.valorPorParcela).
                    else vvalorTotalSeguroPrestamista = (vvalorTotal) * segprestpar.percentualSeguro / 100.
                 
                    vvalorParcelaSeguroPrestamista    = vvalorTotalSeguroPrestamista / vqtdparcelas.
                    
                    ttsegprestpar.codigoSeguroPrestamista       = string(segprestpar.codigoSeguro).
                    ttsegprestpar.valorTotalSeguroPrestamista   = trim(string(vvalorTotalSeguroPrestamista + 
                                                                                vvalorTotalSeguroPrestamistaEntrada  ,">>>>>>>>>>>>>>>>>9.99")).
                    ttsegprestpar.elegivel                      = "true".
                    ttsegprestpar.valorSeguroPrestamistaEntrada = trim(string(
                                                                vvalorTotalSeguroPrestamistaEntrada,">>>>>>>>>>>>>>>>>9.99")).
                        
                            create ttsaidaparcelas.
                            ttsaidaparcelas.qtdParcelas     = ttparcelas.qtdParcelas.
                            ttsaidaparcelas.valorParcela   = 
                                        trim(string(
                                        dec(ttparcelas.valorParcela) + vvalorParcelaSeguroPrestamista
                                        ,">>>>>>>>>>>>>>>>>9.99")).
                            ttsaidaparcelas.valorSeguroRateado   = 
                                        trim(string(
                                        vvalorParcelaSeguroPrestamista
                                        ,">>>>>>>>>>>>>>>>>9.99")).
                                        
                        
                    end.
                end.
            end.
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
          
varquivo  = "/ws/works/calculaseguroloteprestamista" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".
lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
os-command value("rm -f " + varquivo)
