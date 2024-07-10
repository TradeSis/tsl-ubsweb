/* helio 06022023 -     https://trello.com/c/POGR1nkP/966-problema-no-retorno-api-de-cliente-admcom-id-158248
        trocado da função texto() para RemoveAcentos() */
/* HUBSEG 19/10/2021 */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.
{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.
/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/u/bsweb/progr/app/cliente/1/clientesaida.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.


hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttentrada no-error.
if not avail ttentrada
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find neuclien where neuclien.cpfCnpj =  dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfCnpj = ?
           then ""
           else ttentrada.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
find carro where carro.clicod = clien.clicod no-lock no-error.

    var-propriedades = "" .

    run /admcom/progr/neuro/comportamento.p (clien.clicod, ?,   output var-propriedades).

    var-salaberto = dec(pega_prop("LIMITETOM")).
    if var-salaberto = ? then var-salaberto = 0.

    var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
    if var-salaberto-principal = ? then var-salaberto-principal = 0.

    var-salaberto-hubseg = dec(pega_prop("LIMITETOMHUBSEG")).
    if var-salaberto-hubseg = ? then var-salaberto-hubseg = 0.


            vvctoLimite  = if avail neuclien
                           then neuclien.vctolimite
                           else ?.
            vvlrLimite   = if vvctolimite = ? or vvctolimite < today
                           then 0
                           else neuclien.vlrlimite.
            vvlrdisponivel = vVlrLimite - var-salaberto-principal - var-salaberto-hubseg.
            if vvlrdisponivel < 0
            then vvlrdisponivel = 0.


create ttcliente.
         ttcliente.id = "1".

         ttcliente.tipoPessoa =   string(clien.tippes,"F/J").

         ttcliente.dataCadastro =   string(year(clien.dtcad),"9999") + "-" +
                          string(month(clien.dtcad),"99")   + "-" +
                          string(day(clien.dtcad),"99").

         ttcliente.tipoCadastro = "".
         lojaCadastro = string(clien.etbcad).
         codigoCliente = string(clien.clicod).
         ttcliente.razaoSocial = removeacento(clien.clinom).
         inscricaoEstadual = "".
         ttcliente.nome = removeacento(clien.clinom).
         ttcliente.cpfCnpj = clien.ciccgc.
         ttcliente.dataNascimento =  string(year(clien.dtnasc),"9999")
                                       + "-" + string(month(clien.dtnasc),"99")
                                       + "-" + string(day(clien.dtnasc),"99").
         identidade = RemoveAcento(clien.ciins).
         orgaoEmissor = "".
         nacionalidade = "".

             estadoCivil = if clien.estciv = 1 then "Solteiro" else
                if clien.estciv = 2 then "Casado"   else
                if clien.estciv = 3 then "Viuvo"    else
                if clien.estciv = 4 then "Desquitado" else
                if clien.estciv = 5 then "Divorciado" else
                if clien.estciv = 6 then "Falecido" else "".

         if avail cpclien
         then ttcliente.naturalidade = RemoveAcento(cpclien.var-char10).
        else ttcliente.naturalidade = "".

        if clien.sexo <> ?
        then ttcliente.sexo = string(clien.sexo,"M/F").
        else ttcliente.sexo = "".
         ttcliente.nomePai = RemoveAcento(clien.pai).
         ttcliente.nomeMae = RemoveAcento(clien.mae).

        if avail neuclien
        then do:
            codigoMae = RemoveAcento(string(neuclien.codigo_mae)).
        end.
        else do:
            codigoMae = "".
        end.


        if avail cpclien and cpclien.var-char7 <> ?
        then ttcliente.planosaude = entry(1,cpclien.var-char7,"=").
        else ttcliente.planosaude = "".

         possuiSeguroVida = "".
         possuiSeguroSaude = "".
         numeroDependente = RemoveAcento(string(clien.numdep)).

  /*  if clien.clicod <> 1
    then
        ttcliente.observacoes = (if clien.autoriza[1] = ? then "" else clien.autoriza[1]) +
               (if clien.autoriza[2] = ? then "" else clien.autoriza[2]) +
               (if clien.autoriza[3] = ? then "" else clien.autoriza[3]) +
               (if clien.autoriza[4] = ? then "" else clien.autoriza[4]) +
               (if clien.autoriza[5] = ? then "" else clien.autoriza[5]).
    else*/ ttcliente.observacoes = "" .

         ttcliente.documentosApresentados = RemoveAcento(clien.entendereco[1]).
                    bandeirasCartoesCredito = "".
                    do vx = 1 to 7.
                        if avail cpclien
                        then if int(cpclien.var-int[vx]) > 0
                             then bandeirasCartoesCredito = bandeirasCartoesCredito + auxcartao[vx].
                        if vx < 7
                        then  bandeirasCartoesCredito = bandeirasCartoesCredito + ";".
                    end.

            if avail cpclien and cpclien.var-char8 <> ?
            then grauInstrucao = acha("INSTRUCAO",cpclien.var-char8).
            else grauInstrucao = "".

    if avail cpclien and cpclien.var-log8 = true
    then assign situacaoGrauInstrucao = "Sim".
    else assign situacaoGrauInstrucao = "Nao".

create ttemprego.
        ttemprego.id = ttcliente.id + ".1".
        ttemprego.idpai = ttcliente.id.

        ttemprego.dataAdmissao    = EnviaData(clien.prodta[1]).

        if clien.prorenda[1] = ?
        then ttemprego.renda = "".
        else ttemprego.renda = trim(string(clien.prorenda[1],">>>>>>>9.99")).

        if avail neuclien
        then do:
            categoriaProfissional = RemoveAcento(neuclien.catprof).
        end.
        else do:
            categoriaProfissional = "".
        end.

create ttempresa.
        ttempresa.id = ttcliente.id + ".1".
        ttempresa.idpai = ttcliente.id.

         cnpj   = if avail cpclien
                  then RemoveAcento(cpclien.var-char1)
                  else "".
         ttempresa.razaoSocial   = RemoveAcento(clien.proemp[1]).
         nomeFantasia   = "".

create tttelefoneempresa.
        tttelefoneempresa.id = ttempresa.id + ".1".
        tttelefoneempresa.idpai = ttempresa.id.
         tttelefoneempresa.numero   = RemoveAcento(clien.protel[1]).
         tttelefoneempresa.tipo   = "".

create ttenderecoEmpresa.
        ttenderecoempresa.id = ttempresa.id + ".1".
        ttenderecoempresa.idpai = ttempresa.id.
         ttenderecoEmpresa.numero   = RemoveAcento(string(clien.numero[2])).
         ttenderecoEmpresa.rua   = RemoveAcento(clien.endereco[2]).
         ttenderecoEmpresa.bairro   = RemoveAcento(clien.bairro[2]).
         ttenderecoEmpresa.pontoReferencia   = "".
         ttenderecoEmpresa.complemento   = RemoveAcento(clien.compl[2]).
         ttenderecoEmpresa.cep   = RemoveAcento(clien.cep[2]).
         ttenderecoEmpresa.cidade   = RemoveAcento(clien.cidade[2]).
         ttenderecoEmpresa.codIbgeCidade   = "".
         ttenderecoEmpresa.uf   = RemoveAcento(clien.ufecod[2]).
         ttenderecoEmpresa.pais   = "".


create ttprofissao.
        ttprofissao.id = ttempresa.id + ".1".
        ttprofissao.idpai = ttempresa.id.
        find first profissao where profissao.profdesc = clien.proprof[1]
                             no-lock no-error.
        if avail profissao
        then ttprofissao.codigoProfissao =  string(profissao.codprof).
        ttprofissao.profissao   = RemoveAcento(clien.proprof[1]).
        rendaMedia   = "".

create ttcontato.
        ttcontato.id = ttcliente.id + ".1".
        ttcontato.idpai = ttcliente.id.

    ttcontato.email   = lc(RemoveAcento(clien.zona)).
    if avail cpclien and
       cpclien.emailpromocional = true
    then assign ttcontato.desejaReceberEmail = "Sim".
    else assign ttcontato.desejaReceberEmail = "Nao".

create tttelefone.
        tttelefone.id = ttcliente.id + ".1".
        tttelefone.idpai = ttcontato.id.

         tttelefone.numero   = RemoveAcento(clien.fone).
         tttelefone.tipo   = "RESIDENCIAL".

create tttelefone.
        tttelefone.id = ttcliente.id + ".2".
        tttelefone.idpai = ttcontato.id.

         tttelefone.numero   = RemoveAcento(clien.FAX).
         tttelefone.tipo   = "CELULAR".


create ttendereco.
        ttendereco.id = ttcliente.id + ".1".
        ttendereco.idpai = ttcliente.id.
         ttendereco.numero   = RemoveAcento(string(clien.numero[1])).
         ttendereco.rua   = RemoveAcento(clien.endereco[1]).
         ttendereco.bairro   = RemoveAcento(clien.bairro[1]).
         ttendereco.pontoReferencia   = "".
         ttendereco.complemento   = RemoveAcento(clien.compl[1]).
         ttendereco.cep   = RemoveAcento(clien.cep[1]).
         ttendereco.cidade   = RemoveAcento(clien.cidade[1]).
         ttendereco.codIbgeCidade   = "".
         ttendereco.uf   = RemoveAcento(clien.ufecod[1]).
         ttendereco.pais   = "".


create ttresidencia.
        ttresidencia.id = ttcliente.id + ".1".
        ttresidencia.idpai = ttcliente.id.
         tipoResidencia   =    RemoveAcento(string(clien.tipres,"Propria/Alugada")).
         tempoResidencia   =   RemoveAcento(    substr(string(int(clien.temres),"999999"),1,2) + "/"  +
                                                                  substr(string(int(clien.temres),"999999"),3,4) ).
         ttresidencia.possuiSeguro   = "".

create ttveiculo.
        ttveiculo.id = ttcliente.id + ".1".
        ttveiculo.idpai = ttcliente.id.

        possuiVeiculo = "NAO".
        if avail carro
        then if carro.carsit
             then possuiVeiculo = "SIM".

         ttveiculo.marca    = if possuiVeiculo = "NAO" then "" else RemoveAcento(carro.marca).
         ttveiculo.modelo   = if possuiVeiculo = "NAO" then "" else RemoveAcento(carro.modelo).
         ttveiculo.ano   = if possuiVeiculo = "NAO" then "" else RemoveAcento(string(carro.ano,"9999")).
         ttveiculo.possuiSeguro   = "".

do vx = 1 to 4:
    create ttreferenciasComerciais.
        ttreferenciasComerciais.id = ttcliente.id + "." + string(vx).
        ttreferenciasComerciais.idpai = ttcliente.id.

         referenciasComerciais   = RemoveAcento(clien.refcom[vx]).
         if avail cpclien
         then
           case cpclien.var-ext1[vx]:
           when "1"
            then situacaoReferenciasComerciais   = "Apresentado".
           when "2"
            then situacaoReferenciasComerciais   = "Nao Apresentado".
           when "3"
            then situacaoReferenciasComerciais   = "Nao possui cartao".
           otherwise
             situacaoReferenciasComerciais   = "".
        end case.
        else  situacaoReferenciasComerciais   = "".
end.

do vx = 1 to 3:
    create ttreferenciasPessoais.
        ttreferenciasPessoais.id = ttcliente.id + "." + string(vx).
        ttreferenciasPessoais.idpai = ttcliente.id.
         ttreferenciasPessoais.nome   = RemoveAcento(clien.entbairro[vx]).
         parentesco   = RemoveAcento(clien.entcompl[vx]).
         ttreferenciasPessoais.documentosApresentados   = RemoveAcento(clien.entendereco[vx]).
    create tttelefoneReferencia.
        tttelefoneReferencia.id = ttreferenciasPessoais.id + ".1".
        tttelefoneReferencia.idpai = ttreferenciasPessoais.id.
         tttelefoneReferencia.numero   = RemoveAcento(clien.entcep[vx]).
         tttelefoneReferencia.tipo   = "fone_comercial".
    create tttelefoneReferencia.
        tttelefoneReferencia.id = ttreferenciasPessoais.id + ".2".
        tttelefoneReferencia.idpai = ttreferenciasPessoais.id.
         tttelefoneReferencia.numero   = RemoveAcento(clien.entcidade[vx]).
         tttelefoneReferencia.tipo   = "celular".
end.

/*
create ttreferenciasPessoais.
        ttreferenciasPessoais.id = ttcliente.id + ".2".
        ttreferenciasPessoais.idpai = ttcliente.id.
         ttreferenciasPessoais.nome   = RemoveAcento(clien.entbairro[2]).
         parentesco   = RemoveAcento(clien.entcompl[2]).
         ttreferenciasPessoais.documentosApresentados   = RemoveAcento(clien.entendereco[2]).

create tttelefoneReferencia.
        tttelefoneReferencia.id = ttreferenciasPessoais.id + ".1".
        tttelefoneReferencia.idpai = ttreferenciasPessoais.id.
         tttelefoneReferencia.numero   = RemoveAcento(clien.entcep[2]).
         tttelefoneReferencia.tipo   = "fone_comercial".
create tttelefoneReferencia.
        tttelefoneReferencia.id = ttreferenciasPessoais.id + ".2".
        tttelefoneReferencia.idpai = ttreferenciasPessoais.id.
         tttelefoneReferencia.numero   = RemoveAcento(clien.entcidade[2]).
         tttelefoneReferencia.tipo   = "celular".

create ttreferenciasPessoais.
        ttreferenciasPessoais.id = ttcliente.id + ".3".
        ttreferenciasPessoais.idpai = ttcliente.id.
         ttreferenciasPessoais.nome   = RemoveAcento(clien.entbairro[3]).
         parentesco   = RemoveAcento(clien.entcompl[3]).
         ttreferenciasPessoais.documentosApresentados   = RemoveAcento(clien.entendereco[3]).
create tttelefoneReferencia.
        tttelefoneReferencia.id = ttreferenciasPessoais.id + ".1".
        tttelefoneReferencia.idpai = ttreferenciasPessoais.id.
         tttelefoneReferencia.numero   = RemoveAcento(clien.entcep[3]).
         tttelefoneReferencia.tipo   = "fone_comercial".
create tttelefoneReferencia.
        tttelefoneReferencia.id = ttreferenciasPessoais.id + ".2".
        tttelefoneReferencia.idpai = ttreferenciasPessoais.id.
         tttelefoneReferencia.numero   = RemoveAcento(clien.entcidade[3]).
         tttelefoneReferencia.tipo   = "celular".

*/

do vconta = 1 to 4.

    if  RemoveAcento(cpclien.var-ext2[vconta]) = ""
    then next.

    if avail cpclien
    then do:


            create ttdadosBancarios.
            ttdadosBancarios.id = ttcliente.id + "." + string(vconta).
            ttdadosBancarios.idpai = ttcliente.id.
            banco   = RemoveAcento(cpclien.var-ext2[vconta]).
            tipoConta   = RemoveAcento(cpclien.var-ext3[vconta]).
            anoConta   = RemoveAcento(cpclien.var-ext4[vconta]).

    end.

end.


create ttconjuge.
        ttconjuge.id = ttcliente.id + ".1".
        ttconjuge.idpai = ttcliente.id.
         ttconjuge.nome   = RemoveAcento(substr(clien.conjuge,1,50)).
         ttconjuge.cpf   = RemoveAcento(substr(clien.conjuge,51,20)).
         ttconjuge.dataNascimento   = EnviaData(clien.nascon).
         ttconjuge.naturalidade   = "".
         ttconjuge.nomePai   = RemoveAcento(clien.conjpai).
         ttconjuge.nomeMae   = RemoveAcento(clien.conjmae).

create tttelefoneConjuge.
        tttelefoneConjuge.id = ttconjuge.id + ".1".
        tttelefoneConjuge.idpai = ttconjuge.id.
         tttelefoneConjuge.numero   = RemoveAcento(clien.protel[2]).
         tttelefoneConjuge.tipo = "".

create ttempregoConjuge.
        ttempregoConjuge.id = ttconjuge.id + ".1".
        ttempregoConjuge.idpai =  ttconjuge.id.
         ttempregoConjuge.dataAdmissao   = EnviaData(clien.prodta[2]).
         ttempregoConjuge.renda   = RemoveAcento(string(clien.prorenda[2], ">>>>>>9.99")).
         empresaRazaoSocial   = RemoveAcento(clien.proemp[2]).

        find first profissao where profissao.profdesc = clien.proprof[2]
                             no-lock no-error.
        if avail profissao
        then ttempregoConjuge.profissaoCodigo =  string(profissao.codprof).
         ttempregoConjuge.profissao   = clien.proprof[2].


create ttcredito.
        ttcredito.id = ttcliente.id + ".1".
        ttcredito.idpai = ttcliente.id.
         statusCliente   = "".
         statusClienteMsg   = "".
         ttcredito.limite   = trim(string(vvlrLimite,"->>>>>>>>9.99")).
         limiteDisponivel   = trim(string(vvlrdisponivel,"->>>>>>>>9.99")).
         validadeLimite     = EnviaData(vvctoLimite).
         if validadeLimite = ? then validadeLimite = "".
         nota   =  (if  not avail cpclien then "" else RemoveAcento( string(cpclien.var-int3))).

create ttrestricoes.
        ttrestricoes.id = ttcliente.id + ".1".
        ttrestricoes.idpai = ttcliente.id.
         rStatus   = "".
         dataUltmaConsulta   = if clien.entrefcom[1] = ? then "" else string(date(clien.entrefcom[1]),"99/99/9999").
         filialConsulta   = acha("filial",clien.entrefcom[2]).
         localConsulta   = "".
         qtdConsulta   = acha("consultas",clien.entrefcom[2]).
         regAlertas   = acha("alertas",clien.entrefcom[2]).
         regCheque   = acha("cheques",clien.entrefcom[2]).
         regCredito   = acha("credito",clien.entrefcom[2]).
         regNacional   = acha("nacional",clien.entrefcom[2]).
         cpfConsulta   = clien.ciccgc.


lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted trim(string(vlcsaida)).
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 500.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
