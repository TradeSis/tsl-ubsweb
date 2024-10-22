
/* helio 17022022 - 263458 - Revisão da regra de novações  */

def input param vlcentrada as longchar.

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
def var vdtPriVen as char.
def var vdtUltVen as char.
def var vvalorEntrada as dec. 
DEF VAR vrascunho AS LOG.
DEF VAR vtermoteste AS LOG.

def var pcobcod as int.

{termos/1/jsontermos.i NEW}

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

vrascunho = no.
if ttpedidoCartaoLebes.rascunho = "RASCUNHO"
then vrascunho = yes.
vtermoteste = no.
if ttpedidoCartaoLebes.termoteste = "TERMOTESTE"
then vtermoteste = yes.

vvalorTotal = dec(ttpedidoCartaoLebes.valorTotal).
vdia = int(entry(3,ttpedidoCartaoLebes.dataTransacao,"-")).
vmes = int(entry(2,ttpedidoCartaoLebes.dataTransacao,"-")).
vano = int(entry(1,ttpedidoCartaoLebes.dataTransacao,"-")).

vdataTransacao        = date(vmes,vdia,vano).
vdataTransacaoExtenso = string(vdia,"99") + " de " + vmesext[vmes] + " de " + string(vano).


find clien where clien.clicod = int(ttpedidoCartaoLebes.codigoCliente) no-lock no-error. /* helio-gabriel busca clien */

find neuclien where neuclien.clicod =  clien.clicod no-lock no-error.

vdtPriVen = ?.
vdtUltVen = ?.
vvalorEntrada = 0.

FIND FIRST ttparcelas NO-LOCK NO-ERROR. 
IF avail ttparcelas THEN DO:
    vdia = int(entry(3,ttparcelas.dataVencimento,"-")).
    vmes = int(entry(2,ttparcelas.dataVencimento,"-")).
    vano = int(entry(1,ttparcelas.dataVencimento,"-")).
    vdtPriVen = STRING(date(vmes,vdia,vano),"99/99/9999").
END.
FIND LAST ttparcelas NO-LOCK NO-ERROR.
IF avail ttparcelas THEN DO:
    vdia = int(entry(3,ttparcelas.dataVencimento,"-")).
    vmes = int(entry(2,ttparcelas.dataVencimento,"-")).
    vano = int(entry(1,ttparcelas.dataVencimento,"-")).
    vdtUltVen = STRING(date(vmes,vdia,vano),"99/99/9999").
END.

FOR EACH ttrecebimentos NO-LOCK:
    if ttrecebimentos.formaPagamento = "93" /* crediario */ THEN NEXT.
    vvalorEntrada = vvalorEntrada + DEC(ttrecebimentos.valorPago). 
END.


