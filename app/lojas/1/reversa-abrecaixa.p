/* helio 092022 - Reversa Lojas  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "reversa"
    field estabOrigem as char
    field estabDestino   as char
    field pid           as char.

define dataset dadosEntrada for ttentrada.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttnovacaixa no-undo serialize-name "conteudoSaida"
    field estabOrigem as char
    field estabDestino   as char
    field codCaixa      as char.




def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vetbdest as int.
def var vcodCaixa   as int.

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
  ttsaida.descricaoStatus = "Estabelecimento de origem " + ttentrada.estabOrigem
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vetbdest = int(ttentrada.estabDestino).
find estab where estab.etbcod = vetbdest  no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab then 500 else 404.
  ttsaida.descricaoStatus = "Estabelecimento de destino " + ttentrada.estabDestino
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


find last reversaLojas where reversaLojas.etbcod = vetbcod no-lock no-error.
vcodCaixa = if not avail reversaLojas then 1 else reversaLojas.codCaixa + 1.

create reversaLojas.
ASSIGN
reversaLojas.etbcod         = vetbcod.
reversaLojas.codCaixa       = vcodCaixa.
reversaLojas.dtinc          = today.
reversaLojas.hrinc          = time.
reversaLojas.etbdest        = vetbdest.
reversaLojas.catcod         = 0.
reversaLojas.observacao     = "".
reversaLojas.idPedidoGerado = ?.
reversaLojas.dtalt          = today.
reversaLojas.hralt          = time.
reversaLojas.pidUso         = int(ttentrada.pid).
reversaLojas.dtfec          = ?.

create ttnovacaixa.
ttnovacaixa.estabOrigem  = string(reversaLojas.etbcod).
ttnovacaixa.estabDestino = string(reversaLojas.etbdest).
ttnovacaixa.codCaixa     = string(reversaLojas.codCaixa).

hSaida = temp-table ttnovacaixa:HANDLE.

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
