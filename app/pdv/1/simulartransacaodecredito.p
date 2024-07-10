/* 
15042021 helio ID 68725
*/
/* 08/2016: Projeto Credito Pessoal */

def input  parameter vlcentrada as longchar.
def var vlog as char.

vlog = "/ws/log/apipdv_simularTransacaodeCredito" + string(today,"99999999") + ".log".

{/admcom/progr/api/acentos.i}
{/u/bsweb/progr/bsxml.i}
def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.

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


def temp-table simularTransacaodeCredito no-undo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field codigo_produto    as char
    field valor_solicitado  as char
    field numero_parcelas   as char
    field plano_pagamento   as char
    field percentual_seguro as char.

def temp-table ttjson_profin no-undo serialize-name "produtos"
    field codigo_produto    as char
    field nome_produto      as char
    field saldo_produto     as char 
    field valor_tfc     as char
    field pede_token as char
    field obriga_deposito_bancario as char
    field cet       as char
    field cet_ano   as char
    field tx_mes    as char
    field valor_iof  as char.

def temp-table ttjson no-undo serialize-name "dados"
    FIELD pstatus as char serialize-name "status"
    FIELD mensagem_erro as char 
    FIELD codigo_filial as char 
    FIELD numero_pdv as char 
    field codigo_cliente as char
    field cpf as char
    field nome as char
    field data_nascimento as char
    field valor_limite as char.
    
    def dataset dsReturn serialize-name "return" for ttjson, ttjson_profin. 
    
hentrada = temp-table SimularTransacaodeCredito:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

hsaida = dataset dsReturn:handle.


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

if SimularTransacaodeCredito.codigo_produto <> ""
then
    for each tt-profin where tt-profin.codigo <>
                               int(SimularTransacaodeCredito.codigo_produto).
        delete tt-profin.
    end.

find first tt-profin no-lock no-error.
if not avail tt-profin
then run erro ("Produtos nao disponiveis").

vplano   = int(SimularTransacaodeCredito.plano_pagamento).
run log(" plano recebido ->" + string(vplano)).

if vmensagem_erro <> "" then run log(vmensagem_erro).


create ttjson.
ttjson.pstatus       = vstatus.
ttjson.mensagem_erro = vmensagem_erro.
ttjson.codigo_filial = string(SimularTransacaodeCredito.codigo_filial).
ttjson.numero_pdv    = string(SimularTransacaodeCredito.numero_pdv).
ttjson.codigo_cliente = string(vclicod).
ttjson.cpf =  vcpf.
ttjson.nome = Texto(vclinom).
ttjson.data_nascimento = EnviaData(vdtnasc).

ttjson.valor_limite      = trim(string(vlimite,"->>>>>>>>>>9.99")).


if avail tt-profin
then do.
    
    for each tt-profin.
        if SimularTransacaodeCredito.codigo_produto <> ""
        then do.
            /*** Sicred ***/
            vTaxa = tt-profin.tfc.
            vpercseg = dec(SimularTransacaodeCredito.percentual_seguro) / 100.
            vSeguro  = (vvalor_solicitado + vTaxa) * vpercseg.
            vValorCompra  = vvalor_solicitado.
            vdiasparapgto = 30.
            
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
            
            run log("chamando sicred plano ->" + string(vplano)).

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

        create ttjson_profin.
        ttjson_profin.codigo_produto = string(tt-profin.codigo).
        ttjson_profin.nome_produto   = tt-profin.nome.
        ttjson_profin.saldo_produto  = trim(string(tt-profin.saldo,">>>>>>>>>9.99")).

        ttjson_profin.valor_tfc =     trim(string(tt-profin.tfc,">>>>>>>>>9.99")).
        ttjson_profin.pede_token =    if tt-profin.token then "Sim" else "Nao".
        ttjson_profin.obriga_deposito_bancario =  if tt-profin.deposito = "S"
                              then "Sim" else "Nao".
        ttjson_profin.cet       = trim(string(vcet,">>>>>>>>>>9.99")).
        ttjson_profin.cet_ano   = trim(string(vcet_ano,">>>>>>>>>>9.99")).
        ttjson_profin.tx_mes    = trim(string(vtx_mes,">>>>>>>>>>9.99")).
        ttjson_profin.valor_iof = trim(string(vvalor_iof,">>>>>>>>>9.99")).
    end.
    
end.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
put unformatted string(vlcsaida).

/*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
os-command silent cat saida.json.
*/


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.

procedure log.

    def input parameter par-texto as char.

    output to value(vlog) append.
    put unformatted "  ->  " string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","")
            " "
            par-texto skip.
    output close.

end procedure.

