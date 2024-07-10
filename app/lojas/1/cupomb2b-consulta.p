/* #012023 helio cupom desconto b2b */
/* programa api consultacupomb2b - responsavel pela validação do cupom usado na prevenda */

def buffer subclasse for clase.
def buffer classe    for clase.
def buffer grupo     for clase.
def buffer setor     for clase.
def buffer cupom-clase for clase.

def var vmercadologico as char label "Nivel Mercadologico" format "x(10)" extent 4 init
    ["Setor","Grupo","Classe","SubClasse"].
def var cmercadologico as char.

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "cupomb2b" 
    field estabOrigem   as int
    field idCupom       as int
    field clicod        as int.

def temp-table ttitens serialize-name "itens" 
    field codigoProduto as int
    field quantidade    as int
    field valorUnitario as dec.

define dataset dadosEntrada for ttentrada, ttitens.
def var vvenda-clacod as int.
def var vcatcod as int.
def var vok as log.

{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}


DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttcupomb2b serialize-name "cupomb2b" 
    field estabOrigem   as int
    field idCupom       as int
    field categoria     as int
    field subclasse     as int
    field valorDesconto as dec
    field percentualDesconto as dec
    field dataValidade  as date.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vidCupom    as int.

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

vidCupom = int(ttentrada.idCupom).
find cupomb2b where cupomb2b.idCupom = vidCupom no-lock no-error.
if not avail cupomb2b
then do:

  create ttsaida.
  ttsaida.tstatus = if locked cupomb2b then 500 else 404.
  ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.
if cupomb2b.dataTransacao <> ?
then do:

  create ttsaida.
  ttsaida.tstatus = if locked cupomb2b then 500 else 404.
  ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                 + " já utilizado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

if cupomb2b.dataValidade < today
then do:

  create ttsaida.
  ttsaida.tstatus = if locked cupomb2b then 500 else 404.
  ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                 + " passou da validade.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

if cupomb2b.etbcod <> 0 and cupomb2b.etbcod <> vetbcod 
then do:

  create ttsaida.
  ttsaida.tstatus = if locked cupomb2b then 500 else 404.
  ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                 + " nao pode ser usado nesta loja.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


if cupomb2b.catcod <> 0
then do:
    vcatcod = 0.
    for each ttitens.
        find produ where produ.procod = ttitens.codigoProduto no-lock.
        if produ.catcod = 31 or produ.catcod = 41 then do:
            vcatcod = produ.catcod.
            leave.
        end.            
    end.
    if cupomb2b.catcod <> vcatcod
    then do:
        find categoria where categoria.catcod = vcatcod no-lock.
        create ttsaida.
        ttsaida.tstatus = if locked cupomb2b then 500 else 404.
        ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                       + " nao pode ser usado para " + categoria.catnom.
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
      
    end.
end.

if cupomb2b.clacod <> 0
then do:
 
    find cupom-clase where cupom-clase.clacod = cupomb2b.clacod no-lock.
    
    vok = no.
    for each ttitens.
        find produ where produ.procod = ttitens.codigoProduto no-lock.
        find subclasse   where   subclasse.clacod = produ.clacod         no-lock.
        find classe where classe.clacod = subclasse.clasup no-lock.
        find grupo where grupo.clacod = classe.clasup no-lock.
        find setor where setor.clacod = grupo.clasup no-lock.

        if cupom-clase.clagrau = 4
        then  vvenda-clacod = subclasse.clacod.
        if cupom-clase.clagrau = 3
        then  vvenda-clacod = classe.clacod.
        if cupom-clase.clagrau = 2
        then  vvenda-clacod = grupo.clacod.
        if cupom-clase.clagrau = 1
        then  vvenda-clacod = setor.clacod.
        
        if vvenda-clacod = cupomb2b.clacod
        then do:
            vok = yes.
        end.
        
    end.
    
    if vok = no
    then do:

        cmercadologico = vmercadologico[cupom-clase.clagrau].
        create ttsaida.
        ttsaida.tstatus = if locked cupomb2b then 500 else 404.
        ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                       + " nao pode ser usado. somente para " + cmercadologico + "=" + string(cupomb2b.clacod) + " " + cupom-clase.clanom +
                            ".".
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
      
    end.
end.


if cupomb2b.tipocupom = "CASHB"
then do:
    if ttentrada.clicod <> cupomb2b.clicod
    then do:
        create ttsaida.
        ttsaida.tstatus =  404.
        ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
                       + " pertence a outro cliente".
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    
    end.


end.

create ttcupomb2b.
ttcupomb2b.estabOrigem        = cupomb2b.etbcod.
ttcupomb2b.idCupom            = cupomb2b.idCupom.
ttcupomb2b.categoria          = cupomb2b.catcod.
ttcupomb2b.subclasse          = cupomb2b.clacod.
ttcupomb2b.valorDesconto      = cupomb2b.valorDesconto.
ttcupomb2b.percentualDesconto = cupomb2b.percentualDesconto.
ttcupomb2b.dataValidade       = cupomb2b.dataValidade.
    

hSaida = temp-table ttcupomb2b:HANDLE.

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
