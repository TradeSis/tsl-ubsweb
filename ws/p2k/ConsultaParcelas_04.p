
/*10*/ /* 08.03.17 - Helio - Nova Regra para consulta NOVACAO N
                             Quando  tiver pelo menos 1 Titulo Vencido a mais
                             de 60 Dias envia TUDO, se nao tiver
                             Nao Envia  NADA */  
/*
#1 - Ricardo - Versao 02 Nova tag tp_contrato
#2 - Ricardo - 27.07.2017 - Nova tag inf_compl
#3 - Ricardo - 03.08.2017 - Otimizacao
#4 - helio   - 14.08.17 - retornar limite para evitar uso do consultacliente  
#5 - Ricardo - 08/207 Nova novacao
*/

/* #4 */
def NEW shared temp-table tp-titulo like titulo
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

def NEW SHARED var pagas-db as int.
def NEW SHARED var maior-atraso as int /***like plani.pladat***/.
def NEW SHARED var vencidas like clien.limcrd.
def NEW SHARED var v-mes as int format "99".
def NEW SHARED var v-ano as int format "9999".
def NEW SHARED var v-acum like clien.limcrd.
def NEW SHARED var qtd-contrato as int format ">>>9".
def NEW SHARED var parcela-paga    as int format ">>>>9".
def NEW SHARED var parcela-aberta  as int format ">>>>9".
def NEW SHARED var qtd-15       as int format ">>>>9".
def NEW SHARED var qtd-45       as int format ">>>>9".
def NEW SHARED var qtd-46       as int format ">>>>9".
def NEW SHARED var vrepar       as log format "Sim/Nao".
def NEW SHARED var v-media      like clien.limcrd.
def NEW SHARED var ult-compra   like plani.pladat.
def NEW SHARED var sal-aberto   like clien.limcrd.
def NEW SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def NEW SHARED var cheque_devolvido like plani.platot.
def NEW SHARED var vclicod like clien.clicod.
def NEW SHARED var vtotal like plani.platot.
def NEW SHARED var vqtd        as int.
def NEW SHARED var proximo-mes like clien.limcrd.
def var vcalclim as dec.
def var vpardias as dec.
def var vdisponivel as dec.

def NEW shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
/* #4 */

def temp-table tt-modal no-undo
    field modcod like modal.modcod
    field etbcod as int
    field juros  as dec
    index modal is primary unique modcod.

def var mmodal as char extent 4 init ["CRE", "CP0", "CP1", "CPN"]. /* #5 */
/***def var mestab as int  extent 3 init [0, 8000, 8001].***/
def var mestab as int  extent 4 init [0, 0, 0, 0].

/* #5 */
def buffer btp-titulo for tp-titulo.
def var vdias as dec.
def var vtxoperacao as dec.
/* #5 */

/* buscarplanopagamento */
def new global shared var setbcod       as int.

def var vi        as int.
def var vstatus   as char.   
def var vbloqueia as log.
def var vmensagem as char.
def var vjuros    as dec.   
def var vsaldojur as dec.
def var vmensagem_erro as char.
def var vvalor_contrato       as dec.
def var vvalor_total_pendente as dec.
def var vvalor_total_pago     as dec.
def var vvalor_total_encargo  as dec.
def var vaberto   as log.
def var venviar   as log.
def buffer btitulo for titulo.
   
def shared temp-table consultaparcelas
    field tipo_documento as char
    field funcionalidade as char
    field numero_documento as char
    field codigo_contrato as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

{bsxml.i}

find first consultaparcelas no-lock no-error.
if avail consultaparcelas
then do.
    if consultaparcelas.tipo_documento = "1" /* cpF */
    then
        find first clien where clien.ciccgc = consultaparcelas.numero_documento
            no-lock no-error.

    if consultaparcelas.tipo_documento = "2" /* codigo-cliente */
    then 
        find clien where clien.clicod = int(consultaparcelas.numero_documento)
            no-lock no-error.

    if not avail clien
    then assign
            vstatus = "N"
            vmensagem_erro = "Cliente Nao Encontrado".
    else assign
            vstatus = "S"
            vmensagem_erro = "".
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("funcionalidade",consultaparcelas.funcionalidade).