find first ttcartaoLebes no-error.
if avail ttcartaoLebes
then do:
  
    vvalorIOF = dec(ttCartaoLebes.valorIOF).   
    vvalorAcrescimo = dec(ttCartaoLebes.valorAcrescimo). 
    vvalorTFC = dec(ttCartaoLebes.valorTFC). 
    vprincipal = vvalorTotal - vvalorAcrescimo.
    vdatainivigencia12 = ?.
    vdatafimvigencia13 = ?.
    
    find first ttseguroprestamista no-error.
    if avail ttseguroprestamista
    then do:
        vdia = int(entry(3,ttseguroprestamista.dataInicioVigencia,"-")).
        vmes = int(entry(2,ttseguroprestamista.dataInicioVigencia,"-")).
        vano = int(entry(1,ttseguroprestamista.dataInicioVigencia,"-")).
        vdatainivigencia12        = date(vmes,vdia,vano).
        vdia = int(entry(3,ttseguroprestamista.dataFimVigencia,"-")).
        vmes = int(entry(2,ttseguroprestamista.dataFimVigencia,"-")).
        vano = int(entry(1,ttseguroprestamista.dataFimVigencia,"-")).
        vdatafimvigencia13        = date(vmes,vdia,vano).

        vvalorSeguroPrestamista = dec(ttseguroprestamista.valorSeguroPrestamista).
    end.
    if vvalorSeguroPrestamista = ? then vvalorSeguroPrestamista = 0.

    assign  vvalorFinanciado  = vprincipal + vvalorIOF + vvalorSeguroPrestamista + vvalorTFC.
	
    vprincipalPerc = vprincipal / (vvalorFinanciado) * 100.
    viofPerc = vvalorIOF / (vvalorFinanciado) * 100.
    IF viofPerc =  ? then viofPerc = 0.
    vtfcPerc = vvalorTFC / (vvalorFinanciado) * 100.
    IF vtfcPerc =  ? then vtfcPerc = 0.
    vseguroperc = vvalorSeguroPrestamista / (vvalorFinanciado) * 100.
    IF vseguroperc =  ? then vseguroperc = 0.
    
    for each ttparcelas no-lock break by int(ttparcelas.seqParcela).
        if first(int(ttparcelas.seqParcela))
        then vparcelas-valor = trim(string(dec(ttparcelas.valorParcela),">>>>>>>>9.99")).

        vdia = int(entry(3,ttparcelas.dataVencimento,"-")).
        vmes = int(entry(2,ttparcelas.dataVencimento,"-")).
        vano = int(entry(1,ttparcelas.dataVencimento,"-")).
        
        vdataVencimento        = date(vmes,vdia,vano).
        
        vparcelas-lista = vparcelas-lista + 
            ttparcelas.seqParcela + 
            "           Venc: " + string(vdataVencimento,"99/99/9999") + 
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
    vcontratos-lista = "".
    for each  ttcontratosrenegociados:
        vcontratos-Lista = vcontratos-lista + 
        ttcontratosrenegociados.contratoRenegociado
                +
            chr(10).

    end.   
    
    vid = 0.

    if vtermoteste = yes 
    then do:
        find termos where termos.idtermo = "TERMO-TESTE" no-lock no-error.
        if avail termos 
        then do:
            vid = 1.
            if termos.rascunho = ? or vrascunho = no 
            then do:
                COPY-LOB from termos.termo to textFile.
            end.
            else do:
                COPY-LOB from termos.rascunho to textFile.
            end.
            create tttermos.
            tttermos.sequencial = string(vid).
            tttermos.tipo = termos.idtermo.
            tttermos.termo = string(textFile).
            tttermos.quantidadeVias = string(termos.termoCopias).
            tttermos.formato = "TXT".

            run trocamnemos.
            if ttpedidoCartaoLebes.formatoTermo = "BASE64"
            then do:
                tttermos.formato = "BASE64".
                run encodebase64.
            end.
        end.
    end.
    else do:

        if avail ttcartaoLebes
        then do:
            find termos where termos.idtermo = "CARNE-PARCELAS-CONTRATO" no-lock.
            if termos.rascunho = ? or vrascunho = no 
            then do:
                COPY-LOB from termos.termo to textFile.
            end.
            else do:
                COPY-LOB from termos.rascunho to textFile.
            end.

                vid = vid + 1. 

                create tttermos.
                tttermos.sequencial = string(vid).
                tttermos.tipo = termos.idtermo.
                tttermos.termo = string(textFile).
                tttermos.quantidadeVias = string(termos.termoCopias).
                tttermos.formato = "TXT".


                run trocamnemos.
                if ttpedidoCartaoLebes.formatoTermo = "BASE64"
                then do:
                    tttermos.formato = "BASE64".
                    run encodebase64.
                end.
        end.

        if avail ttcartaolebes
        then do:
            if ttcartaolebes.contratoFinanceira = "S"
            then do:
                if ttpedidoCartaoLebes.tipoOperacao = "CDC"
                then do:
                    find termos where termos.idtermo = "CONTRATO-FINANCEIRA-CDC" no-lock.
                end.
                else
                if ttpedidoCartaoLebes.tipoOperacao = "EMPRESTIMO"
                then do:
                    find termos where termos.idtermo = "CONTRATO-FINANCEIRA-EP" no-lock.
                end.
                else 
                if ttpedidoCartaoLebes.tipoOperacao = "NOVACAO"
                then do:
                    find termos where termos.idtermo = "CONTRATO-FINANCEIRA-NOVACAO" no-lock.
                end. 
            end.   
            else do:
                if ttpedidoCartaoLebes.tipoOperacao = "CDC"
                then do:
                    find termos where termos.idtermo = "CONTRATO-DREBES-CDC" no-lock.
                end.
                else
                if ttpedidoCartaoLebes.tipoOperacao = "EMPRESTIMO"
                then do:
                    find termos where termos.idtermo = "CONTRATO-DREBES-EP" no-lock.
                end.
                else
                if ttpedidoCartaoLebes.tipoOperacao = "NOVACAO"
                then do:
                    find termos where termos.idtermo = "CONTRATO-DREBES-NOVACAO" no-lock.
                end. 
            end.

            if termos.rascunho = ? or vrascunho = no 
            then do:
                COPY-LOB from termos.termo to textFile.
            end.
            else do:
                COPY-LOB from termos.rascunho to textFile.
            end.
            

                vid = vid + 1.

                create tttermos.
                tttermos.sequencial = string(vid).
                tttermos.tipo = termos.idtermo.
                tttermos.termo = string(textFile).
                tttermos.quantidadeVias = string(termos.termoCopias).
                tttermos.formato = "TXT".

                run trocamnemos.
                if ttpedidoCartaoLebes.formatoTermo = "BASE64"
                then do:
                    tttermos.formato = "BASE64".
                    run encodebase64.
                end.
        end.

        if avail ttseguroprestamista
        then do:
            if vvalorSeguroPrestamista > 0
            then do:
                if ttpedidoCartaoLebes.tipoOperacao = "EMPRESTIMO"
                then do:
                    find termos where termos.idtermo = "APOLICE-PRESTAMISTA-EP" no-lock.
                end.  
                else
                if ttpedidoCartaoLebes.tipoOperacao = "NOVACAO"
                then do:
                    find termos where termos.idtermo = "APOLICE-PRESTAMISTA-NOVACAO" no-lock.
                end.  
                else 
                if ttpedidoCartaoLebes.tipoOperacao = "CDC"
                then do:
                    if vcatcod = 41
                    then do:
                        find termos where termos.idtermo = "APOLICE-PRESTAMISTA-MODA" no-lock.
                    end. 
                    if vcatcod = 31  
                    then  do:
                        find termos where termos.idtermo = "APOLICE-PRESTAMISTA-MOVEIS" no-lock.
                    end.
                end.

                if termos.rascunho = ? or vrascunho = no 
                then do:
                    COPY-LOB from termos.termo to textFile.
                end.
                else do:
                    COPY-LOB from termos.rascunho to textFile.
                end.

                    vid = vid + 1.

                    create tttermos.
                    tttermos.sequencial = string(vid).
                    tttermos.tipo = termos.idtermo.
                    tttermos.termo = string(textFile).
                    tttermos.quantidadeVias = string(termos.termoCopias).
                    tttermos.formato = "TXT".

                    run trocamnemos.
                    if ttpedidoCartaoLebes.formatoTermo = "BASE64"
                    then do:
                        tttermos.formato = "BASE64".
                        run encodebase64.
                    end.


            end.
        end.
    end.


end.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).

/* export LONG VAR*/
DEF VAR vMEMPTR AS MEMPTR  NO-UNDO.
DEF VAR vloop   AS INT     NO-UNDO.
if length(vlcsaida) > 30000
then do:
    COPY-LOB FROM vlcsaida TO vMEMPTR.
    DO vLOOP = 1 TO LENGTH(vlcsaida): 
        put unformatted GET-STRING(vMEMPTR, vLOOP, 1). 
    END.
end.
else do:
    put unformatted string(vlcSaida).
end.    
	


