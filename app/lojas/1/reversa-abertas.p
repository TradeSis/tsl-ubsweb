/* helio 092022 - Reversa Lojas  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field estabOrigem as char.
    


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

{/admcom/progr/loj/lojreversa.i new}

/*def temp-table ttabertas no-undo serialize-name "reversa"
    field estabOrigem as char
    field etbdest     as char
    field codCaixa      as char
    field catcod        as char
    field pid           as char
    field dtalt         as char
    field hralt         as char.
*/

define dataset conteudoSaida for ttabertas.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.

hEntrada = temp-table ttEntrada:HANDLE.

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


for each reversaLojas where 
            reversaLojas.etbcod = vetbcod and
            reversaLojas.dtfec  = ?
            no-lock.

    create ttabertas.
    ttabertas.estabOrigem  = reversaLojas.etbcod.
    ttabertas.etbdest  =     reversaLojas.etbdest.    
    ttabertas.codCaixa     = reversaLojas.codCaixa.
    ttabertas.catcod        = reversaLojas.catcod.
    ttabertas.pid     = reversaLojas.pid.    
    ttabertas.dtalt     = reversaLojas.dtalt.
    ttabertas.hralt     = reversaLojas.hralt.
    ttabertas.idPedidoGerado     = ?.
end.    

for each reversaLojas where 
            reversaLojas.etbcod = vetbcod and
            reversaLojas.dtfec  >= today - 2 and
            reversaLojas.dtfec  <= today
            no-lock.

    create ttabertas.
    ttabertas.estabOrigem  = reversaLojas.etbcod.
    ttabertas.etbdest  =     reversaLojas.etbdest.    
    ttabertas.codCaixa     = reversaLojas.codCaixa.
    ttabertas.catcod        = reversaLojas.catcod.
    ttabertas.pid     = reversaLojas.pid.    
    ttabertas.dtalt     = reversaLojas.dtalt.
    ttabertas.hralt     = reversaLojas.hralt.
    ttabertas.idPedidoGerado     = reversaLojas.idPedidoGerado.
end.    

find first ttabertas no-error.
if avail ttabertas
then hSaida = dataset conteudoSaida:HANDLE.
else do:
    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Nenhuma Caixa Aberta".
    hsaida  = temp-table ttsaida:handle.

end.    

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
