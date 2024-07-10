{/u/bsweb/progr/acha.i}

function Texto return character
    (input par-texto as char).

    def var vtexto as char.
    def var vletra as char.
    def var vct    as int.
    def var vi     as int.
    def var vtam   as int.

    if par-texto = ?
    then return "".

    par-texto = caps(trim(replace(par-texto, "~\","."))).
    vtam = length(par-texto).
    do vi = 1 to vtam.
        vletra = substring(par-texto, vi, 1).
        if      vletra = "<" then vtexto = vtexto + "&lt;".
        else if vletra = ">" then vtexto = vtexto + "&gt;".
        else if vletra = "&" then vtexto = vtexto + "&amp;".
        else if asc(vletra) = 34 then vtexto = vtexto + "&quot;". /* " */
        else if asc(vletra) = 39 then vtexto = vtexto + "&#39;".  /* ' */
        else
            if length(vletra) = 1 and
               asc(vletra) >  31 and
               asc(vletra) < 127
        then vtexto = vtexto + vletra.
    end.

    return vtexto.

end function.


def NEW shared temp-table tp-titulo like fin.titulo
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
def var cestcivil as char.
def var vcartao as char /***int***/.
def var vi as int.   
def var vcarro as char.
def var vobs as char.
def var vmen-spc as char.
def var vdat-spc as date.
def var vcon-spc as char.
def var vale-spc as char.
def var vcre-spc as char.
def var vche-spc as char.
def var vfil-spc as char.
def var vnac-spc as char.
def var vinstrucao as char.
def var vsituacao-instrucao as char.
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
def var vlibera-cli as log.
def NEW shared temp-table tp-contrato like fin.contrato.
/*** ***/

/*** CREDSCORE - 17/05/2016 ***/
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
/*** ***/

def shared temp-table ConsultaCliente
    field tipo_documento as char
    field numero_documento as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

find first ConsultaCliente no-error.

vstatus = if avail ConsultaCliente
          then "S"
          else "E".
vmensagem_erro = if avail ConsultaCliente
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     
setbcod = int(ConsultaCliente.codigo_filial).

{/u/bsweb/progr/bsxml.i}
    vcnpj = no.
        
    if ConsultaCliente.tipo_documento = "1" /* cpF */
    then do:
        run cpf.p (ConsultaCliente.numero_documento, output par-ok).
        if par-ok
        then find first clien where 
                clien.ciccgc = ConsultaCliente.numero_documento
                no-lock no-error.
        else do:
            run cgc.p (ConsultaCliente.numero_documento, output par-ok).
            if par-ok
            then do:
                find first clien where 
                    clien.ciccgc = ConsultaCliente.numero_documento
                    no-lock no-error.
                if avail clien
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
            then if clien.tippes = no
                 then vcnpj = yes.
        end.
    end.

    if vstatus = "S"
    then do:
        if not avail clien
        then do:
            vstatus = "N".
            vmensagem_erro = "Cliente " + ConsultaCliente.numero_documento + 
            " nao encontrado.".
        end.
        else do:
            vstatus = "S".
            vmensagem_erro = "".
        end.
    end.
    
    vatraso = no.
    
if avail clien and
   clien.clicod > 1
then do.
    connect dragao -H sv-mat-db1 -S sdragao -N tcp -ld dragao no-error.
    if connected ("dragao")
    then do.
        run ./progr/hiscli.p (clien.clicod).

        run /admcom/progr/calccredscore.p (input string(setbcod),
                                input recid(clien),
                                output vcalclim,
                                output vpardias,
                                output vdisponivel).

        disconnect dragao.

        if clien.tippes
        then do.
            run ./progr/pdv/spcpreconsulta.p (?, recid(clien),
                                          output par-spc, output vlibera-cli).
            if par-spc
            then run ./progr/pdv/spcconsulta.p (setbcod,
                               "CPF",
                               recid(clien),
                               "GRAVA",
                               output par-spc,
                               output spc-conecta).
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
        bsxml("cpf",clien.ciccgc).
        bsxml("nome",clien.clinom).

        if clien.dtnasc <> ?
        then bsxml("data_nascimento",string(year(clien.dtnasc),"9999") + "-" +
                                     string(month(clien.dtnasc),"99")   + "-" + 
                                     string( day (clien.dtnasc),"99")   + 
                                     "T00:00:00").
        else bsxml("data_nascimento","1900-01-01T00:00:00").

        bsxml("codigo_senha","").
        bsxml("valor_limite",string(lim-calculado,"->>>>>>>>>9.99")).

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
        bsxml("email",Texto(clien.zona)).
        
        if avail cpclien and cpclien.emailpromocional = true
        then assign vrecebe-email-promo = "Sim".
        else assign vrecebe-email-promo = "Nao".    
        if vrecebe-email-promo = ? then vrecebe-email-promo = "".
        bsxml("deseja_receber_email",vrecebe-email-promo).
        
        bsxml("ddd","").
        bsxml("telefone",Texto(clien.fone)).

        if clien.tippes <> ?
        then bsxml("tipo_pessoa",string(clien.tippes,"F/J")).
        else bsxml("tipo_pessoa","").

        bsxml("credito", string(vcalclim,">>>>>>>9.99")).
        bsxml("tipo_credito", string(clien.classe)).
        
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
        if vcnpj
        then if clien.ciccgc <> ?
             then bsxml("cnpj",clien.ciccgc).
             else bsxml("cnpj","").
        else bsxml("cnpj","").

        bsxml("pai",Texto(clien.pai)).
        bsxml("mae",Texto(clien.mae)).

        if clien.numdep <> ?
        then bsxml("numero_dependentes",string(clien.numdep)).
        else bsxml("numero_dependentes","").

        if avail cpclien and cpclien.var-char8 <> ?
        then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
        else vinstrucao = "".
        if vinstrucao = ? then vinstrucao = "".
        bsxml("grau_de_instrucao",vinstrucao).

        if avail cpclien and cpclien.var-log8 = true
        then assign vsituacao-instrucao = "Sim".
        else assign vsituacao-instrucao = "Nao".    
        if vsituacao-instrucao = ? then vsituacao-instrucao = "".
        bsxml("situacao_grau_instrucao",vsituacao-instrucao).
 
        if avail cpclien and cpclien.var-char7 <> ?
        then vinstrucao = entry(1,cpclien.var-char7,"=").
        else vinstrucao = "".
        bsxml("plano_saude",Texto(vinstrucao)).

        if avail cpclien and cpclien.var-char6 <> ?
        then vinstrucao = entry(1,trim(cpclien.var-char6),"=").
        else vinstrucao = "".
        if vinstrucao <> ?
        then bsxml("seguros",vinstrucao).
        else bsxml("seguros","").

        if avail cpclien and cpclien.var-char9 <> ?
        then bsxml("ponto_referencia",cpclien.var-char9).
        else bsxml("ponto_referencia","").

        bsxml("celular",Texto(clien.fax)).
                
        bsxml("tipo_residencia",if clien.tipres
                                then "Propria"
                                else "Alugada").
        bsxml("tempo_na_residencia",string(clien.temres,"999999")).

        if clien.dtcad <> ?
        then bsxml("data_cadastro",string(year(clien.dtcad),"9999") + "-" +
                                   string(month(clien.dtcad),"99")   + "-" + 
                                   string( day (clien.dtcad),"99")   + 
                                     "T00:00:00").
        else bsxml("data_cadastro","1900-01-01T00:00:00").
        
        if ult-compra <> ?
        then bsxml("data_ultima_compra",string(year(ult-compra),"9999") + "-" +
                                     string(month(ult-compra),"99")   + "-" + 
                                     string( day (ult-compra),"99")   + 
                                     "T00:00:00").
        else bsxml("data_ultima_compra","1900-01-01T00:00:00").

        bsxml("quantidade_contrato",       string(qtd-contrato)).
        bsxml("prestacoes_pagas",          string(parcela-paga)).
        bsxml("prestacoes_abertas",        string(parcela-aberta)).
        bsxml("qtd_atraso_ate_15dias",     string(qtd-15) ).

        if pagas-db > 0
        then assign
                vperc15 = (qtd-15 * 100) / pagas-db
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
        bsxml("media_por_contrato_contrato",    string(vmedia)).

        bsxml("maior_valor_acumulado",  string(v-acum)).
        bsxml("mes_ano",                string(v-mes) + string(v-ano)).
        bsxml("prestacao_media",        string(v-media)).
        bsxml("proximo_mes",            string(proximo-mes)).
        bsxml("maior_atraso",           string(maior-atraso)).
        bsxml("parcelas_vencidas",string(vencidas,">>>>>>>9.99")).
        bsxml("vl_cheque_devolvidos","0").

        /* dados profisionais */
        bsxml("empresa",Texto(clien.proemp[1])).
        bsxml("cnpj_empresa",cpclien.var-char1).
        bsxml("telefone_empresa",Texto(clien.protel[1])).

        if clien.prodta[1] <> ?
        then bsxml("data_admissao",string(year(clien.prodta[1]),"9999") + "-" +
                                   string(month(clien.prodta[1]),"99")  + "-" +
                                   string( day (clien.prodta[1]),"99")    + 
                                   "T00:00:00").
        else bsxml("data_admissao","1900-01-01T00:00:00").

        bsxml("profissao",Texto(clien.proprof[1])).

        if clien.prorenda[1] = ?
        then bsxml("renda_total","0").
        else bsxml("renda_total",string(prorenda[1],">>>>>>>9.99")).

        bsxml("endereco_empresa",Texto(clien.endereco[2])).
        
        if clien.numero[2] = ?
        then bsxml("numero_empresa","").
        else bsxml("numero_empresa",string(clien.numero[2])).
        
            bsxml("complemento_empresa",Texto(clien.compl[2])).
            bsxml("bairro_empresa",Texto(clien.bairro[2])).
            bsxml("cidade_empresa","").
            bsxml("estado_empresa",Texto(clien.ufecod[2])).
            bsxml("cep_empresa",   Texto(clien.cep[2])).

        /* conjuge */
        bsxml("nome_conjuge",Texto(clien.conjuge)).

        bsxml("cpf_conjuge",substr(clien.conjuge,51,20)).
        if clien.nascon <> ?
        then bsxml("data_nascimento_conjuge",
                                    string(year(clien.nascon),"9999") + "-" +
                                     string(month(clien.nascon),"99")   + "-" + 
                                     string( day (clien.nascon),"99")   + 
                                     "T00:00:00").
        else bsxml("data_nascimento_conjuge","1900-01-01T00:00:00").

        bsxml("pai_conjuge",Texto(clien.conjpai)).
        bsxml("mae_conjuge",Texto(clien.conjmae)).
        bsxml("empresa_conjuge",clien.proemp[2]).
        bsxml("telefone_conjuge", Texto(clien.protel[2])).
        bsxml("profissao_conjuge",Texto(clien.proprof[2])).

        if clien.prodta[2] <> ?
        then bsxml("data_admissao_conjuge",
                                  string(year(clien.prodta[2]),"9999") + "-" +
                                  string(month(clien.prodta[2]),"99")   + "-" + 
                                  string( day (clien.prodta[2]),"99")   + 
                                     "T00:00:00").
        else bsxml("data_admissao_conjuge","1900-01-01T00:00:00").

        if clien.prorenda[2] = ?
        then bsxml("renda_mensal_conjuge","0").
        else bsxml("renda_mensal_conjuge",string(clien.prorenda[2],
                        ">>>>>>9.99")).

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
                    /* 0 = Não Possui
                    (0/1) – VISA 
                    (0/2) - MASTERCARD
                    (0/3) - BANRICOMPRAS
                    (0/4) - HIPERCARD
                    (0/5) – CARTOES_LOJAS
                    (0/6) - AMEX
                    (0/7) - DINNERS
                    (0/8) - OUTROS
                        */
/*** Versao nova ***/
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
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

        if avail cpclien
        then do:

           if cpclien.var-ext2[1] = "BANRISUL" or 
              cpclien.var-ext2[1] = "CAIXA ECONOMICA FEDERAL" or
              cpclien.var-ext2[1] = "BANCO DO BRASIL" or
              cpclien.var-ext2[1] = "OUTROS"
           then do:   
               bsxml("banco1", cpclien.var-ext2[1]).
               bsxml("tipo_conta_banco1", cpclien.var-ext3[1]).
               bsxml("ano_conta_banco1", cpclien.var-ext4[1]).
           end.
           else do:
               bsxml("banco1", "").
               bsxml("tipo_conta_banco1", "").
               bsxml("ano_conta_banco1", "").
           end.
           
           if cpclien.var-ext2[2] = "BANRISUL" or 
              cpclien.var-ext2[2] = "CAIXA ECONOMICA FEDERAL" or
              cpclien.var-ext2[2] = "BANCO DO BRASIL" or
              cpclien.var-ext2[2] = "OUTROS"
           then do:   
               bsxml("banco2", cpclien.var-ext2[2]).
               bsxml("tipo_conta_banco2", cpclien.var-ext3[2]).
               bsxml("ano_conta_banco2", cpclien.var-ext4[2]).
           end.
           else do:
               bsxml("banco2", "").
               bsxml("tipo_conta_banco2", "").
               bsxml("ano_conta_banco2", "").
           end.

           
           if cpclien.var-ext2[3] = "BANRISUL" or 
              cpclien.var-ext2[3] = "CAIXA ECONOMICA FEDERAL" or
              cpclien.var-ext2[3] = "BANCO DO BRASIL" or
              cpclien.var-ext2[3] = "OUTROS"
           then do:   
               bsxml("banco3", cpclien.var-ext2[3]).
               bsxml("tipo_conta_banco3", cpclien.var-ext3[3]).
               bsxml("ano_conta_banco3", cpclien.var-ext4[3]).
           end.
           else do:
               bsxml("banco3", "").
               bsxml("tipo_conta_banco3", "").
               bsxml("ano_conta_banco3", "").
           end.
            
           if cpclien.var-ext2[4] = "BANRISUL" or 
              cpclien.var-ext2[4] = "CAIXA ECONOMICA FEDERAL" or
              cpclien.var-ext2[4] = "BANCO DO BRASIL" or
              cpclien.var-ext2[4] = "OUTROS"
           then do:   
               bsxml("banco_outros", cpclien.var-ext2[4]).
               bsxml("tipo_conta_outros", cpclien.var-ext3[4]).
               bsxml("ano_banco_outros", cpclien.var-ext4[4]).
           end.
           else do:
               bsxml("banco_outros", "").
               bsxml("tipo_conta_outros", "").
               bsxml("ano_banco_outros", "").
           end.
           
        end.

        bsxml("referencias_comerciais1",clien.refcom[1]).

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


        bsxml("referencias_comerciais2",clien.refcom[2]).

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
 

        bsxml("referencias_comerciais3",clien.refcom[3]).

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

        bsxml("referencias_comerciais4",clien.refcom[4]).

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

        bsxml("referencias_comerciais5",clien.refcom[5]).

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
            if carro.marca <> ?
            then bsxml("marca",carro.marca).
            else bsxml("marca","").
            if carro.modelo <> ?
            then bsxml("modelo",carro.modelo) .         
            else bsxml("modelo","").            
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
        bsxml("documentos_apresentados_rf1",Texto(entendereco[1])).
        bsxml("nome_ref2",      Texto(clien.entbairro[2])).
        bsxml("fone_comercial_ref2",Texto(clien.entcep[2])).
        bsxml("celular_ref2",   Texto(clien.entcidade[2])).
        bsxml("parentesco_ref2",Texto(clien.entcompl[2])).
        bsxml("documentos_apresentados_rf2",Texto(entendereco[2])). 
        bsxml("nome_ref3",      Texto(clien.entbairro[3])).
        bsxml("fone_comercial_ref3",Texto(clien.entcep[3])).
        bsxml("celular_ref3",   Texto(clien.entcidade[3])).
        bsxml("parentesco_ref3",Texto(clien.entcompl[3])).
        bsxml("documentos_apresentados_rf3",Texto(entendereco[3])).

        /* consulta spc */   

        vspc_cod_motivo_cancelamento = "".
        vspc_descr_motivo = "".
        
        if acha("OK",clien.entrefcom[2]) <> ?  and
           acha("OK",clien.entrefcom[2]) = "NAO"
        then do:
            vmen-spc = "CLIENTE COM REGISTRO".
            vspc_cod_motivo_cancelamento = "93".
            vspc_descr_motivo = "CLIENTE COM RESTRICAO SPC".
        end.    
        else vmen-spc = "CLIENTE SEM REGISTRO".

        vdat-spc = date(clien.entrefcom[1]).
        vfil-spc = acha("filial",clien.entrefcom[2]).
        vcon-spc = acha("consultas",clien.entrefcom[2]).
        vale-spc = acha("alertas",clien.entrefcom[2]).
        vcre-spc = acha("credito",clien.entrefcom[2]).
        vche-spc = acha("cheques",clien.entrefcom[2]).
        vnac-spc = acha("nacional",clien.entrefcom[2]).

        bsxml("resultado_consulta_spc",vmen-spc).
        if vfil-spc = ?
        then bsxml("filial_efetuou_consulta",""). 
        else bsxml("filial_efetuou_consulta",vfil-spc). 
        
        if vdat-spc <> ?
        then bsxml("data_consulta",
                                  string(year(vdat-spc),"9999") + "-" +
                                  string(month(vdat-spc),"99")   + "-" + 
                                  string( day (vdat-spc),"99")   + 
                                     "T00:00:00").
        else bsxml("data_consulta","1900-01-01T00:00:00").

        bsxml("quantidade_consultas_realizadas",vcon-spc). 
        bsxml("registros_de_alertas",vale-spc). 
        bsxml("registro_do_credito",vcre-spc). 
        bsxml("registro_de_cheques",vche-spc). 
        bsxml("registro_nacional",vnac-spc). 
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
        else bsxml("nota",string(cpclien.var-int3)).
                                                  
     connect crm -H "sv-mat-db1" -S sdrebcrm -N tcp -ld crm no-error.
     if connected("crm")
     then run ./progr/pegabonus.p (clien.clicod).
                       
         BSXml("ABREREGISTRO","listabonus"). 
         for each ttbonus.
            BSXml("ABREREGISTRO","bonus").
            bsxml("nome_bonus",ttbonus.nome_bonus).
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

    bsxml("fechatabela","return").
    BSXml("FECHAXML","").

