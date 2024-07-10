/*** Dicionario de dados: clioutb4.p filial 189 ***/
{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-atrasoparcperc as char.
def var var-PARCPAG as int.


/** 100    **/
def var par-recid-neuclien as recid.
def var vtipoconsulta          as char init "WsAC".
def var vneu_cdoperacao as char.

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

def new global shared var setbcod       as int.

def var vprops as char.
def var vPOLITICA as char.

/** 100 **/

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

/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */

def shared temp-table AtualizacaoDadosCliente
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
    field categoria_profissional as char.

find first atualizacaodadoscliente no-error.

vstatus = if avail atualizacaodadoscliente
          then "S"
          else "E".
vmensagem_erro = if avail atualizacaodadoscliente
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     

if avail atualizacaodadoscliente
then setbcod = atualizacaodadoscliente.codigo_filial.

{/u/bsweb/progr/bsxml-iso.i}

vcodigo = ?.
if testavalido(atualizacaodadoscliente.codigo_cliente) 
then vcodigo = int(atualizacaodadoscliente.codigo_cliente) no-error.

vcgccpf = ?.
if testavalido(atualizacaodadoscliente.cpf) 
then vcgccpf = trata-numero(atualizacaodadoscliente.cpf).
    
if vcodigo <> ? and vcodigo <> 0
then do on error undo:
    find clien where clien.clicod = vcodigo no-lock no-error.
    
    if vstatus = "S"
    then
        if not avail clien
        then assign
                vstatus = "N"
                vmensagem_erro = "1Cliente Codigo: " + 
                    atualizacaodadoscliente.codigo_cliente + " Nao Encontrado".
        else assign
                vstatus = "S"
                vmensagem_erro = "".
end.
else assign
        vstatus = "N".
        vmensagem_ERRO = "2Cliente Codigo: " + 
            atualizacaodadoscliente.codigo_cliente + " Nao Encontrado".

if vstatus = "N"
then do:    
    /** 100 
        retirado
    if vcgccpf <> ? and vcgccpf <> ""
    then do on error undo:
        find clien where clien.ciccgc = vcgccpf exclusive no-error.
        if not avail clien
        then do:
            vstatus = "I". 
            run ./progr/p-geraclicod.p (output vgera).

            disable triggers for load of clien.
            create clien.
            assign
                clien.clicod = vgera
                clien.ciccgc = vcgccpf
                clien.clinom = caps(atualizacaodadoscliente.nome)
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
    100
    **/
end.

if vstatus <> "N"
then do:
    
    vtime = time.
    
    /* 100 */
    find neuclien where neuclien.cpfcnpj = dec(clien.ciccgc) /** int64 **/
        no-lock no-error.
    if not avail neuclien
    then do:
         create PreAutorizacao.
         preAutorizacao.codigo_filial   = string(atualizacaodadoscliente.codigo_filial).
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

         run neuro/gravaneuclien_H.p (clien.ciccgc,
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
                     setbcod), 
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
    
    /* 100 */

end.

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

   find current clien exclusive-lock no-wait no-error.
   if avail clien
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
               else 0. 
        clien.estciv = vint.        
    end.
                
    if testavalido(atualizacaodadoscliente.naturalidade)
    then assign
            clien.natur = atualizacaodadoscliente.naturalidade
            cpclien.var-char10 = atualizacaodadoscliente.naturalidade.
        
    if testavalido(atualizacaodadoscliente.endereco)
    then clien.endereco[1] = atualizacaodadoscliente.endereco.
        
    if testavalido(atualizacaodadoscliente.numero)
    then clien.numero[1] = int(atualizacaodadoscliente.numero) no-error.
        
    if testavalido(atualizacaodadoscliente.complemento)
    then clien.compl[1] = atualizacaodadoscliente.complemento.
        
    if testavalido(atualizacaodadoscliente.bairro)
    then clien.bairro[1] = atualizacaodadoscliente.bairro.
        
    if testavalido(atualizacaodadoscliente.cidade)
    then clien.cidade[1] = atualizacaodadoscliente.cidade.
        
    if testavalido(atualizacaodadoscliente.uf)
    then clien.ufecod[1] = atualizacaodadoscliente.uf.
        
    if testavalido(atualizacaodadoscliente.cep)
    then clien.cep[1] = atualizacaodadoscliente.cep.
        
    if testavalido(atualizacaodadoscliente.telefone)
    then clien.fone   = atualizacaodadoscliente.telefone.

    /*VAI
    if clien.prorenda[1] = ?
    then bsxml("renda_total","0").
    else bsxml("renda_total",string(clien.prorenda[1],">>>>>>>9.99")).
    */
    if testavalido(atualizacaodadoscliente.renda_total)
    then do:
        vdec = dec(atualizacaodadoscliente.renda_total) no-error.
        if vdec <> ?
        then clien.prorenda[1] = vdec.
    end.
                
    /*VAI
    if clien.proprof[1] = ?
    then bsxml("profissao","").
    else bsxml("profissao",tiraacentos(clien.proprof[1])).
    */
    if testavalido(atualizacaodadoscliente.profissao)
    then do.
        clien.proprof[1] = caps(atualizacaodadoscliente.profissao).
        find first profissao where profissao.profdesc = clien.proprof[1]
                             no-lock no-error.
        if avail profissao
        then cpclien.var-int4 = profissao.codprof.
    end.

    /*VAI
    if clien.proemp[1] = ?
    then bsxml("empresa","").
    else bsxml("empresa",clien.proemp[1]).
    */
    if testavalido(atualizacaodadoscliente.empresa)
    then clien.proemp[1] = atualizacaodadoscliente.empresa.

    /*VAI
    if clien.prodta[1] <> ?
    then bsxml("data_admissao",string(year(clien.prodta[1]),"9999") + "-" +
                               string(month(clien.prodta[1]),"99")  + "-" +                                    string( day (clien.prodta[1]),"99")   + 
                                    "T00:00:00").
    else bsxml("data_admissao","1900-01-01T00:00:00").
    */
        
    vchar = atualizacaodadoscliente.data_admissao.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                                 int(substring(vchar,9,2)),
                                 int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then clien.prodta[1] = vdata.                                 
    end.                                  
        
    /*VAI
    bsxml("documentos_apresentados_rf1",entendereco[1]). 
    */
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
    /*VAI   bsxml("numero_dependentes",string(clien.numdep)).*/
    if testavalido(atualizacaodadoscliente.numero_dependentes)
    then do:
        vdec = int(atualizacaodadoscliente.numero_dependentes) no-error.
        if vdec <> ?
        then clien.numdep = int(vdec).
    end.
        
    /*VAI
    if avail cpclien and cpclien.var-char8 <> ?
    then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
    else vinstrucao = "".
    if vinstrucao = ? then vinstrucao = "".
    bsxml("grau_de_instrucao",vinstrucao).
    */

    vchar = atualizacaodadoscliente.grau_de_instrucao.
    if testavalido(vchar)
    then cpclien.var-char8 = "INSTRUCAO=" + vchar .         

    vchar = atualizacaodadoscliente.situacao_grau_de_instrucao.
    if testavalido(vchar) and vchar = "Sim"
    then cpclien.var-log8 = true.
    else cpclien.var-log8 = false.
    
    /*VAI
    if avail cpclien and cpclien.var-char7 <> ?
    then vinstrucao = entry(1,cpclien.var-char7,"=").
    else vinstrucao = "".
    bsxml("plano_saude",vinstrucao).
    */
    vchar = atualizacaodadoscliente.plano_saude.
    if testavalido(vchar)
    then assign
            cpclien.var-log7  = yes
            cpclien.var-char7 = trim(vchar) + "=|".

    /*VAI 
    if avail cpclien and cpclien.var-char6 <> ?
    then vinstrucao = entry(1,cpclien.var-char6,"=").
    else vinstrucao = "".
    bsxml("seguros",vinstrucao).
    */
    vchar = atualizacaodadoscliente.seguros.
    if testavalido(vchar)
    then assign
            cpclien.var-log6  = yes
            cpclien.var-char6 = trim(vchar) + "=|".
        
    /*VAI
    if avail cpclien
    then bsxml("ponto_referencia",cpclien.var-char9).
    else bsxml("ponto_referencia","").
    */
    vchar = atualizacaodadoscliente.ponto_referencia.
    if testavalido(vchar)
    then cpclien.var-char9 = vchar.         
        
    /*VAI          bsxml("celular",clien.fax). */
    if testavalido(atualizacaodadoscliente.celular)
    then clien.fax = atualizacaodadoscliente.celular.

    /*VAI
    bsxml("tipo_residencia",if clien.tipres
                                then "Propria"
                                else "Alugada").
    */
    vchar = atualizacaodadoscliente.tipo_residencia.
    if testavalido(vchar)
    then clien.tipres = if vchar = "Propria" then yes else no. 

    /*VAI bsxml("tempo_na_residencia",string(clien.temres,"999999")). */
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

    /*VAI
    if clien.protel[1] = ?
    then bsxml("telefone_empresa","").
    else bsxml("telefone_empresa",clien.protel[1]).
    */

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
                                    
    /*VAI
    if clien.nascon <> ?
    then bsxml("data_nascimento_conjuge",
                                    string(year(clien.nascon),"9999") + "-" +
                                     string(month(clien.nascon),"99")   + "-" + 
                                     string( day (clien.nascon),"99")   + 
                                     "T00:00:00").
    else bsxml("data_nascimento_conjuge","1900-01-01T00:00:00").
    */
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
        clien.proprof[2] = caps(atualizacaodadoscliente.profissao_conjuge).
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
        then clien.prorenda[2] = vdec.
    end.
        
    /*VAI
    vcartao = 0.
    if avail cpclien
    then do vi = 1 to 7.
        if int(cpclien.var-int[vi]) > 0
        then vcartao = vi.
    end.
    bsxml("cartoes_de_credito",string(vcartao)).
    */
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
 
    if testavalido(atualizacaodadoscliente.cartoes_de_credito)
    then do:
        cpclien.var-int = "0". /* limpar cartoes */
/***
        vint = int(atualizacaodadoscliente.cartoes_de_credito) no-error.
        if vint <> ? and vint <> 0
        then do:
            cpclien.var-int = "0".
            cpclien.var-int[vint] = "1".
        end.                
***/

        /* Os Nomes dos cartoes vem separados por "," ***/
        vcartoes = atualizacaodadoscliente.cartoes_de_credito.
        do vct = 1 to num-entries(vcartoes).
            do vint = 1 to 7.
                if trim(entry(vct, vcartoes)) = auxcartao[vint]
                then cpclien.var-int[vint] = string(vint).
            end.
        end.
    end.

/***
    if testavalido(atualizacaodadoscliente.banco1)
        and (atualizacaodadoscliente.banco1 = "BANRISUL" or
             atualizacaodadoscliente.banco1 = "CAIXA ECONOMICA FEDERAL" or
             atualizacaodadoscliente.banco1 = "BANCO DO BRASIL" or
             atualizacaodadoscliente.banco1 = "OUTROS")
    then do:
        cpclien.var-ext2[1] = atualizacaodadoscliente.banco1.

        if testavalido(atualizacaodadoscliente.tipo_conta_banco1)
        then cpclien.var-ext3[1] = atualizacaodadoscliente.tipo_conta_banco1.

        if testavalido(atualizacaodadoscliente.ano_conta_banco1)
        then cpclien.var-ext4[1] = atualizacaodadoscliente.ano_conta_banco1.
    end.
    
    if testavalido(atualizacaodadoscliente.banco2)
        and (atualizacaodadoscliente.banco2 = "BANRISUL" or
             atualizacaodadoscliente.banco2 = "CAIXA ECONOMICA FEDERAL" or
             atualizacaodadoscliente.banco2 = "BANCO DO BRASIL" or
             atualizacaodadoscliente.banco2 = "OUTROS")
    then do:
        cpclien.var-ext2[2] = atualizacaodadoscliente.banco2.

        if testavalido(atualizacaodadoscliente.tipo_conta_banco2)
        then cpclien.var-ext3[2] = atualizacaodadoscliente.tipo_conta_banco2.

        if testavalido(atualizacaodadoscliente.ano_conta_banco2)
        then cpclien.var-ext4[2] = atualizacaodadoscliente.ano_conta_banco2.
    end.
    
    if testavalido(atualizacaodadoscliente.banco3)
        and (atualizacaodadoscliente.banco3 = "BANRISUL" or
             atualizacaodadoscliente.banco3 = "CAIXA ECONOMICA FEDERAL" or
             atualizacaodadoscliente.banco3 = "BANCO DO BRASIL" or
             atualizacaodadoscliente.banco3 = "OUTROS")
    then do:
        cpclien.var-ext2[3] = atualizacaodadoscliente.banco3.

        if testavalido(atualizacaodadoscliente.tipo_conta_banco3)
        then cpclien.var-ext3[3] = atualizacaodadoscliente.tipo_conta_banco3.

        if testavalido(atualizacaodadoscliente.ano_conta_banco3)
        then cpclien.var-ext4[3] = atualizacaodadoscliente.ano_conta_banco3.
    end.

    if testavalido(atualizacaodadoscliente.banco_outros)
        and (atualizacaodadoscliente.banco_outros = "BANRISUL" or
             atualizacaodadoscliente.banco_outros = "CAIXA ECONOMICA FEDERAL" or
             atualizacaodadoscliente.banco_outros = "BANCO DO BRASIL" or
             atualizacaodadoscliente.banco_outros = "OUTROS")
    then do:
        cpclien.var-ext2[4] = atualizacaodadoscliente.banco_outros.

        if testavalido(atualizacaodadoscliente.tipo_conta_outros)
        then cpclien.var-ext3[4] = atualizacaodadoscliente.tipo_conta_outros.

        if testavalido(atualizacaodadoscliente.ano_banco_outros)
        then cpclien.var-ext4[4] = atualizacaodadoscliente.ano_banco_outros.
    end.

***/
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

    /*VAI
        vobs =  (if clien.autoriza[1] = ? then "" else clien.autoriza[1]) + 
                " " +
                (if clien.autoriza[2] = ? then "" else clien.autoriza[2]) +
                " " +
                (if clien.autoriza[3] = ? then "" else clien.autoriza[3]) +
                " " +
                (if clien.autoriza[4] = ? then "" else clien.autoriza[4]) +
                " " +
                (if clien.autoriza[5] = ? then "" else clien.autoriza[5]) + 
                "".
        bsxml("observacoes",vobs).         
    */
    if testavalido(atualizacaodadoscliente.observacoes)
    then do:
        clien.autoriza[1] = substr(atualizacaodadoscliente.observacoes,1,80).
        clien.autoriza[2] = substr(atualizacaodadoscliente.observacoes,81,80).
        clien.autoriza[3] = substr(atualizacaodadoscliente.observacoes,161,80).
        clien.autoriza[4] = substr(atualizacaodadoscliente.observacoes,241,80).
        clien.autoriza[5] = substr(atualizacaodadoscliente.observacoes,321).
    end.            
        
    /*VAI
    vcarro = "NAO".
    find carro where carro.clicod = clien.clicod no-lock no-error.
    if avail carro
    then if carro.carsit 
         then vcarro = "SIM".
    bsxml("possui_veiculo",vcarro).
    */
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

    /*VAI
    bsxml("nome_ref1",clien.entbairro[1]). 
    bsxml("fone_comercial_ref1",clien.entcep[1]). 
    bsxml("celular_ref1",clien.entcidade[1]). 
    bsxml("parentesco_ref1",clien.entcompl[1]). 
    bsxml("documentos_apresentados_rf1",entendereco[1]). 
    bsxml("nome_ref2",clien.entbairro[2]). 
    bsxml("fone_comercial_ref2",clien.entcep[2]). 
    bsxml("celular_ref2",clien.entcidade[2]). 
    bsxml("parentesco_ref2",clien.entcompl[2]). 
    bsxml("documentos_apresentados_rf2",entendereco[2]). 
    bsxml("nome_ref3",clien.entbairro[3]). 
    bsxml("fone_comercial_ref3",clien.entcep[3]). 
    bsxml("celular_ref3",clien.entcidade[3]). 
    bsxml("parentesco_ref3",clien.entcompl[3]). 
    bsxml("documentos_apresentados_rf3",entendereco[3]). 
    */
        
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
            neuclien.codigo_mae = int(atualizacaodadoscliente.codigo_mae) no-error.
        end.
    end.        
    if testavalido(atualizacaodadoscliente.categoria_profissional)
    then do:
        if avail neuclien
        then do:
            find current neuclien exclusive.
            neuclien.catprof = atualizacaodadoscliente.categoria_profissional no-error.
        end.
    end.        
    
   
    find current clien no-lock.
   
    vmensagem_erro = "Cliente Codigo: " + 
            string(clien.clicod) + " " +  string(clien.clinom) + " "
            + if vnovo then " Cadastrado. " else " Atualizado. ".
  end. /* on error */
end.               

/* 100 MOTOR NEUROTECH */
if avail clien and
   avail neuclien and
   (vstatus = "S" or 
    vstatus = "I")
then do:

        /**run ./progr/hiscli_05.p (clien.clicod).
        **/

        /* 100 */

            /** Testa se vai para NEUROTECH **/  
            /* 16.11.2017 - mudou para testar primeiro */
                        
            find first contrato use-index iconcli
                    where contrato.clicod = clien.clicod no-lock no-error.
            if not avail contrato
            then
                vPOLITICA = "P2".   /* Regra, cliente nao possui cadastro */ 
            else             
                vPOLITICA = "P3".
               
            run neuro/submeteneuro.p (input setbcod, 
                                     input vpolitica,
                                      input clien.clicod,   
                                      0,
                                     output vlojaneuro, 
                                     output vneurotech).

 
        if  vlojaneuro and 
            (
            neuclien.vctolimite <> ?  /* quais situacoes vai atualizar **/
           and neuclien.vctolimite >= today 
           and neuclien.sit_credito = "A" 
            )
        then do:

            vvlrLimite  = neuclien.vlrlimite.
            vvctoLimite = neuclien.vctolimite.
            vsit_credito = neuclien.sit_credito.

        end.
        else do:
            
            if vneurotech
            then do:
                
                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "".
                                
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

                vrenda          = if clien.prorenda[1] = ?
                                  then 0
                                  else clien.prorenda[1].
                vrenda_conjuge  = if clien.prorenda[2] = ?
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

                    vneu_cdoperacao = "".       /* Usado para verificar se existe um Operacao Pendente */
                    find first neuproposta where
                        neuproposta.etbcod  = setbcod and
                        neuproposta.dtinclu = today   and
                        neuproposta.cpfcnpj = neuclien.cpfcnpj
                         and
                        neuproposta.hrinclu >= time - (5 * 60)

                        no-lock no-error.
                    if avail neuproposta
                    then do:
                        if neuproposta.neu_resultado = "P"
                        then vneu_cdoperacao = neuproposta.neu_cdoperacao.
                     end.


 
                    vprops = 
                        "POLITICA="             + "CREDITO" + string(setbcod,"9999") +
                        (if vneu_cdoperacao = ""
                         then ""
                         else "&PROP_IDOPERACAO=" + trim(vneu_cdoperacao))
                        +
                        "&PROP_CONTACLI="       + trim(string(clien.clicod)) + 
                        "&PROP_NOMECLI="        + trim(clien.clinom) +  
                        "&PROP_TIPOCREDITO="    + "NORMAL"    
                       + "&PROP_TIPOPESSOA="     +   (  if clien.tippes <> ?
                                                       then string(clien.tippes,"F/J")
                                                       else "")
                       + "&PROP_CPFCLI="         + trim(clien.ciccgc)   
                       + "&PROP_RGCLI="          + texto(clien.ciins)  
                       + "&PROP_DTNASCCLI="      + texto(string(clien.dtnasc,"99/99/9999")) 
                       + "&PROP_CATEGCLI="       + trim(neuclien.catprof) 
                       + "&PROP_SEXOCLI="        +  string(clien.sexo,"M/F")
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
                       + "&PROP_CONTAMAE="       +  texto(string(neuclien.codigo_mae))
                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_EMAILCLI=" + lc(texto(clien.zona))      

                       + "&PROP_LOGRADCLI=" + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="    + texto(string(clien.numero[1]))
                       + "&PROP_CEP="            +      Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="      +      Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="    +      Texto(clien.compl[1])  
                       + "&PROP_CIDADE="         +      Texto(clien.cidade[1])
                       + "&PROP_UF="             +      Texto(clien.ufecod[1])

                       + "&PROP_TIPORESID="      +      string(clien.tipres,
                                                            "Propria/Alugada")
                       + "&PROP_TEMPORESID="     +      texto(    substr(string(int(temres),"999999"),1,2) + "/"  +
                                                                  substr(string(int(temres),"999999"),3,4) )
                       + "&PROP_CELULAR="        +      Texto(clien.fax)  
                       + "&PROP_TELEFONE="       +      Texto(clien.fone) 
                       + "&PROP_DTCADASTRO=" + 
                                texto(string(clien.dtcad,"99/99/9999"))
                       + "&PROP_EMPRESA="        +      Texto(clien.proemp[1])  
                       + "&PROP_CNPJCOMERC="     +      
                                (if avail cpclien
                                 then Texto(cpclien.var-char1)
                                 else "")
                       + "&PROP_FONECOMERC="     + texto(clien.protel[1])
                      + "&PROP_DTADMISSAO="     +      texto(string(clien.prodta[1],"99/99/9999"))
                       + "&PROP_PROFISSAO="      +      Texto(clien.proprof[1])
                        
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
                       + "&PROP_FLXPOLITICA="    + vPOLITICA.
                
                end.
                else do:
                       
        
                    find current neuclien no-lock.         
        
                    run neuro/comportamento.p (neuclien.clicod, ?,  
                                       output var-propriedades). 
                    var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
                    if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
                    var-parcpag = int(pega_prop("PARCPAG")). 
                    if var-parcpag = ? then var-parcpag = 0.
                                    
                    vprops = 
                        "POLITICA="             + "CREDITO" + string(setbcod,"9999") 
                       + "&PROP_CONTACLI="       + trim(string(clien.clicod))       
                       + "&PROP_NOMECLI="        + trim(clien.clinom)   
                       + "&PROP_CPFCLI="         + trim(clien.ciccgc)   
                       + "&PROP_DTNASCCLI="      + texto(string(clien.dtnasc,"99/99/9999")) 
                       + "&PROP_LOGRADCLI="      +      Texto(clien.endereco[1])
                       + "&PROP_NUMERO="         +      texto(string(clien.numero[1]))
                       + "&PROP_CEP="            +      Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="      +      Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="    +      Texto(clien.compl[1])  
                       + "&PROP_CIDADE="         +      Texto(clien.cidade[1])
                       + "&PROP_UF="             +      Texto(clien.ufecod[1])
                       + "&PROP_CELULAR="        +      Texto(clien.fax)  
                       + "&PROP_TELEFONE="       +      Texto(clien.fone) 
                       + "&PROP_DTCADASTRO=" + 
                                texto(string(clien.dtcad,"99/99/9999"))
                       + "&PROP_EMPRESA="        +      Texto(clien.proemp[1])  
                       + "&PROP_DTADMISSAO="     + texto(string(clien.prodta[1],"99/99/9999"))
                       + "&PROP_PROFISSAO="      +      Texto(clien.proprof[1])
                       + "&PROP_RENDAMES="       +      string(vrenda)
                       + "&PROP_SOMARENDAS="     +      string(vrenda + vrenda_conjuge)
                       + "&PROP_LOJACAD="        + trim(string(if neuclien.etbcod = 0 or neuclien.etbcod = ? then setbcod else neuclien.etbcod)) 

                        + "&PROP_PARCPAG=" + string(var-parcpag)
                        + "&PROP_ATRASOPARCPERC=" + texto(var-atrasoparcperc)

                       + "&PROP_FLXPOLITICA="    + vPOLITICA.

                end.   
        
        
                run neuro/wcneurotech.p (setbcod,
                                                  int(AtualizacaoDadosCliente.numero_pdv),
                                                  input vprops,
                                                  input vPOLITICA,
                                                  input vtime,
                                                  input par-recid-neuclien, 
                                                  output vvlrLimite, 
                                                  output vvctolimite,
                                                  output vneuro-sit, 
                                                  output vneuro-mens,
                                                  output vstatus,
                                                  output vmensagem_erro).

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
            end.
            
            if vneurotech = no
            then do: /** ADMCOM **/
            
                vtime = time.
                run neuro/callimiteadmcom.p (recid(neuclien),
                                    vtipoconsulta,
                                    vtime,
                                    setbcod,
                                    AtualizacaoDadosCliente.numero_pdv,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
                if vsit_credito = "E"
                then do:
                    vstatus = "N".
                    vmensagem_erro = "Erro ao calcular Limite Admcom". 
                end.
                vsit_credito = "A".
            end.
                                 
        end.
    
    
end.
/* 100 */



    
BSXml("ABREXML","").
bsxml("abretabela","return").

if vstatus = "I" then vstatus = "S".
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",string(atualizacaodadoscliente.codigo_filial)).
bsxml("numero_pdv",string(atualizacaodadoscliente.numero_pdv)).

    /* 100 **/
    bsxml("credito", string(vvlrLimite,">>>>>>>9.99")).
    bsxml("sit_credito", texto(string(vsit_credito))).
    bsxml("vcto_credito", EnviaData(vvctoLimite)).
    bsxml("mensagem_credito", vneuro-mens).
    
    
    /** 100 **/

bsxml("fechatabela","return").
BSXml("FECHAXML","").


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

