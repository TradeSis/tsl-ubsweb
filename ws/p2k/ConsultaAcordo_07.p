/* helio 06022023 - ID 155445 - cslog enviou no csml o campo idAcordoLebes, com este id fazendo teste se numero de acordo inicia com 9, para desprezar */

/***  3sftt
   Fev/2017 Projeto Novacao
#1 jan/2019 Revisao
#2 07.06.19 - TP 31325157
#3 11.09.2019 - helio.neto - volta chamada via soap php 
19022021 - helio.neto - cslog - apenas um acordo por vez
***/
def var vrec as recid.
def var vx as char. 
def var vtotabe as dec.

{/admcom/progr/api/acentos.i} /* helio 06022023 */

{/u/bsweb/progr/bsxml.i}

def var vprocessa_cslog as log.
def var vi as int.

def var setbcod as int.
def var p-temacordo as log.
def var vstatus   as char.
def var vmensagem_erro as char.
def var vcliente  as int.
def var vmensagem as char.
def var vdesconto as dec.
def var vjuros    as dec.
def var vct       as int.

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

def shared temp-table ConsultaAcordo
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char.

find first ConsultaAcordo no-lock no-error.
if avail ConsultaAcordo
then do.
    setbcod = int(consultaacordo.codigo_filial).
    
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

    run cob/ajustanovacordo.p (clien.clicod, output  p-temacordo). /* Verifica se tem acordo no ADMCOM */
    if not p-temacordo
    then do:    
    
        /* Verifica se tem acordo no CYBER */
        /*** 11/12/2020 helio desativacao do cyber
       *** run ./progr/pdv/cyber_acordo_07a.i /*#3*/
                ("ConsultaAcordo", clien.clicod, 
                 output vmensagem).
        ***/
        find first tt-acordo no-lock no-error.
        if not avail tt-acordo /* senao temno cyber...*/
        then do:

            /* verifica se loa acessa CSLOG */
            vprocessa_cslog = no.

            find first tab_ini where tab_ini.etbcod    = setbcod and
                                 tab_ini.parametro = "CSLOG_PROCESSA"
                           no-lock no-error.
            if avail tab_ini 
            then
                if tab_ini.valor = "SIM"
                then vprocessa_cslog = yes.
                else vprocessa_cslog = no.
            if vprocessa_cslog 
            then do:
                /* Se acessa CSLOG... */
                run /admcom/progr/csl/chama-ws-cslog.p (input clien.clicod, output vmensagem).

                /* helio 06022023 - ID 155445 - Erro ao pagar parcela no p2k com marcação "acordo com o CRIIC" */
                find first tt-novacao no-error.
                run log("retornou " + string(avail tt-novacao,"Com Acordo Cslog/Sem Acordo Cslog")).
                if avail tt-novacao 
                then do:
                    for each tt-novacao.            
                        run log ("Acordo: " + tt-novacao.ahid + " " + string(tt-novacao.idAcordo) + " " +
                                    string(trim(string(tt-novacao.idAcordo)) begins "9","Promessa/Acordo Novacao")). /* helio 06022023 - recebendo idAcordo */
                        for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid.
                            run log ("Acordo: " + string(tt-novacao.idAcordo) + " - Origem: " + tt-contratos.titnum).
                        end.
                        for each tt-acordo where tt-acordo.apahid = tt-novacao.ahid.
                            tt-acordo.titdtven = if tt-acordo.titpar = 0  /* helio 27112023 - Alteração de vencimento Acordo */
                                                 then today /*  entrada manda today */
                                                 else tt-acordo.titdtven.
                        
                            run log ("Acordo: " + string(tt-novacao.idAcordo) + " - Acordo: " + string(tt-acordo.titpar) +  " " + 
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
        end.
    end.
    else do:
                
        vx = "".             
        for each novacordo where
               novacordo.clicod = clien.clicod and
               novacordo.situacao = "PENDENTE"
               no-lock
               by novacordo.dtinclu.
            vx =  string(novacordo.id_acordo).
            create tt-novacao.
            tt-novacao.ahid     = string(vx).
            tt-novacao.ahdt     = novacordo.dtinclu.
            tt-novacao.vltotal  = novacordo.valor_acordo.
            for each tit_novacao where tit_novacao.id_acordo = string(novacordo.id_acordo) no-lock.
                find titulo where 
                titulo.empcod = tit_novacao.ori_empcod and
                titulo.titnat = tit_novacao.ori_titnat and
                titulo.modcod = tit_novacao.ori_modcod and
                titulo.etbcod = tit_novacao.ori_etbcod and
                titulo.clifor = tit_novacao.ori_clifor and
                titulo.titnum = tit_novacao.ori_titnum and
                titulo.titpar = tit_novacao.ori_titpar and
                titulo.titdtemi = tit_novacao.ori_titdtemi
                no-lock no-error.
                if avail titulo
                then do:
                    if titulo.titsit = "LIB"
                    then do:
                        find first tt-contratos where tt-contratos.titnum = titulo.titnum no-error.
                        if not avail tt-contratos
                        then do:
                            create tt-contratos.
                            tt-contratos.adahid = string(vx).
                            tt-contratos.titnum = titulo.titnum.
                            tt-contratos.etbcod = titulo.etbcod.
                        end.
                    end.
                end.                     
            end.    
            for each tit_acordo of novacordo no-lock.
                create tt-acordo.
                tt-acordo.apahid = string(vx).
                tt-acordo.titpar = tit_acordo.titpar.
                tt-acordo.titdtven = if tt-acordo.titpar = 0  /* helio 27112023 - Alteração de vencimento Acordo */
                                     then today /*  entrada manda today */
                                     else tit_acordo.titdtven.
                tt-acordo.titvlcob = tit_acordo.titvlcob.
            end.
        end.
        
    end.
    
end.
        
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
                    then vtotabe = vtotabe + titulo.titvlcob.        
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
    find first tt-novacao no-error.
    if not avail tt-novacao
    then assign
                vstatus = "E"
                vmensagem_erro = "Sem acordo disponivel".

    run log ("status=" + vstatus + " " + string( avail tt-novacao)).
/***/

    vrec = if avail tt-novacao
           then recid(tt-novacao)
           else ?.

if vstatus = "S" and avail tt-novacao
then do.

    if tt-novacao.vltotal = 0
    then for each tt-acordo where tt-acordo.apahid = tt-novacao.ahid no-lock.
        tt-novacao.vltotal = tt-novacao.vltotal + tt-acordo.titvlcob.
    end.
 
    for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid no-lock. /* Contratos do acordo do Cyber */
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
            if titulo.titsit = "LIB" or titulo.titsit = "PAG"
            then.
            else next.
            assign
                tt-cons-contrato.valor_contrato      =
                            tt-cons-contrato.valor_contrato + titulo.titvlcob.
                            
            if titulo.titsit = "PAG"
            then tt-cons-contrato.valor_total_pago     =
                                     tt-cons-contrato.valor_total_pago +
                            titulo.titvlcob.

            vjuros = 0.

            if p-temacordo
            then do:
                find first tit_novacao where
                tit_novacao.id_acordo = tt-novacao.ahid and
                titulo.empcod = tit_novacao.ori_empcod and
                titulo.titnat = tit_novacao.ori_titnat and
                titulo.modcod = tit_novacao.ori_modcod and
                titulo.etbcod = tit_novacao.ori_etbcod and
                titulo.clifor = tit_novacao.ori_clifor and
                titulo.titnum = tit_novacao.ori_titnum and
                titulo.titpar = tit_novacao.ori_titpar and
                titulo.titdtemi = tit_novacao.ori_titdtemi
                no-lock no-error.
                if not avail tit_novacao then next.
                if tit_novacao.ori_titvlcob = 0
                then do:
                    if titulo.titsit = "LIB" /***titdtpag = ?***/ and
                       titulo.titdtven < today
                    then run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* helio 07112020 */
                                       titulo.titdtven,
                                       titulo.titvlcob,
                                       output vjuros).
                end.
            end.
            else  do:
                if titulo.titsit = "LIB" /***titdtpag = ?***/ and
                   today > titulo.titdtven
                then run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* helio 07112020 */
                                   titulo.titdtven,
                                   titulo.titvlcob,
                                   output vjuros).
            end. 
            

            if titulo.titsit = "LIB" /***titdtpag = ?***/
            then do:
                tt-cons-contrato.valor_total_pendente = 
                            tt-cons-contrato.valor_total_pendente +
                            titulo.titvlcob.
                tt-cons-contrato.valor_total_encargo =
                                tt-cons-contrato.valor_total_encargo + vjuros.
            end.
                            
             
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
                vmensagem_erro = "Contrato indicado esta liquidado".
    end. 
