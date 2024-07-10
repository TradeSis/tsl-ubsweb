/* helio 31012022 - API REST */
/* helio 22122021 - Cadastro P2k - Campos Optin */
/* HUBSEG 19/10/2021 */


/* API REST */
def input  parameter vlcentrada as longchar.

{/admcom/progr/api/acentos.i}

def temp-table ConsultaCliente no-undo serialize-name "dadosEntrada"
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char
    field tipo_cadastro as char .

/* API REST */
def temp-table ttreturn no-undo serialize-name "return"
FIELD pstatus as char serialize-name "status"
FIELD mensagem_erro as char 
FIELD codigo_filial as char 
FIELD numero_pdv as char 
FIELD tipo_cadastro as char .

def temp-table ttcliente no-undo serialize-name "return"
FIELD pstatus as char serialize-name "status"
FIELD mensagem_erro as char 
FIELD codigo_filial as char 
FIELD numero_pdv as char 
FIELD tipo_cadastro as char 
FIELD codigo_cliente as char 
FIELD cpf as char 
FIELD nome as char 
FIELD data_nascimento as char
FIELD codigo_senha as char 
FIELD valor_limite as char 
FIELD codigo_bloqueio as char 
FIELD descricao_bloqueio as char 
FIELD percentual_desconto as char 
FIELD validade_desconto as char 
FIELD valor_seguro as char 
FIELD situacao_seguro_cliente as char 
FIELD cep as char 
FIELD endereco as char 
FIELD numero as char 
FIELD complemento as char 
FIELD bairro as char 
FIELD cidade as char 
FIELD uf as char 
FIELD pais as char 
FIELD email as char 
FIELD deseja_receber_email as char 
FIELD ddd as char 
FIELD telefone as char 
FIELD tipo_pessoa as char 
FIELD credito as char 
FIELD tipo_credito as char 
FIELD sexo as char 
FIELD nacionalidade as char 
FIELD identidade as char 
FIELD orgao_emissor as char
FIELD estado_civil as char 
FIELD naturalidade as char 
FIELD cnpj as char 
FIELD pai as char 
FIELD mae as char 
FIELD numero_dependentes as char 
FIELD grau_de_instrucao as char 
FIELD situacao_grau_instrucao as char 
FIELD plano_saude as char 
FIELD seguros as char 
FIELD ponto_referencia as char 
FIELD celular as char 
FIELD tipo_residencia as char 
FIELD tempo_na_residencia as char 
FIELD data_cadastro as char
FIELD data_ultima_compra as char
FIELD quantidade_contrato as char 
FIELD prestacoes_pagas as char 
FIELD prestacoes_abertas as char 
FIELD qtd_atraso_ate_15dias as char 
FIELD percentual_atraso_ate_15dias as char 
FIELD qtd_atraso_15dias_ate_45dias as char 
FIELD perc15-45 as char serialize-name "percentual_atraso_15dias_ate_45dias"
FIELD qtd_atraso_maior_45dias as char 
FIELD percentual_atraso_maior_45dias as char 
FIELD reparcelamento as char 
FIELD media_por_contrato_contrato as char 
FIELD maior_valor_acumulado as char 
FIELD mes_ano as char 
FIELD prestacao_media as char 
FIELD proximo_mes as char 
FIELD maior_atraso as char 
FIELD parcelas_vencidas as char 
FIELD vl_cheque_devolvidos as char 
FIELD empresa as char 
FIELD cnpj_empresa as char 
FIELD telefone_empresa as char 
FIELD data_admissao as char
FIELD profissao as char 
FIELD renda_total as char 
FIELD endereco_empresa as char 
FIELD numero_empresa as char 
FIELD complemento_empresa as char 
FIELD bairro_empresa as char 
FIELD cidade_empresa as char 
FIELD estado_empresa as char 
FIELD cep_empresa as char 
FIELD nome_conjuge as char 
FIELD cpf_conjuge as char 
FIELD data_nascimento_conjuge as char
FIELD pai_conjuge as char 
FIELD mae_conjuge as char 
FIELD empresa_conjuge as char 
FIELD telefone_conjuge as char 
FIELD profissao_conjuge as char 
FIELD data_admissao_conjuge as char
FIELD renda_mensal_conjuge as char 
FIELD cartoes_de_credito as char 
FIELD banco1 as char 
FIELD tipo_conta_banco1 as char 
FIELD ano_conta_banco1 as char 
FIELD banco2 as char 
FIELD tipo_conta_banco2 as char 
FIELD ano_conta_banco2 as char 
FIELD banco3 as char 
FIELD tipo_conta_banco3 as char 
FIELD ano_conta_banco3 as char 
FIELD banco_outros as char 
FIELD tipo_conta_outros as char 
FIELD ano_banco_outros as char 
FIELD referencias_comerciais1 as char 
FIELD situacao_referencias_comerciais1 as char 
FIELD referencias_comerciais2 as char 
FIELD situacao_referencias_comerciais2 as char 
FIELD referencias_comerciais3 as char 
FIELD situacao_referencias_comerciais3 as char 
FIELD referencias_comerciais4 as char 
FIELD situacao_referencias_comerciais4 as char 
FIELD referencias_comerciais5 as char 
FIELD situacao_referencias_comerciais5 as char 
FIELD observacoes as char 
FIELD possui_veiculo as char 
FIELD marca as char 
FIELD modelo as char 
FIELD ano as char 
FIELD nome_ref1 as char 
FIELD fone_comercial_ref1 as char 
FIELD celular_ref1 as char 
FIELD parentesco_ref1 as char 
FIELD documentos_apresentados_rf1 as char 
FIELD nome_ref2 as char 
FIELD fone_comercial_ref2 as char 
FIELD celular_ref2 as char 
FIELD parentesco_ref2 as char 
FIELD documentos_apresentados_rf2 as char 
FIELD nome_ref3 as char 
FIELD fone_comercial_ref3 as char 
FIELD celular_ref3 as char 
FIELD parentesco_ref3 as char 
FIELD documentos_apresentados_rf3 as char 
FIELD resultado_consulta_spc as char 
FIELD filial_efetuou_consulta as char 
FIELD data_consulta as char
FIELD quantidade_consultas_realizadas as char 
FIELD registros_de_alertas as char 
FIELD registro_do_credito as char 
FIELD registro_de_cheques as char 
FIELD registro_nacional as char 
FIELD spc_cod_motivo_cancelamento as char 
FIELD spc_descr_motivo as char 
FIELD resultado_consulta_serasa as char 
FIELD serasa_cod_motivo_cancelamento as char 
FIELD serasa_descr_motivo as char 
FIELD resultado_consulta_crediario as char 
FIELD codmotcancelamento as char serialize-name "crediario_cod_motivo_cancelamento"
FIELD crediario_descr_motivo as char 
FIELD limite_cod_motivo_cancelamento as char 
FIELD limite_descr_motivo as char 
FIELD nota as char 
FIELD sit_credito as char 
FIELD vcto_credito as char
FIELD codigo_mae as char 
FIELD categoria_profissional as char 
FIELD optinWhatsApp as char 
FIELD optinSMS as char .

