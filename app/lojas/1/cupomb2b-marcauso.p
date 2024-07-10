/* #012023 helio cupom desconto b2b */
/* programa api marcausocupomb2b - responsavel pela validação do cupom usado na prevenda */


def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "cupomb2b" 
    field estabOrigem   as int
    field idCupom       as int.

define dataset dadosEntrada for ttentrada.
def var vcatcod as int.
def var vclacod as int.

{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}


DEFINE VARIABLE lokJSON                  AS LOGICAL.

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
find cupomb2b where cupomb2b.idCupom = vidCupom exclusive-lock no-wait no-error.
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


cupomb2b.dataTransacao = today.

create ttsaida.
ttsaida.tstatus = 200.
ttsaida.descricaoStatus = "cupom " + string(ttentrada.idcupom) 
               + " marcado o uso.".

hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcSaida).
return.
