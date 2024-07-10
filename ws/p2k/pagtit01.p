{admcab.i}

def input parameter rec-cli as recid.
def input parameter rec-cxa as recid.

def var rec-plani as recid.

find clien where recid(clien) = rec-cli no-lock.
disp clien.clicod format ">>>>>>>>>9" label "Cliente"
     clien.clinom no-label
     with frame f-cli row 5 1 down no-box side-label.

def shared var v-pro-recarga as log.
def shared var v-cancela-cupom as log.
def shared var v-cancela-pagamento as log.
def shared var v-cupom-emitido as log.

def new shared buffer autoriz for autoriz.

def var v-vok as log.
def shared var p-recid as recid.
def var vecfretorno as int.
def var vecfnsq     as int.
def var vecfcxa     as int.
def var vcoo     as int.
def var vcaixa as int.
def var vok as log.
def var vcartparc as int.
def shared var v-cartao as log format "Sim/Nao".
def shared var v-venda  as log format "Sim/Nao".
def shared var v-valor-tef as dec.

def shared temp-table cupom-tit-pag
    field tef as log init yes
    field tefretorno as char
    field cmopevlr as dec.

def shared temp-table tpb-contrato like contrato.
def shared temp-table tpb-contnf
        field etbcod  like contnf.etbcod
        field placod  like contnf.placod
        field contnum like contnf.contnum
        field marca   as   char format "x".

def shared temp-table tt-titdev
    field marca as char format "x(1)"
    field empcod like titulo.empcod
    field titnat like titulo.titnat
    field modcod like titulo.modcod
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    field titsit   like titulo.titsit
    field titdtemi like titulo.titdtemi    
    field tipdev     as   char

    index i-tit is primary unique empcod 
                                  titnat 
                                  modcod 
                                  etbcod 
                                  clifor 
                                  titnum 
                                  titpar.

def new shared temp-table tt-che
    field comp       as char format "x(3)"
    field banco      as char
    field agencia    as char format "x(6)"
    field controle1  like chq.controle1
    field conta      as char format "x(12)"
    field controle2  like chq.controle2
    field numero     as char
    field controle3  like chq.controle3
    field dataven    as date format "99/99/9999" initial today
    field valor      like chq.valor.

def temp-table tt-titpag
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titjuro  like titulo.titjuro.
    
def var vjuro like titulo.titjuro.
def var vtitvlcob like titulo.titvlcob.
def var vv like titulo.titvlcob.
def var i as int.
def var de-vltit        as   dec.
def var ljuros          as   log      init yes.
def var vnumdia         as   integer  init 0.
def var vtitvlpag       like titulo.titvlpag.
def var vtitdtpag       like titulo.titdtpag.
def var vclicod         like clien.clicod.
def var vtottit         like titulo.titvlcob.
def var vtotliq         like titulo.titvlpag.

def shared temp-table wftit
    field rec    as recid
    field ord    as int
        index ind-1 ord.

def temp-table tit-sel like wftit.

vclicod = clien.clicod.

for each wftit:
    create tit-sel.
    buffer-copy wftit to tit-sel.
end.
    
def new shared temp-table tt-recib
        field rectit as recid
        field titnum like titulo.titnum
        field ordpre as int.

def temp-table ttnovo
    field rec as recid.

def shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum /*is primary unique*/ empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

def shared temp-table tp-cheque like fin.cheque.

def buffer btp-titulo      for tp-titulo.
def buffer ctp-titulo      for tp-titulo.

def var vultpag as log init yes.         
def var vultimo as log init yes.
def temp-table tt-clien like clien.
for each tp-titulo where tp-titulo.titsit = "LIB" no-lock:
    find clien where clien.clicod = tp-titulo.clifor no-lock.
    if avail clien
    then do:
        if clien.clicod = 1
        then do:
            vultpag = no.
            vultimo = no.
        end.
        find tt-clien where tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
    end.
    find first wftit where wftit.rec = recid(tp-titulo) no-lock no-error.
    if not avail wftit or tp-titulo.modcod = "VVI"
    then do:
        vultpag = no.
        vultimo = no.
        leave. 
    end.
    if avail wftit and tp-titulo.titpar < 4
    then do:
        vultpag = no.
    end.    
    if avail wftit and tp-titulo.titpar >= 30
    then do:
        vultpag = no.
    end.    
end.
if vultimo
then do:
    message color red/with
    SKIP
    "   CLIENTE QUITARA A ULTIMA PRESTAÇÃO   "
    SKIP
    view-as alert-box title " ATENÇAO ".
end. 

find caixa where recid(caixa) = rec-cxa no-lock.
scxacod = caixa.cxacod.

assign     vtitvlpag = 0
           vjuro     = 0
           vtitvlcob = 0
           vtotliq   = 0.

for each tt-titpag. delete tt-titpag. end.
vtitdtpag = today.
for each wftit use-index ind-1:
    run pag-tp-titulo (""). 
end.

vjuro = vtitvlpag - vtitvlcob.
vtotliq = vtitvlpag.

def var vmoecod like moeda.moecod.
def var vlpagar as dec.
def var vlfalta as dec.
def var vltroco as dec.

vlfalta = vtotliq.

form with frame f-pag1 width 80
        12 down row 6  
        title " Tela de pagamento ".

form
    vmoecod column-label "Moeda"
    moeda.moenom no-label format "x(18)"
    vlpagar column-label "Pagar  " format ">>,>>9.99" 
    vlfalta column-label "Falta  " format ">>,>>9.99"
    with frame f-pag2 width 45
        7 down row 9 color message overlay no-box column 35.

form with frame f-pag3 row 19 color message
        side-label column 50 no-box overlay.

form vcartparc format ">9" label "Numero de Parcelas"
     validate (vcartparc > 0 and vcartparc < 13, "")
     with frame f-pag5 row 12 color message side-label column 45 overlay
        title " Cartao de Credito ".
    
/*
disp vtotliq label "Total a pagar R$" 
        with frame f-pag1 .
*/
pause 0.

vmoecod = "REA".
vtitdtpag = today.

find first wftit where wftit.rec <> ? no-lock no-error.
if not avail wftit then return.
 
find first btp-titulo where recid(btp-titulo) = wftit.rec no-lock no-error.
if not avail btp-titulo
then return.

def var vnpag as int init 0.
def var vtotpar as int init 0.
def new shared var vmoetit like titulo.moecod.
def var vparcial as log format "Sim/Nao". 
def var vdispensajuro as log format "Sim/Nao".
def var vjuro-d as dec init 0.

/**** tela de pagamento ***************/

def var vtitjuro as dec.
for each tt-titpag where tt-titpag.titnum <> "":
    disp tt-titpag.titnum    format "x(10)"       column-label "Contrato"
         tt-titpag.titpar    format ">9"          column-label "Pc"
         tt-titpag.titvlcob  format ">>,>>9.99"   column-label "Valor"
         tt-titpag.titjuro   format ">,>>9.99"    column-label "Juro"
         with frame f-pag1.
    down with frame f-pag1.
    vtotpar = vtotpar + 1.
    /*if vtotpar = 1
    then*/ vtitjuro = vtitjuro + tt-titpag.titjuro. 
end.
pause 0.

disp vtitdtpag label "DATA PAGAMENTO"  format "99/99/9999"
     vtotliq   label "TOTAL PAGAR R$"  format ">>,>>>,>>9.99"
     with frame f-pag4 overlay row 7 column 50 side-label no-box.
        
def var vretorna as log.

def temp-table tit-gera like titulo.

v-cancela-cupom = no. 
v-cancela-pagamento = no.
v-cupom-emitido = no.

