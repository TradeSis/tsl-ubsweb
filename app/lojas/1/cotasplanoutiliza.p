/* #042023 helio libera plano */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "dadosEntrada" 
    field codigoFilial   as int
    field codigoPlano    as int.

def var vok as log.

{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}


DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttfincotaetb serialize-name "return" 
    field codigoFilial   as int
    field fincod        as int
    field dtivig        as date
    field dtfvig        as date
    field cotaslib      as int
    field cotasuso      as int.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vfincod    as int.


hEntrada = temp-table ttentrada:HANDLE.
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

vetbcod = int(ttentrada.codigoFilial).
find estab where estab.etbcod = vetbcod  no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab  then 500 else 404.
  ttsaida.descricaoStatus = "Estabelecimento de origem " + string(ttentrada.codigoFilial)
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vfincod = int(ttentrada.codigoPlano).
find finan where finan.fincod = vfincod no-lock no-error.
if not avail finan
then do:

  create ttsaida.
  ttsaida.tstatus = if locked fincotaetb then 500 else 404.
  ttsaida.descricaoStatus = "plano " + string(ttentrada.codigoPlano) 
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.
find first ttentrada.

create ttfincotaetb.
ttfincotaetb.codigoFilial = ttentrada.codigoFilial.
ttfincotaetb.fincod = ttentrada.codigoPlano.


find last fincotaetb where 
    fincotaetb.etbcod = int(ttentrada.codigoFilial) and
    fincotaetb.fincod = int(ttentrada.codigoPlano) and
    fincotaetb.dtivig <= today and
    (fincotaetb.dtfvig >= today or fincotaetb.dtfvig = ?) 
    exclusive no-wait no-error.
if avail fincotaetb
then do:
    fincotaetb.cotasuso = fincotaetb.cotasuso + 1.
    ttfincotaetb.dtivig       = fincotaetb.dtivig.
    ttfincotaetb.dtfvig       = fincotaetb.dtfvig.
    ttfincotaetb.cotaslib     = fincotaetb.cotaslib.
    ttfincotaetb.cotasuso     = fincotaetb.cotasuso.
    
end.


hSaida = temp-table ttfincotaetb:HANDLE.

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
