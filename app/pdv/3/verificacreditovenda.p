/* helio 11092023 - PROJETO ANTIFRAUDE - FLUXO SERVICOS MOTOR CREDITO - desativar teste subida ao motor */

/* helio 15082023 - PROJETO ANTIFRAUDE - INTEGRAÇÃO ID BIOMETRIA FACIAL - FLUXO SERVICOS MOTOR CREDITO */
/* helio 22052023 Melhoria ID 502416 - Variï¿½vel ultimas novaï¿½ï¿½es */
/* helio #23112022 ID 154675 - Enviar PROP DTULTPAGTO */
/* #08112022 helio - teste de vendas simultaneas em 1 minutohttps://trello.com/c/WpXlWtfe/53-vendas-simult%C3%A2neas-impedir-que-opera%C3%A7%C3%B5es-simult%C3%A2neas-em-pdvs-diferentes-sejam-enviadas-ao-motor */

/*#01082022 helio - IntegraÃ§Ã£o P2K/Neurotech - Acrescentar o campo IE*/
/* medico na tela 042022 - helio */
/* helio 11042022 - ajuste painel motor */

/* HUBSEG 19/10/2021 */               
def var vidstatuscad as int.
def var vBloqueioVenda as log.

def var vlistapep as char.
def var vlistares as char.
def var vpropLISTA_EGUARDIAN as char.

/* API REST */
def input  parameter vlcentrada as longchar.
def var var-QTDENOV as char.
{/admcom/progr/api/acentos.i} /* helio 21/09/2021 */
def buffer bneuproposta for neuproposta.
def var vsimultanea as char.
def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.

def var var-COMPROMETIMENTO_MENSAL as dec. 

/* API REST */
def  temp-table VerificaCreditoVenda serialize-name "dadosEntrada"
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field tipo_venda       as char 
    field codigo_cliente  as char
    field produtos_valores as char
    field qtde_parcelas    as char
    field vlr_acrescimo as char
    field vlr_entrada as char
    field vlr_prestacao as char
    field dt_primvcto as char
    field dt_ultivcto as char
    field vdaterceiros as char
    field neuro_id_operacao as char
    field ID_BIOMETRIA as char
    field atendimento_presencial as char. /* heloi 29082024 - proj inteligencia biometria */

hentrada = temp-table VerificaCreditoVenda:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").
def temp-table ttreturn no-undo serialize-name "return"
FIELD pstatus as char serialize-name "status"
FIELD mensagem_erro as char 
FIELD codigo_filial as char 
FIELD numero_pdv as char 
FIELD tipo_cadastro as char 
field credito as char
field valor_limite as char
field sit_credito as char
field vcto_credito as char
field mensagem_credito as char
field neuro_id_operacao as char.
    
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



def var initime as int.
initime = time.

/* 28.03.2018 #_06 Cadastro Express Fase 1 */
/* 11.05.2018 #2 - Higienizacao CPF */
/* 17.05.2018 #3 - Melhorias Motor Pct 01 */
/* 01.06.2018 #4 helio - Solicitado novos campos para que o motor calcule o corte do limite quando tem novacao ou atraso */
/* 01.06.2018 #5 helio  Quando tem P2 Pendente , Reprova Venda */
/* 21.06.2018 #7 Helio - Revisao do Fluxo  */
/* 03.07.2018 #8 Helio - Revisao do Fluxo V2 */
/* 21.08.2018 #9 Controle por caixa wcneurotech_v1802 e nova tag id */
/* 15.10.2018 #10 Novas tags
   14.12.2018 #11 TP 28232811
   02.01.2019 #12 Helio Neto Inclusao das PROPS abaixo na P5,P6,P7,P8
                       PROP_CHDEVOLV
                       PROP_DTULTCPA
                       PROP_MAIORATRASO
                       PROP_MAIORCONT
*/
/* 23.04.2019 #11 Helio - PJ retornar situacao "V" e nao subir ao motor */

/* #11 */ def var vforcasitPJ as log init no.


