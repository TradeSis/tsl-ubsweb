/***
Projeto Novacao
Fev/2017
***/
{/u/bsweb/progr/bsxml.i}

def var vstatus   as char.
def var vmensagem_erro as char.
def var vcliente  as int.
def var vmensagem as char.
def var vdesconto as dec.
def var vjuros    as dec.

def temp-table tt-cons-contrato no-undo
    field rec      as recid
    field contnum  like contrato.contnum
    field titdtven as date
    field valor_contrato       as dec
    field valor_total_pendente as dec
    field valor_total_pago     as dec
    field valor_total_encargo  as dec

    index contrato is primary unique contnum.

def temp-table tt-cons-titulo no-undo
    field rec    as recid
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field valor_encargos as dec

    index titulo titnum titpar.

/*** Cyber ***/
def NEW shared temp-table tt-novacao
    field ahdt    as date
    field vltotal as dec.

def NEW shared temp-table tt-contratos
    field adacct as char format "x(20)"
    field titnum as char format "x(15)"
    field adacctg as char
    field adahid as char
    field etbcod as int format "999" .

def NEW shared temp-table tt-acordo
    field apahid as char
    field titvlcob as dec
    field titpar  as int
    field titdtven as date
    field apflag as char
    field titjuro as dec.
/*** ***/

def shared temp-table ConsultaAcordo
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char.

find first ConsultaAcordo no-lock no-error.
if avail ConsultaAcordo
then do.
    vcliente = int(ConsultaAcordo.codigo_cliente) no-error.
    if vcliente <= 1
    then vstatus = "E".
    else do.
        find clien where clien.clicod = vcliente no-lock no-error.
        if not avail clien
        then assign
                vstatus = "E"
                vmensagem_erro = "Cliente " + ConsultaAcordo.codigo_cliente + 
                                     " nao encontrado.".
        else assign
                vstatus = "S"
                vmensagem_erro = "OK".
     end.
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".

if vstatus = "S" /* avail clien*/
then do.
    run ./progr/pdv/cyber_acordo.i ("ConsultaAcordo", clien.clicod,
                                    output vmensagem).
    find first tt-acordo no-lock no-error.
    if not avail tt-acordo
    then assign
            vstatus = "E"
            vmensagem_erro = "Sem acordo disponivel".
end.

if vstatus = "S"
then do.
    for each tt-contratos no-lock. /* Contratos do acordo do Cyber */
        find contrato where contrato.contnum = int(tt-contratos.titnum)
                      no-lock no-error.
        if not avail contrato
        then do.
            assign
                vstatus = "E"
                vmensagem_erro = "Contrato indicado no Cyber nao encontrado" +
                                 " no Admcom".
            leave.
        end.

        find tt-cons-contrato
                      where tt-cons-contrato.contnum = int(tt-contratos.titnum)
                      no-error.
        if not avail tt-cons-contrato
        then do.
            create tt-cons-contrato.
            tt-cons-contrato.contnum  = int(tt-contratos.titnum).
        end.

        for each titulo where titulo.empcod = 19
                          and titulo.titnat = no
                          and titulo.modcod = contrato.modcod
                          and titulo.etbcod = contrato.etbcod
                          and titulo.clifor = contrato.clicod
                          and titulo.titnum = string(contrato.contnum)
                        no-lock.
            if titulo.titsit = "EXC"
            then next.

            assign
                vjuros = 0.
            if titulo.titsit = "LIB" /***titdtpag = ?***/ and
               today > titulo.titdtven
            then run juro_titulo.p (0,
                               titulo.titdtven,
                               titulo.titvlcob,
                               output vjuros).

            assign
                tt-cons-contrato.valor_contrato      =
                            tt-cons-contrato.valor_contrato + titulo.titvlcob
                tt-cons-contrato.valor_total_encargo =
                            tt-cons-contrato.valor_total_encargo + vjuros.

            if titulo.titsit = "LIB" /***titdtpag = ?***/
            then tt-cons-contrato.valor_total_pendente = 
                            tt-cons-contrato.valor_total_pendente +
                            titulo.titvlcob.
            else tt-cons-contrato.valor_total_pago     =
                                     tt-cons-contrato.valor_total_pago +
                            titulo.titvlcob.

            if titulo.titsit <> "LIB"
            then next.

            create tt-cons-titulo.
            assign
                tt-cons-titulo.rec    = recid(titulo)
                tt-cons-titulo.titnum = titulo.titnum
                tt-cons-titulo.titpar = titulo.titpar
                tt-cons-titulo.valor_encargos = vjuros.
        end.
    end.

    for each tt-cons-contrato no-lock.
        if tt-cons-contrato.valor_total_pendente <= 0
        then assign
                vstatus = "E"
                vmensagem_erro = "Contrato indicado pelo Cyber esta liquidado".
    end.