setbcod = int(ConsultaParcelas.codigo_filial).

if vstatus = "S" /* avail clien*/
then do:        
    bsxml("codigo_cliente",string(clien.clicod)).
    bsxml("cpf", Texto(clien.ciccgc)).
    bsxml("nome",Texto(clien.clinom)).
    bsxml("data_nascimento",EnviaData(clien.dtnasc)).
    bsxml("tipo_cartao","?").
    bsxml("codigo_filial",consultaparcelas.codigo_filial).
    bsxml("numero_pdv",consultaparcelas.numero_pdv).

    run ./progr/hiscli.p (clien.clicod). /* Calcyla Sal-aberto */
    /** #4 **/
    if consultaparcelas.funcionalidade = "H"
    then . /* Nao manda para nao demorar o timeout */
    else run calccredscore.p (input string(setbcod), /* Calcula vcalclim */
                              input recid(clien),
                              output vcalclim,
                              output vpardias,
                              output vdisponivel).

    bsxml("valor_limite",string(vcalclim - sal-aberto,"->>>>>>>>>9.99")).
    bsxml("credito", string(vcalclim,">>>>>>>9.99")).

    /** #4 **/
    
    do vi = 1 to 4.
        /* #5
        if consultaparcelas.funcionalidade = "N" and
           mmodal[vi] <> "CRE"
        then next.
        */
        create tt-modal.
        tt-modal.modcod = mmodal[vi].
        tt-modal.etbcod = mestab[vi].
    end.
    
    venviar = no.
        
    /*10*/ /* Inicio - VERIFICACAO SE CLIENTE TEM TITULOS 
                       COM ATRASO MAIOR QUE 60 DIAS*/
    if consultaparcelas.funcionalidade = "N"
    then do.
        for each tt-modal no-lock,
            each btp-titulo where
                btp-titulo.empcod = 19 and
                btp-titulo.titnat = no and
                btp-titulo.clifor = clien.clicod and
                btp-titulo.titdtpag = ? and
                btp-titulo.modcod = tt-modal.modcod and
                btp-titulo.titsit = "LIB" /* #3 */
                no-lock.
            if consultaparcelas.codigo_contrato <> ? and
               consultaparcelas.codigo_contrato <> "" and
               consultaparcelas.codigo_contrato <> "?" and
               consultaparcelas.codigo_contrato <> btp-titulo.titnum
            then next.
        
            /* Novacao: somente contratos vencidos com mais de 60 dias */
            if btp-titulo.titdtven > today - 60 
            then next.
            venviar = yes.
            
            /* se tem pelo menos um titulo em atraso, envia tudo */
            leave.
        end. 
    /*10*/ /* Fim */
    end.

    vaberto = yes.

    /*10*/ /* Inicio */
    if (consultaparcelas.funcionalidade = "N" and venviar) or
       consultaparcelas.funcionalidade = "P"
    then do:
    /*10*/ /* Fim */

        for each tt-modal no-lock,
            each titulo use-index por-clifor where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.clifor = clien.clicod and
                titulo.titdtpag = ? and
                titulo.modcod = tt-modal.modcod and
            (if consultaparcelas.codigo_contrato <> ? and
                consultaparcelas.codigo_contrato <> "" and
                consultaparcelas.codigo_contrato <> "?"
              then titulo.titnum = consultaparcelas.codigo_contrato
              else true)
              and titulo.titsit = "LIB"
            no-lock
            break by titulo.titnum
                  by titulo.titpar.
        
            if first-of(titulo.titnum)
            then assign
                    vaberto = no.
                    /*venviar = no.*/ /*10*/ /* Retirado*/

        /*10*/ /*Inicio Retirado o teste */
        /** 
        /* Novacao: somente contratos vencidos com mais de 60 dias */
        if consultaparcelas.funcionalidade = "N" and
           titulo.titdtven > today - 60 and
           venviar = no
        then next.
        
        venviar = yes.
        **/
        /*10*/ /*Fim Retirado o teste */

            run exporta-cli.
        
            if last-of(titulo.titnum)
            then BSXml("FECHAREGISTRO","contratos"). 
        end. /* estab */

        /** Cheque nao sera incluido nesta versao
        if consultaparcelas.funcionalidade = "P"
        then run exporta-cheque. **/
    end. /*10*/

    if consultaparcelas.funcionalidade = "H"
    then do. /* Historico */
        for each tt-modal no-lock,
            each titulo use-index iclicod where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.clifor = clien.clicod and
                titulo.modcod = tt-modal.modcod and
            (if consultaparcelas.codigo_contrato <> ? and
                consultaparcelas.codigo_contrato <> "" and
                consultaparcelas.codigo_contrato <> "?"
              then titulo.titnum = consultaparcelas.codigo_contrato
              else true)
            no-lock
            break by titulo.titnum
                  by titulo.titpar.
        
            if first-of(titulo.titnum)
            then assign
                    vaberto = no.

            run exporta-cli.
        
            if last-of(titulo.titnum)
            then BSXml("FECHAREGISTRO","contratos"). 
        end. /* modal */

    end.
 
    bsxml("aviso", vmensagem).
    bsxml("bloqueia", if vbloqueia then "sim" else "nao").
