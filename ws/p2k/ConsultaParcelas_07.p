/* helio 06022023 - ID 155445 - cslog enviou no csml o campo idAcordoLebes, com este id fazendo teste se numero de acordo inicia com 9, para desprezar */

/* helio 14072022 estava usando o campo titpagdesc, que é o desconto dos juros dados*/

/* IEPRO 05012022 helio */
/* HUBSEG 19/10/2021 */

def var vtitprot as log.

{/admcom/progr/api/acentos.i} /* helio 06022023 */

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.

/* #4 */

def NEW shared temp-table tp-titulo like titulo
    field descontoAntecipacao   as dec init 0 /* helio 14072022 estava usando o campo titpagdesc, que é o desconto dos juros dados*/
    field vlcet as dec
    field vltfc as dec
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
def NEW SHARED var sal-abertopr like clien.limcrd.
def NEW SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def NEW SHARED var cheque_devolvido like plani.platot.
def NEW SHARED var vclicod like clien.clicod.
def NEW SHARED var vtotal like plani.platot.
def NEW SHARED var vqtd        as int.
def NEW SHARED var proximo-mes like clien.limcrd.


def var vvlrlimite as dec.
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

def var mmodal as char extent 5 init ["CRE", "CP0", "CP1", "CPN","RFN"]. /* helio 21062024 - RFN */
/***def var mestab as int  extent 3 init [0, 8000, 8001].***/
def var mestab as int  extent 5 init [0, 0, 0, 0,0].

/* #5 */

def buffer btp-titulo for tp-titulo.


def var vdias as dec.
def var vtxoperacao as dec.
/* #5 */

/* #6 ini - Cyber ***/
/*** Cyber ***/
def NEW shared temp-table tt-novacao
    field ahid    as char /* #2 */
    field ahdt    as date
    field vltotal as dec
    field idAcordo as int.

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


/* #6 fim */

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
def var vmaioratraso as int. /* #6 */
def buffer btitulo for titulo.
   
def shared temp-table consultaparcelas
    field tipo_documento as char
    field funcionalidade as char
    field numero_documento as char
    field codigo_contrato as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.
