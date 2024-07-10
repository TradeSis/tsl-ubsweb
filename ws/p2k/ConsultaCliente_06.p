/**
# _99 - Versao 99 
**/
/* 28.03.2018 #_06 Cadastro Express Fase 1 */
/* 04.05.2018 #2   Ajustes dentro da versao _06 */
/* 17.05.2018 #3 - Melhorias Motor Pct 01 */
/* 01.06.2018 #4 helio - Solicitado novos campos para que o motor calcule o corte do limite quando tem novacao ou atraso */
/* 12.06.2018 #5 helio - ajustado retorno cpf e cnpj dependente de pessoa fisica ou juridica */
/* 14.06.2018 #6 Ricardo - SPC interno Lebes */
/* 21.06.2018 #7 Helio - Revisao do Fluxo  */
/* 03.07.2018 #8 Helio - Revisao do Fluxo V2 */

def var vforcaadmcom as log init no.
/*#3*/
def var vneu_cdoperacao as char. 
def var vneu_politica as char.
def var vcpf like neuclien.cpf.
def buffer bneuclien for neuclien.
def buffer bclien for clien.

def var vtipo_cadastro      as char.
def var vprocessa_credito   as log.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-atrasoparcperc as char.
def var var-PARCPAG as int.
def var var-saldototnov as dec.

/* _05 */
def var par-recid-neuclien as recid.
def var par-recid-neuproposta as recid.
def var vtipoconsulta          as char init "CC06".
def var vtime                  as int.
def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 

def var vneuro-sit as char.
def var vneuro-mens as char.

def var vsit_credito as char.
def var vvctolimite            as date. 
def var vvlrLimite              as dec.
def var vrenda as dec.
def var vrenda_conjuge as dec.
def var vsituacao-instrucao as char.
def var vinstrucao  as char.
def var vseguro as char.
def var vplanosaude as char.
def var cestcivil as char.
def var vx as int.
def var vlstdadosbanco as char.
def var vlstrefcomerc  as char.
def var vlstcartaocred as char.
def var vveiculo       as char.
def var vlstdadosveic as char.     
def var vlstrefpessoais as char.
def var vlstspc as char.
def var vale-spc as char.
def var vche-spc as char.
def var vcre-spc as char.
def var vnac-spc as char.


/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */


def var vprops as char.
def var vPOLITICA as char.
def var vdtnasc as date.
/* _05 */

def new shared temp-table PreAutorizacao
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


def var varqestatistica as char.
def var vtimeini as int.


def NEW shared temp-table tp-titulo like titulo
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

def new shared temp-table ttbonus
        field numero_bonus as char
        field etbcod as int
        field nome_bonus as char
        field venc_bonus as date
        field vlr_bonus as dec.

def var par-ok  as log.
/* buscarplanopagamento */
def var vcod as int.
def var vatraso as log.
def var vspc_descr_motivo as char.
def var vspc_cod_motivo_cancelamento as char.
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vcartao as char /***int***/.
def var vi as int.   
def var vcarro as char.
def var vobs as char.
def var vmen-spc as char.
def var vdat-spc as date.
def var vcon-spc as char.
def var vfil-spc as char.
def var vcnpj as log.
def var vrecebe-email-promo as char.

def var vperc15 as dec decimals 2.
def var vperc45 as dec decimals 2.
def var vperc46 as dec decimals 2.
def var vmedia  as dec decimals 2.

/* PDV hiscli2.p */
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
/*** ***/

/*** CREDSCORE - 17/05/2016 ***/
/* retirado, passado para calclimiteadmcom.p **/
/*** ***/

def shared temp-table ConsultaCliente
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field tipo_cadastro as char .

{bsxml.i} /* {bsxml-iso.i */

find first ConsultaCliente no-lock no-error.
if avail ConsultaCliente
then do.
    /* #_06 */
    vtipo_cadastro = consultacliente.tipo_cadastro.
    if vtipo_cadastro = "CREDIARIO"
    then vprocessa_credito = yes.
    else vprocessa_credito = no.
    /* #_06 */

    vstatus = "S".

    setbcod = int(ConsultaCliente.codigo_filial).
    vcnpj = no.
        
    if ConsultaCliente.tipo_documento = "1" /* cpF */
    then do:
        find neuclien where
            neuclien.cpf = dec(consultacliente.numero_documento) 
            no-lock no-error.
        if avail neuclien
        then do:
            if neuclien.clicod = ?
            then do:
                find first clien where clien.ciccgc = consultacliente.numero_documento no-lock no-error.
                if avail clien
                then do:
                    find bneuclien where bneuclien.clicod = clien.clicod no-error.
                    if avail bneuclien
                    then do on error undo:
                        if bneuclien.cpf = ?
                        then do:
                            delete bneuclien.
                            find current neuclien exclusive.
                            neuclien.clicod = clien.clicod.
                        end.
                        else do:
                            vstatus = "E".
                            vmensagem_erro = "4CLIENTE " + trim(string(clien.clicod)) + " TEM CPF " + clien.ciccgc
                                             + 
                                             " E TAMBEM NEUCLIEN.CPF " + string(bneuclien.cpf).
                        
                        end.
                    end.
                end.                    
            end.
            else do:
                find clien where clien.clicod = neuclien.clicod no-lock no-error.
                if avail clien
                then do:
                    if dec(clien.ciccgc) <> neuclien.cpf
                    then do: 
                        vstatus = "E". 
                        vmensagem_erro = "4CLIENTE " + trim(string(clien.clicod)) + " TEM CPF " + clien.ciccgc 
                                +  
                                " E TAMBEM NEUCLIEN.CPF " + string(neuclien.cpf).
                    end.
                    else do:
                        find first bclien where bclien.ciccgc = ConsultaCliente.numero_documento and
                                                bclien.clicod <> clien.clicod
                            no-lock no-error.
                        if avail bclien
                        then do:
                            if bclien.clicod <> neuclien.clicod
                            then do:
                                vmensagem_erro = "6CLIENTE " + trim(string(clien.clicod)) + " TEM CPF " + clien.ciccgc 
                                    +  
                                    " E TAMBEM CONTA " + string(bclien.clicod).

                            end.
                        end.    
                    end.
                end.
            end.
        end.    
        else do:
            find first clien where 
                clien.ciccgc = ConsultaCliente.numero_documento
                no-lock no-error.
            if avail clien
            then do:
                find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
                if avail neuclien
                then do:
                    vcpf = dec(clien.ciccgc) no-error.
                    if neuclien.cpf <> vcpf
                    then do:
                        vstatus = "E".
                        vmensagem_erro = "5CLIENTE " + trim(string(clien.clicod)) + " TEM CPF " + clien.ciccgc
                                         + 
                                         " E TAMBEM NEUCLIEN.CPF " + string(neuclien.cpf).
                    end.
                end.
                else do:
                    vforcaadmcom = yes. /* #8 */
                end.
            end.
        end.        
        if avail clien
        then do:
            run cpf.p (ConsultaCliente.numero_documento, output par-ok).
            if par-ok
            then.         
            else do:
                run cgc.p (ConsultaCliente.numero_documento, output par-ok).
                if par-ok
                then vcnpj = yes.      
            end.                    
        end.
    end.
    if ConsultaCliente.tipo_documento = "2" /* codigo-cliente */ 
    then do:
        vcod = int(ConsultaCliente.numero_documento) no-error.
        if vcod <> 0 and vcod <> ?
        then do.
            find first clien where clien.clicod = vcod no-lock no-error.
            if avail clien
            then do:
                if clien.tippes = no
                then vcnpj = yes.
                find first neuclien where neuclien.clicod = clien.clicod no-lock no-error.
                if avail neuclien
                then do:
                    vcpf = dec(clien.ciccgc) no-error.
                    if neuclien.cpfcnpj = ?
                    then do on error undo:
                        find first bneuclien where bneuclien.cpf = dec(clien.ciccgc) no-error.
                        if avail bneuclien
                        then do:
                            if bneuclien.clicod = ?
                            then do:
                                delete bneuclien.
                                find current neuclien exclusive no-wait no-error.
                                if avail neuclien
                                then do:
                                    neuclien.cpfcnpj = dec(clien.ciccgc).
                                end.
                            end.
                            else do:
                                vstatus = "E".
                                vmensagem_erro = "3CLIENTE " + trim(string(vcod)) + " TEM CPF " + clien.ciccgc
                                                 + 
                                                 " E TAMBEM NEUCLIEN.CPF " + string(bneuclien.cpf).

                            end.
                        end.
                        else do:
                            find current neuclien exclusive no-wait no-error.
                            if avail neuclien
                            then do:
                                neuclien.cpfcnpj = dec(clien.ciccgc).
                            end.
                        end.
                    end.
                    else do:
                        if neuclien.cpf <> vcpf
                        then do:
                            vstatus = "E".
                            vmensagem_erro = "CLIENTE " + trim(string(vcod)) + " TEM CPF " + clien.ciccgc
                                             + 
                                             " E TAMBEM NEUCLIEN.CPF " + string(neuclien.cpf).
                        end.
                    end.
                end.
                else do:
                    vforcaadmcom = yes. /* #8 */
                end.
            end.      
        end.
    end.

    if not avail clien
    then assign
            vstatus = "E"
            vmensagem_erro = "Cliente " + ConsultaCliente.numero_documento + 
            " nao encontrado.".
    else do:
        /* #8 */
        if vprocessa_credito and vcnpj
        then do: 
            vmensagem_erro = "PJ nao pode ser Tipo CREDIARIO".
            vstatus = "R". /* #8 */
        end.

    end.
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos".
    
