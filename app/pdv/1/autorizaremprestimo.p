/*
15042021 helio ID 68725

#1 21.08.2017 - nova tag forma_pagamento
#2 28.03.2018 - Numero inicial quando novo GeraSeguro
*/

/* 08/2016: Projeto Credito Pessoal */
def input  parameter vlcentrada as longchar.
def var vlog as char.

vlog = "/ws/log/apipdv_autorizarEmprestimo" + string(today,"99999999") + ".log".

{/admcom/progr/api/acentos.i}
{/u/bsweb/progr/bsxml.i}
def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.

{/admcom/progr/api/sicredsimular.i new} /* 10/2021 moving sicred - chamada api json */

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

def var vclicod as int.
def var vclinom as char.
def var vcpf    as char.
def var vok     as log.
def var vlimite as dec.
def var vdtemissao as date.

/* buscarplanopagamento */
def var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vchar as char.
def var vdata as date.
def var vcontnum like geranum.contnum.
def var vcertifi as char.

def temp-table autorizarEmprestimo no-undo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field codigo_produto    as char
    field valor_tfc         as char
    field valor_credito     as char
    field data_primeiro_vencimento  as char
    field valor_primeiro_vencimento as char
    field numero_parcelas   as char
    field nsu_venda         as char
    field vendedor          as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char
    field forma_pagamento   as char
    field plano_pagamento       as char.
/* helio 12/2022 onda3 */
def var vtotalprazo as dec.
def var ventrada    as dec.
def var vcomjuro    as log.
/* helio 12/2022 onda3 */


/* CET */
def var vValorCompra  as decimal.
def var vLoja         as integer.
def var vPrazo        as int.
def var vValorPMT     as decimal.
def var vDiasParaPgto as integer.
def var vProduto      as integer init 3.
def var vPlano        as integer init 842.

def var vcet as dec.
def var vcet_ano as dec.
def var vtx_mes as dec.
def var vvalor_iof as dec.

def temp-table ttjson no-undo serialize-name "return"
    FIELD pstatus as char serialize-name "status"
    FIELD mensagem_erro as char 
    field codigo_cliente as char
    field cpf as char
    field nome as char
    field numero_contrato as char
    FIELD codigo_filial as char 
    FIELD numero_pdv as char 
    field tipo_operacao as char
    field cet       as char
    field cet_ano   as char
    field tx_mes    as char
    field valor_iof    as char
    field numero_bilhete as char
    field numero_sorte as char
    field data_emissao as char.
    
    
hentrada = temp-table autorizarEmprestimo:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

hsaida = temp-table ttjson:handle.


find first AutorizarEmprestimo no-lock no-error.
if avail AutorizarEmprestimo
then do.
    assign
        vstatus = "S"
        setbcod = int(AutorizarEmprestimo.codigo_filial)
        vloja   = int(AutorizarEmprestimo.codigo_filial).

    find clien where clien.clicod = int(AutorizarEmprestimo.codigo_cliente)
               no-lock no-error.
    if avail clien
    then do.
        assign
            vclicod = clien.clicod
            vclinom = Texto(clien.clinom)
            vcpf    = Texto(clien.ciccgc).
    end.
    else run erro ("CLIENTE Nao Encontrado").
