/*VERSAO 2 23062021*/

{/u/bsweb/progr/acha.i}

/* 28.03.2018 #6 Cadastro Express Fase 1 */
/* 21.06.2018 #7 Helio - Revisao do Fluxo  */
/* 03.07.2018 #8 Helio - Revisao do Fluxo V2 */
/* 21.08.2018 #9 Controle por caixa wcneurotech_v1802 */
/* 04.10.2018 #10 Felipe - Alterado programas para v03*/

def NEW shared temp-table tp-titulo like titulo
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

def var varqestatistica as char.
/*** SPC ***/
def var par-spc     as log init yes.
def var spc-conecta as log init yes.
def var vlibera-cli as log /* #6 */ init yes.
def NEW shared temp-table tp-contrato /***like fin.contrato***/
    field contnum   like contrato.contnum
    field etbcod    like contrato.etbcod
    field dtinicial like contrato.dtinicial
    field vltotal   like contrato.vltotal
    index contrato is primary unique etbcod contnum.

def var setbcod as int.
def var vcxacod as int.
def var vtipo_cadastro      as char.
def var vprocessa_credito   as log.

def buffer bneuclien for neuclien.
def var par-recid-neuclien as recid.
def var par-recid-neuproposta as recid.
def var vtipoconsulta          as char init "WsP1".
def var vtime                  as int.
def var vvlrlimite             as dec.
def var vvctolimite            as date. 
def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 
def var vsit_credito as char.
def var vprops as char.
def var vPOLITICA as char.
def var vcpf    as char.
def var par-ok  as log.
def var vchar   as char.
def var vdtnasc as date.
def var vneuro-sit  as char.
def var vneuro-mens as char.  
def var vclicod as int init ?.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vneu_cdoperacao as char. /* #9 */

def shared temp-table PreAutorizacao
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char
    field nome_pessoa     as char
    field data_nascimento as char
    field mae             as char
    field codigo_mae      as char
    field categoria_profissional as char
    field tipo_cadastro as char.

def var vpasta_log as char init "/ws/log/".
find tab_ini where tab_ini.etbcod = 0
               and tab_ini.cxacod = 0
               and tab_ini.parametro = "WS P2K - Pasta LOG"
             no-lock no-error.
if avail tab_ini
then vpasta_log = tab_ini.valor.

{bsxml.i}

