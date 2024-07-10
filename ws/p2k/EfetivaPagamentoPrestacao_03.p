/*
#1 Versao 02 - TAG Pagamento parcial
#2 Versao 02 - Validacao dos campos de entrada
#3 03.08.2017 - Nova Tag de entrada modalidade
## 18.08.17 - Alteracoes em ARRAY de pagamentos pela sala de guerra
*/
/* pdv-pagtit01.p */ 

            def var vbanco   as int.
            def var vagencia as int.
            def var vconta   as char.


/* buscarplanopagamento */
def var vstatus as char.   
def var vmensagem_erro as char.
def var vmens2 as char.
def var vchar as char.
def var vdec as dec.
def var vdata as date.
def var vvlrcobr as dec.
def var vdtvenc  as date.
def var vvlracre as dec.
def var vvlrdesc as dec.
def var vvlrpago as dec.
def var vvlrparc as dec. /* valor parcial */
def var vvlrjurodisp as dec.
def var vtitpar  like titulo.titpar init ?.
def var vclifor  as int.
def var vultpag  as log.
def var vparcial as log.
def var out-rec as recid.
def buffer btitulo for titulo.

def new shared temp-table ttbonus
    field numero_bonus as char
    field etbcod as int
    field nome_bonus as char
    field venc_bonus as date
    field vlr_bonus as dec.
 

def shared temp-table EfetivaPagamentoPrestacao
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_operador as char .

def shared temp-table ParcelasPag
    field codigo_cliente as char
    field codigo_contrato as char
    field numero_comprovante as char
    field numero_cupom_fiscal as char
    field valor_prestacao as char
    field valor_acrescimos as char
    field valor_desconto as char
    field cpf as char
    field data_vencimento_parcela as char
    field seq_parcela   as char
    field valor_pago    as char
    field parcial       as char
    field modalidade    as char
    field inf_compl     as char.

{bsxml.i}

find first efetivapagamentoprestacao no-lock no-error.
if avail efetivapagamentoprestacao
then do.
    assign
        vstatus = "S".
    find first parcelasPag no-lock no-error.
    if not avail parcelasPag
    then run erro("Parcelas nao enviadas").
