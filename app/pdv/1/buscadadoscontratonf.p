/* Helio 28022023 - onda 3 - p2k nao envia entrada, então considerar todas as parcelas */
/*
#1 07/2018 - Projeto Numero da Sorte
#2 09/2018 - TP 9
*/
/* buscarplanopagamento */
def input  parameter vlcentrada as longchar.
def var vlog as char.

vlog = "/ws/log/apipdv_buscaDadosContratoNf" + string(today,"99999999") + ".log".

{/admcom/progr/api/acentos.i}
{/u/bsweb/progr/bsxml.i}
def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.


{/admcom/progr/api/sicredsimular.i new} /* 10/2021 moving sicred - chamada api json */
def var pprivenc as date.

/* helio 12/2022 onda3 */
def var vtotalprazo as dec.
def var ventrada    as dec.
def var vcomjuro    as log.
/* helio 12/2022 onda3 */


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
 
def temp-table parcelas  no-undo
    field seq_parcela as char
    field vlr_parcela as char
    field data_vencimento as char
    field numero_contrato as char.
 
def temp-table buscaDadosContratoNf no-undo
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field valor_compra as char
    field nsu_venda as char
    field vendedor  as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char
    field plano_pagamento       as char.
  

        
/* CET */
def var vLoja         as integer.
def var vPrazo        as int.
def var vValorCompra  as decimal.
def var vValorPMT     as decimal.
def var vDiasParaPgto as integer.
def var vProduto      as integer init 1.
def var vPlano        as integer init 326.
  
def dataset dadosEntrada for buscaDadosContratoNf, parcelas.

def temp-table ttjson no-undo serialize-name "return"
    FIELD pstatus as char serialize-name "status"
    FIELD mensagem_erro as char 
    field codigo_filial as char
    field numero_pdv as char
    field codigo_cliente as char
    field cpf as char
    field nome as char
    field numero_contrato as char
    field tipo_operacao as char
    field cet as char
    field cet_ano as char
    field tx_mes as char
    field valor_iof as char
    field numero_bilhete as char
    field numero_sorte as char.

hentrada = DATASET dadosEntrada:handle.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").    

find first buscadadoscontratonf no-error.

vstatus = if avail buscadadoscontratonf
          then "S"
          else "E".
vmensagem_erro = if avail buscadadoscontratonf
                 then ""
                 else "Parametros de Entrada nao recebidos.".



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
    run log("gerando contrato ->" + string(vcontnum) + " " + vmensagem_erro).
    
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
    run log("gerando certificado ->" + string(vcertifi) + " " + vmensagem_erro).

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
        run log("gerando num.sorte ->" + string(vnsorte) + " " + vmensagem_erro).
    end.
end.



create ttjson.
ttjson.pstatus       = vstatus.
ttjson.mensagem_erro = vmensagem_erro.


if avail buscadadoscontratonf
then do.
    ttjson.codigo_filial = buscadadoscontratonf.codigo_filial.
    ttjson.numero_pdv = buscadadoscontratonf.numero_pdv.
end.
else do.
    ttjson.codigo_filial = "".
    ttjson.numero_pdv = "".
end.
    
if vstatus = "S" /*** avail clien***/
then do:
    
    ttjson.codigo_cliente = string(clien.clicod).
    if clien.ciccgc = ?
    then ttjson.cpf = "".
    else ttjson.cpf = clien.ciccgc.
    ttjson.nome = Texto(clien.clinom).
    ttjson.numero_contrato = string(vcontnum).
end.
else do:
    ttjson.codigo_cliente = buscadadoscontratonf.numero_documento.
    ttjson.cpf = "".
    ttjson.nome = "".
    ttjson.numero_contrato = "".
end.


