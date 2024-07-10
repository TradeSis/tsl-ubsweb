
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

{/admcom/progr/api/jsontermos.i NEW}

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").




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

hsaida  = temp-table tttermos:handle.

vparcelas-lista = "".
vparcelas-valor = "0.00".
vprodutos-Lista = "".

vid = 0.
find first ttpedidoCartaoLebes no-error.
if not avail ttpedidoCartaoLebes
then return.

vvalorTotal = dec(ttpedidoCartaoLebes.valorTotal).
vdia = int(entry(3,ttpedidoCartaoLebes.dataTransacao,"-")).
vmes = int(entry(2,ttpedidoCartaoLebes.dataTransacao,"-")).
vano = int(entry(1,ttpedidoCartaoLebes.dataTransacao,"-")).

vdataTransacao        = date(vmes,vdia,vano).
vdataTransacaoExtenso = string(vdia,"99") + " de " + vmesext[vmes] + " de " + string(vano).


find first ttcliente no-error.

find first ttcartaoLebes no-error.
if avail ttcartaoLebes
then do:
    vvalorIOF = dec(ttCartaoLebes.valorIOF).   
    vvalorEntrada = dec(ttCartaoLebes.valorEntrada).
    vvalorAcrescimo = dec(ttCartaoLebes.valorAcrescimo).    
    vprincipal = vvalorTotal - vvalorAcrescimo.
    vprincipalPerc = vprincipal / (vvalorTotal) * 100.
    viofPerc = vvalorIOF / (vvalorTotal - vvalorEntrada) * 100.

    vvalorSeguroPrestamista = dec(ttCartaoLebes.valorSeguroPrestamista).
    if vvalorSeguroPrestamista = ? then vvalorSeguroPrestamista = 0.
    
    for each ttparcelas no-lock break by int(ttparcelas.seqParcela).
        if first-of(int(ttparcelas.seqParcela))
        then vparcelas-valor = " R$ " + trim(string(dec(ttparcelas.valorParcela),">>>>>>>>9.99")).

        vdia = int(entry(3,ttparcelas.dataVencimento,"-")).
        vmes = int(entry(2,ttparcelas.dataVencimento,"-")).
        vano = int(entry(1,ttparcelas.dataVencimento,"-")).
        
        vdataVencimento        = date(vmes,vdia,vano).
        
        vparcelas-lista = vparcelas-lista + 
            ttparcelas.seqParcela + 
            " Venc: " + string(vdataVencimento,"99/99/9999") + 
            " R$ " + trim(string(dec(ttparcelas.valorParcela),">>>>>>>>9.99")) + "     " +
                    chr(10).
    end.

    for each ttprodutos no-lock.
        find produ where produ.procod = int(ttprodutos.codigoProduto) no-lock no-error.
        if vcatcod = 0 and (produ.catcod = 31 or produ.catcod = 41)
        then vcatcod = produ.catcod.

        vprodutos-Lista = vprodutos-lista + 
            ttprodutos.codigoProduto + 
            " - " + (if avail produ
                     then produ.pronom
                     else "")
                    +
                chr(10).
    end.

    find termos where termos.idtermo = "CARNE" no-lock.
    COPY-LOB termos.termo TO textFile.

    do vcopias = 1 to termos.termoCopias:
        vid = vid + 1.

        create tttermos.
        tttermos.id = string(vid).
        tttermos.data = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99").
        tttermos.codigo = termos.idtermo. 
        tttermos.conteudo = string(textFile).
        tttermos.extensao = "TXT".
        tttermos.nome = termos.termoNome.
        tttermos.tipo = termos.idtermo.


        run trocamnemos.
    end.

    if ttcartaolebes.contratoFinanceira = "S"
    then do:
        find termos where termos.idtermo = "CONTRATO-FINANCEIRA" no-lock.
    end.   
    else do:
        find termos where termos.idtermo = "CONTRATO-DREBES" no-lock.
    end.

    COPY-LOB termos.termo TO textFile.
    do vcopias = 1 to termos.termoCopias:

        vid = vid + 1.

        create tttermos.
        tttermos.id = string(vid).
        tttermos.data = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99").
        tttermos.codigo = termos.idtermo. 
        tttermos.conteudo = string(textFile).
        tttermos.extensao = "TXT".
        tttermos.nome = termos.termoNome.
        tttermos.tipo = termos.idtermo.

        run trocamnemos.
    end.

    if vvalorSeguroPrestamista > 0
    then do:
        if vcatcod = 41
        then do:
            find termos where termos.idtermo = "ADESAO-SEGURO-PRESTAMISTA-MODA" no-lock.
        end.   
        else do:
            find termos where termos.idtermo = "ADESAO-SEGURO-PRESTAMISTA-MOVEIS" no-lock.
        end.

        COPY-LOB termos.termo TO textFile.

        do vcopias = 1 to termos.termoCopias:
            vid = vid + 1.

            create tttermos.
            tttermos.id = string(vid).
            tttermos.data = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99").
            tttermos.codigo = termos.idtermo. 
            tttermos.conteudo = string(textFile).
            tttermos.extensao = "TXT".
            tttermos.nome = termos.termoNome.
            tttermos.tipo = termos.idtermo.

            run trocamnemos.
        end. 

    end.


end.



def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apipdvbuscatermos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
os-command value("rm -f " + varquivo).