if vstatus = "S" and
   avail clien and
   clien.clicod > 1
then do.

    vtime = time.
    
    vcpf = dec(clien.ciccgc) no-error.
    if vcpf <> ? and vcpf <> 0
    then do:
        
        /* _05 */
        if not avail neuclien
        then find neuclien where neuclien.cpfcnpj = dec(clien.ciccgc) /** int64 **/
                no-lock no-error.
        if not avail neuclien
        then do:
             /*#3*/
             run neuro/gravaneuclilog.p 
                (clien.ciccgc, 
                 vtipoconsulta, 
                 0, 
                 setbcod, 
                 consultacliente.numero_pdv, 
                 "", 
                 "Cadastrando NeuClien"). 
    
             create PreAutorizacao.
             preAutorizacao.codigo_filial   = consultacliente.codigo_filial.
             preAutorizacao.codigo_cliente  = string(clien.clicod).
             preautorizacao.cpf             = clien.ciccgc.
             preautorizacao.tipo_pessoa     = if clien.tippes
                                              then "J"
                                              else "F".
             preAutorizacao.nome_pessoa     = clien.clinom.
             preautorizacao.data_nascimento = string(year(clien.dtnasc),"9999") +
                                              ":" +
                                              string(month(clien.dtnasc),"99")  +
                                              ":" +
                                              string(day(clien.dtnasc),"99").

             run neuro/gravaneuclien_06.p (clien.ciccgc,
                                        output par-recid-neuclien).
            
             find neuclien
                    where recid(neuclien) = par-recid-neuclien 
                    no-lock 
                    no-error.
            if not avail neuclien
            then do:
                vstatus = "E".
                vmensagem_erro = "Erro ao Cadastrar Credito Cliente".
            end.
        end.            
        else do:
            par-recid-neuclien = recid(neuclien).
        end. 
    
        if vstatus = "S"
        then do:
            if neuclien.clicod = ? 
            then do:  
                run neuro/gravaneuclihist.p   
                        (recid(neuclien), 
                         vtipoconsulta, 
                         setbcod, 
                         clien.clicod, 
                         neuclien.vctolimite, 
                         neuclien.vlrlimite, 
                         0,
                         neuclien.sit_credito).
            end.
            if neuclien.clicod <> clien.clicod
            then do:
                find clien where clien.clicod = neuclien.clicod no-lock no-error.
                if avail clien
                then vmensagem_erro = "CPF " + clien.CICCGC + " Cadastrado Conta Principal " + string(neuclien.clicod). 
            end.
        end.
    end.
    else do:
        vstatus = "N".
        vmensagem_erro =  "CPF '" + clien.CICCGC + "' da CONTA " + string(clien.clicod) + " Precisa ser Consertado." . 
    end.
        
    /* _05 */
    
    if vstatus = "S"
    then do:
         
        run ./progr/hiscli_05.p (clien.clicod).

        /* _05 */

       /** Testa se vai para NEUROTECH **/

        /* #3 */
        vneu_cdoperacao = "".       
        vneu_politica = "".
        /* Verifica se existe P2 Pendente */
            find first neuproposta where
                neuproposta.etbcod  = setbcod and
                neuproposta.dtinclu = today   and
                neuproposta.cpfcnpj = neuclien.cpfcnpj and
                neuproposta.hrinclu >= time - (5 * 60)
                and
                    (neuproposta.tipoconsulta = "P2" )
                and 
                    neuproposta.neu_resultado = "P" 
            no-lock no-error.

            if avail neuproposta
            then do:
                if neuproposta.neu_resultado = "P" and
                    (neuproposta.tipoconsulta = "P2" )
                then do:
                    vneu_cdoperacao = neuproposta.neu_cdoperacao.
                    vneu_politica   = neuproposta.tipoconsulta.
                    vsit_credito    = neuproposta.neu_resultado.
                    vneurotech = yes.
                end.    
            end.
         /* #3 */

        vPOLITICA = "P4".

        if vprocessa_credito /* #_06*/
           and vforcaadmcom = no
        then do:
            run neuro/submeteneuro_v1802.p (input setbcod,
                                      input vpolitica,
                                      input clien.clicod,
                                      0,
                                      output vlojaneuro,
                                      output vneurotech).
        end.
        else do: /* #_06 */
            vlojaneuro = no.
            vneurotech = no.
            vsit_credito = "A".
        end. 

        /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */ 
        run neuro/gravaneuclilog.p 
                (neuclien.cpfcnpj, 
                 vtipoconsulta, 
                 0, 
                 setbcod, 
                 consultacliente.numero_pdv, 
                 neuclien.sit_credito, 
                 if vprocessa_credito
                 then "Politica " + vpolitica + " LJNeuro=" + string(vlojaneuro,"S/N") +
                                                " Submete=" + string(vneurotech,"S/N")
                 else "TPCadastro " + vtipo_cadastro + " SIT=" + vsit_credito). 
                                 
        /*
        *if  vlojaneuro /* 16.11.2017 */
        *    and
        *    (
        *        (neuclien.vctolimite <> ?      /* Limite Valido */
        *        and neuclien.vctolimite >= today )
        *        or
        *        (neuclien.vlrlimite = 0)           /* Ou Limite Zerado */
        *    )
        **/
        /*  #1 
            VALIDA:
            SEMPRE TESTE SE CLIENTE TEM LIMITE VALIDO - USA O VLRLIMiTE
            SE FOR LOJANEURO e o VLRLIMITE FOR ZERADO - NAO VAO NO MOTOR
        */  
        if avail neuclien
        then do:
            vvlrLimite   = neuclien.vlrlimite.
            vvctoLimite  = neuclien.vctolimite.
            if (neuclien.vctolimite < today or neuclien.vctolimite = ? or neuclien.vlrlimite = 0)
                and vneurotech = no
            then vforcaadmcom = yes.    
        end.
        if vneu_cdoperacao <> "" or /* #3 */ 
           (avail neuclien and
              (  (neuclien.vctolimite <> ? and neuclien.vctolimite >= today)
              )
           )
           /* #8 */
           or (avail neuclien and vneurotech) /* #8 na consulta nao sobe mais para neurotech */
        then do:                            /* Nao vai para a Neuro */

            if vneu_cdoperacao <> "" /* #3 */
            then do:
                run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     0, 
                     setbcod, 
                     consultacliente.numero_pdv, 
                     neuclien.sit_credito, 
                     "Proposta " + neuproposta.tipoconsulta + 
                     " Pendente " + vneu_cdoperacao).
            end.
            else do:
                run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     0, 
                     setbcod, 
                     consultacliente.numero_pdv, 
                     neuclien.sit_credito, 
                     "USANDO NEUCLIEN VCTO=" + (if neuclien.vctolimite = ?
                                               then "-"
                                               else string(neuclien.vctolimite)) + 
                     " VLR=" + string(neuclien.vlrlimite)).
            end.
                                 
            vvlrLimite   = neuclien.vlrlimite.
            vvctoLimite  = neuclien.vctolimite.
            vsit_credito = if vneu_cdoperacao <> ""  /* #3 */
                           then "P" 
                           else "A".
            
        end.
        
        /* #7
        else do:
            /* #1
                cai neste ELSE
                QUANDO NAO POSSUIR NEUCLIEN
                QUANDO LIMITE NAO ESTIVER VALIDO
                QUANDO LIMITE FOR ZERADO e for LOJA ADMCOM
           */    
            
            /* #1 LOG PARA SUBMETE */ 
            pause 1 no-message.
            vtimeini = time. 
