
/* buscarplanopagamento */
def var vstatus as char.   
def var vmensagem_erro as char.
def var vmens2 as char.
def var vchar as char.
def var vdec as dec.
def var vdata as date.
def var vvlcob as dec.
def var vdtven as date.
def var vvlacre as dec.
def var vvldes as dec.   
def var vcli as int.
def var vultpag as log.
def var out-rec as recid.
def buffer btitulo for titulo.

def new shared temp-table ttbonus
        field numero_bonus as char
        field etbcod as int
        field nome_bonus as char
        field venc_bonus as date
        field vlr_bonus as dec.
 
def shared temp-table efetivapagamentoprestacao
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_cliente as char
    field codigo_contrato as char
    field numero_comprovante as char
    field numero_cupom_fiscal as char
    field valor_prestacao as char
    field valor_acrescimos as char
    field valor_desconto as char
    field codigo_operador as char
    field cpf as char
    field data_vencimento_parcela as char.

find first efetivapagamentoprestacao no-lock no-error.

vstatus = if avail efetivapagamentoprestacao
          then "S"
          else "E".
vmensagem_erro = if avail efetivapagamentoprestacao
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     

{bsxml.i}

BSXml("ABREXML","").
bsxml("abretabela","return").
        
vchar = efetivapagamentoprestacao.data_vencimento_parcela.
if testavalido(vchar)
then do:
    vdata = date(int(substring(vchar,6,2)),
                 int(substring(vchar,9,2)),
                 int(substring(vchar,1,4))) no-error.
    if vdata <> ?
    then vdtven = vdata.                                 
end.

vvlcob = 0.
if testavalido(efetivapagamentoprestacao.valor_prestacao)
then do:
    vdec = dec(efetivapagamentoprestacao.valor_prestacao) no-error.
    if vdec <> ?
    then vvlcob = vdec.
end.

vvlacre = 0.
if testavalido(efetivapagamentoprestacao.valor_acrescimo)
then do:
    vdec = dec(efetivapagamentoprestacao.valor_acrescimo) no-error.
    if vdec <> ?
    then vvlacre = vdec.
end.

vvldes = 0.
if testavalido(efetivapagamentoprestacao.valor_desconto)
then do:
    vdec = dec(efetivapagamentoprestacao.valor_desconto) no-error.
    if vdec <> ?
    then vvldes = vdec.
end.

if testavalido(efetivapagamentoprestacao.codigo_cliente)
then do:
    vdec = int(efetivapagamentoprestacao.codigo_cliente) no-error.
    if vdec <> ?
    then vcli = int(vdec).
end.        

do on error undo.
    find first titulo use-index iclicod where
        titulo.clifor = vcli and
        titulo.empcod = 19 and
        titulo.titnat = no and
        titulo.titnum = string(int(efetivapagamentoprestacao.codigo_contrato))
         and
        (titulo.modcod = "CRE" or 
         titulo.modcod = "CP0" or
         titulo.modcod = "CP1") and
        titulo.titdtpag = ? and
        titulo.titdtven = vdtven and
        titulo.titvlcob = vvlcob
        exclusive no-error.
    if avail titulo
    then do:
        assign
            titulo.titsit   = "PAG"
            titulo.titjuro  = vvlacre
            titulo.titdesc  = vvldes
            titulo.titvlpag = titulo.titvlcob + vvlacre - vvldes
            titulo.titdtpag = today
            titulo.etbcobra = int(efetivapagamentoprestacao.codigo_filial).
        find current titulo no-lock. /*** 01/09/2016 ***/

        if titulo.modcod = "CRE" and
           titulo.clifor > 1
        then run eh-ultimo-pagamento (output vultpag).                
        if vultpag
        then do:
            run fique-aqui (output out-rec).
            find btitulo where recid(btitulo) = out-rec no-lock no-error.
            if avail btitulo
            then do:  
                create ttbonus. 
                ttbonus.nome_bonus = "FIQUE AQUI". 
                ttbonus.numero_bonus = btitulo.titnum. 
                ttbonus.etbcod     = btitulo.etbcod. 
                ttbonus.venc_bonus = btitulo.titdtven. 
                ttbonus.vlr_bonus  = btitulo.titvlcob.
                vmens2 = " - Pagamento Ultima Parcela".
            end.
        end.

        vmensagem_erro = "Pagamento - " + titulo.titnum + "/" +
                     string(titulo.titpar) + " - Efetivado" + vmens2.
    end.
    else do:
        vstatus = "E".
        vmensagem_erro = "Pagamento - " +
            efetivapagamentoprestacao.codigo_contrato + 
            " - NAO Encontrado".
    end.
end.

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",string(efetivapagamentoprestacao.codigo_filial)).
bsxml("numero_pdv",string(efetivapagamentoprestacao.numero_pdv)).