end.
else run erro("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.
    for each parcelasPag.        
        assign
            vvlrcobr = 0
            vvlracre = 0 /* Opcional */
            vvlrdesc = 0 /* Opcional */
            vvlrpago = 0.

        vchar = parcelasPag.data_vencimento_parcela.
        if testavalido(vchar)
        then do:
            vdata = date(int(substring(vchar,6,2)),
                         int(substring(vchar,9,2)),
                         int(substring(vchar,1,4))) no-error.
            if vdata <> ?
            then vdtvenc = vdata.                                 
        end.
        if vdtvenc = ?
        then run erro("DATA DE VENCIMEMNTO invalida"). /* #2 */

        if testavalido(parcelasPag.valor_prestacao)
        then do:
            vdec = dec(parcelasPag.valor_prestacao) no-error.
            if vdec <> ?
            then vvlrcobr = vdec.
        end.
        if vvlrcobr <= 0
        then run erro("VALOR PRESTACAO invalido"). /* #2 */

        if testavalido(parcelasPag.valor_acrescimos)
        then do:
            vdec = dec(parcelasPag.valor_acrescimos) no-error.
            if vdec <> ?
            then vvlracre = vdec.
        end.

        if testavalido(parcelasPag.valor_desconto)
        then do:
            vdec = dec(parcelasPag.valor_desconto) no-error.
            if vdec <> ?
            then do.
                vvlrdesc = vdec.
                vvlrjurodisp = vvlrdesc.
            end.
        end.

        if testavalido(parcelasPag.valor_pago)
        then vvlrpago = dec(parcelasPag.valor_pago) no-error.
        if vvlrpago = ? or
           vvlrpago <= 0
        then run erro("VALOR PAGO invalido"). /* #2 */

        if parcelasPag.parcial = "S"
        then vparcial = yes.
        else if parcelasPag.parcial = "N"
        then vparcial = no.

        if testavalido(parcelasPag.codigo_cliente)
        then vclifor = int(parcelasPag.codigo_cliente) no-error.
        if vclifor = ? or
           vclifor <= 0
        then run erro("CODIGO DE CLIENTE invalido"). /* #2 */

        if testavalido(parcelasPag.seq_parcela)
        then vtitpar = int(parcelasPag.seq_parcela) no-error.
        if vtitpar = ?
        then run erro("NUMERO DA PARCELA invalido"). /* #2 */

        if vparcial /* #1 */ 
        then do.
            /** Nao entrara nesta versao
            **/
        end.

        /**
            Teste CHQ nao entrara nesta versao
        **/    

        if /** Teste CHQ nao entrara nesta versao - parcelasPag.modalidade <> "CHQ" and **/
            vstatus = "S"
        then do:
            find contrato where
                    contrato.contnum = int(parcelasPag.codigo_contrato)
                    no-lock.

            find first titulo use-index titnum where
                titulo.clifor = vclifor and
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = parcelasPag.modalidade and /* #3 */
                titulo.etbcod = contrato.etbcod and
                titulo.titnum = string(int(parcelasPag.codigo_contrato)) and
                titulo.titpar = vtitpar and /* #1 */
                titulo.titdtven = vdtvenc and
                titulo.titvlcob = vvlrcobr
                no-lock no-error.
            if not avail titulo
            then run erro("Pagamento - " +
                        parcelasPag.modalidade + " " +
                        parcelasPag.codigo_contrato + 
                        " - NAO Encontrado").
            else do. /* #2 */
                if titulo.titdtven <> vdtvenc
                then run erro("DATA DE VENCIMEMNTO diferente do cadastro").
                else if titulo.titvlcob <> vvlrcobr
                then run erro("VALOR COBRADO diferente do cadastro").
                if titulo.titdtpag <> ?
                then run erro("Parcela ja Paga").

            end.
        end.
        
    end.
end.

BSXml("ABREXML","").
bsxml("abretabela","return").

if vstatus = "S"
then
    for each parcelasPag.

        assign
            vvlrcobr = 0
            vvlracre = 0 /* Opcional */
            vvlrdesc = 0 /* Opcional */
            vvlrpago = 0.

        vchar = parcelasPag.data_vencimento_parcela.
        vdtvenc = date(int(substring(vchar,6,2)),
                       int(substring(vchar,9,2)),
                       int(substring(vchar,1,4))) no-error.
        vvlrcobr = dec(parcelasPag.valor_prestacao).
        vvlracre = dec(parcelasPag.valor_acrescimos).
        vvlrdesc = dec(parcelasPag.valor_desconto) no-error.
        vvlrjurodisp = vvlrdesc.
        vvlrpago = dec(parcelasPag.valor_pago) no-error.

        if parcelasPag.parcial = "S"
        then vparcial = yes.
        else if parcelasPag.parcial = "N"
        then vparcial = no.

        vclifor = int(parcelasPag.codigo_cliente) no-error.
        vtitpar = int(parcelasPag.seq_parcela) no-error.

        if vparcial /* #1 */ 
        then do.
            /**
              Nao entrara nesta versao
            **/  
        end.

        /**
            CHQ nao entrara nesta versao 
        **/
            
        if /** CHQ nao entrara nesta versao **/ parcelasPag.modalidade <> "CHQ" 
        then do:
            find contrato where
                    contrato.contnum = int(parcelasPag.codigo_contrato)
                    no-lock.

            find first titulo use-index titnum where
                titulo.clifor = vclifor and
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = parcelasPag.modalidade and /* #3 */
                titulo.etbcod = contrato.etbcod and
                titulo.titnum = string(int(parcelasPag.codigo_contrato)) and
                titulo.titpar = vtitpar and /* #1 */
                titulo.titdtven = vdtvenc and
                titulo.titvlcob = vvlrcobr
                exclusive no-wait no-error.
            if avail titulo
            then do:
                assign
                    titulo.cxacod   = int(efetivapagamentoPrestacao.numero_pdv) /*#1*/
                    titulo.titsit   = "PAG"
                    titulo.titjuro  = vvlracre
                    /***titulo.titdesc  = vvlrdesc***/
                    titulo.titvlpag = vvlrpago
                    titulo.titdtpag = today
                    titulo.etbcobra = int(efetivapagamentoPrestacao.codigo_filial).
        
                if vvlrjurodisp > 0
                then titulo.titobs[1] = "DISPENSA-JURO=" + string(vvlrjurodisp) + "|" +
                                    titulo.titobs[1].
                            
                if vparcial and efetivapagamentoPrestacao.codigo_filial = "189"
                then titulo.titobs[1] = "PAGAMENTO-PARCIAL=SIM|" + titulo.titobs[1].

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

                /*** Pagamento Parcial Nao entrara nesta versao ***/

            end.
        end. 
        
        vmensagem_erro = "Pagamento Efetivado" + vmens2.
end.

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",efetivapagamentoPrestacao.codigo_filial).
bsxml("numero_pdv",   efetivapagamentoprestacao.numero_pdv).

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
       titulo.tpcontrato <> ""
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


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.


/**procedure gera-novo-titulo:
    Pagamebnto parcial nao entrara nesta versao
**/
