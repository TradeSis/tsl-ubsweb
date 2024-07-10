
/*10*/ /* 08.03.17 - Helio - Nova Regra para consulta NOVACAO N
                             Quando  tiver pelo menos 1 Titulo Vencido a mais
                             de 60 Dias envia TUDO, se nao tiver
                             Nao Envia  NADA */  
/*
#1 - Ricardo - Versao 02 Nova tag tp_contrato
#2 - Ricardo - 27.07.2017 - Nova tag inf_compl
#3 - Ricardo - 03.08.2017 - Otimizacao
#4 - helio   - 14.0o8.17 - retornar limite para evitar uso do consultacliente  
*/


/* #4 */
def NEW shared temp-table tp-titulo like fin.titulo
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

def var mmodal as char extent 3 init ["CRE", "CP0", "CP1"].
/***def var mestab as int  extent 3 init [0, 8000, 8001].***/
def var mestab as int  extent 3 init [0, 0, 0].

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

    /** #4 **/
    if consultaparcelas.funcionalidade = "H"
    then . /* Nao manda para nao demorar o timeout */
    else do:
        run ./progr/hiscli.p (clien.clicod). /* Calcyla Sal-aberto */

        run calccredscore.p (input string(setbcod), /* Calcula vcalclim */
                                    input recid(clien),
                                    output vcalclim,
                                    output vpardias,
                                    output vdisponivel).
    end.

    bsxml("valor_limite",string(vcalclim - sal-aberto,"->>>>>>>>>9.99")).
    bsxml("credito", string(vcalclim,">>>>>>>9.99")).

    /** #4 **/
    
    do vi = 1 to 3.
        if consultaparcelas.funcionalidade = "N" and
           mmodal[vi] <> "CRE"
        then next.
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
            each titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.clifor = clien.clicod and
                titulo.titdtpag = ? and
                titulo.modcod = tt-modal.modcod and
                titulo.titsit = "LIB" /* #3 */
                no-lock.
            if consultaparcelas.codigo_contrato <> ? and
               consultaparcelas.codigo_contrato <> "" and
               consultaparcelas.codigo_contrato <> "?" and
               consultaparcelas.codigo_contrato <> titulo.titnum
            then next.
        
            /* Novacao: somente contratos vencidos com mais de 60 dias */
            if titulo.titdtven > today - 60 
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
        **/
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
            for each btitulo where
                        btitulo.empcod = 19 and
                        btitulo.titnat = no and
                        btitulo.modcod = titulo.modcod and
                        btitulo.etbcod = titulo.etbcod and
                        btitulo.clifor = titulo.clifor and
                        btitulo.titnum = titulo.titnum and
                        btitulo.titdtemi = titulo.titdtemi
                        no-lock.
                vvalor_contrato = vvalor_contrato + btitulo.titvlcob.
                if btitulo.titsit = "LIB"
                then vvalor_total_pendente = vvalor_total_pendente + 
                                             btitulo.titvlcob.
                else vvalor_total_pago     = vvalor_total_pago     + 
                                             btitulo.titvlcob.

                if (consultaparcelas.funcionalidade = "P" or
                    consultaparcelas.funcionalidade = "N") and
                   btitulo.titsit <> "LIB"
                then next.

                /** BASE MATRIZ  */
                vjuros = 0.
                if btitulo.titsit = "LIB"
                then run juro_titulo.p (0, btitulo.titdtven, btitulo.titvlcob,
                                        output vjuros).
                vvalor_total_encargo = vvalor_total_encargo + vjuros.
            end.        

            bsxml("valor_contrato",string(vvalor_contrato,">>>>>>>>>>>>9.99")).
            bsxml("valor_total_pago",
                                string(vvalor_total_pago,">>>>>>>>>>>>9.99")).
            bsxml("valor_total_pendente",string(vvalor_total_pendente,
                            ">>>>>>>>>>>>9.99")).
            bsxml("valor_total_encargo",string(vvalor_total_encargo,
                            ">>>>>>>>>>>>9.99")).
            bsxml("tp_contrato", titulo.tpcontrato). /* #1 */
        end.

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

end procedure.