{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */




def buffer grupo for clase. 
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.

def var var-saldototnov as dec.
def var vtimeini as int.
def var par-recid-neuclien as recid.
def var vtipoconsulta          as char init "VC07".
def var vdtnasc as date.
/* #3 */
def var vneu_cdoperacao as char.
def var xneu_cdoperacao as char.
def var vneu_politica as char.

def var vsit_credito as char.
def var vvctolimite         as date. 
def var vvlrLimite          as dec.
def var vrenda as dec.
def var vtime               as int.
def var vneurotech          as log init no.
def var vhubseg             as log init no.  

def var vlojaneuro          as log init no. 
def var vvlrvenda           as dec.
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

def var vneuro-sit as char.
def var vneuro-mens as char.

def var vehcpf as log.
def new global shared var setbcod       as int.
def var vcxacod as int.
def var vprops as char.
def var vPOLITICA as char.
def var var-atrasoparcperc as char.
def var var-PARCPAG as int.
def var vprodutos_valores as char.
def var vchar   as char.
def var vsubcla as char.
def var vclanom as char.
def var var-dtultcpa as char. /* #11 */
def var var-dtultNOV as char. /* #11 */

def var var-chdevolv as char. /* #12 */
def var var-maioratraso as int. /* #12 */
def var var-maiorcont as dec. /* #12 */
def var var-DTULTPAGTO as date.

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
    field categoria_profissional as char.

def var vetbcod as int.
def var vcpf    as char.
def var par-ok  as log.
def var vclicod as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vgeralog as log.


def var vpasta_log as char init "/ws/log/".
find tab_ini where tab_ini.etbcod = 0
               and tab_ini.cxacod = 0
               and tab_ini.parametro = "WS P2K - Pasta LOG"
             no-lock no-error.
if avail tab_ini
then vpasta_log = tab_ini.valor.

find first VerificaCreditoVenda no-lock no-error.
if avail VerificaCreditoVenda
then do.
    vstatus = "S".
    vetbcod = int(VerificaCreditoVenda.codigo_filial).
    vcxacod = int(VerificaCreditoVenda.numero_pdv).
    vclicod = int(VerificaCreditoVenda.codigo_cliente).
    vehcpf = yes.
    
    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien
    then run erro("Cliente nao localizado").
    else do.
        /* helio 04012024 - Venda de CNPJ indo ao motor - ID 59106 */
        if clien.tippes = no then vforcasitPJ = yes.
        
        vcpf = trim(clien.ciccgc).
        run cpf.p (vcpf, output par-ok).
        if not par-ok
        then do:
            vehcpf = no.
            
            /* #8 */
            /*#11
            * run erro ("Operacao de Credito Apenas para Pessoa Fisica"). 
            * vstatus = "R".      
            #11 */
            
            /*#11*/
            run cgc.p (vcpf, output par-ok). 
            if par-ok
            then vforcasitPJ = yes.      
            /*#11*/
        end.    
    end.
end.
else run erro("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do:
    setbcod = int(VerificaCreditoVenda.codigo_filial).
    vtime   = mtime.
    if VerificaCreditoVenda.neuro_id_operacao = ""
    then run log("NOVALINHA").
    else run log("MESMAOP").

    run log("NOVA SOLICITACAO P2K ID=" + VerificaCreditoVenda.neuro_id_operacao + " Tipo_Venda=" + VerificaCreditoVenda.tipo_venda).
    
    find neuclien where neuclien.clicod = int(VerificaCreditoVenda.codigo_cliente) no-lock no-error.
    if not avail neuclien
    then do:
        /* #3 */
        run log("gravaneuclilog Cadastrando NeuClien").
        run neuro/gravaneuclilog_v1802.p 
            (clien.ciccgc, 
             vtipoconsulta, 
             vtimeini, 
             setbcod, 
             vcxacod, 
             "",
             "Cadastrando NeuClien"). 

         create PreAutorizacao.
         preAutorizacao.codigo_filial   = verificacreditovenda.codigo_filial.
         preAutorizacao.codigo_cliente  = string(clien.clicod).
         preautorizacao.cpf             = clien.ciccgc.
         preautorizacao.tipo_pessoa     = if clien.tippes
                                          then "J"
                                          else "F".
         preAutorizacao.nome_pessoa     = removeacento(clien.clinom).
         preautorizacao.data_nascimento = string(year(clien.dtnasc),"9999") +
                                          ":" +
                                          string(month(clien.dtnasc),"99")  +
                                          ":" +
                                          string(day(clien.dtnasc),"99").

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
            run log("gravaneuclihist").
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
        end.
    end.
end.

if vstatus = "S"
   /*#11*/ and not vforcasitPJ 
then do.
    vlojaneuro = no.
    vsit_credito = "R".
    vvlrlimite  = neuclien.vlrlimite.
    vvctolimite = neuclien.vctolimite.
    vvlrvenda = (int(VerificaCreditoVenda.qtde_parcelas) *
                 int(VerificaCreditoVenda.vlr_prestacao)). /*#9 */
    /* #3 */
    vneu_cdoperacao = "".       
    vneu_politica = "".

    /* #9 ini */
    if VerificaCreditoVenda.neuro_id_operacao <> "" and
       VerificaCreditoVenda.neuro_id_operacao <> "?"
    then do.
        
/** helio 04022022 NOVO FLUXO INTEGRACAO MOTOR */

        vneu_cdoperacao = VerificaCreditoVenda.neuro_id_operacao. 
        if vneu_cdoperacao = ? then vneu_cdoperacao = "".
        
        release neuproposta.
        if vneu_cdoperacao <> ""
        then find neuproposta where neuproposta.neu_cdoperacao = vneu_cdoperacao  and
                            neuproposta.cpf = neuclien.cpf  
                    no-lock no-error.
        if avail neuproposta
        then do:
            vneu_politica   = neuproposta.tipoconsulta .
            vsit_credito    = neuproposta.neu_resultado.

                find current neuclien no-lock.         

                run log("PROPOSTA JA EXISTENTE ID=" + vneu_cdoperacao + " NOVO FLUXO").
                vvlrLimite   = neuclien.vlrlimite.
                vvctoLimite  = neuclien.vctolimite.
                vsit_credito = neuproposta.neu_resultado.

                    run log("comportamento").
                    run neuro/comportamento.p (neuclien.clicod, ?,  
                                               output var-propriedades). 
                    var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
                    if var-salaberto-principal = ? then var-salaberto-principal = 0.
            
                    var-sallimite  = vvlrlimite - var-salaberto-principal.

                  
                create ttreturn.
                ttreturn.pstatus       = vstatus.
                ttreturn.mensagem_erro = vmensagem_erro.
                ttreturn.codigo_filial = string(verificacreditovenda.codigo_filial).
                ttreturn.numero_pdv    = string(verificacreditovenda.numero_pdv).
                
                ttreturn.credito           = trim(string(vvlrLimite,">>>>>>>9.99")).
                ttreturn.valor_limite      = trim(string(var-sallimite,"->>>>>>>>>>9.99")).
                
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
                verificacreditovenda.neuro_id_operacao = "".
                vneu_cdoperacao = "".
        end.
        /** NOVO FLUXO */

    end.
    /* #9 fim */

   
    /* #08112022 - teste vendas simultaneas 1 minuto */

    vsimultanea = "".
    run log("TESTE SIMULTANEA ID=" + vsimultanea + " "). 

    for each bneuproposta where bneuproposta.cpf = neuclien.cpf and
                                bneuproposta.dtinclu = today and
                                bneuproposta.hrinclu >= time - 120
                                no-lock.
        if bneuproposta.etbcod = int(verificacreditovenda.codigo_filial) and
           bneuproposta.cxacod <> int(verificacreditovenda.numero_pdv)
        then do:
            vsimultanea = bneuproposta.neu_cdoperacao.
            if vsimultanea = ? 
            then vsimultanea = "".
            else leave.
        end.
    end.                                
            
    if vsimultanea <> ""
    then do: 
        run log("PROPOSTA SIMULTANEA ID=" + vsimultanea + " "). 
        vvlrLimite   = neuclien.vlrlimite. 
        vvctoLimite  = neuclien.vctolimite. 
        vsit_credito = "R".

        run log("comportamento"). 
        run neuro/comportamento.p (neuclien.clicod, ?,    output var-propriedades).   
        var-salaberto-principal = dec(pega_prop("LIMITETOMPR")). 
        if var-salaberto-principal = ? then var-salaberto-principal = 0.  
        var-sallimite  = vvlrlimite - var-salaberto-principal.    
        
                create ttreturn.
                ttreturn.pstatus       = vstatus.
                ttreturn.mensagem_erro = vmensagem_erro.
                ttreturn.codigo_filial = string(verificacreditovenda.codigo_filial).
                ttreturn.numero_pdv    = string(verificacreditovenda.numero_pdv).
                
                ttreturn.credito           = trim(string(vvlrLimite,">>>>>>>9.99")).
                ttreturn.valor_limite      = trim(string(var-sallimite,"->>>>>>>>>>9.99")).
                
                ttreturn.sit_credito       = "R".
                ttreturn.vcto_credito      = EnviaData(vvctoLimite).
                ttreturn.mensagem_credito  = "Existe proposta para este cliente em andamento".
                ttreturn.neuro_id_operacao = vneu_cdoperacao.
                
                hsaida = temp-table ttreturn:HANDLE.

                run log("RETORNA PARA P2K ID=" + vneu_cdoperacao + " Situacao=" + vsit_credito).

                lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
                put unformatted string(vlcsaida).


                run log("FIM TESTE SIMULTANEA").
                return.
        
    end. 
                
    run log("SITUACAO CADASTRAL").

    vidstatuscad = 0.
    vBloqueioVenda = no.
       
   /* helio 26062023 */
   if avail clien
   then do:
        find clienstatus of clien no-lock no-error.
        vidstatuscad = clienstatus.idstatuscad.
        vBloqueioVenda = clienstatus.BloqueioVenda.
    end.
    if vBloqueioVenda = yes
    then do:
            vsit_credito = "R".
            vmensagem_erro = "".
        vvlrLimite   = neuclien.vlrlimite. 
        vvctoLimite  = neuclien.vctolimite. 
        vsit_credito = "R".

        run log("comportamento"). 
        run neuro/comportamento.p (neuclien.clicod, ?,    output var-propriedades).   
        var-salaberto-principal = dec(pega_prop("LIMITETOMPR")). 
        if var-salaberto-principal = ? then var-salaberto-principal = 0.  
        var-sallimite  = vvlrlimite - var-salaberto-principal.    
        

              create ttreturn.
                ttreturn.pstatus       = vstatus.
                ttreturn.mensagem_erro = vmensagem_erro.
                ttreturn.codigo_filial = string(verificacreditovenda.codigo_filial).
                ttreturn.numero_pdv    = string(verificacreditovenda.numero_pdv).
                
                ttreturn.credito           = trim(string(vvlrLimite,">>>>>>>9.99")).
                ttreturn.valor_limite      = trim(string(var-sallimite,"->>>>>>>>>>9.99")).
                
                ttreturn.sit_credito       = vsit_credito.
                ttreturn.vcto_credito      = EnviaData(vvctoLimite).
                ttreturn.mensagem_credito  = "Bloqueio por Situacao Cadastral".
                ttreturn.neuro_id_operacao = "".
                
                hsaida = temp-table ttreturn:HANDLE.

                run log("RETORNA PARA P2K ID=" + vneu_cdoperacao + " Situacao=" + vsit_credito).

                lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
                put unformatted string(vlcsaida).


                run log("FIM SITUACAO CADASTRAL").
                return.
        
    end.     
    run log("CONTINUACAO").

    /* #08112022 */            
        
        
    /* HUBSEG */
        do vct = 1 to num-entries(VerificaCreditoVenda.produtos_valores, ";").
            vchar = entry(vct, VerificaCreditoVenda.produtos_valores,  ";").
            if num-entries(vchar, "|") = 2
            then do.
                vsubcla = trim(entry(1, vchar, "|")).
                
                find clase where clase.clacod = int(vsubcla) no-lock no-error.
                if avail clase
                then vclanom = trim(clase.clanom).
                else vclanom = "".

               /* HUBSEG */
               if avail clase
               then do:
                   find grupo where grupo.clacod = clase.clasup no-lock no-error.
                   if avail grupo
                   then do:
                       if grupo.clasup = 802020000 /* hubseg */
                          or grupo.clasup = 801040000    /* medico na tela 042022 - helio */
                       then do:
                           vhubseg = yes. /* 616 */
                       end.    
                   end.
               end.
               
                            
                vprodutos_valores = vprodutos_valores +
                        vsubcla + " | " + vclanom + " |" +   
                        entry(2, vchar, "|") + ";".
            end.
        end.
    
        
    if vneu_cdoperacao = "" 
    then do:
        vPOLITICA = "P4". /* Pega Limite */
        if vehcpf
        then do:
            run log("submeteneuro Politica=" + vpolitica).
            run neuro/submeteneuro_v1802.p (input setbcod,
                                          input vpolitica,
                                          input clien.clicod,
                                          0,
                                          output vlojaneuro,
                                          output vneurotech).
        end.
        else assign
                vlojaneuro = no
                vneurotech = no.
    end.             
    else assign
            vlojaneuro = yes
            vneurotech = yes.


    /* helio 190324 - aqssinatura digital */
    run log("ID_BIOMETRIA " + texto(verificacreditovenda.ID_BIOMETRIA) +
    " atendimento_presencial " + texto(verificacreditovenda.atendimento_presencial)).
    if verificacreditovenda.ID_BIOMETRIA <> ? and verificacreditovenda.ID_BIOMETRIA <> ""
    then do:
        run log("GUARDA Biometria = " + string(clien.clicod) + " " + verificacreditovenda.ID_BIOMETRIA).
        run crd/biometriaguarda.p (clien.clicod, verificacreditovenda.ID_BIOMETRIA)..
    end.

    /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */
    vchar = if vneu_cdoperacao = ""
            then "Politica " + vpolitica +
                 " LJNeuro=" + string(vlojaneuro,"S/N") +
                 " Submete=" + string(vneurotech,"S/N")
            else "Politica" + vneu_politica +
                 " Operacao=" + string(vneu_cdoperacao) +
                 " SIT=" + vsit_credito.
    run log("gravaneuclilog PRIMEIRA AVALIACAO SUBMETE " + vchar).
    run neuro/gravaneuclilog_v1802.p 
                (neuclien.cpfcnpj, 
                 vtipoconsulta, 
                 0, 
                 setbcod, 
                 vcxacod, 
                 neuclien.sit_credito,
                 vchar).
 
    /* Atualizar Limite */
    if /* #3 - Quando Tiver P2 Pendente e nao for P2 Nao Sobe Neuro*/
       (vneu_cdoperacao <> "" and 
        vneu_politica   = "P2" and
        vPOLITICA       <> "P2") 
            or 
       (vneu_cdoperacao <> "" or
        (avail neuclien and
         (neuclien.vctolimite <> ? and neuclien.vctolimite >= today) ))
    then do:
        run log("Nao Sobe Neuro neu_cdoperacao=" + vneu_cdoperacao +
                " neu_politica=" + vneu_politica +
                " POLITICA=" + vPOLITICA +
                " vctolimite=" + (if neuclien.vctolimite <> ?
                                  then string(neuclien.vctolimite)
                                  else "")).
        if vneu_cdoperacao = ""
        then do:
            vchar = "USANDO NEUCLIEN VCTO=" +
                    (if neuclien.vctolimite <> ?
                     then string(neuclien.vctolimite) else "") +
                    " VLR=" + string(neuclien.vlrlimite).
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         0, 
                         setbcod, 
                         vcxacod, 
                         vsit_credito, 
                         vchar).
            vvlrLimite  = neuclien.vlrlimite.
            vvctoLimite = neuclien.vctolimite.
        end.
    end.
    else do:
            /**
            *if   vlojaneuro and
            * (vneu_cdoperacao = "" and
            *    ( neuclien.vctolimite = ? or    /* Se nao tem limite valido */
            *      neuclien.vctolimite < today   /* ou nao esta valido */
            *    )
            * )     
            * or
            * vlojaneuro = no /* 16.11.17*/
            *then do:
            */
        if vneurotech /* desativado *and vhubseg = no **/
        then do:
            /* cai aqui QUANDO LOJANEURO e REGRAS SUBMISSAO = SUBMETE */
            find current neuclien no-lock.
            run log("comportamento").
            run neuro/comportamento.p (neuclien.clicod, ?,  
                                       output var-propriedades). 

            var-atrasoatual = int(pega_prop("ATRASOATUAL")). /* #4 */
            var-saldototnov = dec(pega_prop("SALDOTOTNOV")). /* #4 */
            var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
            if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
        
            var-parcpag = int(pega_prop("PARCPAG")). 
            if var-parcpag = ? then var-parcpag = 0.
            var-COMPROMETIMENTO_MENSAL = dec(pega_prop("COMPROMETIMENTO_MENSAL")) no-error. /* helio 11042022 - ajuste painel motor */
            if var-COMPROMETIMENTO_MENSAL = ? then var-COMPROMETIMENTO_MENSAL = 0.
 
            /* helio #23112022 ID 154675 */
            var-DTULTPAGTO = date(pega_prop("DTULTPAGTO")).
            /**/
                /* PROP_DTULTCPA */     var-dtultcpa = pega_prop("DTULTCPA"). /* #11 */
                if var-dtultcpa = ? then var-dtultcpa = "".         
            
                /* PROP_DTULTNOV */     var-dtultnov = pega_prop("DTULTNOV"). /* #11 */
                if var-dtultnov = ? then var-dtultnov = "".         
            var-QTDENOV = pega_prop("QTDENOV").
            if var-QTDENOV = ? then var-QTDENOV = "".         

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
                then vlstcartaocred = vlstcartaocred + ";".     
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
                vlstdadosveic = removeacento(carro.marca) +  ";" +
                                removeacento(carro.modelo) + ";" +
                if carro.ano <> ?
                then string(carro.ano,"9999")
                else "".
            end.
            vlstrefpessoais = "".
            do vx = 1 to 3.
                vlstrefpessoais = vlstrefpessoais +
                                  (if vlstrefpessoais = ""
                                   then ""
                                   else ";") +
                                  removeacento(clien.entbairro[vx]) + "|" + 
                                  removeacento(clien.entcep[vx])    + "|" + 
                                  removeacento(clien.entcidade[vx]) + "|" +
                                  removeacento(clien.entcompl[vx]). 
            end.

            vlstrefcomerc = "".
            do vx = 1 to 5:
                vlstrefcomerc = vlstrefcomerc + 
                                    (if vlstrefcomerc = "" then "" else ";") +  
                                    removeacento(clien.refcom[vx]) +
                                     "|".
                if avail cpclien
                then do:
                     if cpclien.var-ext1[vx] = "1"
                     then vlstrefcomerc = vlstrefcomerc + "Apresentado".
                     else if cpclien.var-ext1[vx] = "2" then
                     vlstrefcomerc = vlstrefcomerc + "Nao Apresentado".
                     else if cpclien.var-ext1[vx] = "3"
                     then vlstrefcomerc = vlstrefcomerc + 
                                                        "Nao possui cartao".
                     else vlstrefcomerc = vlstrefcomerc + " ".  
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
                    then do:*/
                vlstdadosbanco = vlstdadosbanco +
                                 (if vlstdadosbanco = "" then "" else ";") +
                                 (if avail cpclien
                                  then removeacento(cpclien.var-ext2[vx])
                                  else "") + "|" +
                                 (if avail cpclien
                                  then removeacento(cpclien.var-ext3[vx])
                                  else "") + "|" +
                                 (if avail cpclien
                                  then removeacento(cpclien.var-ext4[vx]) else "").
            end.   
            cestcivil = if clien.estciv = 1 then "Solteiro" else
                        if clien.estciv = 2 then "Casado"   else
                        if clien.estciv = 3 then "Viuvo"    else
                        if clien.estciv = 4 then "Desquitado" else
                        if clien.estciv = 5 then "Divorciado" else
                        if clien.estciv = 6 then "Falecido" else "".

            vdtnasc = clien.dtnasc.
            vprops = 
                     /* helio 032021 politica de credito unificada */
                     /*"POLITICA="        + "CREDITO" + string(setbcod,"9999")*/
                     "POLITICA="        + "CREDITO_UNIFICADA"
                     + "&PROP_LOJAVENDA="       + string(setbcod,"9999") 
                     /*helio 032021 politica de credito unificada */

                   + "&PROP_CONTACLI="   + trim(string(clien.clicod))   
                   + "&PROP_CPFCLI="     + trim(removeacento(clien.ciccgc))   
                   + "&PROP_INSCEST="        + if clien.tippes = no then texto(clien.ciins)  else texto(clien.empresa_inscricaoEstadual) /*#01082022*/
                   + "&PROP_DTNASCCLI="  + 
                               removeacento(string(clien.dtnasc, "99/99/9999")) 
                   + "&PROP_LOJACAD="    + 
                                        trim(removeacento(string(neuclien.etbcod))) 
                   + "&PROP_LIMITEATUAL="    + 
                                    trim(removeacento(string(neuclien.vlrlimite))) 
                   + "&PROP_VALIDADELIM=" + (if neuclien.vctolimite = ?
                                             then ""
                                             else
                                    string(neuclien.vctolimite,"99/99/9999") )
                   + "&PROP_PROFISSAO=" + removeacento(clien.proprof[1])
                   + "&PROP_RENDAMES="  + string(vrenda)
                   + "&PROP_LOGRADCLI=" + removeacento(clien.endereco[1])
                   + "&PROP_NUMERO="    + removeacento(string(clien.numero[1]))
                   + "&PROP_CEP="       + removeacento(clien.cep[1])  
                   + "&PROP_BAIRROCLI=" + removeacento(clien.bairro[1])
                   + "&PROP_COMPLEMENTO=" + removeacento(clien.compl[1])  
                   + "&PROP_CIDADE="    + removeacento(clien.cidade[1])
                   + "&PROP_UF="        + removeacento(clien.ufecod[1])
                   + "&PROP_NOTA="      + (if not avail cpclien then ""
                                           else removeacento( 
                                                     string(cpclien.var-int3)))
                   + "&PROP_DTADMISSAO="     + 
                        removeacento(string(clien.prodta[1],"99/99/9999"))
                   + "&PROP_CPFCONJUGE="   + removeacento(substr(clien.conjuge,51,20))
                   + "&PROP_RENDACONJUGE="   + string(vrenda_conjuge)  
                   + "&PROP_PROFCONJUGE="    + removeacento(clien.proprof[2])    
                   + "&PROP_TELEFONE="       + removeacento(clien.fone) 
                   + "&PROP_INSTRUCAOCLI="   + removeacento(vinstrucao)   
                   + "&PROP_SEGURO="         + removeacento(vseguro)
                   + "&PROP_PLANOSAUDE="     + removeacento(vplanosaude)
                   + "&PROP_LSTCARTAOCRED="  + vlstcartaocred  
                   + "&PROP_VEICULO="        + vveiculo
                   + "&PROP_LSTDADOSVEIC="   + vlstdadosveic  
                   + "&PROP_LSTREFPESSOAIS=" + vlstrefpessoais 
                   + "&PROP_LSTREFCOMERC="   + vlstrefcomerc  
                   + "&PROP_LSTDADOSBANCO="  + vlstdadosbanco  
                   + "&PROP_ESTADOCIVIL="    + removeacento(cestcivil)   
                   + "&PROP_DEPENDENTES="    + removeacento(string(clien.numdep))
                   + "&PROP_TIPORESID="      + string(clien.tipres,
                                                            "Propria/Alugada")
                   + "&PROP_TEMPORESID="     + removeacento(substr(
                                   string(int(temres),"999999"),1,2) + "/"  + 
                                   substr(string(int(temres),"999999"),3,4) )
                   + "&PROP_DEPENDENTES="    + removeacento(string(clien.numdep))
                   + "&PROP_NOMECLI="        + removeacento(clien.clinom)   
                   + "&PROP_PARCPAG=" + string(var-parcpag)
                   + "&PROP_ATRASOPARCPERC=" + removeacento(var-atrasoparcperc)
                   + "&PROP_ATRASOATUAL="    + string(var-atrasoatual) /* #4 */
                   + "&PROP_SALDOTOTNOV="    + string(var-saldototnov) /* #4 */

                    + "&PROP_DTULTCPA="     + var-dtultcpa /* #11 */
                    + "&PROP_DTULTNOV="     + var-dtultnov /* #11 */
                + "&PROP_QTDENOV=" + (if var-QTDENOV = ? then ""  else string(var-QTDENOV))
                   
                   + "&PROP_COMPROMETIMENTO_MENSAL="  + trim(string(var-COMPROMETIMENTO_MENSAL,"->>>>>>>>>>>>>>>>>>>>>>>>9.99"))  /* helio 11042022 - ajuste painel m~~otor */
                   /* helio #23112022 ID 154675 */
                    + "&PROP_DTULTPAGTO=" + (if var-DTULTPAGTO = ? then "" 
                                 else string(var-DTULTPAGTO,"99/99/9999"))
                    /**/ 
                       + "&PROP_PATRIMONIO=" + texto(clien.patrimonio)    
                       + "&PROP_PESSOAEXPOSTA=" + string(clien.pessoaexposta,"true/false")
                       + "&PROP_NOMESOCIAL=" + texto(clien.nomeSocial)    
                       + "&PROP_ATUALIZACAOCADASTRAL=" + (if clien.ultimaAtualizacaoCadastral = ? then "" 
                                 else string(clien.ultimaAtualizacaoCadastral,"99/99/9999"))     
                       + "&PROP_GENERO=" + texto(clien.genero)   

                       + "&PROP_ID_BIOMETRIA=" + trim(texto(VerificaCreditoVenda.ID_BIOMETRIA))  
                       + "&PROP_ATENDIMENTO_PRESENCIAL=" + trim(texto(VerificaCreditoVenda.atendimento_presencial))                          

                   + "&PROP_FLXPOLITICA="    + vPOLITICA.
            vtimeini = mtime. /* #9 */
            if vprops <> ?
            then do:
                xneu_cdoperacao = "".
                run neuro/wcneurotech_v2101.p /* helio 21062021 - chamado por REST */
                                               (setbcod,
                                                vcxacod,
                                                input vprops,
                                                input vPOLITICA,
                                                input vtimeini,
                                                input par-recid-neuclien, 
                                                input-output xneu_cdoperacao,
                                                        /*#9 P4 Nao tem LOOP */
                                                input 0, /*#9 */
                                                output vvlrLimite, 
                                                output vvctolimite,
                                                output vneuro-sit, 
                                                output vneuro-mens,
                                                output vstatus,
                                                output vmensagem_erro).
            end.
            else do.
                run log("*** ERRRO *** vprops nula").
                vstatus = "N".
            end.

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
            else assign
                    vneurotech = no /* Usa Processo ADMCOM */
                    vstatus = "S"
                    vmensagem_erro = "".
            /* #1 */
            vchar = if not vneurotech
                    then "ERRO MOTOR - USARA ADMCOM"
                    else "SIT=" + vsit_credito +
                         " VCTO=" + (if vvctolimite = ?
                                     then "-" else string(vvctolimite)) + 
                         " LIM="  + (if vvlrlimite = ?
                                     then "-" else string(vvlrlimite)).
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         0, 
                         setbcod, 
                         vcxacod, 
                         neuclien.sit_credito,
                         vchar).
            vtimeini = 0.
        end.

        if vneurotech = no /* DESATIVADO *and vhubseg = no*/
        then do: /** ADMCOM **/
            run log("callimiteadmcom").
            vtime = mtime. /* #9 */
            vtimeini = mtime. /* #9 */
            run neuro/callimiteadmcom.p (recid(neuclien),
                                    "ADMC", /* #8 */
                                    vtime,
                                    setbcod,
                                    vcxacod,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
            vsit_credito = "V". 

            /* #2 */
            vchar = "ADMCOM SIT=" + vsit_credito +
                    " VCTO=" + (if vvctolimite = ?
                                then "-" else string(vvctolimite)) + 
                    " LIM="  + (if vvlrlimite = ?
                                then "-" else string(vvlrlimite)).
            run log("gravaneuclilog " + vchar).
            run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         vtimeini, 
                         setbcod, 
                         vcxacod, 
                         vsit_credito,
                         vchar).
            if vsit_credito = "E"
            then assign
                    vstatus = "E"
                    vmensagem_erro = "Erro ao calcular Limite Admcom". 
        end.
    end.

    find current neuclien no-lock.         

    if var-propriedades = "" /* #9 */
    then do.
        run log("comportamento").
        run neuro/comportamento.p (neuclien.clicod, ?,  
                                   output var-propriedades). 
    end.
    var-atrasoatual = int(pega_prop("ATRASOATUAL")).
    var-salaberto = dec(pega_prop("LIMITETOM")).
    if var-salaberto = ? then var-salaberto = 0.
    var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
    if var-salaberto-principal = ? then var-salaberto-principal = 0.

    var-salaberto-hubseg = dec(pega_prop("LIMITETOMHUBSEG")).
    if var-salaberto-hubseg = ? then var-salaberto-hubseg = 0.
    var-salaberto-principal = var-salaberto-principal - var-salaberto-hubseg.
    
    var-sallimite  = vvlrlimite - var-salaberto-principal.
    if var-sallimite = ? then var-sallimite = 0.
    var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
    if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
    var-parcpag = int(pega_prop("PARCPAG")). 
    if var-parcpag = ? then var-parcpag = 0.
        
    /*#12*/
    /* PROP_CHDEVOLV */     var-chdevolv = pega_prop("CHDEVOLV").
    if var-chdevolv = ? then var-chdevolv = "".
    /* PROP_DTULTCPA */     var-dtultcpa = pega_prop("DTULTCPA"). /* #11 */
    if var-dtultcpa = ? then var-dtultcpa = "".         

    /* PROP_DTULTNOV */     var-dtultnov = pega_prop("DTULTNOV"). /* #11 */
    if var-dtultnov = ? then var-dtultnov = "".         
    
    /* PROP_MAIORATRASO */  var-maioratraso = int(pega_prop("MAIORATRASO")).
    if var-maioratraso = ? then var-maioratraso = 0. 
    /* PROP_MAIORCONT */    var-maiorcont = dec(pega_prop("MAIORCONT")).
    if var-maiorcont = ? then var-maiorcont = 0.
    /*#12*/
    var-COMPROMETIMENTO_MENSAL = dec(pega_prop("COMPROMETIMENTO_MENSAL")) no-error. /* helio 11042022 - ajuste painel motor */
    if var-COMPROMETIMENTO_MENSAL = ? then var-COMPROMETIMENTO_MENSAL = 0.

    /* helio #23112022 ID 154675 */
    var-DTULTPAGTO = date(pega_prop("DTULTPAGTO")).
    /**/ 
    /* helio 22052023 ID 502416 */
    var-QTDENOV = pega_prop("QTDENOV").
    /**/ 
     
    
    var-saldototnov = dec(pega_prop("SALDOTOTNOV")). /* helio 16122022 - ID 154806 - Verificar envio de variï¿½vel de novaï¿½ï¿½o para o motor */

    vpolitica = substring(VerificaCreditoVenda.tipo_venda,5,2). /*Pega do p2k*/
    if vpolitica = "P5" or
       vpolitica = "P6" or
       vpolitica = "P7" or
       vpolitica = "P8"
    then.
    else vPOLITICA = "P5".   

    
    /* #3 */
    if vneu_cdoperacao <> "" and
       vneu_politica   = "P2"
    then assign
            vlojaneuro   = yes
            vneurotech   = no
            vsit_credito = "R" /* #5 Quando tem P2 Pendente , Reprova Venda */
            vneuro-mens  = "Reprovado - Verifique Analise Mesa - P2".
    else do:
        run log("submeteneuro").
        run neuro/submeteneuro_v1802.p (input setbcod, 
                                        input vpolitica,
                                        input clien.clicod,
                                        input vvlrvenda,
                                        output vlojaneuro,
                                        output vneurotech).
        vchar = "Politica " + vpolitica +
                " LJNeuro=" + string(vlojaneuro,"S/N") +
                " Submete=" + string(vneurotech,"S/N") +
                " Vlr=" + string(vvlrvenda).
        run log("gravaneuclilog " + vchar).
        vtimeini = mtime. /* #9 */
        run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj,
                     vtipoconsulta,
                     vtimeini,
                     setbcod,
                     vcxacod,
                     neuclien.sit_credito, 
                     vchar).

        if vlojaneuro
        then do:
            if vneurotech = no and
               neuclien.vctolimite <> ? and   /* Se tem limite valido */
               neuclien.vctolimite >= today and
               var-sallimite - vvlrvenda >= 0 /* e tera saldo para esta venda */
            then vsit_credito = "A".
        end.
        
        if vlojaneuro = yes and
           vneurotech = no  and
           (vvctolimite = ? or
            vvctolimite < today)
        then vneurotech = yes.   
    end.    

    /*DESATIVADO *if vhubseg
    *then vsit_credito = "A".*/
    
    if vneurotech  /*DESATIVADO *and vhubseg = no */
    then do: 
                    
        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
                
        vrenda         = if clien.prorenda[1] = ?
                         then 0
                         else clien.prorenda[1].
            /* #9 */
        if vpolitica <> "P5" and
           vpolitica <> "P6" and
           vpolitica <> "P7"
        then vneu_cdoperacao = "".

        if vhubseg then vpolitica = "P5_SERV". /* 1074 helio 16102023 - Milene */

        /* HELIO 08012024 - LISTAS RESTRITIVAS */
        
        if clien.ciccgc <> "" and clien.ciccgc <> ?
        then do:
            run log("CHAMANDO E-GUARDIAN - LISTA PEP - CPF=" + clien.ciccgc).
            run api/consultar-lista-pep.p           (clien.ciccgc ,"", output vlistapep).
            if vlistapep = ? then vlistapep = "".
            run log("CHAMANDO E-GUARDIAN - LISTA PEP -  RETORNO=" + vlistapep).

            run log("CHAMANDO E-GUARDIAN - LISTAS RESTRITIVAS - CPF=" + clien.ciccgc).
            run api/consultar-lista-restritiva.p    (clien.ciccgc ,"", output vlistares).
            if vlistares = ? then vlistares = "".
            run log("CHAMANDO E-GUARDIAN - LISTAS RESTRITIVAS - RETORNO=" + vlistares).
            
        end.
        vpropLISTA_EGUARDIAN = "".
        if vlistapep <> "" 
        then do:
            vpropLISTA_EGUARDIAN = "LISTA_PEP|".
        end.
        if vlistares <> ""
        then do:
            vpropLISTA_EGUARDIAN = vpropLISTA_EGUARDIAN + vlistares.
        end.
            
        if vpropLISTA_EGUARDIAN = ? then vpropLISTA_EGUARDIAN = "".
        
        vprops =  
                /* helio 032021 politica de credito unificada */
                /*"POLITICA="        + "CREDITO" + string(setbcod,"9999")*/
                "POLITICA="        + "CREDITO_UNIFICADA"
                + "&PROP_LOJAVENDA="       + string(setbcod,"9999") 
                /*helio 032021 politica de credito unificada */
                
                + (if vneu_cdoperacao = ""
                   then ""
                   else "&PROP_IDOPERACAO=" + trim(vneu_cdoperacao))
                + "&PROP_CONTACLI="       + trim(string(clien.clicod))     
                + "&PROP_CPFCLI="         + trim(clien.ciccgc)    
                + "&PROP_NOMECLI="        + removeacento(clien.clinom)    
                   + "&PROP_INSCEST="        + if clien.tippes = no then texto(clien.ciins)  else texto(clien.empresa_inscricaoEstadual) /*#01082022*/
                + "&PROP_LOJAVENDA="      + removeacento(VerificaCreditoVenda.codigo_filial) 
                + "&PROP_DTVENDA="        + removeacento(VerificaCreditoVenda.codigo_filial) 
                + "&PROP_HORAVENDA="      + removeacento(VerificaCreditoVenda.codigo_filial) 
                + "&PROP_PRODUTO="        + removeacento(vprodutos_valores)
                + "&PROP_QTDEPARC="       + removeacento(VerificaCreditoVenda.qtde_parcelas) 
                + "&PROP_ACRESC="         + removeacento(VerificaCreditoVenda.vlr_acrescimo) 
                + "&PROP_VALORENTRADA="   + removeacento(VerificaCreditoVenda.vlr_entrada) 
                + "&PROP_VALORPARC="      + removeacento(VerificaCreditoVenda.vlr_prestacao) 
                + "&PROP_DTPRIMVECTO="    + removeacento(VerificaCreditoVenda.dt_primvcto) 
                + "&PROP_DTULTIMOVCTO="   + removeacento(VerificaCreditoVenda.dt_ultivcto) 
                + "&PROP_VDATERCEIROS="   + removeacento(VerificaCreditoVenda.vdaterceiros) 
                + "&PROP_LIMITEATUAL="    + trim(string(neuclien.vlrlimite))  
                + "&PROP_VALIDADELIM="    + (if neuclien.vctolimite = ? then "" 
                                 else string(neuclien.vctolimite,"99/99/9999"))
                + "&PROP_PROFISSAO="      + removeacento(clien.proprof[1]) 
                + "&PROP_RENDAMES="       + string(vrenda) 
                + "&PROP_LOGRADCLI="      + removeacento(clien.endereco[1]) 
                + "&PROP_NUMERO="         + removeacento(string(clien.numero[1])) 
                + "&PROP_CEP="            + removeacento(clien.cep[1])   
                + "&PROP_BAIRROCLI="      + removeacento(clien.bairro[1]) 
                + "&PROP_CIDADE="         + removeacento(clien.cidade[1]) 
                + "&PROP_UF="             + removeacento(clien.ufecod[1]) 
                + "&PROP_NOTA="           + (if not avail cpclien then ""
                                             else removeacento( string(cpclien.var-int3) )   )
                + "&PROP_DTNASCCLI="      + removeacento(string(clien.dtnasc,"99/99/9999")) 
                + "&PROP_LIMITETOM="      + string(var-salaberto)
                + "&PROP_LIMITEDISP="     + string(var-sallimite)
                + "&PROP_ATRASOATUAL="    + string(var-atrasoatual)
                + "&PROP_ATRASOPARCPERC=" + removeacento(var-atrasoparcperc)
                + "&PROP_PARCPAG=" + string(var-parcpag)
                + "&PROP_DTADMISSAO="     +      removeacento(string(clien.prodta[1],"99/99/9999"))
                + "&PROP_CNPJCOMERC="   + (if avail cpclien
                                       then removeacento(cpclien.var-char1)
                                       else "") /* #10 */
                + "&PROP_SALDOTOTNOV="  + string(var-saldototnov)  /* #10 */
                + "&PROP_DTULTCPA="     + var-dtultcpa /* #11 */
                + "&PROP_DTULTNOV="     + var-dtultnov /* #11 */
                + "&PROP_CHDEVOLV="     + var-chdevolv /* #12 */
                + "&PROP_MAIORATRASO="  + STRING(var-maioratraso) /* #12 */
                + "&PROP_MAIORCONT="    + STRING(var-maiorcont) /* #12 */
                + "&PROP_COMPROMETIMENTO_MENSAL="  + trim(string(var-COMPROMETIMENTO_MENSAL,"->>>>>>>>>>>>>>>>>>>>>>>>9.99"))  /* helio 11042022 - ajuste painel m~ot~or */
                /* helio #23112022 ID 154675 */
                + "&PROP_DTULTPAGTO=" + (if var-DTULTPAGTO = ? then "" 
                else string(var-DTULTPAGTO,"99/99/9999"))
                /**/ 
                /* helio 22052023 ID 502416 */
                + "&PROP_QTDENOV=" + (if var-QTDENOV = ? then ""  else string(var-QTDENOV))
                /**/
                        /* helio 27062023 */
                       + "&PROP_PATRIMONIO=" + texto(clien.patrimonio)    
                       + "&PROP_PESSOAEXPOSTA=" + string(clien.pessoaexposta,"true/false")
                       + "&PROP_NOMESOCIAL=" + texto(clien.nomeSocial)    
                       + "&PROP_ATUALIZACAOCADASTRAL=" + (if clien.ultimaAtualizacaoCadastral = ? then "" 
                                 else string(clien.ultimaAtualizacaoCadastral,"99/99/9999"))     
                       + "&PROP_GENERO=" + texto(clien.genero)   
                       + "&PROP_CELULAR="        + Texto(clien.fax)  

                     + "&PROP_DTCADASTRO=" + texto(string(clien.dtcad,"99/99/9999")) 
                     + "&PROP_VALIDADELIM=" + (if neuclien.vctolimite = ? then "" else string(neuclien.vctolimite,"99/99/9999"))                                       
                + "&PROP_ID_BIOMETRIA=" + trim(texto(VerificaCreditoVenda.ID_BIOMETRIA))     
                + "&PROP_ATENDIMENTO_PRESENCIAL=" + trim(texto(VerificaCreditoVenda.atendimento_presencial))                                               
                /* helio 08012024 */
                + "&PROP_LISTA_EGUARDIAN=" + trim(texto(vpropLISTA_EGUARDIAN))                                                  
                + "&PROP_FLXPOLITICA="  + vPOLITICA.

        vtimeini = mtime. /* #9 */
        xneu_cdoperacao = vneu_cdoperacao.
        run neuro/wcneurotech_v2101.p /* helio 21062021 - chamado por REST */
                                    (setbcod, 
                                     input vcxacod,
                                     input vprops, 
                                     input vPOLITICA, 
                                     input vtimeini, 
                                     input par-recid-neuclien,  
                                     input-output xneu_cdoperacao, /*#9 */
                                     input vvlrvenda,   /*#9 */
                                     output vvlrLimite,  
                                     output vvctolimite, 
                                     output vneuro-sit,  
                                     output vneuro-mens, 
                                     output vstatus, 
                                     output vmensagem_erro).
        if vneu_cdoperacao = "" /* Helio 29/10/2021 */
        then vneu_cdoperacao = xneu_cdoperacao.
                                            
        var-sallimite  = vvlrlimite - var-salaberto-principal.
                                     
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
                then "ERRO MOTOR SIT=" + vsit_credito
                else "SIT=" + vsit_credito +
                     " VCTO=" + (if vvctolimite = ?
                                 then "-" else string(vvctolimite)) +
                     " LIM="  + (if vvlrlimite = ?
                                 then "-" else string(vvlrlimite)).
        run log("gravaneuclilog " + vchar).
        run neuro/gravaneuclilog_v1802.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         vtimeini, 
                         setbcod, 
                         vcxacod, 
                         vsit_credito, 
                         vchar).
    end.

    if vlojaneuro = no /*DESATIVADO *and vhubseg = no */
    then vsit_credito = "V".