def temp-table ttclientebonus serialize-name "bonus"
        FIELD codigo_cliente as char  serialize-hidden
        field numero_bonus as char
        field codigo_filial_bonus  as char
        field nome_bonus as char
        field venc_bonus as char
        field vlr_bonus as char.



def new shared temp-table ttbonus 
        field numero_bonus as char
        field etbcod as int
        field nome_bonus as char
        field venc_bonus as date
        field vlr_bonus as dec.


/** 
FIELD listabonus" type="tns:bonuslistaType" minOccurs="0" maxOccurs="unbounded"/>
**/

DEFINE DATASET dadosSaida FOR ttcliente, ttclientebonus
DATA-RELATION for1 FOR ttcliente, ttclientebonus         
    RELATION-FIELDS(ttcliente.codigo_cliente,ttclientebonus.codigo_cliente) NESTED.

DEFINE DATASET dadosReturn serialize-name "dadosSaida" FOR ttreturn.
    
def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.

hentrada = temp-table ConsultaCliente:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").




function Texto return character
    (input par-texto as char).

    if par-texto = ?
    then return "".
    
    return RemoveAcento(par-texto).
    
end.

function EnviaData returns character
    (input par-data as date).

    if par-data <> ?
    then return string(year(par-data),"9999") + "-" +
                string(month(par-data),"99") + "-" + 
                string(day(par-data),"99") + 
                "T00:00:00".
    else return "1900-01-01T00:00:00".

end function.

/* API REST */


def var vforcasitPJ as log init no.
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
def var r1 as char.

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
def var vchar as char.

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
    field vliof as dec
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


def var par-ok  as log.
/* buscarplanopagamento */
def var vcod as int.
def var vatraso as log.
def var vspc_descr_motivo as char.
def var vspc_cod_motivo_cancelamento as char.
def new global shared var setbcod       as int.
def var vcxacod as int.
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
def var var-mediacont  as dec decimals 2.

def var sal-abertopr like clien.limcrd.
def var sal-aberto   like clien.limcrd.
def var ult-compra   like plani.pladat.
def var qtd-contrato as int format ">>>9".
def var parcela-paga    as int format ">>>>9".
def var parcela-aberta  as int format ">>>>9".

def var qtd-15       as int format ">>>>9".
def var qtd-45       as int format ">>>>9".
def var qtd-46       as int format ">>>>9".
def var var-ATRASOPARC as char.


def var vrepar       as log format "Sim/Nao".
def var var-MAIORACUM like clien.limcrd.
def var var-DTMAIORACUM as char.
def var v-media      like clien.limcrd.

def var proximo-mes like clien.limcrd.
def var maior-atraso as int /***like plani.pladat***/.
def var vencidas like clien.limcrd.

/* PDV hiscli2.p */
/*
def NEW SHARED var pagas-db as int.

def NEW SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def NEW SHARED var cheque_devolvido like plani.platot.
def NEW SHARED var vclicod like clien.clicod.
def NEW SHARED var vtotal like plani.platot.
def NEW SHARED var vqtd        as int.
*/

def var sal-abertohubseg as dec.
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

def var vpasta_log as char init "/ws/log/".
find tab_ini where tab_ini.etbcod = 0
               and tab_ini.cxacod = 0
               and tab_ini.parametro = "WS P2K - Pasta LOG"
             no-lock no-error.
if avail tab_ini
then vpasta_log = tab_ini.valor.

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
    vcxacod = int(ConsultaCliente.numero_pdv).
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
            /* #11 vmensagem_erro = "PJ nao pode ser Tipo CREDIARIO".*/
            /* #11 vstatus = "R". /* #8 */ */
            vforcasitPJ = yes.
        end.
    end.
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos".
    
if vstatus = "S" and
   avail clien and
   clien.clicod > 1
   /*#11*/ and not vforcasitPJ 