def var vtotabe as dec.
{/u/bsweb/progr/bsxml.i}

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
    bsxml("cpf", removeAcento(clien.ciccgc)).
    bsxml("nome",removeAcento(clien.clinom)).
    bsxml("data_nascimento",EnviaData(clien.dtnasc)).
    bsxml("tipo_cartao","?").
    bsxml("codigo_filial",consultaparcelas.codigo_filial).
    bsxml("numero_pdv",consultaparcelas.numero_pdv).


    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.

    vvlrlimite  = if avail neuclien
                  then if neuclien.vctolimite >= today
                       then neuclien.vlrlimite
                       else 0
                  else 0.

    /* grava os titulos em temp-table, pois o programa estava assim, fazendo isto dentro do hiscli */

    for each contrato where contrato.clicod = clien.clicod no-lock,
        each titulo where titulo.empcod = 19        and
                           titulo.titnat = no        and
                           titulo.modcod = contrato.modcod and
                           titulo.etbcod = contrato.etbcod and
                           titulo.clifor = contrato.clicod and
                           titulo.titnum = string(contrato.contnum)
                           no-lock:

        if titulo.modcod = "CHQ" or
           titulo.modcod = "DEV" or
           titulo.modcod = "BON" or
           titulo.modcod = "VVI" /*#1*/ or
           length(titulo.titnum) > 11 /* Sujeira de banco */
        then next. /*** ***/


        find first tp-titulo where tp-titulo.empcod = titulo.empcod and
                                   tp-titulo.titnat = titulo.titnat and
                                   tp-titulo.modcod = titulo.modcod and
                                   tp-titulo.etbcod = titulo.etbcod and
                                   tp-titulo.clifor = titulo.clifor and
                                   tp-titulo.titnum = titulo.titnum and
                                   tp-titulo.titpar = titulo.titpar
                                   no-error.
        if not avail tp-titulo
        then do: 
            create tp-titulo.
            buffer-copy titulo to tp-titulo.
        end.
    end.        
                          
    run neuro/comportamento.p (clien.clicod, ?,   /* hubseg */
                              output var-propriedades). 

    var-salaberto = dec(pega_prop("LIMITETOM")).
    if var-salaberto = ? then var-salaberto = 0.
    
    var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
    if var-salaberto-principal = ? then var-salaberto-principal = 0.

    var-salaberto-hubseg = dec(pega_prop("LIMITETOMHUBSEG")).
    if var-salaberto-hubseg = ? then var-salaberto-hubseg = 0.
    
    
    var-sallimite  = vvlrlimite - var-salaberto-principal - var-salaberto-hubseg. /* hubseg */
    if var-sallimite = ? then var-sallimite = 0.

    bsxml("valor_limite",string(var-sallimite,"->>>>>>>>>9.99")).
    bsxml("credito", string(vvlrlimite,">>>>>>>9.99")).

    /** #4 **/
    
    do vi = 1 to /*4*/ 5. /* helio 21062024 rfn */
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

    vtitprot = no. 

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


        /* IEPRO */
        find first titprotparc where titprotparc.operacao = "IEPRO" and 
                                     titprotparc.contnum = int(titulo.titnum) and
                                     titprotparc.titpar  = titulo.titpar 
                                     no-lock no-error.
        if avail titprotparc
        then do:
            find titprotesto of titprotparc no-lock no-error.
            if avail titprotesto 
            then do:
            
                if  titprotesto.ativo = "" or 
                    titprotesto.ativo = "ATIVO"
                then vtitprot = yes.

            end.
        end.    



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

            if today - titulo.titdtven > vmaioratraso
            then vmaioratraso = today - titulo.titdtven. /* #6 */

            run exporta-cli.
        
            if last-of(titulo.titnum)
            then BSXml("FECHAREGISTRO","contratos"). 
        end. /* estab */

        /* #8 */
        if consultaparcelas.funcionalidade = "P"
        then run exporta-cheque.
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

    /* #6 Cyber 25012021 CSLOG */
    vbloqueia = no.
    
    run log (consultaparcelas.funcionalidade).
        
    if consultaparcelas.funcionalidade = "P" and
       clien.clicod > 1 /**and
       vmaioratraso > 54   **/
    then do.
        /** desativado porque nao tem mais cyber
        run ./progr/pdv/cyber_acordo_07.i ("Caixa", clien.clicod,
                                           output vmensagem).
        if vmensagem <> ""
        then vbloqueia = yes.
        **/ 
        
        
        
        /* helio 23052022 https://trello.com/c/TTEUwsi7/642-desativa-consulta-cliente-cslog */
        def var vparam as char.
        run le_tabini.p (0, 0, "ConectaCSLOG", OUTPUT vparam).         
        if vparam = "NAO" 
        then.
        else do:  
            /* 25012021helio CSLOG */
            run log ("verificar cslog").
            run /admcom/progr/csl/chama-ws-cslog.p (input clien.clicod, output vmensagem).
            
            /* helio 06022023 - ID 155445 - Erro ao pagar parcela no p2k com marcação "acordo com o CRIIC" */
            find first tt-novacao no-error.
            run log("retornou " + string(avail tt-novacao,"Com Acordo Cslog/Sem Acordo Cslog")).
            if avail tt-novacao 
            then do:
                for each tt-novacao.            
                    run log ("  Acordo: " + tt-novacao.ahid + " " + string(tt-novacao.idAcordo) + " " +
                                    string(trim(string(tt-novacao.idAcordo)) begins "9","Promessa/Acordo Novacao")). /* helio 06022023 - recebendo idAcordo */
                        for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid.
                            run log ("      Acordo: " + string(tt-novacao.idAcordo) + " - Origem: " + tt-contratos.titnum).
                        end.
                        for each tt-acordo where tt-acordo.apahid = tt-novacao.ahid.
                            run log ("      Acordo: " + string(tt-novacao.idAcordo) + " - Acordo: " + string(tt-acordo.titpar) +  " " + 
                                                                                                string(tt-acordo.titdtven,"99/99/9999") + " " +
                                                                                                trim(string(tt-acordo.titvlcob,">>>>>>>>>9.99"))).
                        end.    
                end.    
            end.
            for each tt-novacao where trim(string(tt-novacao.idAcordo)) begins "9".
                for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid.
                    delete tt-contratos.
                end.
                for each tt-acordo where tt-acordo.apahid = tt-novacao.ahid.
                    delete tt-acordo.
                end.    
                delete tt-novacao.
            end.
            /**/
            
        end.
        /* helio 23052022 */
        
        /* validacao contrato pago */
        for each tt-novacao.
            run log ("-> Acordos: " + tt-novacao.ahid + " " + string(tt-novacao.idAcordo) + " " +
                                    string(trim(string(tt-novacao.idAcordo)) begins "9","Promessa/Acordo Novacao")). /* helio 06022023 - recebendo idAcordo */
        
            for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid no-lock. 
                find contrato where contrato.contnum = int(tt-contratos.titnum)
                              no-lock no-error.
                if not avail contrato 
                then do:
                    tt-novacao.vltotal = 999999.
                end.
                else do:    
                    vtotabe = 0.
                    for each titulo where titulo.empcod = 19
                          and titulo.titnat = no
                          and titulo.modcod = contrato.modcod
                          and titulo.etbcod = contrato.etbcod
                          and titulo.clifor = contrato.clicod
                          and titulo.titnum = string(contrato.contnum)
                        no-lock.
                        if titulo.titsit = "LIB"
                        then do:
                        /* helio 06022023 - retirado porque teste eh direto pelo acordo da api                            
                            /* helio - 25.05.2021 - nao computar quando tem promessa */
                            find last cslpromessa where cslpromessa.contnum = contrato.contnum and
                                                   cslpromessa.parcela  = titulo.titpar
                                               and CSLPromessa.dtbaixa = ?    
                                                   no-lock no-error. 
                            if avail cslpromessa 
                            then do:
                                tt-novacao.vltotal = 999999.
                                next.                                
                            end.    
                        */
                                                    
                            /**/
                            vtotabe = vtotabe + titulo.titvlcob.        
                        end.    
                    end.
                    if vtotabe = 0
                    then do:
                        tt-novacao.vltotal = 999999.
                    end.
                end.
            end.
            if tt-novacao.vltotal = 999999
            then do:
                for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid.
                    delete tt-contratos.
                end.
                for each tt-acordo where tt-acordo.apahid = tt-novacao.ahid.
                    delete tt-acordo.
                end.    
                run log ("->    PAGO: " + tt-novacao.ahid + " " + string(tt-novacao.idAcordo) + " " +
                                    string(trim(string(tt-novacao.idAcordo)) begins "9","Promessa/Acordo Novacao")). /* helio 06022023 - recebendo idAcordo */
                
                delete tt-novacao.
            end.
        end.
        
        
        find first  tt-acordo no-lock no-error. /* Contratos do acordo do CSLOG */
    
        
        if  avail tt-acordo
        then do:
            vbloqueia = yes.
            vmensagem = "Cliente possui acordo no CRIIC. Favor ir para o menu de NOVACAO".
        end.
        else vmensagem = "".
        
        run log ("Mensagem=" + vmensagem).
    end.
    if vtitprot
    then do:
        vmensagem = "Cliente possui Parcelas em Negociacao de Protesto".
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
                    run juro_titulo.p ( if clien.etbcad = 0 then btp-titulo.etbcod else clien.etbcad, /* helio 07112020 */
                                       btp-titulo.titdtven,
                                       btp-titulo.titvlcob,
                                       output vjuros).
                    btp-titulo.titvljur = vjuros.
                end.
                    
                    /** 02072020 helio
                    else /* 5 */
                    if consultaparcelas.funcionalidade = "N" and
                       btp-titulo.titdtven > today and
                       vtxoperacao > 0
                    then do.
                        vdias = (btp-titulo.titdtven - today) / 30.
                        btp-titulo.titvlcob  = btp-titulo.titvlcob 
                                          / exp(1 + vtxoperacao / 100, vdias).
                        btp-titulo.descontoAntecipacao = calculo do desconto antecipacao                   
                    end.**/

                /*21.07.2020*/
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
            bsxml("valor_desconto", string(btp-titulo.descontoAntecipacao, ">>>>>>>>>>9.99")).
            bsxml("inf_compl", ""). /* #2 */
            BSXml("FECHAREGISTRO","parcelas").
        end.
    end.


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


