/* helio 092022 - Reversa Lojas  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/loj/lojreversa.i new}

def temp-table ttentrada no-undo serialize-name "reversa"
    field estabOrigem as char
    field dataPedido  as char
    field codCaixa    as char
    field pid         as char
    field categoria   as char
    field idPedidoGerado    as char.

define dataset dadosEntrada for ttentrada.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttpedidofechado no-undo serialize-name "pedidofechado"
                field codCaixa     as int
                field estabOrigem  as int
                field idPedidoGerado  as char .   


define dataset conteudoSaida for ttpedidofechado. 

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


vcodCaixa = int(ttentrada.codCaixa).
find reversaLojas where reversaLojas.etbcod   = vetbcod and
                        reversaLojas.codCaixa = vcodCaixa exclusive no-wait no-error.
if not avail reversaLoja
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab then 500 else 404.
  ttsaida.descricaoStatus = "Caixa " + ttentrada.codCaixa
                 + " Não encontrada.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

reversalojas.dtfec          = date(int(entry(2,ttentrada.dataPedido,"-")),
                                   int(entry(3,ttentrada.dataPedido,"-")),
                                   int(entry(1,ttentrada.dataPedido,"-"))).
reversaLojas.idPedidoGerado = ttentrada.idPedidoGerado.
reversaLojas.dtalt          = today.
reversaLojas.hralt          = time.
reversalojas.pid            = 0.

create ttpedidofechado. 
ttpedidofechado.codCaixa       = int(ttentrada.codCaixa).
ttpedidofechado.estabOrigem    = int(ttentrada.estabOrigem).
ttpedidofechado.idPedidoGerado = ttentrada.idPedidoGerado.


hSaida = dataset conteudoSaida:HANDLE.

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