#7            run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     vtimeini, 
                     setbcod, 
                     consultacliente.numero_pdv, 
                     neuclien.sit_credito, 
                     if vneurotech
                     then "SUBMETE=" + vPOLITICA
                     else "NAO SUBMETE").

            if vneurotech  /* #8 nao cai mais aqui */
            then do:
                /* cai aqui 
                    QUANDO LOJANEURO e REGRAS SUBMISSAO = SUBMETE 
                */    
        
                find current neuclien no-lock.         
        
#7              run neuro/comportamento.p (neuclien.clicod, ?,  
                                       output var-propriedades). 

                var-atrasoatual = int(pega_prop("ATRASOATUAL")). /* #4 */
                var-saldototnov = dec(pega_prop("SALDOTOTNOV")). /* #4 */
                
                var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
                if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
        
                var-parcpag = int(pega_prop("PARCPAG")). 
                if var-parcpag = ? then var-parcpag = 0.
 
                find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

                vrenda          = if clien.prorenda[1] = ?
                                  then 0
                                  else clien.prorenda[1].
                vrenda_conjuge  = if clien.prorenda[2] = ?
                                  then 0
                                  else clien.prorenda[2].
          
                    if avail cpclien and cpclien.var-char8 <> ?
                    then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
                    else vinstrucao = "".
                    if avail cpclien and cpclien.var-char6 <> ?
                    then vseguro = entry(1,trim(cpclien.var-char6),"=").
                    else vseguro = "".
                    if avail cpclien and cpclien.var-char7 <> ?
                    then vplanosaude = entry(1,cpclien.var-char7,"=").
                    else vplanosaude = "".
         
                    vlstcartaocred = "".
                    do vx = 1 to 7.
                        if avail cpclien  
                        then if int(cpclien.var-int[vx]) > 0
                             then vlstcartaocred = vlstcartaocred + auxcartao[vx].
                        if vx < 7 
                        then  vlstcartaocred = vlstcartaocred + ";".     
                    end.
                                
                /* veiculo */
                vveiculo = "N".
                vlstdadosveic = "".
                find carro where carro.clicod = clien.clicod no-lock no-error.
                if avail carro
                then if carro.carsit 
                     then vveiculo = "S".
                if vveiculo = "S"
                then do:
                    vlstdadosveic =  Texto(carro.marca) +  ";" +
                                     Texto(carro.modelo) + ";" +
                                   if carro.ano <> ?
                                   then string(carro.ano,"9999")         
                                   else "".
                end.
                vlstrefpessoais = "".
                do vx = 1 to 3.
                    vlstrefpessoais = vlstrefpessoais +
                                      (if vlstrefpessoais = ""
                                       then ""
                                       else ";")
                                       +
                                         Texto(clien.entbairro[vx]) + "|" + 
                                         Texto(clien.entcep[vx])    + "|" + 
                                         Texto(clien.entcidade[vx]) + "|" +
                                         Texto(clien.entcompl[vx]). 
                   end.

                vlstrefcomerc = "".
                do vx = 1 to 5:
                    vlstrefcomerc = vlstrefcomerc + 
                                    (if vlstrefcomerc = "" then "" else ";")
                                    +  
                                    Texto(clien.refcom[vx]) +
                                     "|".
                    if avail cpclien
                    then do:
                        if cpclien.var-ext1[vx] = "1" then   vlstrefcomerc = (vlstrefcomerc + "Apresentado").
                        else
                        if cpclien.var-ext1[vx] = "2" then vlstrefcomerc = (vlstrefcomerc + "Nao Apresentado").
                        else
                        if cpclien.var-ext1[vx] = "3" then vlstrefcomerc = vlstrefcomerc + "Nao possui cartao".
                        else vlstrefcomerc = (vlstrefcomerc + " ").  
                    end.                        
                    else vlstrefcomerc = vlstrefcomerc + " ".
                end.
                vlstdadosbanco = "".
                do vx = 1 to 4.
                    /*    
                    if avail cpclien and
                    (cpclien.var-ext2[vx] = "BANRISUL" or 
                     cpclien.var-ext2[vx] = "CAIXA ECONOMICA FEDERAL" or
                     cpclien.var-ext2[vx] = "BANCO DO BRASIL" or
                     cpclien.var-ext2[vx] = "OUTROS")
                    then*/ do:   
                        vlstdadosbanco = vlstdadosbanco +
                                        (if vlstdadosbanco = "" then "" else ";") +
                                         texto(if avail cpclien then cpclien.var-ext2[vx] else "") + "|" +
                                         texto(if avail cpclien then cpclien.var-ext3[vx] else "") + "|" +
                                         texto(if avail cpclien then cpclien.var-ext4[vx] else "").
                    end.
                end.   
                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "".
  

                    vdtnasc = clien.dtnasc.
                    vprops = 
                        "POLITICA="             + "CREDITO" + texto(string(setbcod,"9999")) +
                        "&PROP_CONTACLI="       + trim(string(clien.clicod))   
                       + "&PROP_CPFCLI="       + trim(texto(string(neuclien.cpf)))   
                       + "&PROP_DTNASCCLI="      + texto(string(clien.dtnasc,"99/99/9999")) 
                       + "&PROP_LOJACAD="        + trim(texto(string(neuclien.etbcod))) 
                       + "&PROP_LIMITEATUAL="    + trim(texto(string(neuclien.vlrlimite))) 
                       + "&PROP_VALIDADELIM="    + (if neuclien.vctolimite = ? then ""
                                                   else string(neuclien.vctolimite,"99/99/9999") )
                       + "&PROP_PROFISSAO="      +      Texto(clien.proprof[1])
                       + "&PROP_RENDAMES="       +      string(vrenda)
                       + "&PROP_LOGRADCLI=" + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="    + texto(string(clien.numero[1]))
                       + "&PROP_CEP="            +      Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="      +      Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="    +      Texto(clien.compl[1])  
                       + "&PROP_CIDADE="         +      Texto(clien.cidade[1])
                       + "&PROP_UF="             +      Texto(clien.ufecod[1])
                       + "&PROP_NOTA="           + (if  not avail cpclien then ""
                                                  else texto( string(cpclien.var-int3) )   )
                      + "&PROP_DTADMISSAO="     +      texto(string(clien.prodta[1],"99/99/9999"))
                       + "&PROP_CPFCONJUGE="   +  texto(substr(clien.conjuge,51,20))
                       + "&PROP_RENDACONJUGE="   +       string(vrenda_conjuge)  
                       + "&PROP_PROFCONJUGE=" + texto(clien.proprof[2])    
                       + "&PROP_TELEFONE="       +      Texto(clien.fone) 
                       + "&PROP_INSTRUCAOCLI="   + texto(vinstrucao)   
                       + "&PROP_SEGURO="         + texto(vseguro)
                       + "&PROP_PLANOSAUDE="     + texto(vplanosaude)
                       + "&PROP_LSTCARTAOCRED="  +  vlstcartaocred  
                       + "&PROP_VEICULO="        +  vveiculo
                       + "&PROP_LSTDADOSVEIC="   +  vlstdadosveic  
                       + "&PROP_LSTREFPESSOAIS=" +  vlstrefpessoais 
                       + "&PROP_LSTREFCOMERC="   +  vlstrefcomerc  
                       + "&PROP_LSTDADOSBANCO="  +  vlstdadosbanco  
                       + "&PROP_ESTADOCIVIL="    + texto(cestcivil)   
                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_TIPORESID="      +      string(clien.tipres,
                                                            "Propria/Alugada")
                       + "&PROP_TEMPORESID="     +      texto(    substr(string(int(clien.temres),"999999"),1,2) + "/"  + 
                                                                  substr(string(int(clien.temres),"999999"),3,4) )

                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_NOMECLI="        + trim(clien.clinom)   
                       + "&PROP_PARCPAG=" + string(var-parcpag)
                       + "&PROP_ATRASOPARCPERC=" + texto(var-atrasoparcperc)
                       + "&PROP_ATRASOATUAL="    + string(var-atrasoatual)  /* #4 */
                       + "&PROP_SALDOTOTNOV="    + string(var-saldototnov)  /* #4 */
                       
    
                      +  "&PROP_FLXPOLITICA="    + vPOLITICA.
                pause 1 no-message. 
                vtimeini = time.
                if vprops <> ?
