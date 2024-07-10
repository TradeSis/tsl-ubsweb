/* helio 14082023 - M Hist�rico de altera��o - Solicita��o compliance */
/* helio 26072023 Otimiza��o de Cadastro de Cr�dito V6 - restricoes admcom e ie */
/* helio 22052023 Melhoria ID 502416 - Vari�vel ultimas nova��es */

/* helio #23112022 ID 154675 - Enviar PROP DTULTPAGTO */
/*#01082022 helio - Integração P2K/Neurotech - Acrescentar o campo IE*/
/* helio 11042022 - ajuste painel motor */

/* helio 22122021 - Cadastro P2k - Campos Optin */
/*VERSAO 2 23062021*/

/*** Dicionario de dados: clioutb4.p filial 189 ***/
/* 28.03.2018 #6 Cadastro Express Fase 1 */
/* 11.05.2018 #2 - Higienizacao CPF */
/* 17.05.2018 #3 - Melhorias Motor Pct 01 */
/* 22.05.2018 #7 - Cadastro de PJ */
/* 21.06.2018 #8 Helio - Revisao do Fluxo  */
/* 03.07.2018 #8a Helio - Revisao do Fluxo V2 */
/* 09.07.2018 #9 helio - Solicitado novos campos para que o motor calcule o corte do limite quando tem novacao ou atraso */
/* 21.08.2018 #10 Controle por caixa wcneurotech_v1802 */
/* 23.04.2019 #11 Helio - PJ retornar situacao "V" e nao subir ao motor */

/* API REST */
def input  parameter vlcentrada as longchar.

def var vERAfalecido as log.
def var vidstatuscad as int.
def var vBloqueioAlteracaoCadastral as log.

{/admcom/progr/api/acentos.i}
def var var-qtdenov as char.
def var var-dtultcpa as char. /* #11 */
def var var-dtultnov as char. /* #11 */
def var var-COMPROMETIMENTO_MENSAL as dec. 

def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.

def temp-table ttreturn no-undo serialize-name "return"
FIELD pstatus as char serialize-name "status"
FIELD mensagem_erro as char 
FIELD codigo_filial as char 
FIELD numero_pdv as char 
FIELD tipo_cadastro as char 
field credito as char
field sit_credito as char
field vcto_credito as char
field mensagem_credito as char
field neuro_id_operacao as char.

  


def  temp-table AtualizacaoDadosCliente serialize-name "dadosEntrada"
    field codigo_filial as int
    field codigo_operador as char
    field numero_pdv    as int
    field codigo_cliente as char
    field cpf as char
    field nome as char
    field data_nascimento as char
    field codigo_senha as char
    field valor_limite as char
    field codigo_bloqueio as int
    field descricao_bloqueio as char
    field percentual_desconto as char
    field validade_desconto as char
    field valor_seguro as char
    field situacao_seguro_cliente as char
    field cep as char
    field endereco as char
    field numero as char
    field complemento as char
    field bairro as char
    field cidade as char
    field uf as char
    field pais as char
    field email as char
    field deseja_receber_email as char
    field ddd as char
    field telefone as char
    field tipo_pessoa as char
    field credito as char
    field tipo_credito as char
    field sexo as char
    field nacionalidade as char
    field identidade as char
    field estado_civil as char
    field naturalidade as char
    field cnpj as char
    field pai as char
    field mae as char
    field numero_dependentes as char
    field grau_de_instrucao as char
    field situacao_grau_de_instrucao as char
    field plano_saude as char
    field seguros as char
    field ponto_referencia as char
    field celular as char
    field tipo_residencia as char
    field tempo_na_residencia as char
    field data_cadastro as char
    field empresa as char
    field cnpj_empresa as char
    field telefone_empresa as char
    field data_admissao as char
    field profissao as char
    field renda_total as char
    field endereco_empresa as char
    field numero_empresa as char
    field complemento_empresa as char
    field bairro_empresa   as char 
    field cidade_empresa   as char 
    field estado_empresa   as char 
    field cep_empresa   as char 
    field nome_conjuge   as char 
    field cpf_conjuge   as char 
    field data_nascimento_conjuge   as char 
    field pai_conjuge   as char 
    field mae_conjuge   as char 
    field empresa_conjuge as char 
    field telefone_conjuge   as char 
    field profissao_conjuge as char 
    field data_admissao_conjuge  as char 
    field renda_mensal_conjuge as char
    field cartoes_de_credito  as char 
    field banco1 as char
    field tipo_conta_banco1 as char
    field ano_conta_banco1 as char
    field banco2 as char
    field tipo_conta_banco2 as char
    field ano_conta_banco2 as char
    field banco3 as char
    field tipo_conta_banco3 as char
    field ano_conta_banco3 as char
    field banco_outros as char
    field tipo_conta_outros as char
    field ano_banco_outros as char
    field referencias_comerciais1 as char
    field situacao_referencias_comerciais1 as char
    field referencias_comerciais2 as char
    field situacao_referencias_comerciais2 as char
    field referencias_comerciais3 as char
    field situacao_referencias_comerciais3 as char
    field referencias_comerciais4 as char
    field situacao_referencias_comerciais4 as char
    field referencias_comerciais5 as char
    field situacao_referencias_comerciais5 as char
    field observacoes as char 
    field possui_veiculo    as char         
    field marca as char  
    field modelo as char  
    field ano as char   
    field nome_ref1 as char  
    field fone_comercial_ref1  as char 
    field celular_ref1  as char 
    field parentesco_ref1  as char 
    field documentos_apresentados_rf1   as char 
    field nome_ref2  as char 
    field fone_comercial_ref2   as char 
    field celular_ref2  as char 
    field parentesco_ref2 as char 
    field documentos_apresentados_rf2  as char 
    field nome_ref3  as char 
    field fone_comercial_ref3  as char 
    field celular_ref3  as char 
    field parentesco_ref3  as char 
    field documentos_apresentados_rf3  as char 
    field resultado_consulta_spc  as char 
    field filial_efetuou_consulta  as char 
    field data_consulta  as char 
    field quantidade_consultas_realizadas   as char 
    field registros_de_alertas as char 
    field registro_do_credito  as char 
    field registro_de_cheques  as char 
    field registro_nacional  as char 
    field spc_cod_motivo_cancelamento  as char 
    field spc_descr_motivo  as char 
    field resultado_consulta_serasa  as char 
    field serasa_cod_motivo_cancelamento  as char 
    field serasa_descr_motivo  as char 
    field resultado_consulta_crediario  as char 
    field crediario_cod_motivo_cancelament  as char 
    field crediario_descr_motivo  as char 
    field limite_cod_motivo_cancelamento  as char 
    field limite_descr_motivo  as char 
    field nota as char  
    field codigo_mae as char 
    field categoria_profissional as char
    field optinWhatsApp as char /* helio 22122021 - Cadastro P2k - Campos Optin */
    field optinSMS      as char /* helio 22122021 - Cadastro P2k - Campos Optin */
    field tipo_cadastro   as char
    field neuro_id_operacao   as char
/* V.2 */
field patrimonio as char /*– 3 opções de valor: R$ 0,00 à R$ 50.000,00 | R$ 51.000,00 à R$ 300.000,00 | Acima de R$ 300.000,00*/
field pessoaexposta as char /*– true/false */
field nomeSocial    as char /*- string*/
field ultimaAtualizacaoCadastral as char /* manter no request mas nao utilizar */

field genero as char /*– 3 opções de valor: Masculino | Feminino | Prefiro não Informar*/

field falecido as char /*– true/false*/
field inscricaoEstadual as char
field ID_BIOMETRIA as char.

hentrada = temp-table AtualizacaoDadosCliente:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

function testavalido return log
    (input par-palavra as char).
    def var vok as log.

       if  par-palavra <> "" and 
           par-palavra <> ?  and
           par-palavra <> "?"
       then vok = yes.
       else vok = no.
     return vok.

end function.

function trata-numero returns character
    (input par-num as char).

    def var par-ret as char.
    def var j as int.
    def var t as int.
    def var vletra as char.

    if par-num = ?
    then par-num = "".

    t = length(par-num).
    do j = 1 to t:
        vletra = substr(par-num,j,1).
        if vletra = "0" or
           vletra = "1" or
           vletra = "2" or
           vletra = "3" or
           vletra = "4" or
           vletra = "5" or
           vletra = "6" or
           vletra = "7" or
           vletra = "8" or
           vletra = "9"
        then assign par-ret = par-ret + vletra.
    end.
    return par-ret.

end function.


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



/* #11 */ def var vforcasitPJ as log init no.

def var var-saldototnov as dec.
def var vtipo_cadastro      as char.
def var vprocessa_credito   as log.


