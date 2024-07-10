/* helio 102022 - BAG  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/loj/bagdefs.i new}

def temp-table ttentrada serialize-name "bag" like ttbag.

define dataset dadosEntrada for ttentrada.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

define dataset conteudoSaida for ttbag.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.

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

find bagLojas where bagLojas.etbcod = vetbcod and
                    bagLojas.idbag = ttentrada.idbag and
                    baglojas.cpf    = int64(ttentrada.cpf)
                    no-lock no-error.
if avail bagLoja
then do:

  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "bag " + string(ttentrada.idbag) + " / CPF " + string(ttentrada.cpf,"99999999999")
                 + " ja fechada!".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


find bagLojas where bagLojas.etbcod = vetbcod and
                    bagLojas.idbag = 0 and
                    baglojas.cpf    = int64(ttentrada.cpf)
                    exclusive no-wait no-error.
if not avail bagLoja
then do:

  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "bag " + string(ttentrada.idbag) + " / CPF " + string(ttentrada.cpf,"99999999999")
                 + " Não encontrada.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.



bagLojas.pid            = 0.
bagLojas.dtalt          = today.
bagLojas.hralt          = time.
bagLojas.dtfec          = today.
bagLojas.idBag          = int(ttentrada.idBag). /* ganha id */

create ttbag.
ttbag.estabOrigem       = bagLojas.etbcod.
ttbag.idBag             = baglojas.idBag.
ttbag.cpf               = dec(baglojas.cpf).
ttbag.categoria         = bagLojas.catcod.
ttbag.pid               = ttentrada.pid.
ttbag.nome              = baglojas.nome.
ttbag.consultor         = baglojas.consultor.

    ttbag.datacriacao  = string(year(bagLojas.dtinc)) + "-" + 
                             string(month(bagLojas.dtinc),"99") + "-" + 
                             string(day(bagLojas.dtinc),"99").
    ttbag.datasaida    = string(year(bagLojas.dtfec)) + "-" + 
                             string(month(bagLojas.dtfec),"99") + "-" + 
                             string(day(bagLojas.dtfec),"99").

for each bagprodu where bagprodu.etbcod = baglojas.etbcod and
                        bagprodu.idbag  = 0 and
                        bagprodu.cpf    = baglojas.cpf.
    bagprodu.idbag = baglojas.idBag.
end.                        
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