#7                then         run neuro/wcneurotech_v1801.p (setbcod,
                                                  int(ConsultaCliente.numero_pdv),
                                                  input vprops,
                                                  input vPOLITICA,
                                                  input vtimeini,
                                                  input par-recid-neuclien, 
                                                  output vvlrLimite, 
                                                  output vvctolimite,
                                                  output vneuro-sit, 
                                                  output vneuro-mens,
                                                  output vstatus,
                                                  output vmensagem_erro).
                else vstatus = "N".
                
                if vstatus = "S" /* Sem Erros */
                then do: 
                    if vneuro-sit = "P"  
                    then vneuro-mens = if vneuro-mens = "" 
                                       then "Encaminhar Cliente a FILA DE CREDITO"
                                           else vneuro-mens.
                    else vneuro-mens = if vneuro-mens = ""
                                       then ""
                                       else vneuro-mens.
                    vsit_credito = vneuro-sit.
                end.
                else do:
                    vneurotech = no. /* Usa Processo ADMCOM */
                    vstatus = "S".
                    vmensagem_erro = "".
                end.                
                /* #1 */
#7                run neuro/gravaneuclilog.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         0, 
                         setbcod, 
                         consultacliente.numero_pdv, 
                         neuclien.sit_credito, 
                         if not vneurotech
                         then "ERRO MOTOR - USARA ADMCOM"
                         else "SIT=" + vsit_credito +
                              " VCTO=" + (if vvctolimite = ?
                                         then "-"
                                         else string(vvctolimite)) + 
                              " LIM=" + (if vvlrlimite = ?
                                         then "-"
                                         else string(vvlrlimite))). 
                vtimeini = 0.
            end.
        end.
        #7 **/        
            if vneurotech = no 
                and vprocessa_credito /* #_06 */
                and vforcaadmcom
            then do: /** ADMCOM **/

                pause 1 no-message.

                vtime = time.
                vtimeini = time.
                run neuro/callimiteadmcom.p (recid(neuclien),
                                    "ADMA", /* #8 */
                                    vtime,
                                    setbcod,
                                    consultacliente.numero_pdv,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
                /* #2 */
                run neuro/gravaneuclilog.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         vtimeini, 
                         setbcod, 
                         consultacliente.numero_pdv, 
                         neuclien.sit_credito, 
                         if vneurotech
                         then "USARA ADMCOM"
                         else "SIT=" + vsit_credito +
                              " VCTO=" + (if vvctolimite = ?
                                         then "-"
                                         else string(vvctolimite)) + 
                              " LIM=" + (if vvlrlimite = ?
                                         then "-"
                                         else string(vvlrlimite))). 

                if vsit_credito = "E"
                then do:
                    vstatus = "E".
                    vmensagem_erro = "Erro ao calcular Limite Admcom". 
                end.
                
            end.
                                 
            
        if /*#7 vneurotech = no and */
           /*#7*/ vlojaneuro = no and
           vprocessa_credito /* #_06 */
        then do:
            /* #6
            find first clispc where clispc.clicod = clien.clicod
                                and clispc.dtcanc = ?
                          no-lock no-error.
            */
            /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */ 
            /*pause 1 no-message.*/
            vtimeini = time.
            run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     vtimeini, 
                     setbcod, 
                     consultacliente.numero_pdv, 
                     "", 
                     if /* #6 not avail clispc and */ clien.tippes
                     then "SPC"
                     else "").

            if clien.tippes /* #6 and
               not avail clispc */
            then do.
                varqestatistica = "/ws/log/p2k_spcsicred_estatistica_" + 
                    string(today, "99999999") + ".log".
        
                vtimeini = time. 
                    run ./progr/pdv/spcpreconsulta.p (?, recid(clien),
                                                  output par-spc, 
                                                  output vlibera-cli).
                if par-spc 
                then do:
                    run neuro/gravaneuclilog.p
                            (neuclien.cpfcnpj,
                             vtipoconsulta,
                             vtimeini,
                             setbcod,
                             consultacliente.numero_pdv,
                             neuclien.sit_credito,
                             "CONSULTANDO"). 

                    run ./progr/pdv/spcconsulta_v02.p (setbcod,
                                       recid(clien),
                                       output par-spc,
                                       output spc-conecta).
                    if not par-spc
                    then vlibera-cli = no. /* #6 */
                    vsit_credito = if par-spc
                                   then "A" else "R".

                    run neuro/gravaneuclilog.p
                                (neuclien.cpfcnpj,
                                 vtipoconsulta,
                                 0,
                                 setbcod,
                                 consultacliente.numero_pdv,
                                 vsit_credito,
                                 "SPC Cliente " +
                                    string(par-spc,"Nao Consta/Consta")).

                    if neuclien.sit_credito <> vsit_credito
                    then do:
                        run neuro/gravaneuclihist.p 
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
                    run neuro/gravaneuclilog.p
                            (neuclien.cpfcnpj,
                             vtipoconsulta,
                             vtimeini,
                             setbcod,
                             consultacliente.numero_pdv,
                             neuclien.sit_credito,
                             "NAO"). 
                 
                end.
                output to value(varqestatistica) append.
                    put unformatted
                    skip
                    "spcconsulta" + ";" +
                    string(today,"99999999") + ";" +
                    replace(string(vtimeini,"HH:MM:SS"),":","") + ";" +
                    replace(string(time,"HH:MM:SS"),":","") + ";" +
                    replace(string(time - vtimeini,"HH:MM:SS"),":","") + ";" +
                    string(par-spc,"NAO/SIM") skip.
                output close.
            end.
        end. 
    end.  
    