repeat on error undo, retry:
    vlpagar = 0.
    vjuro-d = 0.

    update vmoecod  go-on (F4 PF4) with frame f-pag2.
    
    if keyfunction(lastkey) = "END-ERROR" /*and
       vlfalta = vtotliq                    */
    then do:
        sresp = no.
        run mensagem.p(input-output sresp,
                       input "  *** OPERACAO SERA CANCELADA ***" +
                             "!!Voce teclou F4, se voce confirmar  " + 
                             "!a operacao sera cancelada e as " +
                             "parcelas serao desmarcada" +
                             "!!Confirma cancelamento da operacao? ",
                       input "",
                       input "  Sim",
                       input "  Nao").
        if sresp
        then do:
            assign
                btp-titulo.titsit = "LIB"
                btp-titulo.titvlpag = 0
                btp-titulo.titjuro = 0
                btp-titulo.titdtpag = ?.
                
            for each titpag where
                titpag.empcod = btp-titulo.empcod and
                titpag.titnat = btp-titulo.titnat and
                titpag.modcod = btp-titulo.modcod and
                titpag.etbcod = btp-titulo.etbcod and
                titpag.clifor = btp-titulo.clifor and
                titpag.titnum = btp-titulo.titnum and
                titpag.titpar = btp-titulo.titpar :
                delete titpag.
            end.
            for each tt-recib:
                delete tt-recib.
            end.
            v-cancela-pagamento = yes.
            leave.
        end.
        else next.    
    end.

    if vmoecod <> "REA" and
       vmoecod <> "CHV" and
       vmoecod <> "CAR" and
       vmoecod <> "PRE"
    then do:
        message color red/with
        "Moedas para pagamento:" skip
        "REA = Dinheiro" skip
        "CAR = Cartao" skip
        "CHV = Cheque" skip
        "PRE = Cheque pre"
        view-as alert-box.
        next.
    end.

    if v-pro-recarga
    then do:
        if vmoecod <> "REA" 
        then do:
            message color red/with "Recarga pagamento somente em dinheiro."
            view-as alert-box.
            next.    
         end.
    end.
    /*
    else if v-venda = no and
            vmoecod = "CAR"
    then do:
        message "Pagamento com Cartao somente entrada ou venda a vista."
            view-as alert-box.
            next. 
    end. 
           */
    /*
    if (vmoecod = "CHV" or
        vmoecod = "PRE") and
        vtotpar <> 1
    then do:
        message color red/with "Pagamento com CHEQUE somente valor total."
        view-as alert-box.
        next. 
    end.
    */

    if vmoecod = "PRE"
    then do:
        update vtitdtpag  with frame f-pag4. 
        assign
           vtitvlpag = 0
           vjuro     = 0
           vtitvlcob = 0
           vtotliq   = 0.

        for each tt-titpag. delete tt-titpag. end.

        for each wftit use-index ind-1:
            run pag-tp-titulo (""). 
        end.

        vjuro = vtitvlpag - vtitvlcob.
        hide frame f-pag1.
        clear frame f-pag1 all.
        for each tt-titpag where tt-titpag.titnum <> "":
            disp tt-titpag.titnum    
                format "x(10)"       column-label "Contrato"
                tt-titpag.titpar     format ">9"          column-label "Pc"
                tt-titpag.titvlcob   format ">>,>>9.99"   column-label "Valor"
                tt-titpag.titjuro    format ">,>>9.99"    column-label "Juro"
                with frame f-pag1.
            down with frame f-pag1.
        end.
        pause 0.
        
        vtotliq = vtitvlpag.
        vlfalta = vtotliq.
        disp vtotliq with frame f-pag4.
    end.    

    find moeda where moeda.moecod = vmoecod no-lock no-error.
    if not avail moeda then next.

    disp moeda.moenom  with frame f-pag2.

    if v-pro-recarga = no and
       vmoecod = "CAR"
    then do on error undo.
        pause 0.
        update vcartparc with frame f-pag5.
        disp moeda.moenom + string(vcartparc, ">>9") + "X" @ moeda.moenom
             with frame f-pag2.
        hide frame f-pag5 no-pause.
    end.

    vlpagar = vlfalta.
    
    repeat on error undo:
    
    update vlpagar  with frame f-pag2.
    
    if v-pro-recarga
    then
        if vlpagar < vlfalta
        then do:
            message color red/with "Recarga pagamento total" view-as alert-box.
            next.    
        end.

    /*
    if vmoecod = "CHV" and
        vlfalta <> vlpagar
    then do:
        message  
            "Valor a pagar incorreto.".
             pause.
        next. 
    end. 
    */   
    
    if (vmoecod = "CHV" or
        vmoecod = "PRE") and
       vlpagar > vlfalta
    then do:
        vlpagar = vlfalta.
        message "Valor a pagar incorreto".
        pause.
        undo. 
    end.    
    
    vlfalta = vlfalta - vlpagar.
    
    if vmoecod <> "REA" and vlfalta < 0
    then do:
        vlfalta = vlfalta + vlpagar.
        message "Valor a pagar incorreto".
        pause.
        undo.    
    end.    
    
    vparcial = no.
    vdispensajuro = no.
    if vmoetit = "" and vlfalta > 0 and
        (vtotpar = 1 or vtitjuro > 0) and 
        btp-titulo.titpar < 300       
    then do:
        if vtitjuro > 0 and
           vlpagar >= vtitvlcob and
           vlpagar <= vtitvlpag and
           (vtitvlpag - vlpagar) <= vtitjuro
        then do:
            message "Dispensa de juros?" update vdispensajuro.
            if vdispensajuro
            then do:
                run dispensa-de-juros. 
                if not vdispensajuro
                then undo.
                vmoetit = vmoecod.
            end.
        end.   
        if vtotpar = 1
        then do:
            if vdispensajuro = no and
               vlpagar >= vtotliq / 2 and
               vmoecod = "REA"   and
               btp-titulo.modcod = "CRE" and
               btp-titulo.titpar > 0
            then repeat on endkey undo:
                message "Pagamento parcial?" update vparcial.
                if vparcial
                then vmoetit = vmoecod.
                leave.
            end. 
        end.
        if vdispensajuro = no and
           vparcial = no   and
           (btp-titulo.titpar = 0 or
            (btp-titulo.titpar = 1 and btp-titulo.modcod = "VVI"))
        then vmoetit = "PDM".
        else if vdispensajuro = no and
                vparcial = no  
        then do:
            vlfalta = vlfalta + vlpagar.
            message  "Operacao nao permitida".
            pause.
            undo.       
        end. 
        else vmoetit = vmoecod.  
    end.
    else if vlfalta > 0 and
            vmoetit <> "" and
            vmoetit <> "PDM"
        then do:
            vlfalta = vlfalta + vlpagar.
            message "Operacao nao permitida".
            pause.
            undo. 
        end.
        else if vmoetit = ""
             then vmoetit = vmoecod.

    if (btp-titulo.titpar >= 300 or
        vtotpar > 1) and
        vlfalta > 0 and
        not vdispensajuro
    then do:
        vlfalta = vlfalta + vlpagar.
        message "Operacao nao permitida".
        pause.
        undo. 
    end.

    if vlfalta <= 0 or
       vparcial or
       vdispensajuro then 
    vnpag = 1.  /* pagar titulo */
    
    if vmoecod = "REA" and vlfalta < 0  
    then do:
        vltroco = 0.
        repeat on error /*endkey*/ undo, retry:
            vltroco = -1 * vlfalta.
            disp vltroco label "Valor Troco R$" with frame f-pag3.
            pause.
            leave.
        end.

        if keyfunction(lastkey) = "END-ERROR"
        then undo.
        vlpagar = vlpagar - vltroco.
    end.
    leave. 
    end.
    if keyfunction(lastkey) = "END-ERROR"
    THEN UNDO.
    
    vretorna = no.
    
    run paga-titulo.
    
    if vretorna = yes 
    then do:
        vlfalta = vlfalta + vlpagar.
        undo.
    end.
    
    if vmoecod = "REA" and vlfalta < 0  
    then do:
        /*
        vltroco = -1 * vlfalta .
            
        disp vltroco label "Valor Troco R$" with frame f-pag3.
        pause.
        */
        leave.
    end. 
    else if vparcial
    then do:
        find first tit-gera no-error.
        if avail tit-gera
        then do:
            display tit-gera.titnum
                    tit-gera.titpar
                    tit-gera.titdtemi
                    tit-gera.titdtven
                    tit-gera.titvlcob
                    with frame fmos width 40 1 column
                               title " Titulo Gerado " overlay centered row 10.
            pause.
        end.                       
        leave.
    end. 
    else disp vlfalta  with frame f-pag2.

    down with frame f-pag2.

    vmoecod = "".

    if vlfalta = 0 or vparcial or vdispensajuro 
    then leave.
end.
/*
hide frame f-pag no-pause.
hide frame f-pag1 no-pause.
hide frame f-pag2 no-pause.
hide frame f-pag3 no-pause.
*/
/********** FIM TELA DE PAGAMENTO *********/

/* */
if keyfunction(lastkey) <> "END-ERROR"
then do:
    run bema-gaveta.p.
 
    find first tt-recib no-error.
    if avail tt-recib
    then do:
        scli = clien.clicod.
        run value(srecibo) (input tt-recib.rectit,
                            input tt-recib.titnum).
        scli = 0.
    end.
    for each tt-recib:
        delete tt-recib.
    end.
    
    /*** Promoção fique aqui ****/
    
    run fique-aqui.
        
    for each tit-sel: delete tit-sel. end. 