end.

BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_cliente",string(vcliente)).

if avail clien
then do.
    bsxml("cpf", Texto(clien.ciccgc)).
    bsxml("nome",Texto(clien.clinom)).
end.

if vstatus = "S"
then do.
    for each tt-cons-contrato no-lock.
        find contrato where contrato.contnum = tt-cons-contrato.contnum
                      no-lock.

        BSXml("ABREREGISTRO","contratos"). 
        bsxml("filial_contrato",string(contrato.etbcod)).
        bsxml("modalidade",     string(contrato.modcod)).
        bsxml("numero_contrato",string(contrato.contnum)).
        bsxml("data_emissao_contrato",EnviaData(contrato.dtinicial)).
        bsxml("valor_contrato",
                  string(tt-cons-contrato.valor_contrato,">>>>>>>>>>>>9.99")).
        bsxml("valor_total_pago",
                  string(tt-cons-contrato.valor_total_pago,">>>>>>>>>>>>9.99")).
        bsxml("valor_total_pendente",
                      string(tt-cons-contrato.valor_total_pendente,
                            ">>>>>>>>>>>>9.99")).
        bsxml("valor_total_encargo",
                      string(tt-cons-contrato.valor_total_encargo,
                            ">>>>>>>>>>>>9.99")).

        for each tt-cons-titulo
                    where tt-cons-titulo.titnum = string(contrato.contnum)
                    no-lock.
            find titulo where recid(titulo) = tt-cons-titulo.rec no-lock.

            BSXml("ABREREGISTRO","parcelas").
            bsxml("seq_parcela", string(titulo.titpar)).
            bsxml("venc_parcela",EnviaData(titulo.titdtven)).
            bsxml("vlr_parcela", string(titulo.titvlcob,">>>>>>>>9.99")).

            /** BASE MATRIZ  */
            vdesconto = 0.
            vjuros = tt-cons-titulo.valor_encargos.

/*** 27.12.2016 - Conforme e-mail Trojack
        if (titulo.modcod = "CP0" or
            titulo.modcod = "CP1") and
           titulo.titdtpag = ? and
           today < titulo.titdtven
        then run ./progr/desconto_titulo.p (titulo.titdtven, titulo.titvlcob,
                               8 /* 8% */,
                               output vdesconto).
***/

            bsxml("valor_encargos",string(vjuros,">>>>>>>>>>9.99")).
/*
            bsxml("percentual_encargo_dia",string(0)).
            bsxml("data_pagamento", EnviaData(titulo.titdtpag)).
            bsxml("valor_desconto",if titulo.titvlpag = 0 or
                                  titulo.titvlpag >= titulo.titvlcob
                               then string(vdesconto, ">>>>>>>9.99")
                               else string(titulo.titvlcob - titulo.titvlpag,
                                    ">>>>>>>>>>9.99")).
*/

            BSXml("FECHAREGISTRO","parcelas").
        end.

        BSXml("FECHAREGISTRO","contratos").
    end.

    find first tt-novacao no-lock.
    for each tt-acordo no-lock.
        tt-novacao.vltotal = tt-novacao.vltotal + tt-acordo.titvlcob.
    end.
    BSXml("ABREREGISTRO","acordo").
    bsxml("modalidade","CRE").
    bsxml("data_emissao",EnviaData(tt-novacao.ahdt)).
    bsxml("valor_total", string(tt-novacao.vltotal)).

    for each tt-acordo no-lock.
        BSXml("ABREREGISTRO","parcelas").
        bsxml("seq_parcela", string(tt-acordo.titpar)).
        bsxml("venc_parcela",EnviaData(tt-acordo.titdtven)).
        bsxml("vlr_parcela", string(tt-acordo.titvlcob,">>>>>>>>9.99")).
        BSXml("FECHAREGISTRO","parcelas").
    end.

    BSXml("FECHAREGISTRO","acordo").
end.

bsxml("fechatabela","return").
BSXml("FECHAXML","").