{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var vtimeini as int.
def var var-atrasoparcperc as char.
def var var-PARCPAG as int.
def var par-recid-neuclien as recid.
def var vtipoconsulta          as char init "AC06".

/* #3 */
def var vneu_cdoperacao as char.
def var xneu_cdoperacao as char.
def var vneu_politica as char.
def var vcpf as dec.
def var vsit_credito as char.
def var vvctolimite            as date. 
def var vvlrLimite              as dec.
def var vrenda  as dec.
def var vrenda_conjuge  as dec.
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
def var vtime                  as int.
def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 
def var vneuro-sit as char.
def var vneuro-mens as char.
def new global shared var setbcod    like estab.etbcod.
def new global shared var scxacod    like estab.etbcod.
def new global shared var xfuncod    like func.funcod.

def var vprops as char.
def var vPOLITICA as char.

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
    field tipo_cadastro   as char.

/* buscarplanopagamento */
def var vstatus as char.   
def var vmensagem_erro as char.
def var vdec  as dec.
def var vchar as char.
def var vint  as int.
def var vdata as date.
def var vcodigo as int.
def var vcgccpf as char.
def var vnovo as log init no.
def var vgera as int.
def var var-DTULTPAGTO as date.
/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].


def var vpasta_log as char init "/ws/log/".
find tab_ini where tab_ini.etbcod = 0
               and tab_ini.cxacod = 0
               and tab_ini.parametro = "WS P2K - Pasta LOG"
             no-lock no-error.
if avail tab_ini
then vpasta_log = tab_ini.valor.

find first atualizacaodadoscliente no-error.
if avail atualizacaodadoscliente
then do:
    /* #6 */
    vtipo_cadastro = atualizacaodadoscliente.tipo_cadastro.
    if vtipo_cadastro = "CREDIARIO"
    then vprocessa_credito = yes.
    else vprocessa_credito = no.
    /* #6 */

    assign
        vstatus = "S"
        setbcod = atualizacaodadoscliente.codigo_filial.
        scxacod = atualizacaodadoscliente.numero_pdv.
        xfuncod = int(atualizacaodadoscliente.codigo_operador).

    vcodigo = ?.
    if testavalido(atualizacaodadoscliente.codigo_cliente) 
    then vcodigo = int(atualizacaodadoscliente.codigo_cliente) no-error.

    vcgccpf = ?.
    if testavalido(atualizacaodadoscliente.cpf) 
    then vcgccpf = trata-numero(atualizacaodadoscliente.cpf).

    /* #7 */
    if vtipo_cadastro = "CREDIARIO" and
       atualizacaodadoscliente.tipo_pessoa = "J"
    then do:
        /*#11 assign
         *   vstatus = "R" /* #8a */
         *   vmensagem_erro = "Pessoa Juridica Somente A VISTA".
         #11*/
         vforcasitPJ = yes.
    end. 
end.    
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos".

if vstatus = "S"
then
    if vcodigo <> ? and
       vcodigo <> 0
    then do on error undo:
        find clien where clien.clicod = vcodigo no-lock no-error.
        if not avail clien
        then assign
                vstatus = "N"
                vmensagem_erro = "1Cliente Codigo: " + 
                    atualizacaodadoscliente.codigo_cliente + " Nao Encontrado".
        else do:
            /* helio 04012024 - Venda de CNPJ indo ao motor - ID 59106 */
            if clien.tippes = no then vforcasitPJ = yes.
        
            find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
            if avail neuclien
            then do:
                if dec(atualizacaodadoscliente.cpf) <> neuclien.cpfcnpj
                then do:
                    vstatus = "E".
                    vmensagem_erro = "CLIENTE " + string(clien.clicod) +  
                                     " COM CPF " + string(neuclien.cpf) +
                                     " JA EXISTENTE".
                end.
            end.
            else do:
                find neuclien where neuclien.cpf = dec(vcgccpf)
                              no-lock no-error.
                if avail neuclien
                then do:
                    if neuclien.clicod <> clien.clicod
                    then do:
                        vstatus = "N".
                        vmensagem_erro =
                                "CPF " + string(atualizacaodadoscliente.cpf) +
                                " JA EXISTENTE  NO CLIENTE CODIGO " +
                                string(neuclien.clicod).
                    end.
                end.
                else assign
                        vstatus = "S"
                        vmensagem_erro = "".
            end.
        end.                
    end.
    else assign
            vstatus = "N"
            vmensagem_ERRO = "2 Cliente Codigo: " +
                    atualizacaodadoscliente.codigo_cliente + " Nao Encontrado".

if vstatus = "N" and
   /* #7 */ atualizacaodadoscliente.tipo_pessoa = "J"
then do:    
    /** #7 retirado ***/
    if vcgccpf <> ? and
       vcgccpf <> ""
    then do on error undo:
        find clien where clien.ciccgc = vcgccpf exclusive no-error.
        if not avail clien
        then do:
            vstatus = "I". 
            run p-geraclicod.p (output vgera).

            disable triggers for load of clien.
            create clien.
            assign
                clien.clicod = vgera
                clien.ciccgc = vcgccpf
                clien.clinom = caps(texto(atualizacaodadoscliente.nome))
                clien.tippes = if atualizacaodadoscliente.tipo_pessoa = "J"
                               then no else yes
                clien.etbcad = int(atualizacaodadoscliente.codigo_filial)
                vnovo = yes.
            vmensagem_erro = "3Cliente Codigo: " + string(clien.clicod) +
                        " CPF: " + atualizacaodadoscliente.cpf + " CADASTRADO".
        end.
        else assign
                vstatus = "S"
                vmensagem_erro = "".
    end.
    /* #7 **/
end.

if vstatus <> "N" and
   vstatus <> "E" and
   vstatus <> "R" /* #8 */