end.

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",ConsultaCliente.codigo_filial).
bsxml("numero_pdv",ConsultaCliente.numero_pdv).
    
if avail clien
then do:
    find cpclien where cpclien.clicod =  clien.clicod no-lock no-error.
        
    bsxml("codigo_cliente",string(clien.clicod)).
    
    /* #5 */
    if avail neuclien and 
       neuclien.cpf <> ? 
    then do:
        if clien.tippes = no /* JURIDICA CNPJ VAI AQUI TAMBEM */
        then do:
            bsxml("cpf",string(neuclien.cpfcnpj,"99999999999999")).
        end.
        else do:
            bsxml("cpf",string(neuclien.cpfcnpj,"99999999999")).
        end.
    end.
    else bsxml("cpf",texto(clien.ciccgc)).

    bsxml("nome",Texto(clien.clinom)).
    bsxml("data_nascimento", EnviaData(clien.dtnasc)).
    bsxml("codigo_senha","").
    bsxml("valor_limite",string(vVlrLimite - sal-aberto,"->>>>>>>>>9.99")).
    /*** lim-calculado ***/

    bsxml("codigo_bloqueio","0").
    bsxml("descricao_bloqueio","").
    bsxml("percentual_desconto","0").
    bsxml("validade_desconto","").  /* incluido em 05/01/2015 */
    bsxml("valor_seguro","0").
    bsxml("situacao_seguro_cliente","").

    bsxml("cep",Texto(clien.cep[1])).
    bsxml("endereco",Texto(clien.endereco[1])).

    if clien.numero[1] <> ?
    then bsxml("numero",string(clien.numero[1])).
    else bsxml("numero","").

    bsxml("complemento",Texto(clien.compl[1])).
    bsxml("bairro",Texto(clien.bairro[1])).
    bsxml("cidade",Texto(clien.cidade[1])).
    bsxml("uf",Texto(clien.ufecod[1])).
    bsxml("pais","BRA").
    bsxml("email",lc(Texto(clien.zona))).
        
    if avail cpclien and 
       cpclien.emailpromocional = true
    then assign vrecebe-email-promo = "Sim".
    else assign vrecebe-email-promo = "Nao".    
    if vrecebe-email-promo = ?
    then vrecebe-email-promo = "".
    bsxml("deseja_receber_email",vrecebe-email-promo).
        
    bsxml("ddd","").
    bsxml("telefone",Texto(clien.fone)).

    if clien.tippes <> ?
    then bsxml("tipo_pessoa",string(clien.tippes,"F/J")).
    else bsxml("tipo_pessoa","").

    /* _05 **/
    bsxml("credito", string(vvlrLimite,">>>>>>>9.99")).
    /** _05 **/
    
    bsxml("tipo_credito", texto(string(clien.classe))).
        
    if clien.sexo <> ?
    then bsxml("sexo",string(clien.sexo,"M/F")).
    else bsxml("sexo","").
        
    bsxml("nacionalidade",Texto(clien.nacion)).
    bsxml("identidade",Texto(clien.ciins)).
    bsxml("orgao_emissor","").
        
    cestcivil = if clien.estciv = 1 then "Solteiro" else
                if clien.estciv = 2 then "Casado"   else
                if clien.estciv = 3 then "Viuvo"    else
                if clien.estciv = 4 then "Desquitado" else
                if clien.estciv = 5 then "Divorciado" else
                if clien.estciv = 6 then "Falecido" else "". 
    bsxml("estado_civil",cestcivil).
    if avail cpclien
    then bsxml("naturalidade",Texto(cpclien.var-char10)).
    else bsxml("naturalidade","").
    
    if clien.tippes = no /* #5 12.06.2018 - helio ajustado */
    then do:
        if avail neuclien and
           neuclien.cpf <> ?
        then bsxml("cnpj",string(neuclien.cpfcnpj,"99999999999999")).
        else bsxml("cnpj",texto(clien.ciccgc)).
    end.
    else bsxml("cnpj","").

    bsxml("pai",Texto(clien.pai)).
    bsxml("mae",Texto(clien.mae)).

    if clien.numdep <> ?
    then bsxml("numero_dependentes",string(clien.numdep)).
    else bsxml("numero_dependentes","").

    if avail cpclien and cpclien.var-char8 <> ?
    then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
    else vinstrucao = "".
    bsxml("grau_de_instrucao",Texto(vinstrucao)).

    if avail cpclien and cpclien.var-log8 = true
    then assign vsituacao-instrucao = "Sim".
    else assign vsituacao-instrucao = "Nao".    
    if vsituacao-instrucao = ?
    then vsituacao-instrucao = "".
    bsxml("situacao_grau_instrucao",vsituacao-instrucao).
 
    if avail cpclien and cpclien.var-char7 <> ?
    then vinstrucao = entry(1,cpclien.var-char7,"=").
    else vinstrucao = "".
    bsxml("plano_saude",Texto(vinstrucao)).

    if avail cpclien and cpclien.var-char6 <> ?
    then vinstrucao = entry(1,trim(cpclien.var-char6),"=").
    else vinstrucao = "".
    bsxml("seguros",Texto(vinstrucao)).

    if avail cpclien and cpclien.var-char9 <> ?
    then bsxml("ponto_referencia",Texto(cpclien.var-char9)).
    else bsxml("ponto_referencia","").

    bsxml("celular",Texto(clien.fax)).
                
    bsxml("tipo_residencia",if clien.tipres then "Propria" else "Alugada").
    bsxml("tempo_na_residencia",texto(string(clien.temres,"999999"))).
    bsxml("data_cadastro",EnviaData(clien.dtcad)).
    bsxml("data_ultima_compra",EnviaData(ult-compra)).
    bsxml("quantidade_contrato",       string(qtd-contrato)).
    bsxml("prestacoes_pagas",          string(parcela-paga)).
    bsxml("prestacoes_abertas",        string(parcela-aberta)).
    bsxml("qtd_atraso_ate_15dias",     string(qtd-15) ).

    if pagas-db > 0
    then assign vperc15 = (qtd-15 * 100) / pagas-db
                vperc45 = (qtd-45 * 100) / pagas-db
                vperc46 = (qtd-46 * 100) / pagas-db.

    bsxml("percentual_atraso_ate_15dias",   string(vperc15)).
    bsxml("qtd_atraso_15dias_ate_45dias",   string(qtd-45)).
    bsxml("percentual_atraso_15dias_ate_45dias",string(vperc45)).
    bsxml("qtd_atraso_maior_45dias",        string(qtd-46)).
    bsxml("percentual_atraso_maior_45dias", string(vperc46)).
    bsxml("reparcelamento", if vrepar then "Sim" else "Nao").

    if vqtd > 0
    then vmedia = (vtotal / vqtd).
    bsxml("media_por_contrato_contrato", string(vmedia)).
    bsxml("maior_valor_acumulado", string(v-acum)).
    bsxml("mes_ano",               string(v-mes) + string(v-ano)).
    bsxml("prestacao_media",       string(v-media)).
    bsxml("proximo_mes",           string(proximo-mes)).
    bsxml("maior_atraso",          string(maior-atraso)).
    bsxml("parcelas_vencidas",string(vencidas,">>>>>>>9.99")).
    bsxml("vl_cheque_devolvidos","0").

    /* dados profisionais */
    bsxml("empresa",Texto(clien.proemp[1])).
    if avail cpclien
    then bsxml("cnpj_empresa",Texto(cpclien.var-char1)).
    else bsxml("cnpj_empresa","").
    
    bsxml("telefone_empresa",Texto(clien.protel[1])).
    bsxml("data_admissao",EnviaData(clien.prodta[1])).
    bsxml("profissao",Texto(clien.proprof[1])).

    if clien.prorenda[1] = ?
    then bsxml("renda_total","0").
    else bsxml("renda_total",string(clien.prorenda[1],">>>>>>>9.99")).

    bsxml("endereco_empresa",Texto(clien.endereco[2])).
        
    if clien.numero[2] = ?
    then bsxml("numero_empresa","").
    else bsxml("numero_empresa",string(clien.numero[2])).

    bsxml("complemento_empresa",Texto(clien.compl[2])).
    bsxml("bairro_empresa",Texto(clien.bairro[2])).
    bsxml("cidade_empresa",Texto(clien.cidade[2])).
    bsxml("estado_empresa",Texto(clien.ufecod[2])).
    bsxml("cep_empresa",   Texto(clien.cep[2])).

    /* conjuge */
    bsxml("nome_conjuge",Texto(substr(clien.conjuge,1,50))).
    bsxml("cpf_conjuge",texto(substr(clien.conjuge,51,20))).
    bsxml("data_nascimento_conjuge",EnviaData(clien.nascon)).
    bsxml("pai_conjuge",Texto(clien.conjpai)).
    bsxml("mae_conjuge",Texto(clien.conjmae)).
    bsxml("empresa_conjuge",  Texto(clien.proemp[2])).
    bsxml("telefone_conjuge", Texto(clien.protel[2])).
    bsxml("profissao_conjuge",Texto(clien.proprof[2])).
    bsxml("data_admissao_conjuge",EnviaData(clien.prodta[2])).

    if clien.prorenda[2] = ?
    then bsxml("renda_mensal_conjuge","0").
    else bsxml("renda_mensal_conjuge",string(clien.prorenda[2], ">>>>>>9.99")).

    /* referencias */
