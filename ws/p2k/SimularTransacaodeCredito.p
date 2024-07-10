/* 
15042021 helio ID 68725
*/
/* 08/2016: Projeto Credito Pessoal */


{/admcom/progr/api/sicredsimular.i new} /* 10/2021 moving sicred - chamada api json */
def var pprivenc as date.

def NEW shared temp-table tt-profin
    field codigo     as int
    field nome       as char
    field avencer    as dec
    field disponivel as dec
    field saldo      as dec
    field modcod     as char
    field tfc        as dec
    field token      as log
    field deposito   as char
    field codsicred  as int.

def var vstatus as char.
def var vmensagem_erro as char.

def var setbcod  as int.
def var vclicod  like clien.clicod.
def var vclinom  as char.
def var vcpf     as char.
def var vdtnasc  as date.
def var vcredito as dec.
def var vok      as log.
def var vlimite  as dec.
def var vvalor_solicitado as dec.

/*** Sicred ***/
def var vetbcod as int.
def var vpercseg as dec.
/* CET */
def var vLoja         as integer.
def var vPrazo        as int.
def var vValorCompra  as decimal.
def var vValorPMT     as decimal.
def var vDiasParaPgto as integer.
def var vProduto      as integer.
def var vPlano        as integer.
def var vTaxa         as dec.
def var vSeguro       as dec.
def var vcet as dec.
def var vcet_ano as dec.
def var vtx_mes as dec.
def var vvalor_iof as dec.


def shared temp-table SimularTransacaodeCredito
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field codigo_produto    as char
    field valor_solicitado  as char
    field numero_parcelas   as char
    field plano_pagamento   as char
    field percentual_seguro as char.

{bsxml.i}

find first SimularTransacaodeCredito no-lock no-error.

if avail SimularTransacaodeCredito
then do.
    vstatus = "S".
    setbcod = int(SimularTransacaodeCredito.codigo_filial) no-error.
    vvalor_solicitado = dec(SimularTransacaodeCredito.valor_solicitado).
    vetbcod = setbcod.
    vloja   = setbcod.

    if setbcod = 0
    then run erro ("Filial invalida").
end.
else run erro ("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.
    find clien where clien.clicod =                 
                                int(SimularTransacaodeCredito.codigo_cliente)
               no-lock no-error.
    if avail clien
    then do.
        assign
            vclicod = clien.clicod
            vclinom = Texto(clien.clinom)
            vcpf    = Texto(clien.ciccgc)
            vdtnasc = clien.dtnasc.

        run cpf.p (vcpf, output vok).
        if not vok
        then run erro ("CPF invalido").
        else if vdtnasc = ?
        then run erro ("Data de Nascimento Invalida").
    end.
    else run erro ("CLIENTE Nao Encontrado").
end.

if vstatus = "S"
then do.
    run /admcom/progr/neuro/creditopessoal_v2101.p ("Simula",
                                  setbcod,
                                  clien.clicod,
                                  vvalor_solicitado,
                                  output vlimite,
                                  output vstatus,
                                  output vmensagem_erro).
end.

if vstatus = "S"
then do.
    /*** Verificar TFC ***/

    /* Verifica se foi cobrado TFC do cliente */
    find first clitaxas where clitaxas.clicod = clien.clicod
                          and clitaxas.tabela = "TFC"
                          and clitaxas.data   >= today - 365
                        no-lock no-error.

    for each tt-profin.

        vcredito = min(tt-profin.saldo, vvalor_solicitado).

        tt-profin.saldo = vcredito.

        if not avail clitaxas
        then do.
            find first profintaxa where
                                    profintaxa.fincod   = tt-profin.codigo
                                and profintaxa.etbcod   = setbcod
                                and profintaxa.vlminimo <= vcredito
                                and profintaxa.dtinicial <= today
                                and profintaxa.vlmaximo >= vcredito
                                and (profintaxa.dtfinal = ? or
                                     profintaxa.dtfinal >= today)
                              no-lock no-error.
            if not avail profintaxa
            then find first profintaxa where
                                    profintaxa.fincod   = tt-profin.codigo
                                and profintaxa.etbcod   = 0
                                and profintaxa.vlminimo <= vcredito
                                and profintaxa.dtinicial <= today
                                and profintaxa.vlmaximo >= vcredito
                                and (profintaxa.dtfinal = ? or
                                     profintaxa.dtfinal >= today)
                          no-lock no-error.
            if avail profintaxa
            then tt-profin.tfc = profintaxa.vltaxa.
        end.
    end.
end.

/*** ATE TER UMA LOGICA MAIS BEM DEFINIDA 
     SE TEM SALDO PARA FACIL SOMENTE MOSTRA ESTE
find first tt-profin where tt-profin.codigo = 8000
                         and tt-profin.saldo > vvalor_solicitado
                       no-lock no-error.
if avail tt-profin
then do.
    find first tt-profin where tt-profin.codigo = 8001 no-error.
    if avail tt-profin
    then delete tt-profin.
end.
***/

if SimularTransacaodeCredito.codigo_produto <> ""
then
    for each tt-profin where tt-profin.codigo <>
                               int(SimularTransacaodeCredito.codigo_produto).
        delete tt-profin.
    end.

find first tt-profin no-lock no-error.
if not avail tt-profin
then run erro ("Produtos nao disponiveis").

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",     vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",SimularTransacaodeCredito.codigo_filial).
bsxml("numero_pdv", SimularTransacaodeCredito.numero_pdv).
bsxml("codigo_cliente", string(vclicod)).
bsxml("cpf",        vcpf).
bsxml("nome",       Texto(vclinom)).