then do:
    run log(vtipoconsulta + 
            " Cliente=" + atualizacaodadoscliente.codigo_cliente +
            " Id=" + atualizacaodadoscliente.neuro_id_operacao +
            " Tipo_Cadastro=" + atualizacaodadoscliente.tipo_cadastro).
    vtime = time.


    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    if not avail neuclien
    then do:
        vcpf = dec(vcgccpf) no-error.
        if vcpf <> ? and vcpf <> 0
        then do:
            find neuclien where neuclien.cpfcnpj = vcpf no-lock no-error.
            if not avail neuclien
            then do:
                /* #3 */
                run log("gravaneuclilog Cadastrando NeuClien").
                run neuro/gravaneuclilog_v1802.p 
                    (clien.ciccgc, 
                     vtipoconsulta, 
                     vtimeini, 
                     setbcod, 
                     atualizacaodadoscliente.numero_pdv, 
                     "", 
                     "Cadastrando NeuClien"). 
    
                create PreAutorizacao.
                preAutorizacao.codigo_filial   = 
                                string(atualizacaodadoscliente.codigo_filial).
                preAutorizacao.codigo_cliente  = string(clien.clicod).
                preautorizacao.cpf             = clien.ciccgc.
                preautorizacao.tipo_pessoa     = if clien.tippes
                                                 then "J"
                                                 else "F".
                preAutorizacao.nome_pessoa     = clien.clinom.
                preautorizacao.data_nascimento =
                                     string(year(clien.dtnasc),"9999") + ":" +
                                     string(month(clien.dtnasc),"99")  + ":" +
                                     string(day(clien.dtnasc),"99").

                run neuro/gravaneuclien_06.p (vcgccpf,
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
        end.
        else do:
            vstatus = "E".
            vmensagem_erro = "CLIENTE " + string(clien.clicod) +  
                             " COM CPF " + string(clien.ciccgc) + " INVALIDO".
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
            find clien where clien.clicod = neuclien.clicod no-lock.
            /* #2 */
            vstatus = "E".
            vmensagem_erro = "CPF " + clien.CICCGC + 
                    " Cadastrado Conta Principal " + string(neuclien.clicod).
        end.
    end.
end.

/** helio 04022022 NOVO FLUXO INTEGRACAO MOTOR */
vneu_cdoperacao = AtualizacaoDadosCliente.neuro_id_operacao.  /* Helio - 30.10.2019 */
if vneu_cdoperacao = ? then vneu_cdoperacao = "".

release neuproposta.
if vneu_cdoperacao <> ""
then find neuproposta where neuproposta.neu_cdoperacao = vneu_cdoperacao and
                            neuproposta.cpf = neuclien.cpf  

    no-lock no-error.
if avail neuproposta
then do:
        run log("PROPOSTA JA EXISTENTE ID=" + vneu_cdoperacao + " NOVO FLUXO").
        vvlrLimite   = neuclien.vlrlimite.
        vvctoLimite  = neuclien.vctolimite.
        vsit_credito = neuproposta.neu_resultado.

        create ttreturn.
        ttreturn.pstatus       = vstatus.
        ttreturn.mensagem_erro = vmensagem_erro.
        ttreturn.codigo_filial = string(atualizacaodadoscliente.codigo_filial).
        ttreturn.numero_pdv    = string(atualizacaodadoscliente.numero_pdv).
        ttreturn.tipo_cadastro = atualizacaodadoscliente.tipo_cadastro.

        ttreturn.credito           = trim(string(vvlrLimite,">>>>>>>9.99")).
        ttreturn.sit_credito       = texto(string(vsit_credito)).
        ttreturn.vcto_credito      = EnviaData(vvctoLimite).
        ttreturn.mensagem_credito  = if  neuproposta.neu_resultado = "P"  
                                     then "Encaminhar Cliente a FILA DE CREDITO"
                                     else neuproposta.RET_MOTIVOS.
                                     
        ttreturn.neuro_id_operacao = vneu_cdoperacao.

        hsaida = temp-table ttreturn:HANDLE.


        run log("RETORNA PARA P2K ID=" + vneu_cdoperacao + " Situacao=" + vsit_credito).

        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        put unformatted string(vlcsaida).

        /*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
        os-command silent cat saida.json.
        */


        run log("FIM NOVO FLUXO").
        return.
        
end.
else do:
            if vneu_cdoperacao = ""
            then run log("NOVA PROPOSTA " +  " CPF " + string(neuclien.cpf)).
            else run log("PROPOSTA " + vneu_cdoperacao + " CPF " + string(neuclien.cpf) +
                        " NAO EXISTENTE. SERA ELIMINADA E HAVERA NOVA PROPOSTA").
        AtualizacaoDadosCliente.neuro_id_operacao = "".
        vneu_cdoperacao = "".
end.
/** NOVO FLUXO */



if avail clien and (vstatus = "S" or vstatus = "I")
then do on error undo:



        /* campos que nao pode ser alterados 
        •         Código do Cliente (gerado pelo sistema)
        •         Nome do cliente;
        •         Filiação;
        •         Número do CPF/CNPJ do cliente;
        •         Número do RG do cliente;
        •         Data Nascimento
        •         Data de cadastro
        */
        
        /* campos alteraveis 
        •         Tipo Pessoa    NAO
        •         Sexo
        •         Nacionalidade
        •         Crédito
        •         Estado Civil
        •         Naturalidade
        •         Logradouro
        •         Numero
        •         Complemento
        •         Bairro
        •         Cidade
        •         Estado
        •         CEP
        •         Telefone
        •         Renda Mensal
        •         Profissão
        •         Nome da Empresa
        •         Data de admissão
        •         Documentos apresentados (apenas para novo cadastro)
        */
    
    vidstatuscad = 0.
    vBloqueioAlteracaoCadastral = no.
       
   find current clien exclusive-lock no-wait no-error.
   /* helio 26062023 */
   if avail clien
   then do:
        find clienstatus of clien no-lock no-error.
        vidstatuscad = clienstatus.idstatuscad.
        vBloqueioAlteracaoCadastral = clienstatus.BloqueioAlteracaoCadastral.
   end.
   
   /**/
   if avail clien and vBloqueioAlteracaoCadastral = no
      then do:
      
    find cpclien where cpclien.clicod = clien.clicod exclusive-lock no-error.
    if not avail cpclien
    then do:
        create cpclien.
        cpclien.clicod = clien.clicod.
    end.
    clien.datexp = today.

    if vcgccpf <> ? and vcgccpf <> ""
        and (clien.ciccgc = ? or clien.ciccgc = "")
    then clien.ciccgc = vcgccpf.

    vchar = atualizacaodadoscliente.data_nascimento.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                     int(substring(vchar,9,2)),
                     int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then clien.dtnasc = vdata.                                 
    end.                                  
 
    if testavalido(atualizacaodadoscliente.sexo)
    then clien.sexo   = if atualizacaodadoscliente.sexo = "M" then true else false.

    if testavalido(atualizacaodadoscliente.nacionalidade)
    then clien.nacion = atualizacaodadoscliente.nacionalidade.

    if testavalido(atualizacaodadoscliente.identidade) 
    then clien.ciins  = atualizacaodadoscliente.identidade.

    if testavalido(atualizacaodadoscliente.inscricaoEstadual) 
    then clien.empresa_inscricaoEstadual  = atualizacaodadoscliente.inscricaoEstadual. 
    
    if testavalido(atualizacaodadoscliente.tipo_credito)
    then
        if atualizacaodadoscliente.tipo_credito = "0" or
           atualizacaodadoscliente.tipo_credito = "1"
        then clien.classe = int(atualizacaodadoscliente.tipo_credito).

    if testavalido(atualizacaodadoscliente.credito)
    then clien.limcrd = dec(atualizacaodadoscliente.credito).

    vchar = atualizacaodadoscliente.estado_civil.
    if testavalido(vchar)
    then do:
        vint = if vchar = "Solteiro" then 1
               else if vchar = "Casado"   then 2
               else if vchar = "Viuvo"    then 3
               else if vchar = "Desquitado" then 4
               else if vchar = "Divorciado" then 5
               else if vchar = "Falecido" then 6 
               else if vchar = "Uniao Estavel" then 7 
               else 0. 
        clien.estciv = vint.        
        /*
                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else
                            if clien.estciv = 7 then "Uniao Estavel" else "".

                /* Casado=2 | Divorciado=5 | Solteiro=1 | União Estável=7 | Viúvo=3 */
        */
    end.
                
    if testavalido(atualizacaodadoscliente.naturalidade)
    then assign
            clien.natur = atualizacaodadoscliente.naturalidade
            cpclien.var-char10 = atualizacaodadoscliente.naturalidade.
        
    if testavalido(atualizacaodadoscliente.endereco)
    then do:
        /* atualizacaocadastral */
        if  clien.endereco[1] <> caps(texto(atualizacaodadoscliente.endereco))
        then do: 
            clien.endereco[1] = caps(texto(atualizacaodadoscliente.endereco)).
            clien.ultimaAtualizacaoCadastral = today.
        end.
    end.    
    if testavalido(atualizacaodadoscliente.numero)
    then do:
        /* atualizacaocadastral */
        if  clien.numero[1] <> int(atualizacaodadoscliente.numero)
        then do: 
            clien.numero[1] = int(atualizacaodadoscliente.numero).
            clien.ultimaAtualizacaoCadastral = today.
        end.
        
    end.        
        
    if testavalido(atualizacaodadoscliente.complemento)
    then do:
        /* atualizacaocadastral */
        if  clien.compl[1] <> atualizacaodadoscliente.complemento
        then do: 
            clien.compl[1] = atualizacaodadoscliente.complemento.
            clien.ultimaAtualizacaoCadastral = today.
        end.
    end.        

    if testavalido(atualizacaodadoscliente.bairro)
    then do:
        /* atualizacaocadastral */
        if clien.bairro[1] <> atualizacaodadoscliente.bairro
        then do: 
            clien.bairro[1] = atualizacaodadoscliente.bairro.
            clien.ultimaAtualizacaoCadastral = today.
        end.
    end.        

    if testavalido(atualizacaodadoscliente.cidade)
    then do:
        /* atualizacaocadastral */ 
        if clien.cidade[1] <> atualizacaodadoscliente.cidade 
        then do: 
            clien.cidade[1] = atualizacaodadoscliente.cidade. 
            clien.ultimaAtualizacaoCadastral = today. 
        end. 
    end.
                                                                    
    if testavalido(atualizacaodadoscliente.uf)
    then do:
        /* atualizacaocadastral */ 
        if clien.ufecod[1] <> atualizacaodadoscliente.uf 
        then do: 
            clien.ufecod[1] = atualizacaodadoscliente.uf. 
            clien.ultimaAtualizacaoCadastral = today. 
        end. 
    end.
        
    if testavalido(atualizacaodadoscliente.cep)
    then do:
        /* atualizacaocadastral */ 
        if clien.cep[1] <> atualizacaodadoscliente.cep
        then do: 
            clien.cep[1] = atualizacaodadoscliente.cep. 
            clien.ultimaAtualizacaoCadastral = today. 
        end. 
    end.
        
    if testavalido(atualizacaodadoscliente.telefone)
    then do:
            /* atualizacaocadastral*/
            if  clien.fone <> atualizacaodadoscliente.telefone
            then do: 
                clien.fone   = atualizacaodadoscliente.telefone.
                clien.ultimaAtualizacaoCadastral = today.
            end.
    end.        

    if testavalido(atualizacaodadoscliente.renda_total)
    then do:
        vdec = dec(atualizacaodadoscliente.renda_total) no-error.
        if vdec <> ?
        then do:
            /* atualizacaocadastral*/
            if  clien.prorenda[1] <> vdec
            then do: 
                clien.prorenda[1] = vdec.
                clien.ultimaAtualizacaoCadastral = today.
            end.
        end.    
    end.
                
    if testavalido(atualizacaodadoscliente.profissao)
    then do.
        /* atualizacaocadastral*/
        if clien.proprof[1] <>  texto(atualizacaodadoscliente.profissao)
        then do: 
            clien.proprof[1] = texto(atualizacaodadoscliente.profissao).
            clien.ultimaAtualizacaoCadastral = today.
        end.
        find first profissao where profissao.profdesc = clien.proprof[1]
                             no-lock no-error.
        if avail profissao
        then cpclien.var-int4 = profissao.codprof.
    end.

    if testavalido(atualizacaodadoscliente.empresa)
    then clien.proemp[1] = atualizacaodadoscliente.empresa.

        
    vchar = atualizacaodadoscliente.data_admissao.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                                 int(substring(vchar,9,2)),
                                 int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then clien.prodta[1] = vdata.                                 
    end.                                  
        
    if testavalido(atualizacaodadoscliente.documentos_apresentados_rf1)
    then clien.entendereco[1] =
                        atualizacaodadoscliente.documentos_apresentados_rf1.

    if testavalido(atualizacaodadoscliente.email)
    then clien.zona = lc(atualizacaodadoscliente.email).

    vchar = atualizacaodadoscliente.deseja_receber_email.
    if testavalido(vchar) and vchar = "Sim"
    then cpclien.emailpromocional = true.
    else cpclien.emailpromocional = false.
                
    /* outros campos alteraveis */
    if testavalido(atualizacaodadoscliente.numero_dependentes)
    then do:
        vdec = int(atualizacaodadoscliente.numero_dependentes) no-error.
        if vdec <> ?
        then clien.numdep = int(vdec).
    end.
        
    
    vchar = atualizacaodadoscliente.grau_de_instrucao.
    if testavalido(vchar)
    then cpclien.var-char8 = "INSTRUCAO=" + vchar .         

    vchar = atualizacaodadoscliente.situacao_grau_de_instrucao.
    if testavalido(vchar) and vchar = "Sim"
    then cpclien.var-log8 = true.
    else cpclien.var-log8 = false.
    
    vchar = atualizacaodadoscliente.plano_saude.
    if testavalido(vchar)
    then assign
            cpclien.var-log7  = yes
            cpclien.var-char7 = trim(vchar) + "=|".

    vchar = atualizacaodadoscliente.seguros.
    if testavalido(vchar)
    then assign
            cpclien.var-log6  = yes
            cpclien.var-char6 = trim(vchar) + "=|".
        
    vchar = atualizacaodadoscliente.ponto_referencia.
    if testavalido(vchar)
    then cpclien.var-char9 = vchar.         
        
    if testavalido(atualizacaodadoscliente.celular)
    then clien.fax = atualizacaodadoscliente.celular.

    vchar = atualizacaodadoscliente.tipo_residencia.
    if testavalido(vchar)
    then clien.tipres = if vchar = "Propria" then yes else no. 

    if testavalido(atualizacaodadoscliente.tempo_na_residencia)
    then do:
        vdec = int(atualizacaodadoscliente.tempo_na_residencia) no-error.
        if vdec <> ?
        then clien.temres = int(vdec).
    end.

    if testavalido(atualizacaodadoscliente.pai)
    then clien.pai = atualizacaodadoscliente.pai.
    if testavalido(atualizacaodadoscliente.mae)
    then clien.mae = atualizacaodadoscliente.mae.

    
    if testavalido(atualizacaodadoscliente.cnpj_empresa)
    then cpclien.var-char1 = atualizacaodadoscliente.cnpj_empresa.

    if testavalido(atualizacaodadoscliente.telefone_empresa)
    then clien.protel[1] = atualizacaodadoscliente.telefone_empresa.

    if testavalido(atualizacaodadoscliente.endereco_empresa)
    then clien.endereco[2] = atualizacaodadoscliente.endereco_empresa.

    if testavalido(atualizacaodadoscliente.numero_empresa)
    then clien.numero[2] = int(atualizacaodadoscliente.numero_empresa).

    if testavalido(atualizacaodadoscliente.complemento_empresa)
    then clien.compl[2] = atualizacaodadoscliente.complemento_empresa.

    if testavalido(atualizacaodadoscliente.bairro_empresa)
    then clien.bairro[2] = atualizacaodadoscliente.bairro_empresa.
        
    if testavalido(atualizacaodadoscliente.cidade_empresa)
    then clien.cidade[2] = atualizacaodadoscliente.cidade_empresa.
        
    if testavalido(atualizacaodadoscliente.estado_empresa)
    then clien.ufecod[2] = atualizacaodadoscliente.estado_empresa.

    if testavalido(atualizacaodadoscliente.cep_empresa)
    then clien.cep[2] = atualizacaodadoscliente.cep_empresa.

def var vnomconj   as char.
def var vcpfconj   as char.
def var vnaturconj as char.

    if clien.conjuge <> ?
    then assign
            vcpfconj   = substr(clien.conjuge,51,20)
            vnaturconj = substr(clien.conjuge,71,20).

    if testavalido(atualizacaodadoscliente.nome_conjuge)
    then vnomconj = atualizacaodadoscliente.nome_conjuge.

    if testavalido(atualizacaodadoscliente.cpf_conjuge)
    then vcpfconj = trata-numero(atualizacaodadoscliente.cpf_conjuge).

    clien.conjuge = string(vnomconj,"x(50)") + string(vcpfconj,"x(20)") +
                    string(vnaturconj,"x(20)").
                                    
    vchar = atualizacaodadoscliente.data_nascimento_conjuge.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                         int(substring(vchar,9,2)),
                         int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then clien.nascon = vdata.                                 
    end.                                  
        
    if testavalido(atualizacaodadoscliente.pai_conjuge)
    then clien.conjpai = atualizacaodadoscliente.pai_conjuge.

    if testavalido(atualizacaodadoscliente.mae_conjuge)
    then clien.conjmae = atualizacaodadoscliente.mae_conjuge.
        
    if testavalido(atualizacaodadoscliente.empresa_conjuge)
    then clien.proemp[2] = atualizacaodadoscliente.empresa_conjuge.

    if testavalido(atualizacaodadoscliente.telefone_conjuge)
    then clien.protel[2] = atualizacaodadoscliente.telefone_conjuge.

    if testavalido(atualizacaodadoscliente.profissao_conjuge)
    then do.
        clien.proprof[2] = texto(atualizacaodadoscliente.profissao_conjuge).
        if clien.proprof[2] <>  texto(atualizacaodadoscliente.profissao_conjuge)
        then do: 
            clien.proprof[2] = texto(atualizacaodadoscliente.profissao_conjuge).
            clien.ultimaAtualizacaoCadastral = today.
        end.
        
        find first profissao where profissao.profdesc = clien.proprof[2]
                             no-lock no-error.
        if avail profissao
        then cpclien.var-int5 = profissao.codprof.
    end.

    vchar = atualizacaodadoscliente.data_admissao_conjuge.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                                 int(substring(vchar,9,2)),
                                 int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then clien.prodta[2] = vdata.                                 
    end.                                  
 
    if testavalido(atualizacaodadoscliente.renda_mensal_conjuge)
    then do:
        vdec = dec(atualizacaodadoscliente.renda_mensal_conjuge) no-error.
        if vdec <> ?
        then do:
            /* atualizacaocadastral*/
            if  clien.prorenda[2] <> vdec
            then do: 
                clien.prorenda[2] = vdec.
                clien.ultimaAtualizacaoCadastral = today.
            end.
        end.    
    end.
        
    if testavalido(atualizacaodadoscliente.cartoes_de_credito)
    then do:
        cpclien.var-int = "0". /* limpar cartoes */

        /* Os Nomes dos cartoes vem separados por "," ***/
        vcartoes = atualizacaodadoscliente.cartoes_de_credito.
        do vct = 1 to num-entries(vcartoes).
            do vint = 1 to 7.
                if trim(entry(vct, vcartoes)) = auxcartao[vint]
                then cpclien.var-int[vint] = string(vint).
            end.
        end.
    end.

    if testavalido(atualizacaodadoscliente.banco1) or
       testavalido(atualizacaodadoscliente.banco2) or
       testavalido(atualizacaodadoscliente.banco3) or
       testavalido(atualizacaodadoscliente.banco_outros)
    then do.
        cpclien.var-ext2 = "". /* limpar bancos */
        cpclien.var-ext3 = "".
        cpclien.var-ext4 = "".
                                
        run banco (atualizacaodadoscliente.banco1,
                   atualizacaodadoscliente.tipo_conta_banco1,
                   atualizacaodadoscliente.ano_conta_banco1).
        run banco (atualizacaodadoscliente.banco2,
                   atualizacaodadoscliente.tipo_conta_banco2,
                   atualizacaodadoscliente.ano_conta_banco2).
        run banco (atualizacaodadoscliente.banco3,
                   atualizacaodadoscliente.tipo_conta_banco3,
                   atualizacaodadoscliente.ano_conta_banco3).
        run banco (atualizacaodadoscliente.banco_outros,
                   atualizacaodadoscliente.tipo_conta_outros,
                   atualizacaodadoscliente.ano_banco_outros).
    end.

    clien.refcom[1] = "". /* limpar dados */
    if avail cpclien
    then assign
            clien.refcom = ""
            cpclien.var-ext1 = "".

    if testavalido(atualizacaodadoscliente.referencias_comerciais1)
    then clien.refcom[1] = atualizacaodadoscliente.referencias_comerciais1.

    if testavalido(atualizacaodadoscliente.situacao_referencias_comerciais1)
    then    
    case atualizacaodadoscliente.situacao_referencias_comerciais1:
        when "Apresentado"       then cpclien.var-ext1[1] = "1".
        when "Nao Apresentado"   then cpclien.var-ext1[1] = "2".
        when "Nao possui cartao" then cpclien.var-ext1[1] = "3".
    end case.    

    if testavalido(atualizacaodadoscliente.referencias_comerciais2)
    then clien.refcom[2] = atualizacaodadoscliente.referencias_comerciais2.

    if testavalido(atualizacaodadoscliente.situacao_referencias_comerciais2)
    then    
    case atualizacaodadoscliente.situacao_referencias_comerciais2:
        when "Apresentado"       then cpclien.var-ext1[2] = "1".
        when "Nao Apresentado"   then cpclien.var-ext1[2] = "2".
        when "Nao possui cartao" then cpclien.var-ext1[2] = "3".
    end case.    

    if testavalido(atualizacaodadoscliente.referencias_comerciais3)
    then clien.refcom[3] = atualizacaodadoscliente.referencias_comerciais3.

    if testavalido(atualizacaodadoscliente.situacao_referencias_comerciais3)
    then    
    case atualizacaodadoscliente.situacao_referencias_comerciais3:
        when "Apresentado"       then cpclien.var-ext1[3] = "1".
        when "Nao Apresentado"   then cpclien.var-ext1[3] = "2".
        when "Nao possui cartao" then cpclien.var-ext1[3] = "3".
    end case.    

    if testavalido(atualizacaodadoscliente.referencias_comerciais4)
    then clien.refcom[4] = atualizacaodadoscliente.referencias_comerciais4.

    if testavalido(atualizacaodadoscliente.situacao_referencias_comerciais4)
    then    
    case atualizacaodadoscliente.situacao_referencias_comerciais4:
        when "Apresentado"       then cpclien.var-ext1[4] = "1".
        when "Nao Apresentado"   then cpclien.var-ext1[4] = "2".
        when "Nao possui cartao" then cpclien.var-ext1[4] = "3".
    end case.    

    if testavalido(atualizacaodadoscliente.referencias_comerciais5)
    then clien.refcom[5] = atualizacaodadoscliente.referencias_comerciais5.

    if testavalido(atualizacaodadoscliente.situacao_referencias_comerciais5)
    then    
    case atualizacaodadoscliente.situacao_referencias_comerciais5:
        when "Apresentado"       then cpclien.var-ext1[5] = "1".
        when "Nao Apresentado"   then cpclien.var-ext1[5] = "2".
        when "Nao possui cartao" then cpclien.var-ext1[5] = "3".
    end case.    

    if testavalido(atualizacaodadoscliente.observacoes)
    then do:
        clien.autoriza[1] = substr(atualizacaodadoscliente.observacoes,1,80).
        clien.autoriza[2] = substr(atualizacaodadoscliente.observacoes,81,80).
        clien.autoriza[3] = substr(atualizacaodadoscliente.observacoes,161,80).
        clien.autoriza[4] = substr(atualizacaodadoscliente.observacoes,241,80).
        clien.autoriza[5] = substr(atualizacaodadoscliente.observacoes,321).
    end.            
        
    vchar = atualizacaodadoscliente.possui_veiculo.
    if testavalido(vchar)
    then do:
        find carro where carro.clicod = clien.clicod exclusive-lock no-error.
        if not avail carro
        then do:
            create carro.
            carro.clicod = clien.clicod.
        end.
        carro.carsit = if vchar = "SIM" then yes else no.                 

        if testavalido(atualizacaodadoscliente.marca)
        then carro.marca  = atualizacaodadoscliente.marca.
        if testavalido(atualizacaodadoscliente.modelo)
        then carro.modelo = atualizacaodadoscliente.modelo.
        vint = int(atualizacaodadoscliente.ano) no-error.
        if vint <> ?
        then carro.ano = vint.
    end.

        
    if testavalido(atualizacaodadoscliente.nome_ref1)
    then clien.entbairro[1] = atualizacaodadoscliente.nome_ref1.
    if testavalido(atualizacaodadoscliente.fone_comercial_ref1)
    then clien.entcep[1] = atualizacaodadoscliente.fone_comercial_ref1.
    if testavalido(atualizacaodadoscliente.celular_ref1)
    then clien.entcidade[1] = atualizacaodadoscliente.celular_ref1.
    if testavalido(atualizacaodadoscliente.parentesco_ref1)
    then clien.entcompl[1] = atualizacaodadoscliente.parentesco_ref1.
        
    if testavalido(atualizacaodadoscliente.nome_ref2)
    then clien.entbairro[2] = atualizacaodadoscliente.nome_ref2.
    if testavalido(atualizacaodadoscliente.fone_comercial_ref2)
    then clien.entcep[2] = atualizacaodadoscliente.fone_comercial_ref2.
    if testavalido(atualizacaodadoscliente.celular_ref2)
    then clien.entcidade[2] = atualizacaodadoscliente.celular_ref2.
    if testavalido(atualizacaodadoscliente.parentesco_ref2)
    then clien.entcompl[2] = atualizacaodadoscliente.parentesco_ref2.
        
    if testavalido(atualizacaodadoscliente.documentos_apresentados_rf2)
    then clien.entendereco[2] =
                        atualizacaodadoscliente.documentos_apresentados_rf2.
                
    if testavalido(atualizacaodadoscliente.nome_ref3)
    then clien.entbairro[3] = atualizacaodadoscliente.nome_ref3.
    if testavalido(atualizacaodadoscliente.fone_comercial_ref3)
    then clien.entcep[3] = atualizacaodadoscliente.fone_comercial_ref3.
    if testavalido(atualizacaodadoscliente.celular_ref3)
    then clien.entcidade[3] = atualizacaodadoscliente.celular_ref3.
    if testavalido(atualizacaodadoscliente.parentesco_ref3)
    then clien.entcompl[3] = atualizacaodadoscliente.parentesco_ref3.
        
    if testavalido(atualizacaodadoscliente.documentos_apresentados_rf3)
    then clien.entendereco[3] = 
                        atualizacaodadoscliente.documentos_apresentados_rf3.

    if testavalido(atualizacaodadoscliente.nota)
    then cpclien.var-int3 = int(atualizacaodadoscliente.nota) no-error.

    if testavalido(atualizacaodadoscliente.codigo_mae)
    then do:
        if avail neuclien
        then do:
            find current neuclien exclusive.
            neuclien.codigo_mae = int(atualizacaodadoscliente.codigo_mae) 
                        no-error.
        end.
    end.        
    if testavalido(atualizacaodadoscliente.categoria_profissional)
    then do:
        if avail neuclien
        then do:
            find current neuclien exclusive.
            neuclien.catprof = atualizacaodadoscliente.categoria_profissional
             no-error.
        end.
    end.        

    /* helio 22122021 - Cadastro P2k - Campos Optin */
    vchar = atualizacaodadoscliente.optinWhatsApp no-error.
    if testavalido(vchar) /* helio 08022022 - combinado com Roberto, só valido altera */
    then do:
        if vchar = "Sim"
        then clien.optinWhatsApp = yes.
        else clien.optinWhatsApp = no.
    end.

    vchar = atualizacaodadoscliente.optinSMS no-error.
    if testavalido(vchar)
    then do:
        if vchar = "Sim"
        then clien.optinSMS = yes.
        else clien.optinSMS = no.
    end.

    /* helio 22122021 - Cadastro P2k - Campos Optin */

    clien.patrimonio = atualizacaodadoscliente.patrimonio no-error.
    clien.pessoaexposta = atualizacaodadoscliente.pessoaexposta = "true" no-error.
    clien.nomeSocial = atualizacaodadoscliente.nomeSocial no-error.
     
    clien.genero = texto(atualizacaodadoscliente.genero) no-error.
    verafalecido = clien.falecido.

    clien.falecido = atualizacaodadoscliente.falecido = "true" no-error.

    if clien.falecido  and not verafalecido
    then do:
        run cli/statuscadins.p (input clien.clicod, "STATUSCAD_FALECIDO", ?).
    end.


    find current clien no-lock.
   
    vmensagem_erro = "Cliente Codigo: " + 
            string(clien.clicod) + " " +  string(clien.clinom) + " "
            + if vnovo then " Cadastrado. " else " Atualizado. ".
  end. /* on error */
end.               

/* MOTOR NEUROTECH */
if avail clien and
   avail neuclien and
   (vstatus = "S" or 
    vstatus = "I") 
    /*#11*/ and not vforcasitPJ 
then do:
        /**run ./progr/hiscli_05.p (clien.clicod). **/

            /** Testa se vai para NEUROTECH **/  
            /* 16.11.2017 - mudou para testar primeiro */

        /* helio 24012023 ID 157487 - Revisão regras P3 */
        /* regra antiga, basta ter 1 contrato
        *find first contrato use-index iconcli
        *            where contrato.clicod = clien.clicod no-lock no-error.
        *if not avail contrato
        *then vPOLITICA = "P2".   /* Regra, cliente nao possui cadastro */ 
        *else vPOLITICA = "P3".
        */
        /* nova regra, desconsidera contratos com idAdesaoHubSeg preenchidos */
        /* foi explicado que pode surgir perda de performance, caso o cliente possua muitos hubseg */
        vPOLITICA = "P2".   /* Regra, cliente nao possui cadastro */ 
        for each contrato use-index iconcli
                    where contrato.clicod = clien.clicod no-lock 
                by contrato.dtinicial.
            if contrato.idAdesaoHubSeg = "" or
               contrato.idAdesaoHubSeg = ? 
            then do:
                vPOLITICA = "P3". /* tem contrato normal */
                leave.
            end.
        end.

        
        run log("ID_BIOMETRIA " + texto(AtualizacaoDadosCliente.ID_BIOMETRIA)).


        vchar = if vprocessa_credito
                then "Politica " + vpolitica +
                     " LJNeuro=" + string(vlojaneuro,"S/N") +
                     " Submete=" + string(vneurotech,"S/N")
                else "TPCadastro " + vtipo_cadastro + " SIT=" + vsit_credito.

        run log("gravaneuclilog 1 PRIMEIRA AVALIACAO SUBMETE " + vchar).

        if vprocessa_credito /* #6 */
        then do:
             run log("submeteneuro Politica=" + vpolitica).
             run neuro/submeteneuro_v1802.p (input setbcod, 
                                             input vpolitica,
                                             input clien.clicod,   
                                             0,
                                             output vlojaneuro, 
                                             output vneurotech).
        vchar = if vprocessa_credito
                then "Politica " + vpolitica +
                     " LJNeuro=" + string(vlojaneuro,"S/N") +
                     " Submete=" + string(vneurotech,"S/N")
                else "TPCadastro " + vtipo_cadastro + " SIT=" + vsit_credito.

        run log("gravaneuclilog 2 PRIMEIRA AVALIACAO SUBMETE " + vchar).

        end.
        else do: /* #6 */
                vlojaneuro = no.
                vneurotech = no.
                vsit_credito = "A".
        end.
        
        /* #2 LOG PARA PRIMEIRA AVALIACAO SUBMETE */
        vchar = if vprocessa_credito
                then "Politica " + vpolitica +
                     " LJNeuro=" + string(vlojaneuro,"S/N") +
                     " Submete=" + string(vneurotech,"S/N")
                else "TPCadastro " + vtipo_cadastro + " SIT=" + vsit_credito.
        run log("gravaneuclilog 3 PRIMEIRA AVALIACAO SUBMETE " + vchar).
        run neuro/gravaneuclilog_v1802.p 
                (neuclien.cpfcnpj, 
                 vtipoconsulta, 
                 0, 
                 setbcod, 
                 AtualizacaoDadosCLiente.numero_pdv, 
                 neuclien.sit_credito,
                 vchar).
        /* #2
        *if  vlojaneuro and 
        *    (
        *    neuclien.vctolimite <> ?  /* quais situacoes vai atualizar **/
        *   and neuclien.vctolimite >= today 
        *   and neuclien.sit_credito = "A" 
        *    )
        *then do:
        */
        /*  #2 
            VALIDA:
            SEMPRE TESTE SE CLIENTE TEM LIMITE VALIDO - USA O VLRLIMiTE
            SE FOR LOJANEURO e o VLRLIMITE FOR ZERADO - NAO VAO NO MOTOR
        */    
                
        /* #3 */
        vneu_cdoperacao = "".       
        vneu_politica = "".