then do.
    vtime = time.
    
    vcpf = dec(clien.ciccgc) no-error.
    if vcpf <> ? and vcpf <> 0
    then do:
        /* _05 */
        if not avail neuclien
        then find neuclien where neuclien.cpfcnpj = dec(clien.ciccgc)
                no-lock no-error.
        if not avail neuclien
        then do:
             /*#3*/
             run log("gravaneuclilog Cadastrando NeuClien").
             run neuro/gravaneuclilog_v1802.p 
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
             preautorizacao.data_nascimento = string(year(clien.dtnasc),"9999")
                                       + ":" + string(month(clien.dtnasc),"99")
                                       + ":" + string(day(clien.dtnasc),"99").

             run neuro/gravaneuclien_06.p (clien.ciccgc,
                                        output par-recid-neuclien).
            
             find neuclien where recid(neuclien) = par-recid-neuclien 
                    no-lock no-error.
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
                run log("gravaneuclihist clicod=" + string(clien.clicod)).
                run neuro/gravaneuclihist_v1802.p
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
                find clien where clien.clicod = neuclien.clicod
                        no-lock no-error.
                if avail clien
                then vmensagem_erro = "CPF " + clien.CICCGC +
                    " Cadastrado Conta Principal " + string(neuclien.clicod). 
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
        /** HELIO 21082023 - RETIRADO **run /admcom/progr/api/hiscli_05.p (clien.clicod).  **/
        /* helio 20/04/2021 usar comportamrnto */

        run neuro/comportamento.p (neuclien.clicod, ?,   /* hubseg */
                                   output var-propriedades). 
        
        sal-abertopr = dec(pega_prop("LIMITETOMPR")).
        sal-abertohubseg = dec(pega_prop("LIMITETOMHUBSEG")).
        if sal-abertohubseg = ? then sal-abertohubseg = 0.
        sal-abertopr = sal-abertopr - sal-abertohubseg.
                
        sal-aberto   = dec(pega_prop("LIMITETOM")).
        ult-compra   = date(pega_prop("DTULTCPA")).
        qtd-contrato = int(pega_prop("QTDECONT")). if qtd-contrato = ? then qtd-contrato = 0.
        parcela-paga = int(pega_prop("PARCPAG")). if parcela-paga = ? then parcela-paga = 0.
        parcela-aberta = int(pega_prop("PARCABERT")). if parcela-aberta = ? then parcela-aberta= 0.
        qtd-15  = 0.
        qtd-45  = 0.
        qtd-46  = 0.
        var-ATRASOPARC = pega_prop("ATRASOPARC").
        if num-entries(var-ATRASOPARC,"|") = 3
        then do:
                qtd-15 = int(entry(1,var-ATRASOPARC,"|")).
                qtd-45 = int(entry(2,var-ATRASOPARC,"|")).
                qtd-46 = int(entry(3,var-ATRASOPARC,"|")).
        end.
        vperc15 = 0.
        vperc45 = 0.
        vperc46 = 0.
        var-ATRASOPARCPERC = pega_prop("ATRASOPARCPERC").
        if num-entries(var-ATRASOPARCPERC,"|") = 3
        then do:
                var-ATRASOPARCPERC = replace(var-ATRASOPARCPERC,"%",""). 
                vperc15 = dec(entry(1,var-ATRASOPARCPERC,"|")).
                vperc45 = dec(entry(2,var-ATRASOPARCPERC,"|")).
                vperc46 = dec(entry(3,var-ATRASOPARCPERC,"|")).
        end.
        var-saldototnov = dec(pega_prop("SALDOTOTNOV")). if var-saldototnov = ? then var-saldototnov = 0.
        vrepar     = var-saldototnov > 0.
        
        var-mediacont   = dec(pega_prop("MEDIACONT")). if var-mediacont = ? then var-mediacont = 0.
        var-MAIORACUM   = dec(pega_prop("MAIORACUM")). if var-maioracum = ? then var-maioracum = 0.

        var-DTMAIORACUM = pega_prop("DTMAIORACUM"). if var-DTMAIORACUM = ? then var-DTMAIORACUM = "".
        v-media         = int(pega_prop("PARCMEDIA")). if v-media = ? then v-media = 0.
        proximo-mes = 0.
        r1 = pega_prop("LSTCOMPROMET").
        if num-entries(r1,"|") >= 2 /* helio 27112023 */
        then  proximo-mes = dec(entry(2,r1,"|")).   
        maior-atraso = int(pega_prop("ATRASOATUAL")). if maior-atraso = ? then maior-atraso = 0. /* helio 230823 - pegar prop atrasoatual */
        vencidas = dec(pega_prop("VLRPARCVENC")). if vencidas = ? then vencidas = 0.
                                
                                
       /* _05 */
       /** Testa se vai para NEUROTECH **/

        /* #3 */
        vneu_cdoperacao = "".       
        vneu_politica = "".
        /* Verifica se existe P2 Pendente */
            find first neuproposta where
                neuproposta.etbcod  = setbcod and
                neuproposta.cxacod  = vcxacod and /* # */
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
            run log("submeteneuro Politica=" + vpolitica).
            run neuro/submeteneuro_v1802.p (input setbcod,
                                      input vpolitica,
                                      input clien.clicod,
                                      0,
                                      output vlojaneuro,
                                      output vneurotech).
        end.
        else do.
            run log("TPCadastro=" + vtipo_cadastro +
                    " Forca Limite Admcom=" + string(vforcaadmcom,"S/N")).
            assign /* #_06 */
                vlojaneuro = no
                vneurotech = no
                vsit_credito = "A".
        end.

        /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */
        vchar = if vprocessa_credito
                then "Politica " + vpolitica +
                     " LJNeuro=" + string(vlojaneuro,"S/N") +
                     " Submete=" + string(vneurotech,"S/N")
                else "TPCadastro " + vtipo_cadastro + " SIT=" + vsit_credito.
        run log("gravaneuclilog PRIMEIRA AVALIACAO SUBMETE " + vchar).
        run neuro/gravaneuclilog_v1802.p 
                (neuclien.cpfcnpj, 
                 vtipoconsulta, 
                 0, 
                 setbcod,
                 consultacliente.numero_pdv, 
                 neuclien.sit_credito, 
                 vchar). 
                                 
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
            /*#12*/
            if vneu_cdoperacao = ""
            then do:
                run /admcom/progr/neuro/ajustalimitenovacao.p (recid(neuclien)). 
                find current neuclien no-lock.
            end.
            /*#12*/
            
            vvlrLimite   = neuclien.vlrlimite.
            vvctoLimite  = neuclien.vctolimite.
            if (neuclien.vctolimite < today or neuclien.vctolimite = ? or
                neuclien.vlrlimite = 0)
                and vneurotech = no
            then do:
                
                vforcaadmcom = yes.    
                vvlrLimite  = 0. /* helio 20/04/021*/
            end.    

        end.
        if vneu_cdoperacao <> "" or /* #3 */ 
           (avail neuclien and
             ( (neuclien.vctolimite <> ? and neuclien.vctolimite >= today) ) )
           /* #8 */
           or (avail neuclien and vneurotech) /* #8 na consulta nao sobe mais para neurotech */
        then do:                            /* Nao vai para a Neuro */
            if vneu_cdoperacao <> "" /* #3 */
            then do:
                vchar = "Proposta " + neuproposta.tipoconsulta + 
                        " Pendente " + vneu_cdoperacao.
                run log("gravaneuclilog " + vchar).
                run neuro/gravaneuclilog_v1802.p
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     0,
                     setbcod,
                     consultacliente.numero_pdv,
                     neuclien.sit_credito,
                     vchar).
            end.
            else do:
                vchar = "USANDO NEUCLIEN VCTO=" + 
                        (if neuclien.vctolimite = ?
                         then "-"
                         else string(neuclien.vctolimite)) + 
                        " VLR=" + string(neuclien.vlrlimite).
                run log("gravaneuclilog " + vchar).
                run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     0, 
                     setbcod, 
                     consultacliente.numero_pdv, 
                     neuclien.sit_credito, 
                     vchar).
            end.
                                 
            vvlrLimite   = neuclien.vlrlimite.
            vvctoLimite  = neuclien.vctolimite.
            vsit_credito = if vneu_cdoperacao <> ""  /* #3 */
                           then "P" 
                           else "A".            
        end.
        
            if vneurotech = no 
                and vprocessa_credito /* #_06 */
                and vforcaadmcom
            then do: /** ADMCOM **/
                vtime = mtime.
                vtimeini = mtime.
                run log("callimiteadmcom").
                run neuro/callimiteadmcom.p (recid(neuclien),
                                    "ADMA", /* #8 */
                                    vtime,
                                    setbcod,
                                    consultacliente.numero_pdv,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
                /* #2 */
                vchar = if vneurotech
                        then "USARA ADMCOM"
                        else "SIT=" + vsit_credito +
                             " VCTO=" + (if vvctolimite = ?
                                        then "-"
                                        else string(vvctolimite)) + 
                             " LIM=" + (if vvlrlimite = ?
                                        then "-"
                                        else string(vvlrlimite)).
                run log("gravaneuclilog " + vchar).
                run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj,
                         vtipoconsulta,
                         vtimeini,
                         setbcod,
                         consultacliente.numero_pdv,
                         neuclien.sit_credito,
                         vchar).
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
            vtimeini = mtime.
            vchar = if /* #6 not avail clispc and */ clien.tippes
                    then "SPC"
                    else "".
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     vtimeini, 
                     setbcod, 
                     consultacliente.numero_pdv, 
                     "",
                     vchar).
            if clien.tippes /* #6 and
               not avail clispc */
            then do.
                varqestatistica = "/ws/log/p2k_spcsicred_estatistica_" + 
                    string(today, "99999999") + ".log".
        
                vtimeini = mtime. 
                run api/spcpreconsulta_v03.p /*#9*/ (?, recid(clien),
                                                  output par-spc, 
                                                  output vlibera-cli).
                if par-spc 
                then do:
                    run log("gravaneuclilog CONSULTANDO SPC").
                    run neuro/gravaneuclilog_v1802.p
                            (neuclien.cpfcnpj,
                             vtipoconsulta,
                             vtimeini,
                             setbcod,
                             consultacliente.numero_pdv,
                             neuclien.sit_credito,
                             "CONSULTANDO SPC"). 

                    run api/spcconsulta_v03.p /*#9*/ (setbcod,
                                       vcxacod,
                                       recid(clien),
                                       output par-spc,
                                       output spc-conecta).
                    if not par-spc
                    then vlibera-cli = no. /* #6 */
                    vsit_credito = if par-spc
                                   then "A" else "R".

                    vchar = "SPC Cliente " + 
                            string(par-spc,"Nao Consta/Consta").
                    run log("gravaneuclilog " + vchar).
                    run neuro/gravaneuclilog_v1802.p
                                (neuclien.cpfcnpj,
                                 vtipoconsulta,
                                 0,
                                 setbcod,
                                 consultacliente.numero_pdv,
                                 vsit_credito,
                                 vchar).

                    if neuclien.sit_credito <> vsit_credito
                    then do:
                        run log("gravaneuclihist " + vsit_credito).
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