end.

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure exporta-cli.
                
    if vaberto = no
    then do:
        if consultaparcelas.funcionalidade = "N" /* # 5*/
        then run con_vpres (recid(titulo), output vtxoperacao).
        
        vaberto = yes.
        BSXml("ABREREGISTRO","contratos"). 
        bsxml("filial_contrato",string(titulo.etbcod)).
        bsxml("modalidade",titulo.modcod).
        bsxml("numero_contrato",string(int(titulo.titnum),"9999999999")).
        bsxml("data_emissao_contrato",EnviaData(titulo.titdtemi)).
            
        assign
            vvalor_contrato = 0
            vvalor_total_pago = 0
            vvalor_total_pendente = 0
            vvalor_total_encargo = 0.

        for each btp-titulo where
                        btp-titulo.empcod = 19 and
                        btp-titulo.titnat = no and
                        btp-titulo.modcod = titulo.modcod and
                        btp-titulo.etbcod = titulo.etbcod and
                        btp-titulo.clifor = titulo.clifor and
                        btp-titulo.titnum = titulo.titnum and
                        btp-titulo.titdtemi = titulo.titdtemi
                        no-lock.
            vvalor_contrato = vvalor_contrato + btp-titulo.titvlcob.

            if btp-titulo.titsit = "PAG"
            then vvalor_total_pago = vvalor_total_pago + btp-titulo.titvlcob.

            if (consultaparcelas.funcionalidade = "P" or
                consultaparcelas.funcionalidade = "N") and
               btp-titulo.titsit <> "LIB"
            then next.

            /** BASE MATRIZ  */
            vjuros = 0.
            if btp-titulo.titsit = "LIB"
            then do.
                if btp-titulo.titdtven < today
                then do.
                    run juro_titulo.p (0,
                                        btp-titulo.titdtven,
                                        btp-titulo.titvlcob,
                                        output vjuros).
                    btp-titulo.titvljur = vjuros.
                end.
                else /* #5 */
                    if consultaparcelas.funcionalidade = "N" and
                       btp-titulo.titdtven > today and
                       vtxoperacao > 0
                    then do.
                        vdias = (btp-titulo.titdtven - today) / 30.
                        btp-titulo.titvlcob  = btp-titulo.titvlcob 
                                          / exp(1 + vtxoperacao / 100, vdias).
                    end.

                vvalor_total_pendente = vvalor_total_pendente + 
                                        btp-titulo.titvlcob.
            end.
            vvalor_total_encargo = vvalor_total_encargo + vjuros.
        end.        

        bsxml("valor_contrato",string(vvalor_contrato,">>>>>>>>>>>>9.99")).
        bsxml("valor_total_pago",string(vvalor_total_pago,">>>>>>>>>>>>9.99")).
        bsxml("valor_total_pendente",string(vvalor_total_pendente,
                            ">>>>>>>>>>>>9.99")).
        bsxml("valor_total_encargo",string(vvalor_total_encargo,
                            ">>>>>>>>>>>>9.99")).
        bsxml("tp_contrato", titulo.tpcontrato). /* #1 */

        /* Enviar as parcelas usando a temp */
        for each btp-titulo where
                        btp-titulo.empcod = 19 and
                        btp-titulo.titnat = no and
                        btp-titulo.modcod = titulo.modcod and
                        btp-titulo.etbcod = titulo.etbcod and
                        btp-titulo.clifor = titulo.clifor and
                        btp-titulo.titnum = titulo.titnum and
                        btp-titulo.titdtemi = titulo.titdtemi
                        no-lock.
            if (consultaparcelas.funcionalidade = "P" or
                consultaparcelas.funcionalidade = "N") and
               btp-titulo.titsit <> "LIB"
            then next.

            BSXml("ABREREGISTRO","parcelas").
            bsxml("seq_parcela",string(btp-titulo.titpar)).
            bsxml("venc_parcela",EnviaData(btp-titulo.titdtven)).
            bsxml("vlr_parcela",string(btp-titulo.titvlcob,">>>>>>>>9.99")).
            bsxml("valor_encargos",string(btp-titulo.titvljur,
                        ">>>>>>>>>>9.99")).
            bsxml("percentual_encargo_dia",string(0)).
            bsxml("data_pagamento", EnviaData(btp-titulo.titdtpag)).
            bsxml("valor_desconto",if btp-titulo.titvlpag = 0 or
                                     btp-titulo.titvlpag >= btp-titulo.titvlcob
                               then string("0.00")
                               else string(btp-titulo.titvlcob
                                           - btp-titulo.titvlpag,
                                        ">>>>>>>>>>9.99")).
            bsxml("inf_compl", ""). /* #2 */
            BSXml("FECHAREGISTRO","parcelas").
        end.
    end.