end.

if vforcasitPJ  /* #11 */
then vsit_credito = "V".

create ttreturn.
ttreturn.pstatus       = vstatus.
ttreturn.mensagem_erro = vmensagem_erro.
ttreturn.codigo_filial = string(verificacreditovenda.codigo_filial).
ttreturn.numero_pdv    = string(verificacreditovenda.numero_pdv).

ttreturn.credito           = trim(string(vvlrLimite,">>>>>>>9.99")).
ttreturn.valor_limite      = trim(string(var-sallimite,"->>>>>>>>>>9.99")).

ttreturn.sit_credito       = texto(string(vsit_credito)).
ttreturn.vcto_credito      = EnviaData(vvctoLimite).
ttreturn.mensagem_credito  = removeacento(vneuro-mens).
ttreturn.neuro_id_operacao = vneu_cdoperacao.


run log("RETORNA PARA P2K ID=" + vneu_cdoperacao).

hsaida = temp-table ttreturn:HANDLE.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
put unformatted string(vlcsaida).

/*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
os-command silent cat saida.json.
*/

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
    if par-texto = "NOVALINHA"
    then put unformatted skip(2).
    else if par-texto = "MESMAOP"
         then put unformatted skip "-" skip.
    else put unformatted 
            " VerificaCreditoVenda OP=" + VerificaCreditoVenda.neuro_id_operacao + " " + 
            string(initime,"HH:MM:SS") " CLI=" + VerificaCreditoVenda.codigo_cliente " " string(time,"HH:MM:SS") " "
         par-texto skip.
    output close.

end procedure.