create ttreturn.
 ttreturn.pstatus = vstatus.
 ttreturn.mensagem_erro = vmensagem_erro.
 ttreturn.codigo_filial = ConsultaCliente.codigo_filial.
 ttreturn.numero_pdv    = ConsultaCliente.numero_pdv.
 ttreturn.tipo_cadastro = consultacliente.tipo_cadastro.
 hsaida = dataset dadosReturn:HANDLE.
    
if avail clien
then do:
    find cpclien where cpclien.clicod =  clien.clicod no-lock no-error.
    /* API REST */
    hsaida = dataset dadosSaida:HANDLE.

    create ttcliente.
    ttcliente.codigo_cliente = string(clien.clicod).
    ttcliente.pstatus = vstatus.
    ttcliente.mensagem_erro = vmensagem_erro.
    ttcliente.codigo_filial = ConsultaCliente.codigo_filial.
    ttcliente.numero_pdv    = ConsultaCliente.numero_pdv.
    ttcliente.tipo_cadastro = consultacliente.tipo_cadastro.
       
    
    /* #5 */
    if avail neuclien and 
       neuclien.cpf <> ? 
    then do:
        if clien.tippes = no /* JURIDICA CNPJ VAI AQUI TAMBEM */
        then do:
            ttcliente.cpf = string(neuclien.cpfcnpj,"99999999999999").
        end.
        else do:
            ttcliente.cpf = string(neuclien.cpfcnpj,"99999999999").
        end.
    end.
    else ttcliente.cpf = texto(clien.ciccgc).

    ttcliente.nome = Texto(clien.clinom).
    ttcliente.data_nascimento =  EnviaData(clien.dtnasc).
    ttcliente.codigo_senha = "".
    ttcliente.valor_limite = trim(string(vVlrLimite - sal-abertopr,"->>>>>>>>>9.99")). /*Conversa com Thalis, dia 03/05/2021 H�lio, eu falei com ela. Ela pediu pra mandar o calculado sem o juros, mesmo o saldo em aberto e o cr�dito estando "errados". No caso considerar o principal no cr�dito e no saldo em aberto para o calculado ser sem juros*/
    /*** lim-calculado ***/

    ttcliente.codigo_bloqueio = "0".
    ttcliente.descricao_bloqueio = "".
    ttcliente.percentual_desconto = "0".
    ttcliente.validade_desconto = "".  /* incluido em 05/01/2015 */
    ttcliente.valor_seguro = "0".
    ttcliente.situacao_seguro_cliente = "".

    ttcliente.cep = Texto(clien.cep[1]).
    ttcliente.endereco = Texto(clien.endereco[1]).

    if clien.numero[1] <> ?
    then ttcliente.numero = string(clien.numero[1]).
    else ttcliente.numero = "".

    ttcliente.complemento = Texto(clien.compl[1]).
    ttcliente.bairro = Texto(clien.bairro[1]).
    ttcliente.cidade = Texto(clien.cidade[1]).
    ttcliente.uf = Texto(clien.ufecod[1]).
    ttcliente.pais = "BRA".
    ttcliente.email = lc(clien.zona).
        
    if avail cpclien and 
       cpclien.emailpromocional = true
    then assign vrecebe-email-promo = "Sim".
    else assign vrecebe-email-promo = "Nao".    
    if vrecebe-email-promo = ?
    then vrecebe-email-promo = "".
    ttcliente.deseja_receber_email = vrecebe-email-promo.
        
    ttcliente.ddd = "".
    ttcliente.telefone = Texto(clien.fone).

    if clien.tippes <> ?
    then ttcliente.tipo_pessoa = string(clien.tippes,"F/J").
    else ttcliente.tipo_pessoa = "".

    /* _05 **/
    ttcliente.credito =  trim(string(vvlrLimite,">>>>>>>9.99")).
    /** _05 **/
    
    ttcliente.tipo_credito =  texto(string(clien.classe)).
        
    if clien.sexo <> ?
    then ttcliente.sexo = string(clien.sexo,"M/F").
    else ttcliente.sexo = "".
        
    ttcliente.nacionalidade = Texto(clien.nacion).
    ttcliente.identidade = Texto(clien.ciins).
    ttcliente.orgao_emissor = "".
        
    cestcivil = if clien.estciv = 1 then "Solteiro" else
                if clien.estciv = 2 then "Casado"   else
                if clien.estciv = 3 then "Viuvo"    else
                if clien.estciv = 4 then "Desquitado" else
                if clien.estciv = 5 then "Divorciado" else
                if clien.estciv = 6 then "Falecido" else "". 
    ttcliente.estado_civil = cestcivil.
    if avail cpclien
    then ttcliente.naturalidade = Texto(cpclien.var-char10).
    else ttcliente.naturalidade = "".
    
    if clien.tippes = no /* #5 12.06.2018 - helio ajustado */
    then do:
        if avail neuclien and
           neuclien.cpf <> ?
        then ttcliente.cnpj = string(neuclien.cpfcnpj,"99999999999999").
        else ttcliente.cnpj = texto(clien.ciccgc).
    end.
    else ttcliente.cnpj = "".

    ttcliente.pai = Texto(clien.pai).
    ttcliente.mae = Texto(clien.mae).

    if clien.numdep <> ?
    then ttcliente.numero_dependentes = string(clien.numdep).
    else ttcliente.numero_dependentes = "".

    if avail cpclien and cpclien.var-char8 <> ?
    then vinstrucao = acha("INSTRUCAO", cpclien.var-char8).
    else vinstrucao = "".
    ttcliente.grau_de_instrucao = Texto(vinstrucao).

    if avail cpclien and cpclien.var-log8 = true
    then assign vsituacao-instrucao = "Sim".
    else assign vsituacao-instrucao = "Nao".    
    if vsituacao-instrucao = ?
    then vsituacao-instrucao = "".
    ttcliente.situacao_grau_instrucao = vsituacao-instrucao.
 
    if avail cpclien and cpclien.var-char7 <> ?
    then vinstrucao = entry(1,cpclien.var-char7,"=").
    else vinstrucao = "".
    ttcliente.plano_saude = Texto(vinstrucao).

    if avail cpclien and cpclien.var-char6 <> ?
    then vinstrucao = entry(1,trim(cpclien.var-char6),"=").
    else vinstrucao = "".
    ttcliente.seguros = Texto(vinstrucao).

    if avail cpclien and cpclien.var-char9 <> ?
    then ttcliente.ponto_referencia = Texto(cpclien.var-char9).
    else ttcliente.ponto_referencia = "".

    ttcliente.celular = Texto(clien.fax).
                
    ttcliente.tipo_residencia = if clien.tipres then "Propria" else "Alugada".
    ttcliente.tempo_na_residencia = texto(string(clien.temres,"999999")).
    ttcliente.data_cadastro = EnviaData(clien.dtcad).
    ttcliente.data_ultima_compra = EnviaData(ult-compra).
    ttcliente.quantidade_contrato =        string(qtd-contrato).
    ttcliente.prestacoes_pagas =           string(parcela-paga).
    ttcliente.prestacoes_abertas =         string(parcela-aberta).
    ttcliente.qtd_atraso_ate_15dias =      string(qtd-15) .

    ttcliente.percentual_atraso_ate_15dias =    string(vperc15).
    ttcliente.qtd_atraso_15dias_ate_45dias =    string(qtd-45).
    ttcliente.perc15-45 = string(vperc45).
    ttcliente.qtd_atraso_maior_45dias =         string(qtd-46).
    ttcliente.percentual_atraso_maior_45dias =  string(vperc46).
    ttcliente.reparcelamento =  if vrepar then "Sim" else "Nao".

    ttcliente.media_por_contrato_contrato =  string(var-mediacont).
    ttcliente.maior_valor_acumulado =  string(var-maioracum).
    ttcliente.mes_ano =                string(var-DTMAIORACUM).
    ttcliente.prestacao_media =        string(v-media).
    ttcliente.proximo_mes =            string(proximo-mes).
    ttcliente.maior_atraso =           string(maior-atraso).
    ttcliente.parcelas_vencidas = trim(string(vencidas,">>>>>>>9.99")).
    ttcliente.vl_cheque_devolvidos = "0".

    /* dados profisionais */
    ttcliente.empresa = Texto(clien.proemp[1]).
    if avail cpclien
    then ttcliente.cnpj_empresa = Texto(cpclien.var-char1).
    else ttcliente.cnpj_empresa = "".
    
    ttcliente.telefone_empresa = Texto(clien.protel[1]).
    ttcliente.data_admissao = EnviaData(clien.prodta[1]).
    ttcliente.profissao = Texto(clien.proprof[1]).

    if clien.prorenda[1] = ?
    then ttcliente.renda_total = "0".
    else ttcliente.renda_total = trim(string(clien.prorenda[1],">>>>>>>9.99")).

    ttcliente.endereco_empresa = Texto(clien.endereco[2]).
        
    if clien.numero[2] = ?
    then ttcliente.numero_empresa = "".
    else ttcliente.numero_empresa = string(clien.numero[2]).

    ttcliente.complemento_empresa = Texto(clien.compl[2]).
    ttcliente.bairro_empresa = Texto(clien.bairro[2]).
    ttcliente.cidade_empresa = Texto(clien.cidade[2]).
    ttcliente.estado_empresa = Texto(clien.ufecod[2]).
    ttcliente.cep_empresa =    Texto(clien.cep[2]).

    /* conjuge */
    ttcliente.nome_conjuge = Texto(substr(clien.conjuge,1,50)).
    ttcliente.cpf_conjuge = texto(substr(clien.conjuge,51,20)).
    ttcliente.data_nascimento_conjuge = EnviaData(clien.nascon).
    ttcliente.pai_conjuge = Texto(clien.conjpai).
    ttcliente.mae_conjuge = Texto(clien.conjmae).
    ttcliente.empresa_conjuge =   Texto(clien.proemp[2]).
    ttcliente.telefone_conjuge =  Texto(clien.protel[2]).
    ttcliente.profissao_conjuge = Texto(clien.proprof[2]).
    ttcliente.data_admissao_conjuge = EnviaData(clien.prodta[2]).

    if clien.prorenda[2] = ?
    then ttcliente.renda_mensal_conjuge = "0".
    else ttcliente.renda_mensal_conjuge = trim(string(clien.prorenda[2], ">>>>>>9.99")).

    /* referencias */