/* #10 */
    if AtualizacaoDadosCliente.neuro_id_operacao <> "" or
       AtualizacaoDadosCliente.neuro_id_operacao <> "?"
    then do.
    
        vneu_cdoperacao = AtualizacaoDadosCliente.neuro_id_operacao.  /* Helio - 30.10.2019 */

        find neuproposta where
                    neuproposta.etbcod  = setbcod
                and neuproposta.cxacod  = scxacod /*#10 */
                and neuproposta.dtinclu = today
                and neuproposta.cpfcnpj = neuclien.cpfcnpj
                and neuproposta.neu_cdoperacao =
                                     AtualizacaoDadosCliente.neuro_id_operacao
            no-lock no-error.
        if avail neuproposta
        then
            if neuproposta.tipoconsulta = "P2"
            then do:
                /*vneu_cdoperacao = neuproposta.neu_cdoperacao.*/
                vsit_credito    = neuproposta.neu_resultado.
                if vPOLITICA = "P2" /* quando for P2, vai resubmeter */
                then vneurotech = yes.
            end.    
    end.
        /* #3 */
        if  /* #3 - Quando Tiver P2 Pendente e nao for P2 Nao Sobe Neuro*/
            (vneu_cdoperacao <> "" and 
             vneu_politica   = "P2" and
             vPOLITICA       <> "P2") 
             or 
           (vneu_cdoperacao = "" and
           avail neuclien and
              ( (neuclien.vctolimite <> ? and neuclien.vctolimite >= today) and
                 neuclien.vlrlimite > 0) )  
        then do: /* Nao vai para a Neuro */
            run log("Nao Sobe Neuro neu_cdoperacao(P2)=" + vneu_cdoperacao +
                    " neu_politica=" + vneu_politica +
                    " POLITICA=" + vPOLITICA).
            
            /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */
            vchar = "USANDO NEUCLIEN VCTO=" +
                    (if neuclien.vctolimite = ?
                     then "-" else string(neuclien.vctolimite)) +
                    " VLR=" + string(neuclien.vlrlimite).
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     0,
                     setbcod,
                     AtualizacaoDadosCliente.numero_pdv,
                     neuclien.sit_credito,
                     vchar).
            vvlrLimite   = neuclien.vlrlimite.
            vvctoLimite  = neuclien.vctolimite.
            vsit_credito = if vneu_cdoperacao <> "" /* #3 */
                           then "P" 
                           else "A".
        end.
        else do:
            /* #2
                cai neste ELSE
                QUANDO NAO POSSUIR NEUCLIEN
                QUANDO LIMITE NAO ESTIVER VALIDO
                QUANDO LIMITE FOR ZERADO e for LOJA ADMCOM
            */    
            
            /* #2 LOG PARA SUBMETE */ 
            vtimeini = mtime.
            vchar = if vneurotech
                    then "SUBMETE=" + vPOLITICA + " " + vneu_cdoperacao
                    else "NAO SUBMETE".
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     vtimeini,
                     setbcod,
                     AtualizacaoDadosCliente.numero_pdv,
                     neuclien.sit_credito,
                     vchar).

            if vneurotech
            then do:
                /* cai aqui 
                    QUANDO LOJANEURO e REGRAS SUBMISSAO = SUBMETE 
                */    
                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else
                            if clien.estciv = 7 then "Uniao Estavel" else "".

                /* Casado=2 | Divorciado=5 | Solteiro=1 | União Estável=7 | Viúvo=3 */

                if avail cpclien and cpclien.var-log8 = true
                then assign vsituacao-instrucao = "Sim".
                else assign vsituacao-instrucao = "Nao".
          
                if avail cpclien and cpclien.var-char8 <> ?
                then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
                else vinstrucao = "".
           
                if avail cpclien and cpclien.var-char6 <> ?
                then vseguro = entry(1,trim(cpclien.var-char6),"=").
                else vseguro = "".
            
                if avail cpclien and cpclien.var-char7 <> ?
                then vplanosaude = entry(1,cpclien.var-char7,"=").
                else vplanosaude = "".

                vrenda         = if clien.prorenda[1] = ?
                                 then 0
                                 else clien.prorenda[1].
                vrenda_conjuge = if clien.prorenda[2] = ?
                                 then 0
                                 else clien.prorenda[2].

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

                vlstrefcomerc = "".
                do vx = 1 to 5:
                    vlstrefcomerc = vlstrefcomerc + 
                                    (if vlstrefcomerc = "" then "" else ";") +  
                                    Texto(clien.refcom[vx]) + "|".
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
                    vlstdadosveic = Texto(carro.marca) + ";" +
                                    Texto(carro.modelo) + ";" +
                                   (if carro.ano <> ?
                                    then string(carro.ano,"9999") else "").
                end.
                vlstrefpessoais = "".
                do vx = 1 to 3.
                    vlstrefpessoais = vlstrefpessoais +
                                      (if vlstrefpessoais = ""
                                       then "" else ";") +
                                      Texto(clien.entbairro[vx]) + "|" + 
                                      Texto(clien.entcep[vx])    + "|" + 
                                      Texto(clien.entcidade[vx]) + "|" +
                                      Texto(clien.entcompl[vx]). 
                end.
                vlstspc = "".
                vlstspc = if clien.entrefcom[1] <> ?
                          then enviaData(date(clien.entrefcom[1]))
                          else "".
                if vlstspc = ? then vlstspc = "".
                if vlstspc <> ""
                then do:
                    vale-spc = acha("alertas",clien.entrefcom[2]).
                    if vale-spc = ? then vale-spc = "".
                    vcre-spc = acha("credito",clien.entrefcom[2]).
                    if vcre-spc = ? then vcre-spc = "".
                    vche-spc = acha("cheques",clien.entrefcom[2]).
                    if vche-spc = ? then vche-spc = "".
                    vnac-spc = acha("nacional",clien.entrefcom[2]).
                    if vnac-spc = ? then vnac-spc = "".

                    vlstspc = vlstspc + "|" + vale-spc.
                    vlstspc = vlstspc + "|" + vcre-spc.
                    vlstspc = vlstspc + "|" + vche-spc.
                    vlstspc = vlstspc + "|" + vnac-spc.
                end.

                if vpolitica = "P2"
                then do:  
                    vprops = 
                        /* helio 032021 politica de credito unificada */
                            /*"POLITICA="        + "CREDITO" + string(setbcod,"9999")*/
                        "POLITICA="        + "CREDITO_UNIFICADA"
                       + "&PROP_LOJAVENDA="       + string(setbcod,"9999") 
                       /*helio 032021 politica de credito unificada */
                       
                       + (if vneu_cdoperacao = ""
                          then ""
                          else "&PROP_IDOPERACAO=" + trim(vneu_cdoperacao))
                       +
                        "&PROP_CONTACLI="       + trim(string(clien.clicod)) + 
                        "&PROP_NOMECLI="        + trim(clien.clinom) +  
                        "&PROP_TIPOCREDITO="    + "NORMAL"    
                       + "&PROP_TIPOPESSOA=" + (if clien.tippes <> ?
                                                then string(clien.tippes,"F/J")
                                                else "")
                       + "&PROP_CPFCLI="         + trim(clien.ciccgc)   
                       + "&PROP_RGCLI="          + (if clien.tippes then texto(clien.ciins)  else "") 
                       + "&PROP_INSCEST="        + (if clien.tippes = no then texto(clien.ciins)  else texto(clien.empresa_inscricaoEstadual)) /*#01082022*/
                       + "&PROP_DTNASCCLI="      +
                                    texto(string(clien.dtnasc,"99/99/9999"))
                       + "&PROP_CATEGCLI="       + trim(neuclien.catprof) 
                       + "&PROP_SEXOCLI="        + string(clien.sexo,"M/F")
                       + "&PROP_PLANOSAUDE="     + texto(vplanosaude)
                       + "&PROP_SEGURO="         + texto(vseguro)
                       + "&PROP_INSTRUCAOCLI="   + texto(vinstrucao)   
                       + "&PROP_INSTCOMP="       + texto(vsituacao-instrucao)
                       + "&PROP_NATURALCLI=" + 
                                            (if avail cpclien
                                               then Texto(cpclien.var-char10)
                                               else "")
                       + "&PROP_NOMEPAICLI="    + texto(clien.pai)
                       + "&PROP_ESTADOCIVIL="    + texto(cestcivil)   
                       + "&PROP_NOMEMAE="        + trim(clien.mae) 
                       + "&PROP_CONTAMAE=" + texto(string(neuclien.codigo_mae))
                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_EMAILCLI=" + lc(texto(clien.zona))
                       + "&PROP_LOGRADCLI=" + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="    + texto(string(clien.numero[1]))
                       + "&PROP_CEP="            +      Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="      +      Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="    +      Texto(clien.compl[1])  
                       + "&PROP_CIDADE="         +      Texto(clien.cidade[1])
                       + "&PROP_UF="             +      Texto(clien.ufecod[1])

                       + "&PROP_TIPORESID="      + string(clien.tipres,
                                                            "Propria/Alugada")
                       + "&PROP_TEMPORESID="     +  texto( 
                               substr(string(int(temres),"999999"),1,2) + "/" +
                               substr(string(int(temres),"999999"),3,4) )
                       + "&PROP_CELULAR="        + Texto(clien.fax)  
                       + "&PROP_TELEFONE="       + Texto(clien.fone) 
                       + "&PROP_DTCADASTRO=" + 
                                texto(string(clien.dtcad,"99/99/9999"))
                       + "&PROP_EMPRESA="        + Texto(clien.proemp[1])  
                       + "&PROP_CNPJCOMERC="     +      
                                (if avail cpclien
                                 then Texto(cpclien.var-char1) else "")
                       + "&PROP_FONECOMERC="     + texto(clien.protel[1])
                      + "&PROP_DTADMISSAO="     +      texto(string(clien.prodta[1],"99/99/9999"))
                       + "&PROP_PROFISSAO="      + Texto(clien.proprof[1])
                        
                       + "&PROP_ENDCOMERC="      + texto(clien.endereco[2])
                       + "&PROP_NUMCOMERC="   + texto(string(clien.numero[2]))
                       + "&PROP_CIDADECOMERC=" + texto(clien.cidade[2])    
                       + "&PROP_UFCOMERC="    + texto(clien.ufecod[2])
                       + "&PROP_CEPCOMERC=" + texto(clien.cep[2])     
                       + "&PROP_RENDAMES="       +      string(vrenda)
                       + "&PROP_SOMARENDAS="     +      string(vrenda + vrenda_conjuge)
                        
                       + "&PROP_NOMECONJUGE=" +                                     texto(substr(clien.conjuge,1,50))   
                       + "&PROP_CPFCONJUGE="   +  texto(substr(clien.conjuge,51,20))
                       + "&PROP_DTNASCCONJUGE="  + 
                            (if clien.nascon = ?
                            then ""
                            else string(clien.nascon,"99/99/9999"))
                       + "&PROP_EMPRCONJUGE="    +    
                                texto(clien.proemp[2])
                       + "&PROP_DTADMCONJUGE=" +
                            (if clien.prodta[2] = ?
                            then ""
                            else string(clien.prodta[2],"99/99/9999"))
                               
                       + "&PROP_RENDACONJUGE="   +       string(vrenda_conjuge)  
                        
                       + "&PROP_PROFCONJUGE=" + texto(clien.proprof[2])    
                       + "&PROP_LSTDADOSBANCO="  +  vlstdadosbanco  
                       + "&PROP_LSTREFCOMERC="   +  vlstrefcomerc  
                       + "&PROP_LSTCARTAOCRED="  +  vlstcartaocred  
                       + "&PROP_VEICULO="        +  vveiculo
                       + "&PROP_LSTDADOSVEIC="   +  vlstdadosveic  
                       + "&PROP_LSTREFPESSOAIS=" +  vlstrefpessoais 
                       + "&PROP_LSTSPC="         +  vlstspc
                       + "&PROP_NOTA="           + (if  not avail cpclien then ""
                                                  else texto( string(cpclien.var-int3) )   )
                       + "&PROP_LOJACAD="        + trim(string(if neuclien.etbcod = 0 or neuclien.etbcod = ? then setbcod else neuclien.etbcod)) 

                        /* helio 27062023 */
                       + "&PROP_PATRIMONIO=" + texto(clien.patrimonio)    
                       + "&PROP_PESSOAEXPOSTA=" + string(clien.pessoaexposta,"true/false")
                       + "&PROP_NOMESOCIAL=" + texto(clien.nomeSocial)    
                       + "&PROP_ATUALIZACAOCADASTRAL=" +  (if clien.ultimaAtualizacaoCadastral = ? then "" 
                                 else string(clien.ultimaAtualizacaoCadastral,"99/99/9999"))     
                       + "&PROP_GENERO=" + texto(clien.genero)   
                       + "&PROP_ID_BIOMETRIA=" + trim(texto(AtualizacaoDadosCliente.ID_BIOMETRIA))   

                       + "&PROP_FLXPOLITICA="    + vPOLITICA.
                
                end.
                else do:
                    find current neuclien no-lock.         
                    run log("comportamento").
                    run neuro/comportamento.p (neuclien.clicod, ?,  
                                       output var-propriedades). 
                    var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
                    if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
                    var-parcpag = int(pega_prop("PARCPAG")). 
                    if var-parcpag = ? then var-parcpag = 0.

                    var-atrasoatual = int(pega_prop("ATRASOATUAL")). /* #9 */
                    var-saldototnov = dec(pega_prop("SALDOTOTNOV")). /* #9 */
                    var-COMPROMETIMENTO_MENSAL = dec(pega_prop("COMPROMETIMENTO_MENSAL")). /* helio 11042022 - ajuste painel motor */
                    
                    /* helio #23112022 ID 154675 */
                    var-DTULTPAGTO = date(pega_prop("DTULTPAGTO")).
                    /**/
                    /* helio 22052023 ID 502416 */
                    var-QTDENOV = pega_prop("QTDENOV").
                    /**/ 
                    /* PROP_DTULTCPA */     var-dtultcpa = pega_prop("DTULTCPA"). /* #11 */
                    if var-dtultcpa = ? then var-dtultcpa = "".         
                    /* PROP_DTULTNOV */     var-dtultnov = pega_prop("DTULTNOV"). /* #11 */
                    if var-dtultnov = ? then var-dtultnov = "".         

                    vprops = 
                        /* helio 032021 politica de credito unificada */
                            /*"POLITICA="        + "CREDITO" + string(setbcod,"9999")*/
                        "POLITICA="        + "CREDITO_UNIFICADA"
                       + "&PROP_LOJAVENDA="       + string(setbcod,"9999") 
                        
                       + "&PROP_CONTACLI="     + trim(string(clien.clicod))
                       + "&PROP_NOMECLI="      + trim(clien.clinom)   
                       + "&PROP_CPFCLI="       + trim(clien.ciccgc)   
                       + "&PROP_INSCEST="        + (if clien.tippes = no then texto(clien.ciins)  else texto(clien.empresa_inscricaoEstadual)) /*#01082022*/
                       + "&PROP_DTNASCCLI="    + texto(string(clien.dtnasc,
                                                            "99/99/9999")) 
                       + "&PROP_LOGRADCLI="    + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="       + Texto(string(clien.numero[1]))
                       + "&PROP_CEP="          + Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="    + Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="  + Texto(clien.compl[1])  
                       + "&PROP_CIDADE="       + Texto(clien.cidade[1])
                       + "&PROP_UF="           + Texto(clien.ufecod[1])
                       + "&PROP_CELULAR="      + Texto(clien.fax)  
                       + "&PROP_TELEFONE="     + Texto(clien.fone) 
                       + "&PROP_DTCADASTRO=" + 
                                texto(string(clien.dtcad,"99/99/9999"))
                       + "&PROP_EMPRESA="        + Texto(clien.proemp[1])  
                       + "&PROP_DTADMISSAO="   + texto(string(clien.prodta[1],
                                                            "99/99/9999"))
                       + "&PROP_PROFISSAO="    + Texto(clien.proprof[1])
                       + "&PROP_RENDAMES="     + string(vrenda)
                       + "&PROP_SOMARENDAS="  + string(vrenda + vrenda_conjuge)
                       + "&PROP_LOJACAD="  + trim(string(if neuclien.etbcod = 0 or neuclien.etbcod = ? then setbcod else neuclien.etbcod)) 
                        + "&PROP_PARCPAG=" + string(var-parcpag)
                        + "&PROP_ATRASOPARCPERC=" + texto(var-atrasoparcperc)
                       + "&PROP_ATRASOATUAL="  + string(var-atrasoatual) /*#9*/
                       + "&PROP_SALDOTOTNOV="  + string(var-saldototnov) /*#9*/
                   /* #10 */
                   + "&PROP_PLANOSAUDE="   + texto(vplanosaude)
                   + "&PROP_SEGURO="       + texto(vseguro)
                   + "&PROP_INSTRUCAOCLI=" + texto(vinstrucao)
                   + "&PROP_ESTADOCIVIL="  + texto(cestcivil)
                   + "&PROP_DEPENDENTES="  + texto(string(clien.numdep))
                   + "&PROP_TIPORESID="    + string(clien.tipres,
                                                            "Propria/Alugada")
                   + "&PROP_TEMPORESID="   + Texto(
                               substr(string(int(temres),"999999"),1,2) + "/" +
                               substr(string(int(temres),"999999"),3,4))
                   + "&PROP_CPFCONJUGE="   + texto(substr(clien.conjuge,51,20))
                   + "&PROP_RENDACONJUGE=" + string(vrenda_conjuge)
                   + "&PROP_PROFCONJUGE="  + texto(clien.proprof[2])
                   + "&PROP_LSTDADOSBANCO=" + vlstdadosbanco
                   + "&PROP_LSTREFCOMERC=" + vlstrefcomerc
                   + "&PROP_LSTCARTAOCRED=" + vlstcartaocred
                   + "&PROP_VEICULO="      + vveiculo
                   + "&PROP_LSTDADOSVEIC=" + vlstdadosveic
                   + "&PROP_LSTREFPESSOAIS=" + vlstrefpessoais
                   + "&PROP_NOTA="         + (if not avail cpclien then ""
                                          else texto(string(cpclien.var-int3)))
                   + "&PROP_LIMITEATUAL="  + trim(string(neuclien.vlrlimite))  
                   + "&PROP_VALIDADELIM=" + (if neuclien.vctolimite = ? then "" 
                                 else string(neuclien.vctolimite,"99/99/9999"))
                    /* helio #23112022 ID 154675 */
                    + "&PROP_DTULTPAGTO=" + (if var-DTULTPAGTO = ? then "" 
                                 else string(var-DTULTPAGTO,"99/99/9999"))
                    /**/             
                                 
                    /* #10 */
                   + "&PROP_COMPROMETIMENTO_MENSAL="  + trim(string(var-COMPROMETIMENTO_MENSAL,"->>>>>>>>>>>>>>>>>>>>>>>>9.99"))  /* helio 11042022 - ajuste painel m~otor */
                   /* helio 22052023 ID 502416 */
                    + "&PROP_QTDENOV=" + (if var-QTDENOV = ? then ""  else string(var-QTDENOV))
                    + "&PROP_DTULTCPA="     + var-dtultcpa /* #11 */
                    + "&PROP_DTULTNOV="     + var-dtultnov /* #11 */
                    
                    /**/
                        /* helio 27062023 */
                       + "&PROP_PATRIMONIO=" + texto(clien.patrimonio)    
                       + "&PROP_PESSOAEXPOSTA=" + string(clien.pessoaexposta,"true/false")
                       + "&PROP_NOMESOCIAL=" + texto(clien.nomeSocial)    
                       + "&PROP_ATUALIZACAOCADASTRAL=" + (if clien.ultimaAtualizacaoCadastral = ? then "" 
                                 else string(clien.ultimaAtualizacaoCadastral,"99/99/9999"))     
                       + "&PROP_GENERO=" + texto(clien.genero)   
                       + "&PROP_ID_BIOMETRIA=" + trim(texto(AtualizacaoDadosCliente.ID_BIOMETRIA))                          

                       + "&PROP_FLXPOLITICA="    + vPOLITICA.

                end.   
        
                vtimeini = mtime.
                xneu_cdoperacao = vneu_cdoperacao.
                
                run neuro/wcneurotech_v2101.p /* helio 21062021 - chamado por REST */
                                              (setbcod,
                                               scxacod,
                                               input vprops,
                                               input vPOLITICA,
                                               input vtimeini,
                                               input par-recid-neuclien, 
                                        input-output xneu_cdoperacao, /* #10 */
                                               input 0, /* #10 */
                                               output vvlrLimite, 
                                               output vvctolimite,
                                               output vneuro-sit, 
                                               output vneuro-mens,
                                               output vstatus,
                                               output vmensagem_erro).
                if vneu_cdoperacao = ""
                then vneu_cdoperacao = xneu_cdoperacao.
                
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
                vchar = if not vneurotech
                        then "ERRO MOTOR - USARA ADMCOM"
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
                         0, 
                         setbcod, 
                         AtualizacaoDadosCliente.numero_pdv, 
                         vsit_credito, 
                         vchar).
            end.
            
            if vneurotech = no and
               vprocessa_credito = yes
            then do: /** ADMCOM **/
                run log("callimiteadmcom").
                vtime = mtime.
                vtimeini = mtime.
                run neuro/callimiteadmcom.p (recid(neuclien),
                                    "ADMA", /* #8a */
                                    vtime,
                                    setbcod,
                                    AtualizacaoDadosCliente.numero_pdv,
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
                         0 /*vtimeini*/,
                         setbcod,
                         AtualizacaoDadosCliente.numero_pdv,
                         neuclien.sit_credito,
                         vchar).

                if vsit_credito = "E"
                then do:
                    vstatus = "N".
                    vmensagem_erro = "Erro ao calcular Limite Admcom". 
                end.
                vsit_credito = "A".
            end.
                                 
        end.
