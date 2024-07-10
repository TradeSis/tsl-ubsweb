def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var par-clicod like clien.clicod.

def var vdec  as dec.
def var vchar as char.
def var vint  as int.
def var vdata as date.

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

{/u/bsweb/progr/app/cliente/1/clienteentrada.i}
/*
{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */
*/

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vcodigoCliente as int.
def var vcpfCnpj       as int64.

/*
def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
*/

lokJSON = hEntrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttcliente no-error.
if not avail ttcliente
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vcodigoCliente = int(ttcliente.codigoCliente) no-error.
vcpfCnpj       = dec(ttcliente.cpfCnpj)       no-error.

if vcpfCnpj <> ? and vcpfCnpj <> 0
then do:
    find neuclien where neuclien.cpfCnpj =  vcpfCnpj no-lock no-error.
    if not avail neuclien
    then do:
        if vcodigoCliente <> ? and vcodigoCliente <> 0
        then do:
            find clien where clien.clicod = vcodigoCliente no-lock no-error.
        end.
        if not avail clien
        then find clien where clien.ciccgc = trim(string(vcpfCnpj)) no-lock no-error.
    end.
    else do:
        find clien where clien.clicod = neuclien.clicod no-lock no-error.
    end.
end.
else do:
    if vcodigoCliente <> ? and vcodigoCliente <> 0
    then do:
        find clien where clien.clicod = vcodigoCliente no-lock no-error.
    end.
end.
par-clicod = 0.
if not avail clien
then do:

                run /admcom/progr/p-geraclicod.p (output par-clicod).
                ttcliente.codigoCliente = string(par-clicod).
                do on error undo.

                    create clien.
                    assign
                        clien.clicod = int(ttcliente.codigoCliente) .
                        clien.ciccgc = string(ttcliente.cpf).
                        clien.clinom = string(ttcliente.nome).
                        clien.tippes = ttcliente.tipoPessoa = "F".
                        clien.etbcad = 777.
               end.
end.

if not avail neuclien
then do on error undo:

                    create neuclien.
                    neuclien.cpfcnpj = dec(clien.ciccgc).
                    neuclien.tippes  = clien.tippes.
                    neuclien.etbcod  = clien.etbcad.
                    neuclien.dtcad   = today.
                    neuclien.nome_pessoa = clien.clinom.
                    neuclien.clicod = clien.clicod.

end.

find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

if not avail cpclien
then do on error undo:
                    create cpclien.
                    assign
                    cpclien.clicod     = clien.clicod
                    cpclien.var-char11 = ""
                    cpclien.datexp     = today.
end.

