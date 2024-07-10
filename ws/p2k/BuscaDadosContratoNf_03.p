/*
#1 07/2018 - Projeto Numero da Sorte
#2 09/2018 - TP 9
*/
/* buscarplanopagamento */


{/admcom/progr/api/sicredsimular.i new} /* 10/2021 moving sicred - chamada api json */
def var pprivenc as date.

def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vchar as char.
def var vdata as date.
def var vetbcod as int.
def var vcontnum like geranum.contnum.
def var vcertifi as char.
def var vnsorte  as char.
def var vseq     as int.

def var vdtinimes as date.
def var vdtfimmes as date.
def var vTaxa         as dec.
def var vSeguro       as dec.
def var vcet as dec.
def var vcet_ano as dec.
def var vtx_mes as dec.
def var vvalor_iof as dec.
 
def shared temp-table parcelas 
    field seq_parcela as char
    field vlr_parcela as char
    field venc_parcela as char
    field numero_contrato as char.
 
def shared temp-table BuscaDadosContratoNf
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field valor_compra as char
    field nsu_venda as char
    field vendedor  as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char.
  
/* CET */
def var vLoja         as integer.
def var vPrazo        as int.
def var vValorCompra  as decimal.
def var vValorPMT     as decimal.
def var vDiasParaPgto as integer.
def var vProduto      as integer init 1.
def var vPlano        as integer init 326.
  
find first buscadadoscontratonf no-error.

vstatus = if avail buscadadoscontratonf
          then "S"
          else "E".
vmensagem_erro = if avail buscadadoscontratonf
                 then "S"
                 else "Parametros de Entrada nao recebidos.".

{bsxml.i}

if vstatus = "S"
then do:
    vetbcod = int(buscadadoscontratonf.codigo_filial).
    if buscadadoscontratonf.tipo_documento = "1" /* cpF */
    then do:
        find first clien where 
            clien.ciccgc = buscadadoscontratonf.numero_documento
            no-lock no-error.
    end.
    if buscadadoscontratonf.tipo_documento = "2" /* codigo-cliente */
    then do:
        find first clien where 
            clien.clicod = int(buscadadoscontratonf.numero_documento)
            no-lock no-error.
    end. 
    if not avail clien 
    then do: 
        vstatus = "E". 
        vmensagem_erro = "CLIENTE Nao Encontrado". 
    end.
end.

if vstatus = "S"
then do:
    /* Busca os Dados */
    
    /* Numeracao Contratos **/
    do for geranum on error undo on endkey undo:
        find geranum where geranum.etbcod = 999 
            exclusive-lock 
            no-wait 
            no-error.
        if not avail geranum
        then do:
            if not locked geranum
            then do:
                create geranum.
                assign
                    geranum.etbcod  = 999
                    geranum.clicod  = 300000000
                    geranum.contnum = 300000000.
                vcontnum = geranum.contnum.    
                find current geranum no-lock.
            end.
            else do: /** LOCADO **/
                vstatus = "E".
                vmensagem_erro = "Tente novamente". 
            end.
        end.
        else do:
            geranum.contnum = geranum.contnum + 1. 
            find current geranum no-lock. 
            vcontnum = geranum.contnum.
        end.
    end.

    if vstatus = "S"
    then do.
        if buscadadoscontratonf.codigo_seguro_prestamista = "559910" or
           buscadadoscontratonf.codigo_seguro_prestamista = "559911" or
           buscadadoscontratonf.codigo_seguro_prestamista = "578790" or
           buscadadoscontratonf.codigo_seguro_prestamista = "579359"
        then do for geraseguro on error undo.
            /* Gerar Numero do Certificado */
            find geraseguro where geraseguro.tpseguro = 2
                              and geraseguro.etbcod = vetbcod
                exclusive-lock 
                no-wait 
                no-error.
            if not avail geraseguro
            then do:
                if not locked geraseguro
                then do.
                    create geraseguro.
                    assign
                        geraseguro.tpseguro = 2
                        geraseguro.etbcod   = vetbcod.
                end.
                else do: /** LOCADO **/
                    vstatus = "E".
                    vmensagem_erro = "Tente Novamente".
                end.
            end.
            else do:
                assign
                    geraseguro.sequencia = geraseguro.sequencia + 1.
                vcertifi = string(vetbcod, "999") +
                       "2" /* tpserv P2K */ +
                       string(geraseguro.sequencia, "9999999").
                find current geraseguro no-lock.
            end.
        end.
    end.
    
    if buscadadoscontratonf.codigo_seguro_prestamista = "559911" or
       buscadadoscontratonf.codigo_seguro_prestamista = "578790" or
       buscadadoscontratonf.codigo_seguro_prestamista = "579359"
    then do:
        vdtinimes = date(month(today),1,year(today)).
        vdtfimmes = date(if month(today) + 1 > 12 then 1 else month(today) + 1,
                         1,
                         if month(today) + 1 > 12
                         then year(today) + 1 else year(today))
                         - 1.

        do for segnumsorte on error undo.
            find first segnumsorte use-index venda-ordem /*#1venda*/
                where segnumsorte.dtivig = vdtinimes and
                      segnumsorte.dtfvig = vdtfimmes and
                      segnumsorte.dtuso  = ?
                exclusive-lock
                no-wait 
                no-error.
            if not avail segnumsorte
            then do:
                if not locked segnumsorte
                then assign /* INEXISTENTE **/
                        vstatus = "E"
                        vmensagem_erro = "Numeros da sorte esgotados".
                else assign /** LOCADO **/
                        vstatus = "E"
                        vmensagem_erro = "Tente Novamente".
            end.
            else do:
                assign
                    segnumsorte.dtuso   = today
                    segnumsorte.hruso   = time
                    segnumsorte.etbcod  = vetbcod
                    segnumsorte.contnum = vcontnum
                    segnumsorte.certifi = vcertifi
                    segnumsorte.nsu     = int(buscadadoscontratonf.nsu_venda)
                    segnumsorte.cxacod  = int(buscadadoscontratonf.numero_pdv).
                vnsorte = string(segnumsorte.serie,"999") +
                          string(segnumsorte.nsorteio,"99999").
                find current segnumsorte no-lock.
            end.
        end.            
    end.