/***
    vcartao = 0.
    if avail cpclien
    then do vi = 1 to 7.
        if int(cpclien.var-int[vi]) > 0
        then vcartao = vi.
    end.
    ttcliente.cartoes_de_credito = string(vcartao).
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
    ttcliente.cartoes_de_credito = vcartao.

    if avail cpclien and
       (cpclien.var-ext2[1] = "BANRISUL" or 
        cpclien.var-ext2[1] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[1] = "BANCO DO BRASIL" or
        cpclien.var-ext2[1] = "OUTROS")
    then do:   
        ttcliente.banco1 =  texto(cpclien.var-ext2[1]).
        ttcliente.tipo_conta_banco1 = texto(cpclien.var-ext3[1]).
        ttcliente.ano_conta_banco1 =  texto(cpclien.var-ext4[1]).
    end.
    else do:
        ttcliente.banco1 =  "".
        ttcliente.tipo_conta_banco1 = "".
        ttcliente.ano_conta_banco1 =  "".
    end.
           
    if avail cpclien and
       (cpclien.var-ext2[2] = "BANRISUL" or 
        cpclien.var-ext2[2] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[2] = "BANCO DO BRASIL" or
        cpclien.var-ext2[2] = "OUTROS")
    then do:   
        ttcliente.banco2 =  cpclien.var-ext2[2].
        ttcliente.tipo_conta_banco2 = cpclien.var-ext3[2].
        ttcliente.ano_conta_banco2 =  cpclien.var-ext4[2].
    end.
    else do:
        ttcliente.banco2 =  "".
        ttcliente.tipo_conta_banco2 = "".
        ttcliente.ano_conta_banco2 =  "".
    end.

    if avail cpclien and
       (cpclien.var-ext2[3] = "BANRISUL" or 
        cpclien.var-ext2[3] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[3] = "BANCO DO BRASIL" or
        cpclien.var-ext2[3] = "OUTROS")
    then do:   
        ttcliente.banco3 =  cpclien.var-ext2[3].
        ttcliente.tipo_conta_banco3 = cpclien.var-ext3[3].
        ttcliente.ano_conta_banco3 =  cpclien.var-ext4[3].
    end.
    else do:
        ttcliente.banco3 =  "".
        ttcliente.tipo_conta_banco3 = "".
        ttcliente.ano_conta_banco3 =  "".
    end.
            
    if avail cpclien and
       (cpclien.var-ext2[4] = "BANRISUL" or 
        cpclien.var-ext2[4] = "CAIXA ECONOMICA FEDERAL" or
        cpclien.var-ext2[4] = "BANCO DO BRASIL" or
        cpclien.var-ext2[4] = "OUTROS")
    then do:   
        ttcliente.banco_outros =  cpclien.var-ext2[4].
        ttcliente.tipo_conta_outros = cpclien.var-ext3[4].
        ttcliente.ano_banco_outros =  cpclien.var-ext4[4].
    end.
    else do:
        ttcliente.banco_outros =  "".
        ttcliente.tipo_conta_outros = "".
        ttcliente.ano_banco_outros =  "".
    end.

    ttcliente.referencias_comerciais1 = Texto(clien.refcom[1]).

    if avail cpclien
    then 
        case cpclien.var-ext1[1]:
          when "1"
            then ttcliente.situacao_referencias_comerciais1 = "Apresentado".
          when "2"
            then ttcliente.situacao_referencias_comerciais1 = "Nao Apresentado".
          when "3"
            then ttcliente.situacao_referencias_comerciais1 = "Nao possui cartao".
          otherwise
             ttcliente.situacao_referencias_comerciais1 = "".  
        end case.    
    else ttcliente.situacao_referencias_comerciais1 = "".

    ttcliente.referencias_comerciais2 = Texto(clien.refcom[2]).

    if avail cpclien
    then
        case cpclien.var-ext1[2]:
          when "1"
            then ttcliente.situacao_referencias_comerciais2 = "Apresentado".
          when "2"
            then ttcliente.situacao_referencias_comerciais2 = "Nao Apresentado".
          when "3"
            then ttcliente.situacao_referencias_comerciais2 = "Nao possui cartao".
          otherwise
             ttcliente.situacao_referencias_comerciais2 = "".  
        end case.
    else ttcliente.situacao_referencias_comerciais2 = "".

    ttcliente.referencias_comerciais3 = Texto(clien.refcom[3]).

    if avail cpclien
    then
        case cpclien.var-ext1[3]:
          when "1"
            then ttcliente.situacao_referencias_comerciais3 = "Apresentado".
          when "2"
            then ttcliente.situacao_referencias_comerciais3 = "Nao Apresentado".
          when "3"
            then ttcliente.situacao_referencias_comerciais3 = "Nao possui cartao".
          otherwise
             ttcliente.situacao_referencias_comerciais3 = "".  
        end case.
    else ttcliente.situacao_referencias_comerciais3 = "".

    ttcliente.referencias_comerciais4 = Texto(clien.refcom[4]).

    if avail cpclien
    then
        case cpclien.var-ext1[4]:
          when "1"
            then ttcliente.situacao_referencias_comerciais4 = "Apresentado".
          when "2"
            then ttcliente.situacao_referencias_comerciais4 = "Nao Apresentado".
          when "3"
            then ttcliente.situacao_referencias_comerciais4 = "Nao possui cartao".
          otherwise
             ttcliente.situacao_referencias_comerciais4 = "".  
        end case.
    else ttcliente.situacao_referencias_comerciais4 = "".

    ttcliente.referencias_comerciais5 = Texto(clien.refcom[5]).

    if avail cpclien
    then
        case cpclien.var-ext1[5]:
          when "1"
            then ttcliente.situacao_referencias_comerciais5 = "Apresentado".
          when "2"
            then ttcliente.situacao_referencias_comerciais5 = "Nao Apresentado".
          when "3"
            then ttcliente.situacao_referencias_comerciais5 = "Nao possui cartao".
          otherwise
             ttcliente.situacao_referencias_comerciais5 = "".  
        end case.
    else ttcliente.situacao_referencias_comerciais5 = "".

    if clien.clicod <> 1
    then
        vobs = (if clien.autoriza[1] = ? then "" else clien.autoriza[1]) +
               (if clien.autoriza[2] = ? then "" else clien.autoriza[2]) +
               (if clien.autoriza[3] = ? then "" else clien.autoriza[3]) +
               (if clien.autoriza[4] = ? then "" else clien.autoriza[4]) +
               (if clien.autoriza[5] = ? then "" else clien.autoriza[5]).
    else vobs = "" .
    ttcliente.observacoes =  Texto(vobs).         

    /* veiculo */
    vcarro = "NAO".
    find carro where carro.clicod = clien.clicod no-lock no-error.
    if avail carro
    then if carro.carsit 
         then vcarro = "SIM".
    ttcliente.possui_veiculo = vcarro.
    if vcarro = "SIM"
    then do:
        ttcliente.marca =  Texto(carro.marca).
        ttcliente.modelo = Texto(carro.modelo).
        if carro.ano <> ?
        then ttcliente.ano = string(carro.ano,"9999").         
        else ttcliente.ano = "".         
    end.
    else do:
        ttcliente.marca = "".         
        ttcliente.modelo = "".         
        ttcliente.ano = "".         
    end.            

    /* referencias pessoas 3 */
    ttcliente.nome_ref1 =       Texto(clien.entbairro[1]). 
    ttcliente.fone_comercial_ref1 = Texto(clien.entcep[1]). 
    ttcliente.celular_ref1 =    Texto(clien.entcidade[1]).
    ttcliente.parentesco_ref1 = Texto(clien.entcompl[1]).
    ttcliente.documentos_apresentados_rf1 = Texto(clien.entendereco[1]).
    ttcliente.nome_ref2 =       Texto(clien.entbairro[2]).
    ttcliente.fone_comercial_ref2 = Texto(clien.entcep[2]).
    ttcliente.celular_ref2 =    Texto(clien.entcidade[2]).
    ttcliente.parentesco_ref2 = Texto(clien.entcompl[2]).
    ttcliente.documentos_apresentados_rf2 = Texto(clien.entendereco[2]). 
    ttcliente.nome_ref3 =       Texto(clien.entbairro[3]).
    ttcliente.fone_comercial_ref3 = Texto(clien.entcep[3]).
    ttcliente.celular_ref3 =    Texto(clien.entcidade[3]).
    ttcliente.parentesco_ref3 = Texto(clien.entcompl[3]).
    ttcliente.documentos_apresentados_rf3 = Texto(clien.entendereco[3]).

    /* consulta spc */   

    vspc_cod_motivo_cancelamento = "".
    vspc_descr_motivo = "".
            