/***
    BSXml("ABREREGISTRO","parcelas").
    bsxml("seq_parcela",string(titulo.titpar)).
    bsxml("venc_parcela",EnviaData(titulo.titdtven)).
    bsxml("vlr_parcela",string(titulo.titvlcob,">>>>>>>>9.99")).

    /** BASE MATRIZ  */
    vjuros = 0.
    if titulo.titsit = "LIB"
    then run juro_titulo.p (0, titulo.titdtven, titulo.titvlcob,
                            output vjuros).

    bsxml("valor_encargos",string(vjuros,">>>>>>>>>>9.99")).
    bsxml("percentual_encargo_dia",string(0)).
    bsxml("data_pagamento", EnviaData(titulo.titdtpag)).
    bsxml("valor_desconto",if titulo.titvlpag = 0 or
                              titulo.titvlpag >= titulo.titvlcob
                           then string("0.00")
                           else string(titulo.titvlcob - titulo.titvlpag,
                                    ">>>>>>>>>>9.99")).
    bsxml("inf_compl", ""). /* #2 */
    BSXml("FECHAREGISTRO","parcelas").
***/

end procedure.


procedure con_vpres. /* #5 */

    def input  parameter par-rec  as recid.
    def output parameter par-txjuros as dec init 0.

    def var vvlrttcontr as dec.
    def var vvlrfinanc  as dec.
    def var vqtdparcela as dec format ">>>9".
    def buffer xtitulo for titulo.

    find xtitulo where recid(xtitulo) = par-rec no-lock.

    find contrato where contrato.contnum = int(xtitulo.titnum)
                  no-lock no-error.
    if avail contrato and
       contrato.txjuros > 0
    then do.
        par-txjuros = contrato.txjuros.
        return.
    end.