if vstatus = "S"
then do.
    vloja = int(buscadadoscontratonf.codigo_filial).
    vvalorcompra = dec(buscadadoscontratonf.valor_compra).
    vtotalprazo = 0.
    ventrada = 0.
    vprazo = 0.
    for each parcelas 
        by int(parcelas.seq_parcela).
        
        /* Helio 28022023 - onda 3 - p2k nao envia entrada, então considerar todas as parcelas
        *if int(parcelas.seq_parcela) = 0
        *then do:
        *    ventrada = dec(parcelas.vlr_parcela).
        *    next. helio 28022023 - entrada faz parte
        *end.
        */
        
        /* #2 */
        vchar = parcelas.data_vencimento.
    

        vdata = ?.
        vdata = date(int(substring(vchar,6,2)),
                          int(substring(vchar,9,2)),
                          int(substring(vchar,1,4))) no-error.

        run log("    parcela ->" + string(parcelas.seq_parcela) + " vencimento " + vchar + " - " + 
                    (if vdata = ? then "null" else string(vdata,"99/99/9999")) + " valor->" + string(parcelas.vlr_parcela)).

        if vdata = ?
        then vdata = today + 1. /*next. */
        
        assign
                vprazo = vprazo + 1.
        if vprazo = 1
        then assign
                vvalorpmt = dec(parcelas.vlr_parcela)
                vdiasparapgto = vdata - today
                pprivenc      = vdata.
        /* #2 */
        vtotalprazo = vtotalprazo + dec(parcelas.vlr_parcela).
    end.


    /** {ws/p2k/progr/chama-cal-tx-wssicred.i}
    assign vCET         = round(decimal(vret-CET),2).
    assign vCET_Ano     = round(decimal(vret-CETAnual),2).
    assign vvalor_iof   = dec(vret-valoriof). ***/
    
    
                    vcomjuro    = vtotalprazo > (vvalorcompra - ventrada).
                    run log("JUROS->" +  string(vtotalprazo - (vvalorcompra - ventrada)) + " = total_compra->" + string(vvalorcompra) +
                                " - somatorioParcelas->" + string(vvalorcompra - ventrada)).
                                 

                    vplano = int(plano_pagamento) no-error.
                    if vplano = ? then vplano = 0.

                    if vcomjuro /* Inicialmente considera tudo compra CDC */
                    then vproduto = 1.
                    else vproduto = 18.
                    vproduto = 1. /* a pedido do Volmir 11/07/2023, CDC eh sempre 1 */  


                    /* Testar pra ver se plano esta no findepara, se estiver eh NOVACAO */ 
                    release findepara.
                    if vplano > 0
                    then do:
                        find first findepara where findepara.fincod = vplano no-lock no-error.
                    end.     
                    if avail findepara or vplano = 0
                    then do: /* eh novacao */
                        if vcomjuro 
                        then vproduto = 2.
                        else vproduto = 19. 
                        vproduto = 2. /* a pedido do Volmir 12/07/2023, NOVACAO eh sempre 1 */

                        run log("NOVACAO-> " + string(avail findepara,"DePara/ ") + "|" + string(vplano = 0,"PLANO=0/") + " Produto=" + string(vproduto)).
                        
                    end.
                     
                    run log("p2k enviou o plano ->" + if plano_pagamento = ? then "null" else plano_pagamento).
                                        
                    /* helio 122022 - onda 3 */
                    if vplano = 0  /* Novacao */
                    then do:
                        
                        /* depara */
                        find last findepara where 
                                findepara.prazo      = vprazo and
                                findepara.comentrada = (ventrada > 0) and
                                (
                                if vcomjuro
                                then  (findepara.taxa_juros <=  100)
                                else  (findepara.taxa_juros = 0)
                                )
                            no-lock no-error.
                        if avail findepara
                        then do:
                            vplano = findepara.fincod.
                            run log(string(avail findepara,"Encontrou no Depara/ ") + " plano=" + string(vplano)).                            
                        end.
                        else vplano = 326.
                        
                        
                        
                    end.    
                    if vplano = ?
                    then vplano = 326.

                    run log("chamando sicred plano ->" + string(vplano)).

                    /* helio 122022 - onda 3 */

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
                        ttdados.valorParcela    = ? /* enviar null vvalorpmt*/ .
                        ttdados.valorSeguro     = vSeguro.
                        ttdados.taxa            = vTaxa.
                        ttdados.prazoMin        = ?.
                        ttdados.prazoMax        = ?.
                        ttdados.produto         = string(vProduto,"999999").
                        ttdados.numeroContrato  =  string(vcontnum).

                    run /admcom/progr/api/sicredsimular-v2.p. /* 10/2021 moving sicred - chamada api json */

                find first ttreturn no-error.
                if avail ttreturn
                then do:
                    assign vcet    = ttreturn.cetMes.
                    assign vcet_ano = ttreturn.cetAno.
                    assign vvalor_iof = ttreturn.valorIOF.
                    assign vtx_mes = ttreturn.taxames.
                    /* 10/2021 moving sicred - chamada api json */
                    
                end.
                run log("retorno sicred -> cet: " + string(vcet) + " tx: " + string(vtx_mes)).
    
end.


ttjson.tipo_operacao = "CDC".
ttjson.cet = trim(string(vcet,">>>>>>>>>>9.99")).
ttjson.cet_ano = trim(string(vcet_ano,">>>>>>>>>>9.99")).
ttjson.tx_mes = trim(string(vtx_mes,">>>>>>>>>>9.99")).
ttjson.valor_iof = trim(string(vvalor_iof,">>>>>>>>>9.99")).

ttjson.numero_bilhete = vcertifi.
ttjson.numero_sorte =  vnsorte.
                                                         

hsaida = temp-table ttjson:HANDLE.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
put unformatted string(vlcsaida).

/*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
os-command silent cat saida.json.
*/



procedure log.

    def input parameter par-texto as char.

    output to value(vlog) append.
    put unformatted "  ->  " string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","")
            " "
            par-texto skip.
    output close.

end procedure.