if avail tt-profin
then do.
    BSXml("ABREREGISTRO","listaprodutos").
    for each tt-profin.
        if SimularTransacaodeCredito.codigo_produto <> ""
        then do.
            /*** Sicred ***/
            vTaxa = tt-profin.tfc.
            vpercseg = dec(SimularTransacaodeCredito.percentual_seguro) / 100.
            vSeguro  = (vvalor_solicitado + vTaxa) * vpercseg.
            vValorCompra  = vvalor_solicitado.
            vdiasparapgto = 30.
            vplano   = int(SimularTransacaodeCredito.plano_pagamento).
            if vplano = 0
            then vplano = 810.
            vprazo   = int(SimularTransacaodeCredito.Numero_Parcelas).
            vProduto = tt-profin.codsicred.
            pprivenc = today + vdiasparapgto.

            /** MODELO ANTIGO DE CHAMADA 
            {ws/p2k/progr/chama-cal-tx-wssicred.i} **/
            /**
            assign vCET         = round(decimal(vret-CET),2).
            assign vCET_Ano     = round(decimal(vret-CETAnual),2).
            assign vvalor_iof   = dec(vret-valoriof). **/
            
                    /* 10/2021 moving sicred - chamada api json */
                    create ttdados.
                        ttdados.loja = string(vetbcod,"9999").
/*                        ttdados.dataInicio = string(year(today),"9999")  + "-" +
                                             string(month(today),"99") + "-" +
                                             string(day(today),"99")   + " 00:00:00". */
                        ttdados.dataPrimeiroVencimento = string(year(pprivenc),"9999")  + "-" +
                                             string(month(pprivenc),"99") + "-" +
                                             string(day(pprivenc),"99")   + " 00:00:00" .
                        ttdados.plano   = string(vplano,"9999").
                        ttdados.prazo   = vprazo.
                        ttdados.valorSolicitado = vvalor_solicitado.
                        ttdados.valorParcela    = ?.
                        ttdados.valorSeguro     = vSeguro.
                        ttdados.taxa            = 0.
                        ttdados.valortfc        = vtaxa.
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

        BSXml("ABREREGISTRO","produtos").
        bsxml("codigo_produto",string(tt-profin.codigo)).
        bsxml("nome_produto", tt-profin.nome).
        bsxml("saldo_produto",string(tt-profin.saldo,">>>>>>>>>9.99")).
        bsxml("valor_tfc",    string(tt-profin.tfc,">>>>>>>>>9.99")).
        bsxml("pede_token",   if tt-profin.token then "Sim" else "Nao").
        bsxml("obriga_deposito_bancario", if tt-profin.deposito = "S"
                              then "Sim" else "Nao").
        bsxml("cet",string(vcet,">>>>>>>>>>9.99")).
        bsxml("cet_ano",string(vcet_ano,">>>>>>>>>>9.99")).
        bsxml("tx_mes",string(vtx_mes,">>>>>>>>>>9.99")).
        bsxml("valor_iof",    string(vvalor_iof,">>>>>>>>>9.99")).
        BSXml("FECHAREGISTRO","produtos").
    end.
    BSXml("FECHAREGISTRO","listaprodutos").
end.

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.

