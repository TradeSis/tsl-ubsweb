/* helio 102022 - BAG  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/loj/bagdefs.i new}

def temp-table ttentrada no-undo serialize-name "bag" like ttbag.
    
define dataset dadosEntrada for ttentrada.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttbagfechado no-undo serialize-name "bagfechado"
                field codbag     as int
                field estabOrigem  as int
                field idbag  as char .   


define dataset conteudoSaida for ttbagfechado. 

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vetbdest as int.
def var vcodbag   as int.

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


vcodbag = int(ttentrada.codbag).
find bagLojas where bagLojas.etbcod   = vetbcod and
                        bagLojas.codbag = vcodbag exclusive no-wait no-error.
if not avail bagLoja
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab then 500 else 404.
  ttsaida.descricaoStatus = "bag " + ttentrada.codbag
                 + " Não encontrada.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

baglojas.dtfec          = today.
bagLojas.idbag          = int(ttentrada.idbag).
bagLojas.dtalt          = today.
bagLojas.hralt          = time.
baglojas.pid            = 0.

create ttbagfechado. 
ttbagfechado.codbag       = int(ttentrada.codbag).
ttbagfechado.estabOrigem  = int(ttentrada.estabOrigem).
ttbagfechado.idbag        = ttentrada.idbag.


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