end procedure.


procedure exporta-cheque.

    for each cheque where cheque.clicod = clien.clicod
                      and cheque.chesit = "LIB"
                    no-lock:
        BSXml("ABREREGISTRO","contratos"). 
        bsxml("filial_contrato",string(cheque.cheetb)).
        bsxml("modalidade","CHQ").
        bsxml("numero_contrato",string(cheque.chenum,"9999999999")).
        bsxml("data_emissao_contrato",EnviaData(cheque.cheemi)).

        assign
            vjuros = 0.

        if cheque.cheven < today
        then
            run juro_titulo.p (setbcod /*#7 0 */,
                               cheque.cheven,
                               cheque.cheval,
                               output vjuros).

        bsxml("valor_contrato",      string(cheque.cheval,">>>>>>>>9.99")).
        bsxml("valor_total_pago",    string(0,            ">>>>>>>>9.99")).
        bsxml("valor_total_pendente",string(cheque.cheval,">>>>>>>>9.99")).
        bsxml("valor_total_encargo", string(vjuros,       ">>>>>>>>9.99")).
        bsxml("tp_contrato", ""). /* #1 */

        BSXml("ABREREGISTRO","parcelas").
        bsxml("seq_parcela",   "1").
        bsxml("venc_parcela",  EnviaData(cheque.cheven)).
        bsxml("vlr_parcela",   string(cheque.cheval,">>>>>>>>9.99")).
        bsxml("valor_encargos",string(vjuros,       ">>>>>>>>9.99")).
        bsxml("percentual_encargo_dia","0").
        bsxml("data_pagamento",EnviaData(cheque.chepag)).
        bsxml("valor_desconto","0").
        bsxml("inf_compl",string(cheque.cheban) + "," +
                          string(cheque.cheage) + "," +
                          string(cheque.checon)).
        BSXml("FECHAREGISTRO","parcelas").
        BSXml("FECHAREGISTRO","contratos").
    end.

end procedure.


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = "/ws/log/p2k07_" + string(today, "99999999") + ".log".

    output to value(varquivo) append.
    put unformatted "    -> " string(time,"HH:MM:SS")
        " ConsultaParcelas " par-texto skip.
    output close.

end procedure.