/***
    vcartao = 0.
    if avail cpclien
    then do vi = 1 to 7.
        if int(cpclien.var-int[vi]) > 0
        then vcartao = vi.
    end.
    bsxml("cartoes_de_credito",string(vcartao)).
***/
        vcartao = "".
    if avail cpclien
    then 
        do vi = 1 to 7.
            if vcartao <> ""
            then vcartao = vcartao + ",".
            if int(cpclien.var-int[vi]) > 0
            then vcartao = vcartao + auxcartao[vi].
        end.
    bsxml("cartoes_de_credito",vcartao).

    if avail cpclien and
       (cpclien.var-ext2[1] = "BANRISUL" or 
        cpclien.var-ext2[1] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[1] = "BANCO DO BRASIL" or
        cpclien.var-ext2[1] = "OUTROS")
    then do:   
        bsxml("banco1", texto(cpclien.var-ext2[1])).
        bsxml("tipo_conta_banco1",texto(cpclien.var-ext3[1])).
        bsxml("ano_conta_banco1", texto(cpclien.var-ext4[1])).
    end.
    else do:
        bsxml("banco1", "").
        bsxml("tipo_conta_banco1","").
        bsxml("ano_conta_banco1", "").
    end.
           
    if avail cpclien and
       (cpclien.var-ext2[2] = "BANRISUL" or 
        cpclien.var-ext2[2] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[2] = "BANCO DO BRASIL" or
        cpclien.var-ext2[2] = "OUTROS")
    then do:   
        bsxml("banco2", cpclien.var-ext2[2]).
        bsxml("tipo_conta_banco2",cpclien.var-ext3[2]).
        bsxml("ano_conta_banco2", cpclien.var-ext4[2]).
    end.
    else do:
        bsxml("banco2", "").
        bsxml("tipo_conta_banco2","").
        bsxml("ano_conta_banco2", "").
    end.

    if avail cpclien and
       (cpclien.var-ext2[3] = "BANRISUL" or 
        cpclien.var-ext2[3] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[3] = "BANCO DO BRASIL" or
        cpclien.var-ext2[3] = "OUTROS")
    then do:   
        bsxml("banco3", cpclien.var-ext2[3]).
        bsxml("tipo_conta_banco3",cpclien.var-ext3[3]).
        bsxml("ano_conta_banco3", cpclien.var-ext4[3]).
    end.
    else do:
        bsxml("banco3", "").
        bsxml("tipo_conta_banco3","").
        bsxml("ano_conta_banco3", "").
    end.
            
    if avail cpclien and
       (cpclien.var-ext2[4] = "BANRISUL" or 
        cpclien.var-ext2[4] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[4] = "BANCO DO BRASIL" or
        cpclien.var-ext2[4] = "OUTROS")
    then do:   
        bsxml("banco_outros", cpclien.var-ext2[4]).
        bsxml("tipo_conta_outros",cpclien.var-ext3[4]).
        bsxml("ano_banco_outros", cpclien.var-ext4[4]).
    end.
    else do:
        bsxml("banco_outros", "").
        bsxml("tipo_conta_outros","").
        bsxml("ano_banco_outros", "").
    end.

    bsxml("referencias_comerciais1",Texto(clien.refcom[1])).

    if avail cpclien
    then 
        case cpclien.var-ext1[1]:
          when "1"
            then bsxml("situacao_referencias_comerciais1","Apresentado").
          when "2"
            then bsxml("situacao_referencias_comerciais1","Nao Apresentado").
          when "3"
            then bsxml("situacao_referencias_comerciais1","Nao possui cartao").
          otherwise
             bsxml("situacao_referencias_comerciais1","").  
        end case.    
    else bsxml("situacao_referencias_comerciais1","").

    bsxml("referencias_comerciais2",Texto(clien.refcom[2])).

    if avail cpclien
    then
        case cpclien.var-ext1[2]:
          when "1"
            then bsxml("situacao_referencias_comerciais2","Apresentado").
          when "2"
            then bsxml("situacao_referencias_comerciais2","Nao Apresentado").
          when "3"
            then bsxml("situacao_referencias_comerciais2","Nao possui cartao").
          otherwise
             bsxml("situacao_referencias_comerciais2","").  
        end case.
    else bsxml("situacao_referencias_comerciais2","").

    bsxml("referencias_comerciais3",Texto(clien.refcom[3])).

    if avail cpclien
    then
        case cpclien.var-ext1[3]:
          when "1"
            then bsxml("situacao_referencias_comerciais3","Apresentado").
          when "2"
            then bsxml("situacao_referencias_comerciais3","Nao Apresentado").
          when "3"
            then bsxml("situacao_referencias_comerciais3","Nao possui cartao").
          otherwise
             bsxml("situacao_referencias_comerciais3","").  
        end case.
    else bsxml("situacao_referencias_comerciais3","").

    bsxml("referencias_comerciais4",Texto(clien.refcom[4])).

    if avail cpclien
    then
        case cpclien.var-ext1[4]:
          when "1"
            then bsxml("situacao_referencias_comerciais4","Apresentado").
          when "2"
            then bsxml("situacao_referencias_comerciais4","Nao Apresentado").
          when "3"
            then bsxml("situacao_referencias_comerciais4","Nao possui cartao").
          otherwise
             bsxml("situacao_referencias_comerciais4","").  
        end case.
    else bsxml("situacao_referencias_comerciais4","").

    bsxml("referencias_comerciais5",Texto(clien.refcom[5])).

    if avail cpclien
    then
        case cpclien.var-ext1[5]:
          when "1"
            then bsxml("situacao_referencias_comerciais5","Apresentado").
          when "2"
            then bsxml("situacao_referencias_comerciais5","Nao Apresentado").
          when "3"
            then bsxml("situacao_referencias_comerciais5","Nao possui cartao").
          otherwise
             bsxml("situacao_referencias_comerciais5","").  
        end case.
    else bsxml("situacao_referencias_comerciais5","").

    if clien.clicod <> 1
    then
        vobs = (if clien.autoriza[1] = ? then "" else clien.autoriza[1]) + " " +
               (if clien.autoriza[2] = ? then "" else clien.autoriza[2]) + " " +
               (if clien.autoriza[3] = ? then "" else clien.autoriza[3]) + " " +
               (if clien.autoriza[4] = ? then "" else clien.autoriza[4]) + " " +
               (if clien.autoriza[5] = ? then "" else clien.autoriza[5]) + "".
    else vobs = "" .
    bsxml("observacoes", Texto(vobs)).         

    /* veiculo */
    vcarro = "NAO".
    find carro where carro.clicod = clien.clicod no-lock no-error.
    if avail carro
    then if carro.carsit 
         then vcarro = "SIM".
    bsxml("possui_veiculo",vcarro).
    if vcarro = "SIM"
    then do:
        bsxml("marca", Texto(carro.marca)).
        bsxml("modelo",Texto(carro.modelo)).
        if carro.ano <> ?
        then bsxml("ano",string(carro.ano,"9999")).         
        else bsxml("ano","").         
    end.
    else do:
        bsxml("marca","").         
        bsxml("modelo","").         
        bsxml("ano","").         
    end.            

    /* referencias pessoas 3 */
    bsxml("nome_ref1",      Texto(clien.entbairro[1])). 
    bsxml("fone_comercial_ref1",Texto(clien.entcep[1])). 
    bsxml("celular_ref1",   Texto(clien.entcidade[1])).
    bsxml("parentesco_ref1",Texto(clien.entcompl[1])).
    bsxml("documentos_apresentados_rf1",Texto(clien.entendereco[1])).
    bsxml("nome_ref2",      Texto(clien.entbairro[2])).
    bsxml("fone_comercial_ref2",Texto(clien.entcep[2])).
    bsxml("celular_ref2",   Texto(clien.entcidade[2])).
    bsxml("parentesco_ref2",Texto(clien.entcompl[2])).
    bsxml("documentos_apresentados_rf2",Texto(clien.entendereco[2])). 
    bsxml("nome_ref3",      Texto(clien.entbairro[3])).
    bsxml("fone_comercial_ref3",Texto(clien.entcep[3])).
    bsxml("celular_ref3",   Texto(clien.entcidade[3])).
    bsxml("parentesco_ref3",Texto(clien.entcompl[3])).
    bsxml("documentos_apresentados_rf3",Texto(clien.entendereco[3])).

    /* consulta spc */   

    vspc_cod_motivo_cancelamento = "".
    vspc_descr_motivo = "".
            