end.

if vforcasitPJ and vprocessa_credito /*#11*/
then vsit_credito = "V".
if vprocessa_credito = no /* #6 */
then vsit_credito = "A".

if vstatus = "I" then vstatus = "S".

create ttreturn.
ttreturn.pstatus       = vstatus.
ttreturn.mensagem_erro = vmensagem_erro.
ttreturn.codigo_filial = string(atualizacaodadoscliente.codigo_filial).
ttreturn.numero_pdv    = string(atualizacaodadoscliente.numero_pdv).
ttreturn.tipo_cadastro = atualizacaodadoscliente.tipo_cadastro.

ttreturn.credito           = trim(string(vvlrLimite,">>>>>>>9.99")).
ttreturn.sit_credito       = texto(string(vsit_credito)).
ttreturn.vcto_credito      = EnviaData(vvctoLimite).
ttreturn.mensagem_credito  = removeacento(vneuro-mens).
ttreturn.neuro_id_operacao = vneu_cdoperacao.

hsaida = temp-table ttreturn:HANDLE.


run log("RETORNA PARA P2K ID=" + vneu_cdoperacao + " Situacao=" + vsit_credito).

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
put unformatted string(vlcsaida).

/*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
os-command silent cat saida.json.
*/


run log("FIM").


procedure banco.
    def input parameter par-banco      as char.
    def input parameter par-tipo_conta as char.
    def input parameter par-ano_conta  as char.
    
    if testavalido(par-banco)
    then do.
        if par-banco = "BANRISUL"
        then vint = 1.
        else if par-banco = "CAIXA ECONOMICA FEDERAL"
        then vint = 2.
        else if par-banco = "BANCO DO BRASIL"
        then vint = 3.
        else vint = 4.

        cpclien.var-ext2[vint] = par-banco.

        if testavalido(par-tipo_conta)
        then cpclien.var-ext3[vint] = par-tipo_conta.

        if testavalido(par-ano_conta)
        then cpclien.var-ext4[vint] = par-ano_conta.
    end.
end procedure.


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = vpasta_log + "Neurotech_" + string(today, "99999999") + "_" +
           string(setbcod) + "_" + string(scxacod) + ".log".

    output to value(varquivo) append.
    put unformatted string(time,"HH:MM:SS")
        " AtualizacaoDadosCliente_3 " par-texto skip.
    output close.

end procedure.

