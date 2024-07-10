/* helio 102022 - BAG  */

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

{/admcom/progr/loj/bagdefs.i new}

define dataset conteudoSaida for ttbaglistagem.


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

find first baglojas where 
            bagLojas.etbcod = vetbcod and
            bagLojas.dtfec  <> ? and
            baglojas.dtvenda = ? and
            bagLojas.dtfec < today - 5
            no-lock no-error.

if avail baglojas
then do:

  create ttsaida.
  ttsaida.tstatus = 401.
  ttsaida.descricaoStatus = "Estabelecimento de BAGs PENDENTES de fechamento a mais de 5 dias " + chr(10) + " Nao eh permitido abrir bags" .

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.
end.


for each baglojas where 
            bagLojas.etbcod = vetbcod and
            bagLojas.dtfec  = ? 
            no-lock.

    create ttbaglistagem.
    ttbaglistagem.estabOrigem  = bagLojas.etbcod.
    ttbaglistagem.consultor = baglojas.consultor.
    ttbaglistagem.catcod        = bagLojas.catcod.
    ttbaglistagem.pid     = bagLojas.pid.    
    ttbaglistagem.dtalt     = bagLojas.dtalt.
    ttbaglistagem.hralt     = bagLojas.hralt.

    ttbaglistagem.cpf   = dec(baglojas.cpf).
    ttbaglistagem.nome  = baglojas.nome.
    ttbaglistagem.datacriacao  = string(year(bagLojas.dtinc)) + "-" + 
                             string(month(bagLojas.dtinc),"99") + "-" + 
                             string(day(bagLojas.dtinc),"99").
    ttbaglistagem.datasaida    = string(year(bagLojas.dtfec)) + "-" + 
                             string(month(bagLojas.dtfec),"99") + "-" + 
                             string(day(bagLojas.dtfec),"99").
    
end.    

/*
for each bagLojas where 
            bagLojas.etbcod = vetbcod and
            bagLojas.dtfec  >= today - 2 and
            bagLojas.dtfec  <= today
            no-lock.

    create ttbaglistagem.
    ttbaglistagem.estabOrigem  = bagLojas.etbcod.
    ttbaglistagem.codBag     = bagLojas.codBag.
    ttbaglistagem.consultor = baglojas.consultor.
    ttbaglistagem.catcod        = bagLojas.catcod.
    ttbaglistagem.pid     = bagLojas.pid.    
    ttbaglistagem.dtalt     = bagLojas.dtalt.
    ttbaglistagem.hralt     = bagLojas.hralt.
    ttbaglistagem.cpf   = baglojas.cpf.
    ttbaglistagem.nome  = baglojas.nome.
    
end.    
*/

find first ttbaglistagem no-error.
if avail ttbaglistagem
then hSaida = dataset conteudoSaida:HANDLE.
else do:
    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Nenhuma BAG Aberta".
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