find first ttbonus no-lock no-error.
if avail ttbonus
then do:
    BSXml("ABREREGISTRO","listabonus"). 
    for each ttbonus.
        BSXml("ABREREGISTRO","bonus").
        bsxml("nome_bonus",ttbonus.nome_bonus).
        bsxml("numero_bonus",ttbonus.numero_bonus).
        bsxml("codigo_filial_bonus",string(ttbonus.etbcod)).
        bsxml("venc_bonus",EnviaData(ttbonus.venc_bonus)).
        bsxml("vlr_bonus",string(ttbonus.vlr_bonus,">>>>>>>>9.99")).
        BSXml("FECHAREGISTRO","bonus").
    end.
    BSXml("FECHAREGISTRO","listabonus"). 
end.

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure eh-ultimo-pagamento. /* regras em pagtit01.p */

    def output parameter p-ultpag as log init yes.
    def var vsaldo as dec.

    if titulo.clifor = 1 or
       titulo.modcod = "VVI" or
       titulo.titpar < 4 or
       titulo.tpcontrato <> "" /***titulo.titpar >= 30***/
    then p-ultpag = no.

/*** 01/09/2016
    vsaldo = 0.
    for each btitulo where
            btitulo.empcod = titulo.empcod and
            btitulo.titnat = titulo.titnat and
            btitulo.modcod = titulo.modcod and
            btitulo.etbcod = titulo.etbcod and
            btitulo.clifor = titulo.clifor and
            btitulo.titnum = titulo.titnum and
            btitulo.titpar <> titulo.titpar and
            btitulo.titpar < 30
            no-lock.
        if btitulo.titdtpag = ? or btitulo.titsit = "LIB"
        then vsaldo = vsaldo + btitulo.titvlcob.
    end.
    if vsaldo <> 0
    then p-ultpag = no.
***/
    find first btitulo use-index iclicod where
            btitulo.clifor = titulo.clifor and
            btitulo.titnat = titulo.titnat and
            btitulo.modcod = titulo.modcod and
            (btitulo.titdtpag = ? or btitulo.titsit = "LIB")
            no-lock no-error.
    if avail btitulo
    then p-ultpag = no.

    /***
    if titulo.titdtven - titulo.titdtemi > 30
    then p-ultpag = no.
    ***/

end procedure.


procedure fique-aqui:
    def output parameter out-rec as recid.

    def var dt-validade as date.
    def var vl-bonus as dec.
    def var vi as int.

/***
    dt-validade =  
                date(if month(today) = 12 then 01 else month(today) + 1,
                     01,
                     if month(today) = 12 then
                            int(string(year(today),"9999")) + 1  else
                            int(string(year(today),"9999"))) - 1.
***/
    /*** 22.08.2016 - 5o. dia util do mes seguinte ***/
    dt-validade =  
                date(if month(today) = 12 then 1 else month(today) + 1,
                     1,
                     if month(today) = 12
                     then int(string(year(today),"9999")) + 1
                     else int(string(year(today),"9999"))).
    repeat.
        if weekday(dt-validade) <> 1 and
           weekday(dt-validade) <> 7
        then do.
            find dtextra where dtextra.exdata = dt-validade no-lock no-error.
            if not avail dtextra
            then do.
                vi = vi + 1.
                if vi >= 5 /* 5o. dia util */
                then leave.
            end.
        end.
        dt-validade = dt-validade + 1.
    end.

    vl-bonus = 20.  /** peguei do pagtit01.p dia 22.09.2015 era R$ 12,00 **/
                    /** em 12/07/2016 apos corretiva foi alterado para 20 **/

    run gera-bonus-fique-aqui (input dt-validade,
                               input vl-bonus,
                               output out-rec).

end procedure.


procedure gera-bonus-fique-aqui:
    def input parameter dt-validade as date.
    def input parameter vl-bonus as dec.
    def output parameter out-rec as recid.

    def var vtitnum like titulo.titnum.
    def var vtitpar like titulo.titpar.

    vtitnum = string(day(today),"99") + string(month(today),"99") +
              string(year(today),"9999") + substr(string(time,"hh:mm"),1,2).
    vtitpar = int(substr(string(time,"hh:mm"),4,2)).

    find first btitulo use-index titnum where
                      btitulo.empcod = 19 and
                      btitulo.titnat = yes and
                      btitulo.modcod = "BON" and
                      btitulo.etbcod = titulo.etbcod and
                      btitulo.clifor = titulo.clifor and
                      btitulo.titnum = vtitnum and
                      btitulo.titpar = vtitpar
                     NO-LOCK no-error.
    if not avail btitulo
    then do ON ERROR UNDO:
        create btitulo.
        assign
           btitulo.empcod    = 19
           btitulo.modcod    = "BON"
           btitulo.clifor    = titulo.clifor
           btitulo.titnum    = vtitnum
           btitulo.titpar    = vtitpar
           btitulo.titnat    = yes
           btitulo.etbcod    = if titulo.etbcobra > 0
                               then titulo.etbcobra else titulo.etbcod
           btitulo.titdtemi  = today
           btitulo.titdtven  = dt-validade
           btitulo.datexp    = today
           btitulo.titvlcob  = vl-bonus
           btitulo.exportado = no
           btitulo.titsit    = "LIB"
           btitulo.moecod    = "BON"
           btitulo.titobs[2] = "BONUS=FIQUE AQUI|".
    end.            
    out-rec = recid(btitulo).
    
end procedure.