end.

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_cliente",string(vcliente)).

if avail clien
then do.
    bsxml("cpf", RemoveAcento(clien.ciccgc)). /* helio 06022023 - trocado para remove acentos */
    bsxml("nome",RemoveAcento(clien.clinom)).
end.

if vstatus = "S" and avail tt-novacao
then do.

   find tt-novacao where recid(tt-novacao) = vrec no-error.
    
   for each tt-cons-contrato no-lock.
        find contrato where contrato.contnum = tt-cons-contrato.contnum
                      no-lock.

        BSXml("ABREREGISTRO","contratos"). 
        bsxml("filial_contrato",string(contrato.etbcod)).
        bsxml("modalidade",     contrato.modcod /*+ ".F123456789"*/).
        /* F. = projeto feirao que nao foi aprovado */
        bsxml("numero_contrato",string(contrato.contnum,"9999999999")).
        bsxml("data_emissao_contrato",EnviaData(contrato.dtinicial)).
        bsxml("valor_contrato",
                  string(tt-cons-contrato.valor_contrato,">>>>>>>>>>>9.99")).
        bsxml("valor_total_pago",
                  string(tt-cons-contrato.valor_total_pago,">>>>>>>>>>>9.99")).
        bsxml("valor_total_pendente",
                  string(tt-cons-contrato.valor_total_pendente,
                            ">>>>>>>>>>>9.99")).
        bsxml("valor_total_encargo",
                  string(tt-cons-contrato.valor_total_encargo,
                            ">>>>>>>>>>>9.99")).

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
            bsxml("valor_encargos",string(vjuros,">>>>>>>>>>9.99")).


            BSXml("FECHAREGISTRO","parcelas").
        end.

        BSXml("FECHAREGISTRO","contratos").
    end.

    BSXml("ABREREGISTRO","acordo").
    bsxml("modalidade",  "CRE").
    bsxml("data_emissao",EnviaData(tt-novacao.ahdt)) .
     
    bsxml("valor_total", string(tt-novacao.vltotal)).

    
    for each tt-acordo where  tt-acordo.apahid = tt-novacao.ahid no-lock.
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

run log ("FIM").


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = "/ws/log/p2k07_" + string(today, "99999999") + ".log".

    output to value(varquivo) append.
    put unformatted "    -> " string(time,"HH:MM:SS")
        " ConsultaAcordo " par-texto skip.
    output close.

end procedure.