end.
else run erro ("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.
    find profin where profin.fincod = int(AutorizarEmprestimo.codigo_produto)
                no-lock no-error.
    if not avail profin
    then run erro ("Produto Financeiro Nao Encontrado").
    else if not profin.situacao
    then run erro ("Produto Financeiro Inativo").
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
        if AutorizarEmprestimo.codigo_seguro_prestamista = "569131"
        then do for geraseguro on error undo.
            /* Gerar Numero do Certificado */
            find geraseguro where geraseguro.tpseguro = 3
                              and geraseguro.etbcod = setbcod
                exclusive-lock 
                no-wait 
                no-error.
            if not avail geraseguro
            then do:
                if not locked geraseguro
                then do.
                    create geraseguro.
                    assign
                        geraseguro.tpseguro = 3
                        geraseguro.etbcod   = setbcod.

                    /* #2 */
                    assign
                        geraseguro.sequencia = 1.
                        
                    vcertifi = string(setbcod, "999") +
                               "3" /* tpserv P2K Credito Pessoal */ +
                               string(geraseguro.sequencia, "9999999").
                    /* #2 */
                end.
                else do: /** LOCADO **/
                    vstatus = "E".
                    vmensagem_erro = "Tente Novamente".
                end.
            end.
            else do:
                assign
                    geraseguro.sequencia = geraseguro.sequencia + 1.
                vcertifi = string(setbcod, "999") +
                           "3" /* tpserv P2K Credito Pessoal */ +
                           string(geraseguro.sequencia, "9999999").
                find current geraseguro no-lock.
            end.
        end.
    end.
    run log("gerando certificado ->" + string(vcertifi) + " " + vmensagem_erro).

end.
 
if vstatus = "S"
then do.
    run /admcom/progr/neuro/creditopessoal_v2101.p ("Autoriza", setbcod, clien.clicod, 0,
                                  output vlimite,
                                  output vstatus,
                                  output vmensagem_erro).
    find first tt-profin where tt-profin.codigo = 
                                        int(AutorizarEmprestimo.codigo_produto)
                           no-lock no-error.
    if not avail tt-profin or
       tt-profin.saldo < dec(AutorizarEmprestimo.valor_credito)
    then run erro ("Saldo nao disponivel").
end.



create ttjson.
ttjson.pstatus       = vstatus.
ttjson.mensagem_erro = vmensagem_erro.
ttjson.codigo_cliente = string(vclicod).
ttjson.cpf =  vcpf.
ttjson.nome = Texto(vclinom).
ttjson.numero_contrato = string(vcontnum).

if avail AutorizarEmprestimo
then do.
    ttjson.codigo_filial = string(AutorizarEmprestimo.codigo_filial).
    ttjson.numero_pdv    = string(AutorizarEmprestimo.numero_pdv).
end.
else do.
    ttjson.codigo_filial = "".
    ttjson.numero_pdv    = "".
end.

if vstatus = "S"
then do.
    /*** Data de emissao do contrato ***/
    vdtemissao = today.
    /**48775
    if AutorizarEmprestimo.forma_pagamento <> "deposito" /* #1 */ and
       time > 55800 /*** 15h30min  60 * 60 * 15 + (60 * 30) ***/
    then vdtemissao = vdtemissao + 1.
    
    repeat.
        if weekday(vdtemissao) = 1 /* domingo */
        then vdtemissao = vdtemissao + 1.
        else if weekday(vdtemissao) = 7 /* sabado */
        then vdtemissao = vdtemissao + 2.

        /*** verificar dtesp ***/
        find first dtesp where dtesp.etbcod = 999 and
                               dtesp.datesp = vdtemissao
                         no-lock no-error.
        if avail dtesp
        then do.
            vdtemissao = vdtemissao + 1.
            next.
        end.

        leave.
    end.
    **/
end.

if vstatus = "S"
then do.
    vprazo = int(AutorizarEmprestimo.numero_parcelas).
    vvalorpmt = dec(AutorizarEmprestimo.valor_primeiro_vencimento).

    vchar = AutorizarEmprestimo.data_primeiro_vencimento.
    vdata = date(int(substring(vchar,6,2)),
                 int(substring(vchar,9,2)),
                 int(substring(vchar,1,4))) no-error.
    if vdata <> ?
    then vdiasparapgto = vdata - today.
    else do:
        vdiasparapgto = 30.
        vdata = today + vdiasparapgto.
    end.    

    vvalorcompra = (dec(AutorizarEmprestimo.valor_credito) +
                    dec(AutorizarEmprestimo.valor_tfc)) * 1.08.

    /** MODELO ANTIGO DE CHAMADA 
       {ws/p2k/progr/chama-cal-tx-wssicred.i} **
    assign vCET         = round(decimal(vret-CET),2).
    assign vCET_Ano     = round(decimal(vret-CETAnual),2).
    assign vvalor_iof   = dec(vret-valoriof). */

                    vcomjuro    = vtotalprazo > (vvalorcompra - ventrada).
                     
                    if vcomjuro
                    then vproduto = 1.
                    else vproduto = 18.
                    vproduto = 4.
                    /* helio 122022 - onda 3 */
                    vplano = int(plano_pagamento) no-error.
                    if vplano = ?  /* Novacao */
                    then do:
                        
                        if vcomjuro
                        then vproduto = 2.
                        else vproduto = 5.
                                                
                        
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
                        then vplano = findepara.fincod.
                        else vplano = 326.
                        
                    end.    
                    vproduto = 4.

                    if vplano = ?
                    then vplano = 842.

                    run log("chamando sicred plano ->" + string(vplano)).

                    /* 10/2021 moving sicred - chamada api json */
                    create ttdados.
                        ttdados.loja = string(vloja,"9999").
/*                        ttdados.dataInicio = string(year(vdtemissao),"9999")  + "-" +
                                             string(month(vdtemissao),"99") + "-" +
                                             string(day(vdtemissao),"99")   + " 00:00:00". */
                        ttdados.dataPrimeiroVencimento = string(year(vdata),"9999")  + "-" +
                                             string(month(vdata),"99") + "-" +
                                             string(day(vdata),"99")   + " 00:00:00" .
                        ttdados.plano   = string(vplano,"9999").
                        ttdados.prazo   = vprazo.
                        ttdados.valorSolicitado = vvalorcompra.
                        ttdados.valorParcela    = ?.
                        ttdados.valorSeguro     = 0.
                        ttdados.taxa            = 0.
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
    
end.


ttjson.tipo_operacao = "CDC".
ttjson.cet = trim(string(vcet,">>>>>>>>>>9.99")).
ttjson.cet_ano = trim(string(vcet_ano,">>>>>>>>>>9.99")).
ttjson.tx_mes = trim(string(vtx_mes,">>>>>>>>>>9.99")).
ttjson.valor_iof = trim(string(vvalor_iof,">>>>>>>>>9.99")).
ttjson.numero_bilhete = vcertifi.
ttjson.numero_sorte =  "".
ttjson.data_emissao = EnviaData(vdtemissao).

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