find first PreAutorizacao  no-error.
if avail PreAutorizacao
then do.
    /* #8 */
    setbcod = int(preautorizacao.codigo_filial).
    vcxacod = int(preAutorizacao.numero_pdv).
    /* #6 */
    vtipo_cadastro = preAutorizacao.tipo_cadastro.
    if vtipo_cadastro = "CREDIARIO"
    then vprocessa_credito = yes.
    else vprocessa_credito = no.
    /* #6 */
     
    vstatus = "S".
    vcpf = PreAutorizacao.cpf.
    preautorizacao.nome_pessoa = caps(preautorizacao.nome_pessoa). 
    if trim(preAutorizacao.tipo_pessoa) = "J"
    then do: 
        run cgc.p (vcpf, output par-ok).
        if not par-ok
        then run erro("CNPJ Invalido").
        
        /* #8 */
        if vprocessa_credito
        then do: 
            vmensagem_erro = "PJ nao pode ser Tipo CREDIARIO".
            vstatus = "R". /* #8 */
        end.
    end.
    else do:
        run cpf.p (vcpf, output par-ok).
        if not par-ok
        then run erro("CPF invalido").
    end.

    if vstatus = "S"
    then do.
        find first neuclien where neuclien.cpf = dec(preAutorizacao.cpf) no-lock no-error.
        if avail neuclien
        then do:
            find clien where clien.clicod = neuclien.clicod no-lock no-error.
            if avail clien
            then do:
                run erro("CLIENTE " + string(neuclien.clicod) + 
                         " CPF " + preAutorizacao.cpf + 
                         " JA CADASTRADO NA BASE").
                vstatus = "R". /* #8 */
            end.
            else do on error undo:
                find first clien where clien.ciccgc = PreAutorizacao.cpf
                    no-lock no-error.
                /* helio 24.06.2021 Lidia if not avail clien
                then do on error undo:            
                    find current neuclien exclusive.
                    delete neuclien.
                end.
                else*/ if avail clien then do on error undo:
                    find bneuclien where bneuclien.clicod = clien.clicod
                     no-error.
                    if avail bneuclien
                    then do:
                        if bneuclien.cpf = ?
                        then do:
                            delete bneuclien.
                            find current neuclien exclusive.
                            neuclien.clicod = clien.clicod.
                            
                            run erro("CLIENTE " + string(clien.clicod) + 
                                 " CPF " + preAutorizacao.cpf + 
                                 " JA CADASTRADO NA BASE.2").
                            vstatus = "R". /* #8 */
                        end.
                        else do:
                            run erro("CLIENTE " + string(clien.clicod) + 
                              " CPF " + preAutorizacao.cpf + 
                              " POSSUI NEUCLIEN.CPF " + string(bneuclien.cpf)).
                            vstatus = "R". /* #8 */
                        end.
                    end.
                    else do:
                        find current neuclien exclusive.
                        neuclien.clicod = clien.clicod.
                    end.
                end.
            end.
        end. 
        else do: 
            find first clien where clien.ciccgc = PreAutorizacao.cpf
                    no-lock no-error.
            if avail clien
            then do:
                run erro("Cliente ja cadastrado com este CPF:" +
                      string(clien.clicod)). 
                vstatus = "R". /* #8 */
            end.
        end.
    end.

    if vstatus = "S"
    then do.
        vchar = PreAutorizacao.data_nascimento.
        if testavalido(vchar)
        then vdtnasc = date(int(substring(vchar,6,2)),
                            int(substring(vchar,9,2)),
                            int(substring(vchar,1,4))) no-error.
         if vdtnasc = ? or vdtnasc = 01/01/1900
         then run erro("Data de nascimento invalida").
    end.