/* #6
    if avail clispc or
       (acha("OK = clien.entrefcom[2]) <> ? and
        acha("OK = clien.entrefcom[2]) = "NAO")
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
    vale-spc = acha("alertas", clien.entrefcom[2]).
    vcre-spc = acha("credito",clien.entrefcom[2]).
    vche-spc = acha("cheques", clien.entrefcom[2]).
    vnac-spc = acha("nacional",clien.entrefcom[2]).

    ttcliente.resultado_consulta_spc =  Texto(vmen-spc).
    ttcliente.filial_efetuou_consulta = Texto(vfil-spc).
    ttcliente.data_consulta =  EnviaData(vdat-spc).
    ttcliente.quantidade_consultas_realizadas = Texto(vcon-spc).
    ttcliente.registros_de_alertas = Texto(vale-spc).
    ttcliente.registro_do_credito =  Texto(vcre-spc).
    ttcliente.registro_de_cheques =  Texto(vche-spc).
    ttcliente.registro_nacional =    Texto(vnac-spc).
    ttcliente.spc_cod_motivo_cancelamento = vspc_cod_motivo_cancelamento. 
    ttcliente.spc_descr_motivo = vspc_descr_motivo. 

    /* consulta serasa */
    ttcliente.resultado_consulta_serasa = "". 
    ttcliente.serasa_cod_motivo_cancelamento = "". 
    ttcliente.serasa_descr_motivo = "". 
    /* consulta crediario */
    if vatraso = no
    then do:
        ttcliente.resultado_consulta_crediario = "". 
        ttcliente.codmotcancelamento = "". 
        ttcliente.crediario_descr_motivo = "". 
    end.
    else do:
        ttcliente.resultado_consulta_crediario = "CLIENTE COM REGISTRO". 
        ttcliente.codmotcancelamento = "94". 
        ttcliente.crediario_descr_motivo = "CLIENTE COM RESTRICAO CREDIARIO". 
    end.

    /* cosulta limite */
    ttcliente.limite_cod_motivo_cancelamento = "95". 
    ttcliente.limite_descr_motivo = "CLIENTE COM LIMITE DE CREDITO INSUFICIENTE". 

    /* nota credit score */
    if not avail cpclien
    then ttcliente.nota = "". 
    else ttcliente.nota = texto(string(cpclien.var-int3)).

    /* _05 **/
    if vforcasitPJ /*#11*/
    then vsit_credito = "V". 

    ttcliente.sit_credito =  texto(string(vsit_credito)).
    ttcliente.vcto_credito =  EnviaData(vvctoLimite).
    
    if avail neuclien
    then do:
        ttcliente.codigo_mae =  texto(string(neuclien.codigo_mae)).
        ttcliente.categoria_profissional =  texto(neuclien.catprof).
    end.
    else do:
        ttcliente.codigo_mae =  "".
        ttcliente.categoria_profissional =  "".
    
    end.

    /* helio 22122021 - Cadastro P2k - Campos Optin */
    
    ttcliente.optinWhatsApp = string(if clien.optinWhatsApp = ? then no else clien.optinWhatsApp,"Sim/Nao").
    ttcliente.optinSMS      = string(if clien.optinSMS      = ? then no else clien.optinSMS,"Sim/Nao").
    /* helio 22122021 - Cadastro P2k - Campos Optin */
    

    /** _05 **/
   
                                                     
    connect crm -H "sv-mat-db1" -S crm_p2k -N tcp -ld crm no-error. /* helio 28032022 -S */
    if connected("crm")
    then run /admcom/progr/api/pegabonus.p (clien.clicod).
    else do:
        create ttbonus.
        ttbonus.nome_bonus = "".
        ttbonus.numero_bonus = "".
        ttbonus.venc_bonus = 01/01/1900.
        ttbonus.vlr_bonus = 0.
    end.
                       
    for each ttbonus.
        create ttclientebonus.
        ttclientebonus.codigo_cliente = ttcliente.codigo_cliente.

        ttclientebonus.nome_bonus = Texto(ttbonus.nome_bonus).
        ttclientebonus.numero_bonus = ttbonus.numero_bonus.
        ttclientebonus.codigo_filial_bonus = string(ttbonus.etbcod).
        ttclientebonus.venc_bonus = string(year(ttbonus.venc_bonus),"9999") + "-" +
                           string(month(ttbonus.venc_bonus),"99")  + "-" +
                           string( day (ttbonus.venc_bonus),"99")  +
                                     "T00:00:00".
        ttclientebonus.vlr_bonus = trim(string(ttbonus.vlr_bonus,">>>>>>>>9.99")).
        
    end.     
    

end.


    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    put unformatted string(vlcsaida).

/*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
  os-command silent cat saida.json.
*/


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = vpasta_log + "Neurotech_" + string(today, "99999999") + "_" +
           string(setbcod) + "_" + string(vcxacod) + ".log".

    output to value(varquivo) append.
    put unformatted string(time,"HH:MM:SS")
        " ConsultaCliente " par-texto skip.
    output close.

end procedure.