/* #6
    if avail clispc or
       (acha("OK",clien.entrefcom[2]) <> ? and
        acha("OK",clien.entrefcom[2]) = "NAO")
*/
    if not vlibera-cli
    then assign
            vmen-spc = "CLIENTE COM REGISTRO"
            vspc_cod_motivo_cancelamento = "93"
            vspc_descr_motivo = "CLIENTE COM RESTRICAO SPC".
    else vmen-spc = "CLIENTE SEM REGISTRO".

    vdat-spc = date(clien.entrefcom[1]).
    vfil-spc = acha("filial",clien.entrefcom[2]).
    vcon-spc = acha("consultas",clien.entrefcom[2]).
    vale-spc = acha("alertas",clien.entrefcom[2]).
    vcre-spc = acha("credito",clien.entrefcom[2]).
    vche-spc = acha("cheques",clien.entrefcom[2]).
    vnac-spc = acha("nacional",clien.entrefcom[2]).

    bsxml("resultado_consulta_spc", Texto(vmen-spc)).
    bsxml("filial_efetuou_consulta",Texto(vfil-spc)).
    bsxml("data_consulta", EnviaData(vdat-spc)).
    bsxml("quantidade_consultas_realizadas",Texto(vcon-spc)).
    bsxml("registros_de_alertas",Texto(vale-spc)).
    bsxml("registro_do_credito", Texto(vcre-spc)).
    bsxml("registro_de_cheques", Texto(vche-spc)).
    bsxml("registro_nacional",   Texto(vnac-spc)).
    bsxml("spc_cod_motivo_cancelamento",vspc_cod_motivo_cancelamento). 
    bsxml("spc_descr_motivo",vspc_descr_motivo). 

    /* consulta serasa */
    bsxml("resultado_consulta_serasa",""). 
    bsxml("serasa_cod_motivo_cancelamento",""). 
    bsxml("serasa_descr_motivo",""). 
    /* consulta crediario */
    if vatraso = no
    then do:
        bsxml("resultado_consulta_crediario",""). 
        bsxml("crediario_cod_motivo_cancelamento",""). 
        bsxml("crediario_descr_motivo",""). 
    end.
    else do:
        bsxml("resultado_consulta_crediario","CLIENTE COM REGISTRO"). 
        bsxml("crediario_cod_motivo_cancelamento","94"). 
        bsxml("crediario_descr_motivo","CLIENTE COM RESTRICAO CREDIARIO"). 
    end.

    /* cosulta limite */
    bsxml("limite_cod_motivo_cancelamento","95"). 
    bsxml("limite_descr_motivo","CLIENTE COM LIMITE DE CREDITO INSUFICIENTE"). 

    /* nota credit score */
    if not avail cpclien
    then bsxml("nota",""). 
    else bsxml("nota",texto(string(cpclien.var-int3))).

    /* _05 **/
    bsxml("sit_credito", texto(string(vsit_credito))).
    bsxml("vcto_credito", EnviaData(vvctoLimite)).
    
    if avail neuclien
    then do:
        bsxml("codigo_mae", texto(string(neuclien.codigo_mae))).
        bsxml("categoria_profissional", texto(neuclien.catprof)).
    end.
    else do:
        bsxml("codigo_mae", "").
        bsxml("categoria_profissional", "").
    
    end.
        
    /** _05 **/
                                                  
    connect crm -H "sv-mat-db1" -S sdrebcrm -N tcp -ld crm no-error.
    if connected("crm")
    then run ./progr/pegabonus.p (clien.clicod).
    else do:
        create ttbonus.
        ttbonus.nome_bonus = "".
        ttbonus.numero_bonus = "".
        ttbonus.venc_bonus = 01/01/1900.
        ttbonus.vlr_bonus = 0.
    end.
                       
    BSXml("ABREREGISTRO","listabonus"). 
    for each ttbonus.
        BSXml("ABREREGISTRO","bonus").
        bsxml("nome_bonus",Texto(ttbonus.nome_bonus)).
        bsxml("numero_bonus",ttbonus.numero_bonus).
        bsxml("codigo_filial_bonus",string(ttbonus.etbcod)).
        bsxml("venc_bonus",string(year(ttbonus.venc_bonus),"9999") + "-" +
                           string(month(ttbonus.venc_bonus),"99")  + "-" +
                           string( day (ttbonus.venc_bonus),"99")  +
                                     "T00:00:00").
        bsxml("vlr_bonus",string(ttbonus.vlr_bonus,">>>>>>>>9.99")).
        BSXml("FECHAREGISTRO","bonus").
    end.     
    BSXml("FECHAREGISTRO","listabonus"). 
end.

bsxml("tipo_cadastro",consultacliente.tipo_cadastro).

bsxml("fechatabela","return").
BSXml("FECHAXML","").