end.

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
    
    
if vstatus = "S" /*** avail clien***/
then do:
    bsxml("codigo_cliente",string(clien.clicod)).
    if clien.ciccgc = ?
    then bsxml("cpf","").
    else bsxml("cpf",clien.ciccgc).
    bsxml("nome",Texto(clien.clinom)).
    bsxml("numero_contrato", string(vcontnum)).
end.
else do:
    bsxml("codigo_cliente",buscadadoscontratonf.numero_documento).
    bsxml("cpf","").
    bsxml("nome","").
    bsxml("numero_contrato","").
end.

if avail buscadadoscontratonf
then do.
    bsxml("codigo_filial",buscadadoscontratonf.codigo_filial).
    bsxml("numero_pdv",buscadadoscontratonf.numero_pdv).
end.
else do.
    bsxml("codigo_filial","").
    bsxml("numero_pdv","").
end.

if vstatus = "S"
then do.
    vloja = int(buscadadoscontratonf.codigo_filial).
    vvalorcompra = dec(buscadadoscontratonf.valor_compra).
    vprazo = 0.
    for each parcelas 
        where int(parcelas.seq_parcela) > 0
        by int(parcelas.seq_parcela).
        /* #2 */
        vchar = parcelas.venc_parcela.
        vdata = ?.
        if testavalido(vchar)
        then vdata = date(int(substring(vchar,6,2)),
                          int(substring(vchar,9,2)),
                          int(substring(vchar,1,4))) no-error.
        if vdata = ?
        then next.
        assign
                vprazo = vprazo + 1.
        if vprazo = 1
        then assign
                vvalorpmt = dec(parcelas.vlr_parcela)
                vdiasparapgto = vdata - today
                pprivenc      = vdata.
        /* #2 */
    end.

    /** {ws/p2k/progr/chama-cal-tx-wssicred.i}
    assign vCET         = round(decimal(vret-CET),2).
    assign vCET_Ano     = round(decimal(vret-CETAnual),2).
    assign vvalor_iof   = dec(vret-valoriof). ***/
    
    
                    /* 10/2021 moving sicred - chamada api json */
                    create ttdados.
                        ttdados.loja = string(vloja,"9999").
/*                        ttdados.dataInicio = string(year(today),"9999")  + "-" +
                                             string(month(today),"99") + "-" +
                                             string(day(today),"99")   + " 00:00:00". */
                        ttdados.dataPrimeiroVencimento = string(year(pprivenc),"9999")  + "-" +
                                             string(month(pprivenc),"99") + "-" +
                                             string(day(pprivenc),"99")   + " 00:00:00" .
                        ttdados.plano   = string(vplano,"9999").
                        ttdados.prazo   = vprazo.
                        ttdados.valorSolicitado = vvalorcompra.
                        ttdados.valorParcela    = ? /*vvalorpmt*/ .
                        ttdados.valorSeguro     = vSeguro.
                        ttdados.taxa            = vTaxa.
                        ttdados.prazoMin        = ?.
                        ttdados.prazoMax        = ?.
                        ttdados.produto         = string(vProduto,"999999").
    

                    run /admcom/progr/api/sicredsimular.p. /* 10/2021 moving sicred - chamada api json */

                find first ttreturn no-error.
                if avail ttreturn
                then do:
                    assign vcet    = ttreturn.cetMes.
                    assign vcet_ano = ttreturn.cetAno.
                    assign vvalor_iof = ttreturn.valorIOF.
                    assign vtx_mes = ttreturn.taxames.
                    /* 10/2021 moving sicred - chamada api json */
                    
                end.
    
    
end.


bsxml("tipo_operacao","CDC").
bsxml("cet",string(vcet,">>>>>>>>>>9.99")).
bsxml("cet_ano",string(vcet_ano,">>>>>>>>>>9.99")).
bsxml("tx_mes",string(vtx_mes,">>>>>>>>>>9.99")).
bsxml("valor_iof",string(vvalor_iof,">>>>>>>>>9.99")).

bsxml("numero_bilhete",vcertifi).
bsxml("numero_sorte",  vnsorte).
                                                          
bsxml("fechatabela","return").
BSXml("FECHAXML","").

