/* 10072023 helio combo descontos plano */
def buffer subclasse for clase.
def buffer classe    for clase.
def buffer grupo     for clase.
def buffer setor     for clase.

def var vregra as char.
def var vperc  as dec. 

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "pedido" 
    field estabOrigem   as int
    field codigoPlano   as int
    field identificador as char
    field vendedor      as int.

def temp-table ttitens serialize-name "itens" 
    field codigoProduto as int
    field quantidade    as int
    field valorUnitario as dec.

define dataset dadosEntrada for ttentrada, ttitens.

{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}


DEFINE VARIABLE lokJSON                  AS LOGICAL.


def temp-table ttcombo serialize-name "combo" 
    field estabOrigem   as int
    field codigoPlano   as int
    field filial   as int
    field codigoPlanoUsar       as int
    field percDesc      as dec.

def temp-table ttcombo-itens serialize-name "itens" 
    field codigoProduto as int
    field quantidade    as int
    field valorUnitario as dec
    field categoria     as char
    field setor         as char
    field regra         as char
    field percDesc      as dec
    field valorDesc     as dec.

define dataset dadosSaida for ttcombo, ttcombo-itens.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vfincod as int.

hEntrada = dataset dadosEntrada:HANDLE.

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

vetbcod = int(ttentrada.estabOrigem).
find estab where estab.etbcod = vetbcod  no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab  then 500 else 404.
  ttsaida.descricaoStatus = "Estabelecimento de origem " + string(ttentrada.estabOrigem)
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vfincod = int(ttentrada.codigoPlano).

find first combodescplan where combodescplan.etbcod = vetbcod and
                               combodescplan.fincod = vfincod
    no-lock no-error.
if not avail combodescplan
then do:
    find first combodescplan where combodescplan.etbcod = 0 and
                                   combodescplan.fincod = vfincod
        no-lock no-error.
end.
if not avail combodescplan
then do:
        create ttsaida.
        ttsaida.tstatus = 404.
        ttsaida.descricaoStatus = "plano " + string(vfincod) + " sem parametrizacao COMBO".
        hsaida  = temp-table ttsaida:handle.
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
end.

def var vservico as log.
vservico = no.
for each ttitens. 
    find produ where produ.procod = ttitens.codigoProduto no-lock.
    find subclasse   where   subclasse.clacod = produ.clacod         no-lock.
    find classe where classe.clacod = subclasse.clasup no-lock.
    find grupo where grupo.clacod = classe.clasup no-lock.
    find setor where setor.clacod = grupo.clasup no-lock.
    if produ.proipiper = 98
    then vservico = yes.
end. 
if vservico
then do:
        create ttsaida.
        ttsaida.tstatus = 404.
        ttsaida.descricaoStatus = "venda com servico".
        hsaida  = temp-table ttsaida:handle.
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
end.

def var vproduto as dec.

create ttcombo.
ttcombo.estabOrigem = ttentrada.estabOrigem.
ttcombo.filial = combodescplan.etbcod.
ttcombo.codigoPlanoUsar    =  combodescplan.finusar.
ttcombo.codigoPlano    =  combodescplan.fincod.
ttcombo.percDesc           = combodescplan.percDesc.
for each ttitens. 
    find produ where produ.procod = ttitens.codigoProduto no-lock.
    find subclasse   where   subclasse.clacod = produ.clacod         no-lock.
    find classe where classe.clacod = subclasse.clasup no-lock.
    find grupo where grupo.clacod = classe.clasup no-lock.
    find setor where setor.clacod = grupo.clasup no-lock.

    create ttcombo-itens.
    ttcombo-itens.codigoProduto =   ttitens.codigoProduto.
    ttcombo-itens.quantidade    =   ttitens.quantidade.
    ttcombo-itens.valorUnitario =   ttitens.valorUnitario.

    ttcombo-itens.categoria     = string(produ.catcod).
    ttcombo-itens.setor         = string(setor.clacod).
    vregra = "GERAL".
    vperc  = combodescplan.percdesc.

    find first combodescset of combodescplan where 
        combodescset.catcod = produ.catcod and
        combodescset.clacod = setor.clacod 
        no-lock no-error.
    if avail combodescset
    then do:
        vregra = "SETOR".
        vperc  = combodescset.percdesc.
    end.
    else do:
        find first combodescset of combodescplan where 
            combodescset.catcod = produ.catcod and
            combodescset.clacod = 0
            no-lock no-error.
        if avail combodescset
        then do:
            vregra = "CATEGORIA".
            vperc  = combodescset.percdesc.
        end.
    end.
    ttcombo-itens.regra         = vregra.

    ttcombo-itens.percDesc      = vperc.
    vproduto = int(ttcombo-itens.quantidade) * dec(ttcombo-itens.valorUnitario).
    ttcombo-itens.valorDesc     =   round(vproduto * vperc / 100,2).
end.    

hSaida = dataset dadosSaida:HANDLE.

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