end.
/* */

hide frame f-pag  no-pause.
hide frame f-pag1 no-pause.
hide frame f-pag2 no-pause.
hide frame f-pag3 no-pause.
hide frame f-pag4 no-pause.
hide frame f-pag5 no-pause.


procedure paga-titulo:

    def var vmoepagtit  like moeda.moecod.
    def var vobspagtit  as char.

    v-cartao = no.
    if vmoecod = "CAR" or
       v-pro-recarga 
    then v-cartao = yes.

    i = 0.
    for each ttnovo.
        delete ttnovo.
    end.
    for each tt-recib.
        delete tt-recib.
    end.

    if v-cartao
    then v-valor-tef = vlpagar.
    else v-valor-tef = 0.
    
    repeat:

    if not v-venda and v-cartao
    then do:
        for each cupom-tit-pag.
            delete cupom-tit-pag.
        end.

        v-vok = yes.
/***
        if sprog-fiscal begins "nfce"
        then do.
            find plani where recid(plani) = p-recid no-lock.
            run pagpartef.p (plani.numero, output v-vok).
        end.
        else* if sprog-fiscal begins "bema"
        then***/ run pagpartef.p (0, output v-vok).
        if not v-vok    
        then vretorna = yes /*return*/.
    end.
    if vretorna then leave.

    if v-venda and v-cartao
    then do:
        if v-cartao and (sprog-fiscal begins "bema" or
                         sprog-fiscal begins "nfce")
        then do:
            find plani where recid(plani) = p-recid no-lock.

            for each cupom-tit-pag.
                delete cupom-tit-pag.
            end.
            hide message no-pause.
 
            if v-pro-recarga
            then do.
                v-valor-tef = plani.platot.

                if sprog-fiscal begins "bema"
                then run bemamfd.p (recid(plani),
                           "Numero",
                           "",  
                           output vecfnsq,  
                           output vecfcxa,
                           output vecfretorno,
                           yes).
                else if sprog-fiscal begins "nfce"
                then assign
                        vecfnsq = plani.numero
                        vecfcxa = plani.cxacod.

                if vecfnsq = 0 or
                   vecfcxa = 0
                then do.
                    message "Sem comunicao com a ECF (pagtit01)"
                            view-as alert-box.
                    vretorna = yes.
                end.
                if sprog-fiscal begins "bema"
                then do.
                    run ver-status-bema.p(output vecfretorno).
                    if vecfretorno = 0
                    then vecfnsq = vecfnsq + 1.
                end.
            end.
            else do.
                /* 
                Fase 1 = imprime cupom fiscal ate o subtotal
                */
                message "TEF - Fase 1 ... ".

                repeat:
                    if sprog-fiscal begins "bema"
                    then run bemamfd.p (recid(plani),
                           "FasE1",  
                           "",  
                           output vecfnsq,  
                           output vecfcxa,  
                           output vecfretorno,
                           yes).
                    else if sprog-fiscal begins "nfce"
                    then assign
                            vecfnsq = plani.numero
                            vecfcxa = plani.cxacod
                            vecfretorno = 1.
                           
                    if vecfretorno = -1
                    then next.
                    else if vecfnsq = 0
                    then do.
                        message color normal "Cupom NAO impresso".
                        do on endkey undo, retry:
                            pause 1 no-message.
                        end.
                        vretorna = yes.
                        leave.
                    end.
                    else leave. /* Fase 1 ok */
                end.
            end.

            repeat.
                vretorna = no.
                
                run pdvmoedas.p (recid(plani), 
                                 input vecfnsq,
                                 vcartparc).
            
                find first cupom-tit-pag no-lock no-error.
                if avail cupom-tit-pag
                then leave.
                else do.
                    sresp = yes.
                    vretorna = yes.
                    leave.
                end.
            end.
            v-cupom-emitido = yes.
        end. /* v-cartao */
        if vretorna
        then leave.
        
        if v-pro-recarga
        then do.
            if sprog-fiscal begins "bema"
            then run bemamfd.p (recid(plani), 
                       "Comprovante",
                       "",
                       output vcoo, 
                       output vcaixa, 
                       output vecfretorno, 
                       yes).
            assign
                vcaixa = vecfcxa.
        end.
        else do.
            /*
                Fase 2 = imprime pagtos, fim do cupom e comprovante de TEF
            */

            repeat.
                hide message no-pause.
                if sprog-fiscal begins "bema"
                then run bemamfd.p (recid(plani), 
                       "FasE2",  
                       "COO=" + string(vecfnsq) + 
                       "|CAIXA=" + string(vecfcxa), 
                       output vcoo, 
                       output vcaixa, 
                       output vecfretorno, 
                       yes).
                else if sprog-fiscal begins "nfce"
                then run nfce.p (recid(plani),
                        "Fase2",
                        "",
                        output vcoo,
                        output vcaixa,
                        output vecfretorno, 
                        no).
                if vecfretorno = 0
                then do:
                    /*
                    run contingencia_NFC-e.p(input recid(plani),
                                         output rec-plani,
                                         output vecfretorno).
                    
                    find plani where recid(plani) = rec-plani no-lock.
                    */
                    if vecfretorno = 0
                    then do:
                        vretorna = yes. /*return. */
                        leave.
                    end.
                end.    
                else if vecfretorno = -1
                then next.
                else leave. /* Fase 2 ok */
            end.
        end.
        
        /*
            Fase 3 - Comprovante de TEF
        */

        vok = no.
        for each cupom-tit-pag where cupom-tit-pag.tef no-lock.

            if (acha("ARCLI", cupom-tit-pag.tefretorno) <> ? and
                acha("ARCLI", cupom-tit-pag.tefretorno) <> "")
            then do.
                if search(acha("ARCLI", cupom-tit-pag.tefretorno)) <> ?
                then do.
                    vok = yes.
                    leave.
                end.
            end.
            if (acha("ARCAI", cupom-tit-pag.tefretorno) <> ? and
                acha("ARCAI", cupom-tit-pag.tefretorno) <> "")
            then do.
                if search(acha("ARCAI", cupom-tit-pag.tefretorno)) <> ?
                then do.
                    vok = yes.
                    leave.
                end.
            end.
        end.
        if vok
        then do.
            vcoo = vecfnsq.
            repeat.
                hide message no-pause.
                if sprog-fiscal begins "bema"
                then run bemamfd.p (recid(plani), 
                               (if v-pro-recarga then "FasE4" else "FasE3"),
                               "COO="      + string(vecfnsq) + 
                               "|RETORNO=" + string(vcaixa), 
                               output vcoo,  
                               output vcaixa,  
                               output vecfretorno, 
                               yes).
                else if sprog-fiscal begins "nfce"
                then run nfce.p (recid(plani), 
                               "FasE3",
                               "COO=" + string(vecfnsq),
                               output vcoo,  
                               output vcaixa,  
                               output vecfretorno, 
                               yes).
                if vecfretorno = 0
                then do:
                    vretorna = yes.
                    leave.
                end.    
                else if vecfretorno = -1
                then next.
                else leave. /* Fase 3 ok */
            end.
        end.
    end.
    if vretorna = yes
    then leave.

    vmoepagtit = vmoecod.
    if vmoecod = "CAR"
    then v-venda = no.
    
    find first cupom-tit-pag where cupom-tit-pag.tef no-lock no-error.
    vobspagtit = "".
    if avail cupom-tit-pag and vmoecod = "CAR"
    then do.
        vmoepagtit = acha("Moeda", cupom-tit-pag.tefretorno).
        if vmoepagtit = ?
        then vmoepagtit = vmoecod.
        if vcartparc > 0
        then vobspagtit = "PARCELASCARTAO=" + string(vcartparc).
    end.

    if vtotpar = 1
    then do transaction:
        find first titpag where
                       titpag.empcod = btp-titulo.empcod and
                       titpag.titnat = btp-titulo.titnat and
                       titpag.modcod = btp-titulo.modcod and
                       titpag.etbcod = btp-titulo.etbcod and
                       titpag.clifor = btp-titulo.clifor and
                       titpag.titnum = btp-titulo.titnum and
                       titpag.titpar = btp-titulo.titpar and
                       titpag.moecod = vmoepagtit
                       no-error.
        if not avail titpag
        then do:
            create titpag.
            assign
                titpag.empcod   = btp-titulo.empcod
                titpag.titnat   = btp-titulo.titnat
                titpag.modcod   = btp-titulo.modcod
                titpag.etbcod   = btp-titulo.etbcod
                titpag.clifor   = btp-titulo.clifor
                titpag.titnum   = btp-titulo.titnum
                titpag.titpar   = btp-titulo.titpar
                titpag.moecod   = vmoepagtit
                titpag.titvlpag = vlpagar
                titpag.cxacod   = scxacod
                titpag.cxmdata  = today
                titpag.cxmhora  = string(time)
                titpag.datexp   = today
                titpag.exportado = no.
                if vobspagtit <> ""
                then titpag.titobs[1] = vobspagtit.
            /***run meios-de-pagamento.***/
        end.
        else do:
            /*if titpag.titvlpag >= btp-titulo.titvlpag
            then.
            else */
            assign
                titpag.titvlpag = titpag.titvlpag + vlpagar
                titpag.cxacod   = scxacod
                titpag.cxmdata  = today
                titpag.cxmhora  = string(time)
                titpag.datexp   = today
                titpag.exportado = no.
                if vobspagtit <> ""
                then titpag.titobs[1] = vobspagtit.
            /***run meios-de-pagamento.***/
        end.
    end.    
    
    if vnpag = 1
    then do on error undo, return on endkey undo, retry:  /* bloquear F4 */
    
    for each wftit use-index ind-1:
        run pag-tp-titulo ("PAG").
        
        find first tp-titulo where recid(tp-titulo) = wftit.rec
                               and tp-titulo.titsit = "PAG".

        if vtotpar > 1
        then do transaction:
            find first titpag where
                       titpag.empcod = tp-titulo.empcod and
                       titpag.titnat = tp-titulo.titnat and
                       titpag.modcod = tp-titulo.modcod and
                       titpag.etbcod = tp-titulo.etbcod and
                       titpag.clifor = tp-titulo.clifor and
                       titpag.titnum = tp-titulo.titnum and
                       titpag.titpar = tp-titulo.titpar and
                       titpag.moecod = vmoepagtit
                       no-error.
            if not avail titpag
            then do:
                create titpag.
                assign
                titpag.empcod = tp-titulo.empcod
                titpag.titnat = tp-titulo.titnat
                titpag.modcod = tp-titulo.modcod
                titpag.etbcod = tp-titulo.etbcod
                titpag.clifor = tp-titulo.clifor
                titpag.titnum = tp-titulo.titnum
                titpag.titpar = tp-titulo.titpar
                titpag.moecod = vmoepagtit
                titpag.titvlpag = tp-titulo.titvlpag
                titpag.cxacod = scxacod
                titpag.cxmdata = today
                titpag.cxmhora = string(time)
                titpag.datexp  = today
                titpag.exportado = no.
                if vobspagtit <> ""
                then titpag.titobs[1] = vobspagtit.
                /***run meios-de-pagamento.***/
            end.
            else do:
                if titpag.titvlpag >= tp-titulo.titvlpag
                then.
                else 
                assign
                titpag.titvlpag = titpag.titvlpag + tp-titulo.titvlpag
                titpag.cxacod = scxacod
                titpag.cxmdata = today
                titpag.cxmhora = string(time)
                titpag.datexp  = today
                titpag.exportado = no.
                if vobspagtit <> ""
                then titpag.titobs[1] = vobspagtit.
                /***run meios-de-pagamento.***/
             end.
        end.
        
        repeat on endkey undo,retry transaction:
            find titulo where titulo.empcod = tp-titulo.empcod
                                  and titulo.titnat = tp-titulo.titnat
                                  and titulo.modcod = tp-titulo.modcod
                                  and titulo.clifor = tp-titulo.clifor
                                  and titulo.etbcod = tp-titulo.etbcod
                                  and titulo.titnum = tp-titulo.titnum
                                  and titulo.titpar = tp-titulo.titpar
                                  no-error.
            if avail titulo 
            then do: 
                if titulo.titsit = "LIB"
                then
                    assign 
                        titulo.titsit   = tp-titulo.titsit
                        titulo.moecod   = tp-titulo.moecod
                        titulo.titdtpag = today
                        titulo.titvlpag = tp-titulo.titvlpag
                        titulo.titvlcob = tp-titulo.titvlcob 
                        titulo.titvldes = tp-titulo.titvldes
                        titulo.titjuro  = tp-titulo.titjuro 
                        titulo.titvljur = tp-titulo.titvljur 
                        titulo.cxacod   = tp-titulo.cxacod 
                        titulo.cxmdata  = tp-titulo.cxmdata 
                        titulo.cxmhora  = tp-titulo.cxmhora
                        titulo.etbcobra = tp-titulo.etbcobra 
                        titulo.datexp   = tp-titulo.datexp
                        titulo.titobs[1]   = tp-titulo.titobs[1].
            end. 
            else do :
                create titulo. 
                assign
                    titulo.empcod   = tp-titulo.empcod
                    titulo.moecod   = tp-titulo.moecod
                    titulo.modcod   = tp-titulo.modcod
                    titulo.clifor   = tp-titulo.clifor
                    titulo.titnum   = tp-titulo.titnum
                    titulo.titpar   = tp-titulo.titpar
                    titulo.titsit   = tp-titulo.titsit
                    titulo.titnat   = tp-titulo.titnat
                    titulo.etbcod   = tp-titulo.etbcod
                    titulo.titdtemi = tp-titulo.titdtemi
                    titulo.titdtven = tp-titulo.titdtven
                    titulo.titdtpag = today
                    titulo.titvlcob = tp-titulo.titvlcob
                    titulo.cobcod   = tp-titulo.cobcod
                    titulo.titvlpag = tp-titulo.titvlpag
                    titulo.titvljur = tp-titulo.titvljur
                    titulo.titvldes = tp-titulo.titvldes
                    titulo.etbcobra = tp-titulo.etbcobra
                    titulo.titjuro  = tp-titulo.titjuro
                    titulo.cxacod   = tp-titulo.cxacod
                    titulo.cxmdata  = tp-titulo.cxmdata
                    titulo.cxmhora  = tp-titulo.cxmhora
                    titulo.datexp   = tp-titulo.datexp
                    titulo.titobs[1] = tp-titulo.titobs[1].
            end. 
            vtotliq   = vtotliq - titulo.titvlpag.
            vtitvlpag = vtitvlpag - titulo.titvlpag.
            
            sresp = yes.
    
            if caixa.moecod = "bar"    
            then do:
                find first tt-recib where 
                     tt-recib.titnum = tp-titulo.titnum  and
                     tt-recib.ordpre = wftit.ord no-error. 
                if not avail tt-recib and   
                   tp-titulo.titpar <> 0  
                then do:  
                    find first tt-recib where 
                            tt-recib.rectit = recid(tp-titulo)
                            no-error.
                    if not avail tt-recib
                    then create tt-recib. 
                    assign tt-recib.rectit = recid(tp-titulo) 
                        tt-recib.titnum = tp-titulo.titnum 
                        tt-recib.ordpre = wftit.ord.
                end.  
            end.  
            else
                run recibb4.p (input (recid(tp-titulo)),
                               input scxacod).
        
            assign sresp = yes.
            leave.
        end. 
        if vparcial
        then do:
            de-vltit = vlfalta /*vtotliq - vlpagar*/.
            run gera-novo-titulo.
        end.

        if moeda.moecod = "PRE" or
           moeda.moecod = "CHP" or
           moeda.moecod = "CHV" 
        then do: 
            create ttnovo. 
            ttnovo.rec = recid(titulo) .
        end.
        delete wftit.
    end.
    
    for each tp-titulo where tp-titulo.titsit   = "PAG"
                         and tp-titulo.titdtpag = today
                       by tp-titulo.titvlpag desc:

        if vtotliq > 0 and
           vparcial = no and
           vdispensajuro = no
        then do:
            if tp-titulo.titjuro <= vtotliq
            then assign vtotliq = vtotliq - tp-titulo.titjuro
                    tp-titulo.titjuro = 0
                    tp-titulo.titvlpag = tp-titulo.titvlcob.
            else assign tp-titulo.titjuro = tp-titulo.titjuro - vtotliq
                    tp-titulo.titvlpag = tp-titulo.titvlcob +
                                         tp-titulo.titjuro
                    vtotliq = 0.
   
            find titulo where titulo.empcod = tp-titulo.empcod
                                  and titulo.titnat = tp-titulo.titnat
                                  and titulo.modcod = tp-titulo.modcod
                                  and titulo.clifor = tp-titulo.clifor
                                  and titulo.etbcod = tp-titulo.etbcod
                                  and titulo.titnum = tp-titulo.titnum
                                  and titulo.titpar = tp-titulo.titpar
                                  use-index titnum no-error.
            if avail titulo 
            then do transaction:
                assign titulo.titsit   = tp-titulo.titsit
                   titulo.titdtpag = tp-titulo.titdtpag
                   titulo.titvlpag = tp-titulo.titvlpag
                   titulo.titvlcob = tp-titulo.titvlcob 
                   titulo.titjuro  = tp-titulo.titjuro 
                   titulo.titvljur = tp-titulo.titvljur 
                   titulo.cxacod   = tp-titulo.cxacod 
                   titulo.cxmdata  = tp-titulo.cxmdata 
                   titulo.cxmhora  = tp-titulo.cxmhora
                   titulo.etbcobra = tp-titulo.etbcobra 
                   titulo.datexp   = tp-titulo.datexp
                   titulo.titobs[1] = "CPD/" 
                            + string(titulo.titdtpag,"99/99/9999").
            end. 
        end.
    
        if tp-titulo.titobs[1] <> "" and tp-titulo.modcod = "CHQ"
        then do:
            if acha("CHENUM",tp-titulo.titobs[1]) = ? then next.
            if acha("CHEAGE",tp-titulo.titobs[1]) = ? then next. 
            if acha("CHEBAN",tp-titulo.titobs[1]) = ? then next.

            find fin.cheque where 
                 fin.cheque.chenum = int(acha("CHENUM",tp-titulo.titobs[1]))
                and fin.cheque.cheage = int(acha("CHEAGE",tp-titulo.titobs[1]))
                and fin.cheque.cheban = int(acha("CHEBAN",tp-titulo.titobs[1]))
                                 no-error.
            if not avail fin.cheque
            then do transaction:
                create fin.cheque.

                if acha("CHEAGE",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.cheage  = int(acha("CHEAGE",tp-titulo.titobs[1])).
               
                if acha("CHEALIN",tp-titulo.titobs[1]) <> ?
                then 
                fin.cheque.chealin = int(acha("CHEALIN",tp-titulo.titobs[1])).
               
                if acha("CHEBAN",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.cheban  = int(acha("CHEBAN",tp-titulo.titobs[1])).

                if acha("CHECID",tp-titulo.titobs[1]) <> ?
                then
                fin.cheque.checid = string(acha("CHECID",tp-titulo.titobs[1])).
                  
                if acha("CHEDTF",tp-titulo.titobs[1]) <> ?
                then 
                fin.cheque.chedtf  = date(acha("CHEDTF",tp-titulo.titobs[1])).
                  
                if acha("CHEDTI",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.chedti  = date(acha("CHEDTI",tp-titulo.titobs[1])).
                  
                if acha("CHEEMI",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.cheemi  = date(acha("CHEEMI",tp-titulo.titobs[1])).
                  
                if acha("CHEETB",tp-titulo.titobs[1]) <> ?
                then 
                fin.cheque.cheetb  = int(acha("CHEETB",tp-titulo.titobs[1])).
                 
                if acha("CHEJUR",tp-titulo.titobs[1]) <> ? 
                then  fin.cheque.chejur  = tp-titulo.titjuro.
        
                if acha("CHENUM",tp-titulo.titobs[1]) <> ?
                then 
                fin.cheque.chenum  = int(acha("CHENUM",tp-titulo.titobs[1])).
               
                if acha("CHEPAG",tp-titulo.titobs[1]) <> ? 
                then fin.cheque.chepag  = today.
                  
                if acha("CHESIT",tp-titulo.titobs[1]) <> ?
                then fin.cheque.chesit  = "PAG".
                  
                if acha("CHEVAL",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.cheval  = dec(acha("CHEVAL",tp-titulo.titobs[1])).
                  
                if acha("CHEVEN",tp-titulo.titobs[1]) <> ?
                then 
                fin.cheque.cheven  = date(acha("CHEVEN",tp-titulo.titobs[1])).
                  
                if acha("CLICOD",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.clicod  = int(acha("CLICOD",tp-titulo.titobs[1])).
                  
                if acha("CODCOB",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.codcob  = int(acha("CODCOB",tp-titulo.titobs[1])).
               
                if acha("NOME",tp-titulo.titobs[1]) <> ? 
                then 
                fin.cheque.nome    = (acha("NOME",tp-titulo.titobs[1])).
        
                output to /usr/admcom/work/cheque_dev.pag append.
                    put scxacod " "
                    fin.cheque.chepag format "99/99/9999" " "
                    fin.cheque.cheval skip.
                output close.
            end.
        end.
    end.
    end. 
    
    find first ttnovo no-error.
    if avail ttnovo
    THEN DO:
         for each tt-che. delete tt-che. end.
     
         run dig_chq.p(input vlpagar /*vtitvlpag*/,
                   input vtitdtpag).

         /*Criando todos os chqs*/
        for each tt-che.
            find first chq where chq.banco = int(tt-che.banco)
                         and chq.agencia = int(tt-che.agencia)
                         and chq.conta = tt-che.conta
                         and chq.numero = tt-che.numero no-error.
            if not avail chq
            then do :
                create chq.
                assign chq.numero    = tt-che.numero
                   chq.banco     = int(tt-che.banco)
                   chq.agencia   = int(tt-che.agencia)
                   chq.controle1 = tt-che.controle1
                   chq.controle2 = tt-che.controle2
                   chq.controle3 = tt-che.controle3
                   chq.conta     = tt-che.conta
                   chq.datemi    = today
                   chq.comp      = int(tt-che.comp)
                   chq.valor     = tt-che.valor
                   chq.data      = tt-che.dataven.
            end.

            for each ttnovo where ttnovo.rec <> 0:
        
                find first titulo where 
                        recid(titulo) = ttnovo.rec no-lock no-error.
                if avail titulo
                then do:
               /****** VERIFICANDO SE JA TEM RELACAO TITULO COM CHEQUE ********/
                    find chqtit where chqtit.titnat  = titulo.titnat
                             and chqtit.etbcod  = setbcod
                             and chqtit.modcod  = titulo.modcod
                             and chqtit.clifor  = titulo.clifor
                             and chqtit.titnum  = titulo.titnum
                             and chqtit.titpar  = titulo.titpar
                             and chqtit.banco   = chq.banco
                             and chqtit.agencia = chq.agencia
                             and chqtit.conta   = chq.conta
                             and chqtit.numero  = chq.numero 
                             no-lock no-error.
                    if not avail chqtit
                    then do:
                        create chqtit.
                        assign chqtit.titnat  = titulo.titnat 
                          chqtit.modcod  = titulo.modcod 
                          chqtit.etbcod  = setbcod 
                          chqtit.clifor  = titulo.clifor 
                          chqtit.titpar  = titulo.titpar 
                          chqtit.titnum  = titulo.titnum 
                          chqtit.banco   = chq.banco 
                          chqtit.agencia = chq.agencia 
                          chqtit.conta   = chq.conta 
                          chqtit.numero  = chq.numero.
                    end.
                end.
            end.
     
        end.

     /*** Imprimindo ***/
        sresp = no.
        message "Deseja imprimir os cheques ?" update sresp.
     
        if sresp
        then do:
            for each tt-che break by tt-che.dataven by tt-che.numero:
                find first chq where chq.banco   = int(tt-che.banco)
                         and chq.agencia = int(tt-che.agencia)
                         and chq.conta   = tt-che.conta
                         and chq.numero  = tt-che.numero no-lock no-error.
                if not avail chq then next.
                
                disp chq.numero chq.data chq.valor
                    with frame f-impche centered 5 down overlay row 6
                        title " Emissao dos Cheques ".
                down with frame f-impche.
        
     
                display "Coloque o Cheque numero "
                    chq.numero
                   " na Impressora e tecle ENTER"
                    with frame f-mens centered no-label overlay row 15. pause.

                run impcheq.p (input chq.valor,
                       input chq.data).

            end.                       
        end.
    end.
    leave.
    end.
    
end procedure.

procedure pag-tp-titulo:
    def input parameter p-tipo as char.
    
    vv = 0.
    
    find first tp-titulo where recid(tp-titulo) = wftit.rec
                           and tp-titulo.titsit = "LIB" no-error.
    if avail tp-titulo 
    then do:                       
        assign
           tp-titulo.titdtpag = vtitdtpag
           tp-titulo.etbcobra = setbcod
           tp-titulo.datexp   = today
           tp-titulo.cxmdata  = today
           tp-titulo.cxmhora  = string(time)
           tp-titulo.cxacod   = scxacod .

        if tp-titulo.titdtpag > tp-titulo.titdtven and
            /*vdispensajuro = no and*/
           vparcial = no
        then do:
            ljuros = yes.
            if tp-titulo.titdtpag - tp-titulo.titdtven = 3
            then do:
                find dtextra where exdata = tp-titulo.titdtpag - 3
                             NO-LOCK no-error.
                if weekday(tp-titulo.titdtpag - 3) = 1 or avail dtextra
                then do:
                find dtextra where exdata = tp-titulo.titdtpag - 1
                             NO-LOCK no-error.
                if weekday(tp-titulo.titdtpag - 1) = 1 or avail dtextra
                then ljuros = no.
                end.
            end.
         
            if tp-titulo.titdtpag - tp-titulo.titdtven = 2
            then do:
                find dtextra where exdata = tp-titulo.titdtpag - 2
                             NO-LOCK no-error.
                if weekday(tp-titulo.titdtpag - 2) = 1 or avail dtextra
                then do:
                find dtextra where exdata = tp-titulo.titdtpag - 1
                             NO-LOCK no-error.
                if weekday(tp-titulo.titdtpag - 1) = 1 or avail dtextra
                then ljuros = no.
                end.
            end.
            else do:
                if tp-titulo.titdtpag - tp-titulo.titdtven = 1
                then do:
                    find dtextra where exdata = tp-titulo.titdtpag - 1
                             NO-LOCK no-error.
                    if weekday(tp-titulo.titdtpag - 1) = 1 or avail dtextra
                    then ljuros = no.
                end.
            end.
            vnumdia = if not ljuros
                  then 0
                  else tp-titulo.titdtpag - tp-titulo.titdtven.

            find tabjur where tabjur.nrdias = vnumdia no-lock no-error.
            if not avail tabjur
            then do:
                message "Fator para" vnumdia "dias de atraso, nao cadastrado".
                pause.
                undo.
            end.
            else assign 
                tp-titulo.titvlpag = (tp-titulo.titvlcob * tabjur.fator)
                tp-titulo.titjuro = tp-titulo.titvlpag - tp-titulo.titvlcob.

            if vdispensajuro
            then do:
                if tp-titulo.titjuro > vjuro-d
                then assign
                         tp-titulo.titvlpag = tp-titulo.titvlpag - vjuro-d
                         tp-titulo.titjuro = 
                                tp-titulo.titvlpag - tp-titulo.titvlcob
                         vjuro-d = 0.
                
                else if tp-titulo.titjuro > 0
                then assign
                        vjuro-d = vjuro-d - tp-titulo.titjuro
                        tp-titulo.titjuro = 0
                        tp-titulo.titvlpag = tp-titulo.titvlcob.
            end.

            if ljuros
            then do: 
                /*******/
                vv = ( (int(tp-titulo.titvlpag) -  tp-titulo.titvlpag) )  - 
                    round(( (int(tp-titulo.titvlpag) - 
                            (tp-titulo.titvlpag)) ),1).
                if vv < 0  
                then vv = 0.10 - (vv * -1).

                tp-titulo.titvlpag = tp-titulo.titvlpag + vv.
                tp-titulo.titjuro  =  tp-titulo.titvlpag - tp-titulo.titvlcob.
                /*******/
                
                /***
                run arredonda-parcela.
                ***/
            end. 
        end.
        else do:
            /*if vdispensajuro
            then do:
                assign
                    tp-titulo.titvlpag = vlpagar
                    tp-titulo.titjuro = 
                            tp-titulo.titvlpag - tp-titulo.titvlcob.
            end.
            else*/ if vparcial
            then tp-titulo.titvlpag = vlpagar.
            else tp-titulo.titvlpag = tp-titulo.titvlcob.
        end.

        if p-tipo = "PAG"
        then assign vtitvlpag = vtitvlpag + tp-titulo.titvlpag
               vtitvlcob = vtitvlcob + tp-titulo.titvlcob
               tp-titulo.etbcobra = setbcod
               tp-titulo.datexp   = today
               tp-titulo.cxmdata  = today
               tp-titulo.cxmhora  = string(time)
               tp-titulo.cxacod   = scxacod
               tp-titulo.moecod   = vmoetit
               tp-titulo.titdtpag = vtitdtpag
               tp-titulo.cobcod   = if tp-titulo.cobcod <> 10 then 2 else 10
               tp-titulo.titsit   = "PAG".
        else do:
            find first tt-titpag where
                           tt-titpag.titnum = tp-titulo.titnum 
                       and tt-titpag.titpar = tp-titulo.titpar 
                       no-error.
            if not avail tt-titpag
            then do:
                create tt-titpag.
                assign
                    tt-titpag.titnum = tp-titulo.titnum
                    tt-titpag.titpar = tp-titulo.titpar
                    tt-titpag.titvlcob = tp-titulo.titvlcob
                    tt-titpag.titjuro  = tp-titulo.titjuro.
            end. 
            assign
                 vtitvlpag = vtitvlpag + tp-titulo.titvlpag
                 vtitvlcob = vtitvlcob + tp-titulo.titvlcob
                 tp-titulo.titvlpag = 0
                 tp-titulo.titjuro = 0.             
        end.

    end.
end procedure.

procedure gera-novo-titulo:

    def var vtitpar like titulo.titpar.
    def buffer ltitulo for titulo.
            find last btp-titulo use-index titnum where 
                      btp-titulo.empcod   = 19             and
                      btp-titulo.titnat   = no   and
                      btp-titulo.modcod   = "CRE"          and
                      btp-titulo.etbcod   = tp-titulo.etbcod  and
                      btp-titulo.clifor   = vclicod        and
                      btp-titulo.titnum   = tp-titulo.titnum
                      no-error.
            if avail btp-titulo
            then vtitpar = btp-titulo.titpar + 1. 

            find last titulo use-index titnum where 
                      titulo.empcod   = 19             and
                      titulo.titnat   = no   and
                      titulo.modcod   = "CRE"          and
                      titulo.etbcod   = tp-titulo.etbcod  and
                      titulo.clifor   = vclicod        and
                      titulo.titnum   = tp-titulo.titnum
                      no-error.
            if avail titulo and titulo.titpar > btp-titulo.titpar 
            then vtitpar = titulo.titpar + 1. 

            do transaction:
            create ctp-titulo.
            assign ctp-titulo.empcod = btp-titulo.empcod
                                ctp-titulo.cxacod = scxacod
                                ctp-titulo.titnat = btp-titulo.titnat
                                ctp-titulo.modcod = btp-titulo.modcod
                                ctp-titulo.etbcod = btp-titulo.etbcod
                                ctp-titulo.clifor = btp-titulo.clifor
                                ctp-titulo.titnum = btp-titulo.titnum
                                ctp-titulo.titpar = vtitpar
                                ctp-titulo.cobcod = btp-titulo.cobcod
                                ctp-titulo.titsit = "LIB"
                                ctp-titulo.titdtemi = tp-titulo.titdtemi
                                ctp-titulo.titdtven = tp-titulo.titdtven
                                ctp-titulo.datexp   = today
                                ctp-titulo.titvlcob = de-vltit
                                ctp-titulo.titnumger = btp-titulo.titnum
                                ctp-titulo.titparger = btp-titulo.titpar.
                                
            create ltitulo.
            {tt-titulo.i ltitulo ctp-titulo}
            create tit-gera.
            buffer-copy ltitulo to tit-gera.
            
            end.
end procedure.

procedure dispensa-de-juros:
    def var val-p as dec.
    def var val-j as dec.

    val-p = 0. val-j = 0.    
    /*
    for each tp-titulo:
        assign
            val-p = val-p + tp-titulo.titvlcob
            val-j = val-j + tp-titulo.titvljur.
    end.    
    */
    def var par-ok as log.
                       assign svalor3   = val-j
                              sautoriza = "Dispensa de Juros"
                              scliaut   = btp-titulo.clifor.
                       display skip(1) " Dispensando Pagamento de Juros "
                               skip(1) with frame fpend overlay
                               centered color white/red row 9 .
                       /*display tp-titulo.titvlcob tp-titulo.titjuro
                               vtitvlpag label "Valor a Pagar"
                               with overlay row 14 centered color white/yelow
                               title " JUROS DISPENSADOS " frame fdeve.
                       */
                       /*
                       run senha.p (output par-ok).
                       */
                       /*hide frame fpend no-pause.
                       hide frame fdeve no-pause.
                       */
                       sresp = no.
            
            run senha-aut.p(output sresp, yes, yes, no, no, 0, 0, 0, 12 ).
    
            svalor3 = 0.
                       
            if not sresp 
            then vdispensajuro = no.
            else vjuro-d = vlfalta .

end procedure.

procedure arredonda-parcela.
        
        def var v1 as dec.
        
        v1 = dec(substr(string(tp-titulo.titvlpag,">>>>>>>>>>>>9.99"),15,2))
            / 100.
        
        if int(substr(string(v1),3,1)) <> 0 and
           int(substr(string(v1),3,1)) <> 5
        then do:   
            if int(substr(string(v1),3,1)) < 5
            then tp-titulo.titvlpag = tp-titulo.titvlpag +
                ((5 - int(substr(string(v1),3,1))) / 100).
            else if int(substr(string(v1),3,1)) < 10
            then tp-titulo.titvlpag = tp-titulo.titvlpag +
                ((10 - int(substr(string(v1),3,1))) / 100).
     
        end.

end procedure.

def var dt-validade as date.
def var vl-bonus as dec.

procedure fique-aqui:
    def var varquivo as char.

    hide frame fpag1 no-pause.
    if vultpag  and
        (   setbcod = 01 or
           setbcod = 02 or
            setbcod = 03 or
          setbcod = 04 or 
            setbcod = 05 or
            setbcod = 06 or
         setbcod = 07 or
            setbcod = 08 or
         setbcod = 09 or
          setbcod = 10 or
         setbcod = 11 or
            setbcod = 12 or
            setbcod = 13 or
            setbcod = 14 or
            setbcod = 15 or
        setbcod = 16 or
            setbcod = 17 or
        setbcod = 18 or
        setbcod = 19 or
            setbcod = 20 or
            setbcod = 21 or
        setbcod = 23 or
            setbcod = 24 or
            setbcod = 25 or
            setbcod = 26 or
            setbcod = 27 or
         setbcod = 28 or
            setbcod = 29 or
         setbcod = 30 or
            setbcod = 31 or
            setbcod = 32 or
            setbcod = 33 or
        setbcod = 34 or
        setbcod = 35 or
        setbcod = 36 or
        setbcod = 37 or
            setbcod = 38 or
            setbcod = 39 or
            setbcod = 40 or
          setbcod = 41 or
          setbcod = 42 or
          setbcod = 43 or
          setbcod = 44 or
            setbcod = 45 or
            setbcod = 46 or
          setbcod = 47 or
            setbcod = 48 or
            setbcod = 49 or
            setbcod = 50 or
            setbcod = 51 or
            setbcod = 52 or
            setbcod = 53 or
          setbcod = 54 or
          setbcod = 55 or
            setbcod = 56 or
            setbcod = 57 or
          setbcod = 58 or
            setbcod = 59 or
            setbcod = 60 or
            setbcod = 61 or
            setbcod = 62 or
          setbcod = 63 or
            setbcod = 64 or
            setbcod = 65 or
          setbcod = 66 or
          setbcod = 67 or
            setbcod = 68 or
            setbcod = 69 or
            setbcod = 70 or
          setbcod = 71 or
            setbcod = 72 or
            setbcod = 73 or
            setbcod = 74 or
            setbcod = 75 or
          setbcod = 76 or
            setbcod = 77 or
            setbcod = 78 or
            setbcod = 79 or
            setbcod = 80 or
            setbcod = 81 or
            setbcod = 82 or
            setbcod = 83 or
            setbcod = 84 or
            setbcod = 85 or
            setbcod = 86 or
            setbcod = 87 or
            setbcod = 88 or
            setbcod = 89 or
            setbcod = 90 or
         setbcod = 91 or
         setbcod = 92 or
            setbcod = 93 or
            setbcod = 94 or
            setbcod = 95 or
            setbcod = 96 or
            setbcod = 97 or
            setbcod = 98 or
            setbcod = 99 or  
            setbcod = 100 or
            setbcod = 101 or
            setbcod = 102 or
            setbcod = 103 or
            setbcod = 104 or
            setbcod = 105 or
            setbcod = 106 or        
            setbcod = 108 or 
            setbcod = 109 or
            setbcod = 110 or
            setbcod = 111 or
            setbcod = 112 or
            setbcod = 113 or
            setbcod = 114 or
            setbcod = 115 or
            setbcod = 116 or
            setbcod = 117 or
            setbcod = 118 or
            setbcod = 119 or
            setbcod = 120 or
            setbcod = 121 or
            setbcod = 122 or
            setbcod = 123 or
            setbcod = 124 or
            setbcod = 125 or
            setbcod = 126 or
            setbcod = 127 or
            setbcod = 128 or        
            setbcod = 129 or
            setbcod = 130 or
            setbcod = 131 or                         
            setbcod = 189)
    then do:
        for each tit-sel no-lock:
          
            find first tp-titulo where recid(tp-titulo) = tit-sel.rec
                           and tp-titulo.titsit = "LIB"
                           no-error.
            if not avail tp-titulo 
            then next  .                  
            find clien where clien.clicod = tp-titulo.clifor no-lock.
            if avail clien and clien.clicod = 1
            then vultpag = no.
            if tp-titulo.titdtven - tp-titulo.titdtemi > 30
            then vultpag = no.
        end.

        /*Chamado 39771 Nede - 27/03/2012*/
        /*Pago até 3 parcelas não gerar Bonus Fique Aqui*/
        /*Bloqueado por Claudir Corretiva 136631*/
        /**if vtotpar <= 3
        then vultpag = no.
        else vultpag = yes.
        **/

        if vultpag = yes
        then do:
            message color red/with
            SKIP
            "CLIENTE TODO LIMITE DE CREDITO LIBERADO" SKIP
            /*"ENCAMINHAR VENDEDOR ENTREGAR VALE BRINDE"*/
            "ENTREGAR CUPOM BONUS QUE SERA IMPRESSO A SEGUIR"
            SKIP
            view-as alert-box title " ATENCAO " .

            find first tt-clien where tt-clien.clicod > 0 no-error.
    
            /**
            v-comando = "./fiscal " + sporta-ecf + 
                " ultcpag.txt" + " 25 01 " +  " VALE BRINDE ".
                                          
            os-command silent value(v-comando). 
            **/
        
            dt-validade =  
                date(if month(today) = 12 then 01 else month(today) + 1,
                     01,
                     if month(today) = 12 then
                            int(string(year(today),"9999")) + 1  else
                            int(string(year(today),"9999"))) - 1
                            .
            vl-bonus = 12.                
            run gera-bonus-fique-aqui.
            
            varquivo = "/usr/admcom/spool/" + "valebrinde" + string(time).
    
            output to value(varquivo).
            put chr(29) + chr(33) + chr(0) skip  /* tamanho da fonte */
                chr(27) + chr(97) + chr(49) skip  /* centraliza */
                chr(27) + chr(51) + chr(25) skip  /* espaco 1/6 entre linhas */
                chr(27) + "!" + chr(48) skip
                "Lojas Lebes" skip
                chr(27) + chr(97) + chr(49) skip  /* centraliza */
                chr(27) + "!" + chr(8)
                trim(estab.endereco + " " + estab.munic) format "x(40)" skip.
                if setbcod = 1000 
                then put skip(1)
                "========================================" skip
                "========================================" today skip.
                put
                "========================================" skip 
                "       FALE COM SEU CONSULTOR " skip 
                "========================================" skip(1)
                "BONUS DE R$12,00(doze reais)............" skip
                "Para ser usado na compra de qualquer " skip
                "produto da loja ate " 
                string(dt-validade,"99/99/9999") format "x(10)"
                ".........." skip
                "Cliente : " tt-clien.clinom format "x(30)" skip
                "Codigo  : " tt-clien.clicod format ">>>>>>>9"  skip(1)
                "    ----------------------------------  " skip
                "                Assinatura " 
                chr(10) skip  /* line feed */
                chr(29) + chr(86) + chr(66) skip.      /* corta */ 
    
            output close.

            if scarne = "local"
            then unix silent /fiscal/lp value(varquivo).
            else unix silent /fiscal/lp value(varquivo) 1.
        end.
    end.
end procedure.

/**   FIQUE AQUI ATÉ 31/05/2011
procedure fique-aqui:
def var varquivo as char.
hide frame fpag1 no-pause.
if vultpag and
  (  setbcod = 01 or
     setbcod = 02 or
     setbcod = 03 or
     setbcod = 04 or
     setbcod = 05 or
   setbcod = 06 or
     setbcod = 07 or
     setbcod = 08 or
   setbcod = 09 or
   setbcod = 10 or
     setbcod = 11 or
     setbcod = 12 or
   setbcod = 13 or
     setbcod = 14 or
   setbcod = 15 or
     setbcod = 16 or
     setbcod = 17 or
     setbcod = 18 or
     setbcod = 19 or
   setbcod = 20 or
     setbcod = 21 or
     setbcod = 23 or
     setbcod = 24 or
     setbcod = 25 or
     setbcod = 26 or
     setbcod = 27 or
     setbcod = 28 or
     setbcod = 29 or
     setbcod = 30 or
     setbcod = 31 or
     setbcod = 32 or
     setbcod = 33 or
     setbcod = 34 or
     setbcod = 35 or
     setbcod = 36 or
     setbcod = 37 or
     setbcod = 38 or
     setbcod = 39 or
     setbcod = 40 or
     setbcod = 41 or
     setbcod = 42 or
     setbcod = 43 or
     setbcod = 44 or
   setbcod = 45 or
     setbcod = 46 or
     setbcod = 47 or
     setbcod = 48 or
     setbcod = 49 or
     setbcod = 50 or
     setbcod = 51 or
   setbcod = 52 or
     setbcod = 53 or
     setbcod = 54 or
     setbcod = 55 or
     setbcod = 56 or
     setbcod = 57 or
     setbcod = 58 or
     setbcod = 59 or
     setbcod = 60 or
     setbcod = 61 or
     setbcod = 62 or
     setbcod = 63 or
   setbcod = 64 or
     setbcod = 65 or
     setbcod = 66 or
     setbcod = 67 or
     setbcod = 68 or
   setbcod = 69 or
     setbcod = 70 or
     setbcod = 71 or
     setbcod = 72 or
     setbcod = 73 or
     setbcod = 74 or
   setbcod = 75 or
   setbcod = 76 or
   setbcod = 77 or
   setbcod = 78 or
     setbcod = 79 or
   setbcod = 80 or
     setbcod = 81 or
     setbcod = 82 or
     setbcod = 83 or
   setbcod = 84 or
   setbcod = 85 or
   setbcod = 86 or
     setbcod = 87 or
     setbcod = 88 or
     setbcod = 89 or
     setbcod = 90 or
   setbcod = 91 or   
     setbcod = 92 or
     setbcod = 93 or
   setbcod = 94 or
     setbcod = 95 or
   setbcod = 96 or
   setbcod = 97 or
     setbcod = 98 or
   setbcod = 99 or
   setbcod = 100 or
   setbcod = 101 or
    setbcod = 102 or
   setbcod = 103 or
   setbcod = 104 or
   setbcod = 105 or
     setbcod = 106 or
   setbcod = 108 or
     setbcod = 109 or
        setbcod = 110 or
        setbcod = 111 or
     setbcod = 112 or
        setbcod = 113 or
        setbcod = 114 or
        setbcod = 115 or
        setbcod = 116 or
     setbcod = 117 or
        setbcod = 118 or        
     setbcod = 119 or
        setbcod = 120 or
     setbcod = 121 or
     setbcod = 122 or
     setbcod = 123 or
     setbcod = 124 or
     setbcod = 125 or
     setbcod = 126 or
     setbcod = 127 or
     setbcod = 128 or
     setbcod = 129 or
     setbcod = 130 or
     setbcod = 131 or                
     setbcod = 189)
then do:
    for each wftit no-lock:
        find first tp-titulo where recid(tp-titulo) = wftit.rec
                           and tp-titulo.titsit = "LIB"
                           no-error.
        if not avail tp-titulo 
        then next  .                  
        find clien where clien.clicod = tp-titulo.clifor no-lock.
        if avail clien and clien.clicod = 1
        then vultpag = no.
        if tp-titulo.titdtven - tp-titulo.titdtemi > 30
        then vultpag = no.
    end.
    if vultpag = yes
    then do:
        message color red/with
        SKIP
        "CLIENTE TODO LIMITE DE CREDITO LIBERADO," SKIP
        "ENCAMINHAR VENDEDOR ENTREGAR VALE BRINDE"
        SKIP
        view-as alert-box title " ATENCAO " .

        find first tt-clien where tt-clien.clicod > 0 no-error.

        /**
        v-comando = "./fiscal " + sporta-ecf + " ultcpag.txt" + " 25 01 " + 
                " VALE BRINDE ".
                                          
        os-command silent value(v-comando). 
        **/
        
        varquivo = "/usr/admcom/spool/" + "valebrinde" + string(time).
    
        output to value(varquivo).
        put chr(29) + chr(33) + chr(0) skip  /* tamanho da fonte */
            chr(27) + chr(97) + chr(49) skip  /* centraliza */
            chr(27) + chr(51) + chr(25) skip  /* espaco 1/6 entre linhas */
            chr(27) + "!" + chr(48) skip
            "Lojas Lebes" skip
            chr(27) + chr(97) + chr(49) skip  /* centraliza */
            chr(27) + "!" + chr(8)
            trim(estab.endereco + " " + estab.munic) format "x(40)" skip.
            if setbcod = 1000 
            then put skip(1)
            "========================================" skip
            "========================================" today skip.
            put
            "========================================" skip 
            "       FALE COM SEU CONSULTOR " skip 
            "========================================" skip
            /*chr(27) + chr(50) skip*/  /* espaco entre linhas padrao */
            chr(27) + chr(97) + chr(48) skip  /* justifica esquerda */ 
            "Cliente : " tt-clien.clinom format "x(30)" skip
            "Codigo  : " tt-clien.clicod format ">>>>>>>9"  skip(1)
            /*"    ----------------------------------  " skip
            "                Assinatura " */
            chr(10) skip  /* line feed */
            chr(29) + chr(86) + chr(66) skip.      /* corta */ 
    
        output close.

        if scarne = "local"
        then unix silent /fiscal/lp value(varquivo).
        else unix silent /fiscal/lp value(varquivo) 1.
    end.
end.

end procedure.
*****/

procedure gera-bonus-fique-aqui:

    def var vtitnum like titulo.titnum.
    def var vtitpar like titulo.titpar.

    vtitnum = string(day(today),"99") + string(month(today),"99") +
              string(year(today),"9999") + substr(string(time,"hh:mm"),1,2).
    vtitpar = int(substr(string(time,"hh:mm"),4,2)).

    find first titulo use-index titnum where titulo.empcod = 19 and
                      titulo.titnat = yes and
                      titulo.modcod = "BON" and
                      titulo.etbcod = setbcod and
                      titulo.clifor = tt-clien.clicod and
                      titulo.titnum = vtitnum and
                      titulo.titpar = vtitpar
                      no-error.
    if not avail titulo
    then do:  
        create titulo.
        assign
           titulo.empcod    = 19
           titulo.modcod    = "BON"
           titulo.clifor    = tt-clien.clicod
           titulo.titnum    = vtitnum
           titulo.titpar    = vtitpar
           titulo.titnat    = yes
           titulo.etbcod    = setbcod
           titulo.titdtemi  = today
           titulo.titdtven  = dt-validade
           titulo.datexp    = today
           titulo.titvlcob  = vl-bonus
           titulo.exportado = no
           titulo.titsit    = "LIB"
           titulo.moecod    = "BON"
           titulo.titobs[2] = "BONUS=FIQUE AQUI|".
    end.            
end procedure.

/***2014
procedure meios-de-pagamento:
    if avail cupom-tit-pag
    then do:

    if acha("PG" , cupom-tit-pag.tefretorno) <> ?
    then do: 
    if acha("PG1" , titpag.titobs[1]) = ?
    then titpag.titobs[1] = titpag.titobs[1] + "|PG1=" +
         acha("PG", cupom-tit-pag.tefretorno).
    else if acha("PG2" , titpag.titobs[1]) = ?
    then titpag.titobs[1] = titpag.titobs[1] + "|PG2=" +
         acha("PG", cupom-tit-pag.tefretorno).
    else if acha("PG3" , titpag.titobs[1]) = ?
    then titpag.titobs[1] = titpag.titobs[1] + "|PG3=" +
         acha("PG", cupom-tit-pag.tefretorno).
    else if acha("PG4" , titpag.titobs[1]) = ?
    then titpag.titobs[1] = titpag.titobs[1] + "|PG4=" +
         acha("PG", cupom-tit-pag.tefretorno).
    else if acha("PG5" , titpag.titobs[1]) = ?
    then titpag.titobs[1] = titpag.titobs[1] + "|PG5=" +
         acha("PG", cupom-tit-pag.tefretorno).
    end.
    end.
end procedure.
***/