/** Calculo da taxa de juros em versao futura
    for each btp-titulo where btp-titulo.empcod = xtitulo.empcod
                          and btp-titulo.titnat = xtitulo.titnat
                          and btp-titulo.clifor = xtitulo.clifor
                          and btp-titulo.titnum = xtitulo.titnum
                          and btp-titulo.etbcod = xtitulo.etbcod
                        no-lock:
        if btp-titulo.titpar = 0
        then .
        else assign
                vqtdparcela = vqtdparcela + 1
                vvlrttcontr = vvlrttcontr + btp-titulo.titvlcob.
    end.

    if vvlrfinanc = vvlrttcontr
    then return.

    find last contnf where contnf.contnum = int(xtitulo.titnum)
                       and contnf.etbcod  = xtitulo.etbcod
                     no-lock no-error.
    if avail contnf
    then do.
        find first plani where plani.placod = contnf.placod
                           and plani.etbcod = contnf.etbcod
                         no-lock no-error.
        if avail plani
        then do:
            vvlrfinanc = plani.platot.
        /*Solicitacao pelo Airton para considerar entrada no financiado mas nao
          contabilizar a mesma na contagem de parcelas*/
        /* vvlrfinanc = vvlrfinanc - val_entrada. */
        end.
    end.
    else /* Novacao */
        for each tit_novacao where 
                                 tit_novacao.ger_contnum = int(xtitulo.titnum)
                             and tit_novacao.etbnova     = xtitulo.etbcod
                             no-lock:
            vvlrfinanc = vvlrfinanc + tit_novacao.ori_titvlpag.
        end.

    if vvlrfinanc > 0
    then /* calcula taxa de juros */
        run credtxjuros.p (input vvlrfinanc,
                           input vvlrttcontr,
                           input vqtdparcela,
                           output par-txjuros).

    if avail contrato and
       par-txjuros > 0
    then do on error undo.
        find current contrato exclusive no-wait no-error.
        if avail contrato
        then assign
                contrato.txjuros    = par-txjuros
                contrato.nroparc    = vqtdparcela
                contrato.vlmontante = vvlrfinanc.
    end.
***/

end procedure.


procedure exporta-cheque.

    for each cheque where cheque.clicod = clien.clicod
                      and cheque.chesit = "LIB" no-lock:

        BSXml("ABREREGISTRO","contratos"). 
        bsxml("filial_contrato",string(cheque.cheetb)).
        bsxml("modalidade","CHQ").
        bsxml("numero_contrato",string(cheque.chenum,"9999999999")).
        bsxml("data_emissao_contrato",EnviaData(cheque.cheemi)).

        assign
            vvalor_total_pago = 0
            vvalor_total_pendente = 0
            vvalor_total_encargo = 0
            vjuros = 0.

        if cheque.chesit = "LIB"
        then vvalor_total_pendente = cheque.cheval.
        else vvalor_total_pago     = cheque.cheval + cheque.chejur.

        bsxml("valor_contrato",string(cheque.cheval,">>>>>>>>>>>>9.99")).
        bsxml("valor_total_pago",string(vvalor_total_pago,">>>>>>>>>>>>9.99")).
        bsxml("valor_total_pendente",string(vvalor_total_pendente,
                            ">>>>>>>>>>>>9.99")).
        bsxml("valor_total_encargo",string(vvalor_total_encargo,
                            ">>>>>>>>>>>>9.99")).
        bsxml("tp_contrato", ""). /* #1 */

        BSXml("ABREREGISTRO","parcelas").
        bsxml("seq_parcela","1").
        bsxml("venc_parcela",EnviaData(cheque.cheven)).
        bsxml("vlr_parcela",string(cheque.cheval,">>>>>>>>9.99")).
        bsxml("valor_encargos",string(vjuros,">>>>>>>>>>9.99")).
        bsxml("percentual_encargo_dia",string(0)).
        bsxml("data_pagamento", EnviaData(cheque.chepag)).
        bsxml("valor_desconto","0").
        bsxml("inf_compl",string(cheque.cheban) + "," +
                          string(cheque.cheage) + "," +
                          string(cheque.checon)).
        BSXml("FECHAREGISTRO","parcelas").

        BSXml("FECHAREGISTRO","contratos").
    end.

end procedure.