do on error undo:

    find current clien exclusive.
    find cpclien where cpclien.clicod = clien.clicod exclusive.

                    for each ttendereco where ttendereco.idpai = ttcliente.id.
                        clien.endereco[1]   = caps(ttendereco.rua).
                        clien.numero[1]     = int(ttendereco.numero) no-error.
                        clien.compl[1]      = caps(ttendereco.complemento).
                        clien.bairro[1]     = caps(ttendereco.bairro).
                        clien.cidade[1]     = caps(ttendereco.cidade).
                        clien.ufecod[1]     = caps(ttendereco.uf).
                        clien.cep[1]        = (ttendereco.cep).
                        vchar = ttendereco.pontoreferencia.
                        if testavalido(vchar)
                        then cpclien.var-char9 = vchar.

                    end.
                    find first ttcontato no-error.
                    if avail ttcontato
                    then do:
                        clien.zona = ttcontato.email.
                        vchar = ttcontato.desejareceberemail.
                        if testavalido(vchar) and vchar = "Sim"
                        then cpclien.emailpromocional = true.
                        else cpclien.emailpromocional = false.

                    end.

                    find first tttelefone where tttelefone.tipo = "CELULAR" no-error.
                    if avail tttelefone
                    then clien.fax = tttelefone.numero.
                    find first tttelefone where tttelefone.tipo <> "CELULAR" no-error.
                    if avail tttelefone
                    then clien.fone = tttelefone.numero.


    find carro where carro.clicod = clien.clicod no-lock no-error.

    clien.datexp = today.



    vchar = ttcliente.dataNascimento.
    if testavalido(vchar)
    then do:
        vdata = date(int(substring(vchar,6,2)),
                     int(substring(vchar,9,2)),
                     int(substring(vchar,1,4))) no-error.
        if vdata <> ?
        then clien.dtnasc = vdata.
    end.

    if testavalido(ttcliente.sexo)
    then clien.sexo   = if ttcliente.sexo = "M" then true else false.

    if testavalido(ttcliente.nacionalidade)
    then clien.nacion = ttcliente.nacionalidade.

    if testavalido(ttcliente.identidade)
    then clien.ciins  = ttcliente.identidade.


    vchar = ttcliente.estadocivil.
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

    if testavalido(ttcliente.naturalidade)
    then assign
            clien.natur = ttcliente.naturalidade
            cpclien.var-char10 = ttcliente.naturalidade.

    if testavalido(ttcliente.numerodependente)
    then do:
        vdec = int(ttcliente.numerodependente) no-error.
        if vdec <> ?
        then clien.numdep = int(vdec).
    end.

    vchar = ttcliente.grauinstrucao.
    if testavalido(vchar)
    then cpclien.var-char8 = "INSTRUCAO=" + vchar .

    vchar = ttcliente.situacaograuinstrucao.
    if testavalido(vchar) and vchar = "Sim"
    then cpclien.var-log8 = true.
    else cpclien.var-log8 = false.

    find first ttresidencia no-error.
    if avail ttresidencia
    then do:

        vchar = ttresidencia.tiporesidencia.
        if testavalido(vchar)
        then clien.tipres = if vchar = "Propria" then yes else no.

        if testavalido(ttresidencia.temporesidencia)
        then do:
            vdec = int(ttresidencia.temporesidencia) no-error.
            if vdec <> ?
            then clien.temres = int(vdec).
        end.
    end.

    if testavalido(ttcliente.nomepai)
    then clien.pai = ttcliente.nomepai.
    if testavalido(ttcliente.nomemae)
    then clien.mae = ttcliente.nomemae.


    find first ttemprego no-error.
    if avail ttemprego
    then do:
        if testavalido(ttemprego.renda)
        then do:
            vdec = dec(ttemprego.renda) no-error.
            if vdec <> ?
            then clien.prorenda[1] = vdec.
        end.
        vchar = ttemprego.dataadmissao.
        if testavalido(vchar)
        then do:
            vdata = date(int(substring(vchar,6,2)),
                                     int(substring(vchar,9,2)),
                                     int(substring(vchar,1,4))) no-error.
            if vdata <> ?
            then clien.prodta[1] = vdata.
        end.
        if testavalido(ttemprego.categoriaprofissional)
        then do:
            if avail neuclien
            then do:
                find current neuclien exclusive.
                neuclien.catprof = ttemprego.categoriaprofissional
                 no-error.
            end.
        end.

    end.


    find first ttprofissao no-error.
    if avail ttprofissao
    then do:
        if testavalido(ttprofissao.profissao)
        then do.
            clien.proprof[1] = texto(ttprofissao.profissao).
            find first profissao where profissao.profdesc = clien.proprof[1]
                                 no-lock no-error.
            if avail profissao
            then cpclien.var-int4 = profissao.codprof.
        end.
    end.

    find first ttempresa no-error.
    if avail ttempresa
    then do:
        if testavalido(ttempresa.razaoSocial)
        then clien.proemp[1] = ttempresa.razaoSocial.
        if testavalido(ttempresa.cnpj)
        then cpclien.var-char1 = ttempresa.cnpj.

        find first ttenderecoempresa no-error.
        if avail ttenderecoempresa
        then do:
            if testavalido(ttenderecoempresa.rua)
            then clien.endereco[2] = ttenderecoempresa.rua.
            if testavalido(ttenderecoempresa.numero)
            then clien.numero[2] = int(ttenderecoempresa.numero).
            if testavalido(ttenderecoempresa.complemento)
            then clien.compl[2] = ttenderecoempresa.complemento.
            if testavalido(ttenderecoempresa.bairro)
            then clien.bairro[2] = ttenderecoempresa.bairro.
            if testavalido(ttenderecoempresa.cidade)
            then clien.cidade[2] = ttenderecoempresa.cidade.
            if testavalido(ttenderecoempresa.uf)
            then clien.ufecod[2] = ttenderecoempresa.uf.
            if testavalido(ttenderecoempresa.cep)
            then clien.cep[2] = ttenderecoempresa.cep.

            find first tttelefoneempresa no-error.
            if avail tttelefoneempresa
            then clien.protel[1] = ttcliente.numero.
        end.
    end.


    def var vnaturconj as char.
    def var vnomconj as char.
    def var vcpfconj as char.

    if avail ttconjuge
    then do:
        if testavalido(ttconjuge.nome)
        then vnomconj = ttconjuge.nome.
        if testavalido(ttconjuge.cpf)
        then vcpfconj = trata-numero(ttconjuge.cpf).

        if testavalido(ttconjuge.naturalidade)
        then vnaturconj  = ttconjuge.naturalidade.

        clien.conjuge = string(vnomconj,"x(50)") + string(vcpfconj,"x(20)") +
                        string(vnaturconj,"x(20)").

        vchar = ttconjuge.dataNascimento.
        if testavalido(vchar)
        then do:
            vdata = date(int(substring(vchar,6,2)),
                             int(substring(vchar,9,2)),
                             int(substring(vchar,1,4))) no-error.
            if vdata <> ?
            then clien.nascon = vdata.
        end.

        if testavalido(ttconjuge.nomePai)
        then clien.conjpai = ttconjuge.nomePai.
        if testavalido(ttconjuge.nomemae)
        then clien.conjpai = ttconjuge.nomeMae.

        find first ttempregoconjuge no-error.

        if avail ttempregoconjuge
        then do:
            if testavalido(ttempregoConjuge.empresaRazaoSocial)
            then clien.proemp[2] = ttempregoconjuge.empresaRazaoSocial.

            if testavalido(ttempregoConjuge.profissao)
            then do.
                clien.proprof[2] = texto(ttempregoConjuge.profissao).
                find first profissao where profissao.profdesc = clien.proprof[2]
                                     no-lock no-error.
                if avail profissao
                then cpclien.var-int5 = profissao.codprof.
            end.

            vchar = ttempregoConjuge.dataAdmissao.
            if testavalido(vchar)
            then do:
                vdata = date(int(substring(vchar,6,2)),
                                         int(substring(vchar,9,2)),
                                         int(substring(vchar,1,4))) no-error.
                if vdata <> ?
                then clien.prodta[2] = vdata.
            end.

            if testavalido(ttempregoConjuge.renda)
            then do:
                vdec = dec(ttempregoConjuge.renda) no-error.
                if vdec <> ?
                then clien.prorenda[2] = vdec.
            end.

        end.
        find first tttelefoneConjuge no-error.
        if avail tttelefoneConjuge
        then do:
            if testavalido(tttelefoneConjuge.numero)
            then clien.protel[2] = tttelefoneConjuge.numero.
        end.
    end.

    if testavalido(ttcliente.bandeirasCartoesCredito)
    then do:
        cpclien.var-int = "0". /* limpar cartoes */
        vcartoes = ttcliente.bandeirasCartoesCredito.
        do vct = 1 to num-entries(vcartoes).
            do vint = 1 to 7.
                if trim(entry(vct, vcartoes)) = auxcartao[vint]
                then cpclien.var-int[vint] = string(vint).
            end.
        end.
    end.


    for each ttdadosBancarios:
        if testavalido(ttdadosBancarios.banco)
        then do.
            if ttdadosBancarios.banco = "BANRISUL"
            then vint = 1.
            else if ttdadosBancarios.banco = "CAIXA ECONOMICA FEDERAL"
            then vint = 2.
            else if ttdadosBancarios.banco = "BANCO DO BRASIL"
            then vint = 3.
            else vint = 4.

            cpclien.var-ext2[vint] = ttdadosBancarios.banco.

            if testavalido(ttdadosBancarios.tipoConta)
            then cpclien.var-ext3[vint] = ttdadosBancarios.tipoConta.

            if testavalido(ttdadosBancarios.anoConta)
            then cpclien.var-ext4[vint] = ttdadosBancarios.anoConta.
        end.
    end.

    vx = 0.
    find first ttreferenciasComerciais no-error.
    if avail ttreferenciasComerciais
    then do:
        clien.refcom[1] = "". /* limpar dados */
        if avail cpclien
        then assign
                clien.refcom = ""
                cpclien.var-ext1 = "".

        for each ttreferenciasComerciais:

            if  testavalido(ttreferenciasComerciais.referenciasComerciais)
            then do:
                vx = vx + 1.
                clien.refcom[int(vx)] = ttreferenciasComerciais.referenciasComerciais.
                case ttreferenciasComerciais.situacaoReferenciasComerciais:
                    when "Apresentado"       then cpclien.var-ext1[int(vx)] = "1".
                    when "Nao Apresentado"   then cpclien.var-ext1[int(vx)] = "2".
                    when "Nao possui cartao" then cpclien.var-ext1[int(vx)] = "3".
                end case.
            end.

        end.

    end.



    vx = 0.
    find first ttreferenciasPessoais no-error.
    if avail ttreferenciasPessoais
    then do:
        clien.entbairro = "".
        clien.entcompl  = "".
        clien.entcep    = "".
        clien.entcidade = "".
    end.
    for each ttreferenciasPessoais.

        vx = vx + 1.
        if testavalido(ttreferenciasPessoais.nome)
        then clien.entbairro[vx] = ttreferenciasPessoais.nome.
        if testavalido(ttreferenciasPessoais.parentesco)
        then clien.entcompl[vx] = ttreferenciasPessoais.parentesco.

        if testavalido(ttreferenciasPessoais.documentosApresentados)
        then clien.entendereco[vx] = ttreferenciasPessoais.documentosApresentados.

        for each tttelefoneReferencia where tttelefoneReferencia.idpai = ttreferenciasPessoais.id.

            if tttelefoneReferencia.tipo <> "CELULAR"
               and testavalido(tttelefoneReferencia.numero)
            then clien.entcep[vx] = tttelefoneReferencia.numero.

            if tttelefoneReferencia.tipo = "CELULAR"
               and testavalido(tttelefoneReferencia.numero)
            then clien.entcidade[vx] = tttelefoneReferencia.numero.


        end.


    end.


    if testavalido(ttcliente.observacoes)
    then do:
        clien.autoriza[1] = substr(ttcliente.observacoes,1,80).
        clien.autoriza[2] = substr(ttcliente.observacoes,81,80).
        clien.autoriza[3] = substr(ttcliente.observacoes,161,80).
        clien.autoriza[4] = substr(ttcliente.observacoes,241,80).
        clien.autoriza[5] = substr(ttcliente.observacoes,321).
    end.


    find first ttveiculo no-error.
    if avail ttveiculo
    then do:
        vchar = ttveiculo.possuiveiculo.
        if testavalido(vchar)
        then do:
            find carro where carro.clicod = clien.clicod exclusive-lock no-error.
            if not avail carro
            then do:
                create carro.
                carro.clicod = clien.clicod.
            end.
            carro.carsit = if vchar = "SIM" then yes else no.

            if testavalido(ttveiculo.marca)
            then carro.marca  = ttveiculo.marca.
            if testavalido(ttveiculo.modelo)
            then carro.modelo = ttveiculo.modelo.
            vint = int(ttveiculo.ano) no-error.
            if vint <> ?
            then carro.ano = vint.
        end.

    end.


    find first ttcredito no-error.
    if avail ttcredito
    then do:
        if testavalido(ttcredito.nota)
        then cpclien.var-int3 = int(ttcredito.nota) no-error.
    end.

    if testavalido(ttcliente.codigomae)
    then do:
        if avail neuclien
        then do:
            find current neuclien exclusive.
            neuclien.codigo_mae = int(ttcliente.codigomae)
                        no-error.
        end.
    end.


end.




create ttsaida.
ttsaida.tstatus = 200.
ttsaida.descricaoStatus = "Cliente ".

ttsaida.descricaoStatus = ttsaida.descricaoStatus + if avail clien then "Codigo: " + string(clien.clicod) else "".
ttsaida.descricaoStatus = ttsaida.descricaoStatus + if avail neuclien then
                                                      if neuclien.tippes
                                                      then " CPF: " + string(neuclien.cpfCnpj,"99999999999")
                                                      else " CNPJ: " + string(neuclien.cpfCnpj,"99999999999999")
                                                    else " ".
ttsaida.descricaoStatus = ttsaida.descricaoStatus + if par-clicod = 0
                          then " Atualizado"
                          else " Incluido".

hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcSaida).