end.
else run erro("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.
    vtime = mtime.
    vPOLITICA = "P1".
    vstatus = "S".
    vneuro-sit = "".
    
    vdtnasc = date(int(substring(preAutorizacao.data_nascimento,6,2)),
                   int(substring(preAutorizacao.data_nascimento,9,2)),
                   int(substring(preAutorizacao.data_nascimento,1,4))).        

    vprops =    /* helio 032021 politica de credito unificada*/
                /*"POLITICA="        + "CREDITO" +  string(int(preAutorizacao.codigo_filial),"9999") + */
                "POLITICA="        + "CREDITO_UNIFICADA"
                + "&PROP_LOJAVENDA="       + string(int(preAutorizacao.codigo_filial),"9999") 
                /*helio 032021 politica de credito unificada */
     
            + "&PROP_NOMECLI="   + trim(preAutorizacao.nome_pessoa) +  
            "&PROP_CPFCLI="    + vcpf +
            "&PROP_DTNASCCLI=" + trim(string(vdtnasc,"99/99/9999")) +
            "&PROP_CATEGCLI="  + trim(preAutorizacao.categoria_profissional) +
            "&PROP_CONTAMAE="  + trim(preAutorizacao.codigo_mae) +
            "&PROP_NOMEMAE="   + trim(preAutorizacao.mae) +
            "&PROP_LOJACAD="   + trim(preAutorizacao.codigo_filial) +
            "&PROP_FLXPOLITICA=" + vPOLITICA.

    find neuclien where neuclien.cpfcnpj = dec(preAutorizacao.cpf) /** int64 **/
        no-lock no-error.
    if not avail neuclien
    then do:
        run neuro/gravaneuclien_06.p (preAutorizacao.cpf,
                                      output par-recid-neuclien).
     
        find neuclien where recid(neuclien) = par-recid-neuclien 
                no-lock no-error.
        if not avail neuclien
        then do:
            run erro("Erro ao Cadastrar Credito Cliente").
        end.
    end.        
    else do:
        par-recid-neuclien = recid(neuclien).
        if  neuclien.clicod <> ? 
        then do:
            vclicod = neuclien.clicod.
            vneuro-sit  = "E". /**neuclien.sit_credito.**/
            vneuro-mens = "CPF " + preautorizacao.cpf +
                " ja cadastrado na conta principal " + string(neuclien.clicod).
            vstatus = "S".
            vmensagem_erro = "".
        end.            
    end.
   
    if vstatus = "S" and
       vneuro-sit = "" 
    then do: 
        /** Testa se vai para NEUROTECH **/  
               
        if vprocessa_credito /* #6 */
        then do:
            run log("submeteneuro Politica=" + vpolitica).
            run neuro/submeteneuro_v1802.p (input setbcod,
                                      input vpolitica,
                                      input neuclien.clicod,
                                      0,
                                      output vlojaneuro,
                                      output vneurotech).
        end.
        else assign
            vneurotech = no.
                
        if vneurotech
        then do:
           run neuro/wcneurotech_v2101.p /* helio 21062021 - chamado por REST */
                                        (input setbcod,
                                         input vcxacod,
                                         input vprops,
                                         input vPOLITICA,
                                         input vtime,
                                         input par-recid-neuclien, 
                                         input-output vneu_cdoperacao /* #9 */,
                                         0  /* #9 */,
                                         output vvlrLimite, 
                                         output vvctolimite,
                                         output vneuro-sit, 
                                         output vneuro-mens,
                                         output vstatus,
                                         output vmensagem_erro).

            if vstatus = "S" /* Sem Erros */
            then do:
                if vneuro-sit = "A" /* Aprovado Neuro */
                then do:
                    vclicod = neuclien.clicod.
                    if vclicod = ?
                    then run neuro/gravaclien.p
                            (par-recid-neuclien,
                             vpolitica,
                             setbcod,
                             vcpf,
                             output vclicod,
                             output vstatus).
                    find clien where clien.clicod = vclicod no-lock no-error.
                    if not avail clien
                    then do:
                        run erro("Erro ao Cadastrar Cliente").
                    end.
                end.
                else do:
                    if vneuro-sit = "P" 
                    then vneuro-mens = if vneuro-mens = ""
                                 then "Encaminhar o Cliente a FILA DE CREDITO."
                                 else vneuro-mens.
                    else vneuro-mens = if vneuro-mens = ""
                                       then ""
                                       else vneuro-mens.
                end.
            end.
            else do:
                vneurotech = no. /* Usa Processo ADMCOM */
                vstatus = "S".
                vmensagem_erro = "".
            end.                
        end.

        if not vneurotech /* ADMCOM */ /* #8 */
        then do:
            vtime = mtime.
            vneuro-sit = "A".
            vneuro-mens = "".
            vclicod = neuclien.clicod.

            if vclicod = ?
            then run neuro/gravaclien.p
                    (par-recid-neuclien,
                     vpolitica + "ADMCOM",
                     setbcod,
                     vcpf,
                     output vclicod,
                     output vstatus).
                    
            /* #8 Consulta SPC */
            find clien where clien.clicod = vclicod no-lock no-error.
            if not avail clien or
               clien.tippes = no /* PJ */
            then vstatus = "E".
            else do: 
                if clien.tippes and vprocessa_credito
                then do.
                    varqestatistica = "/ws/log/p2k_spcsicred_estatistica_" + 
                        string(today, "99999999") + ".log".
        
                    vtime = mtime. 
                    run ./progr/pdv/spcpreconsulta_v03.p /*#10*/ (?,
                                                  recid(clien),
                                                  output par-spc, 
                                                  output vlibera-cli).
                    if par-spc 
                    then do:
                        run log("gravaneuclilog CONSULTANDO").
                        run neuro/gravaneuclilog_v1802.p
                                (neuclien.cpfcnpj,
                                 vtipoconsulta,
                                 vtime,
                                 setbcod,
                                 vcxacod,
                                 neuclien.sit_credito,
                                 "CONSULTANDO"). 
                        run ./progr/pdv/spcconsulta_v03.p (setbcod,
                                           vcxacod,
                                           recid(clien),
                                           output par-spc,
                                           output spc-conecta).
                        if not par-spc
                        then vlibera-cli = no. 
                        vsit_credito = if par-spc
                                       then "A" else "A".

                        vchar = "SPC Cliente " +
                                string(par-spc,"Nao Consta/Consta").
                        run log("gravaneuclilog " + vchar).
                        run neuro/gravaneuclilog_v1802.p
                                    (neuclien.cpfcnpj,
                                     vtipoconsulta,
                                     0,
                                     setbcod,
                                     vcxacod,
                                     vsit_credito,
                                     vchar).

                        if neuclien.sit_credito <> vsit_credito
                        then do:
                            run log("gravaneuclihist").
                            run neuro/gravaneuclihist_v1802.p
                                    (par-recid-neuclien,
                                     vtipoconsulta,
                                     setbcod,
                                     clien.clicod,
                                     input vvctolimite,
                                     input vvlrLimite,
                                     0,
                                     vsit_credito).
                        end.
                    end.
                    else do:
                        run log("gravaneuclilog NAO").
                        run neuro/gravaneuclilog_v1802.p
                                (neuclien.cpfcnpj,
                                 vtipoconsulta,
                                 vtime,
                                 setbcod,
                                 vcxacod,
                                 neuclien.sit_credito,
                                 "NAO"). 
                    end.
                    output to value(varqestatistica) append.
                        put unformatted
                        skip
                        "spcconsulta" + ";" +
                        string(today,"99999999") + ";" +
                        replace(string(vtime,"HH:MM:SS"),":","") + ";" +
                        replace(string(time,"HH:MM:SS"),":","") + ";" +
                        replace(string(time - vtime,"HH:MM:SS"),":","") + ";" +
                        string(par-spc,"SIM/NAO") skip.
                    output close.
                end.
            end.
            
            /* #8 Consulta SPC */
            if vstatus = "S"
            then vneuro-sit = "A".
            else do:
                vneuro-sit = "R".
                vmensagem_erro = "ADMCOM - Erro Cadastrar Cliente".
            end.    

            vchar = if vstatus = "S" then vneuro-mens else vmensagem_erro.
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p
                     (neuclien.cpfcnpj,
                      vpolitica + "ADMCOM",
                      vtime, 
                      setbcod, 
                      vcxacod,
                      if vstatus = "S"
                      then vneuro-sit
                      else neuclien.sit_credito,
                      vchar).
        end.
    end.
    else do:
        run log("gravaneuclilog " + vmensagem_erro).
        run neuro/gravaneuclilog_v1802.p
                (preAutorizacao.cpf,
                 vtipoconsulta,
                 vtime,
                 preAutorizacao.codigo_filial,
                 vcxacod,
                 "",
                 vmensagem_erro).
    end. 
end.

BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",PreAutorizacao.codigo_filial).
bsxml("numero_pdv",PreAutorizacao.numero_pdv).
bsxml("sit_credito", vneuro-sit).
bsxml("codigo_cliente",if vclicod <> ? then string(vclicod) else "").
bsxml("mensagem_credito", vneuro-mens).
bsxml("tipo_cadastro",PreAutorizacao.tipo_cadastro).

bsxml("fechatabela","return").
BSXml("FECHAXML","").

run log("FIM").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = vpasta_log + "Neurotech_" + string(today, "99999999") + "_" +
           string(setbcod) + "_" + string(vcxacod) + ".log".

    output to value(varquivo) append.
    put unformatted string(time,"HH:MM:SS")
        " PreAutorizacao " par-texto skip.
    output close.

end procedure.

