/* helio 022023 insert nop crediario admcom */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

DEFINE VARIABLE vstatus                            AS int.


def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field etbcod as char
    field codigoSeguro   as char.

{/admcom/progr/api/acentos.i}
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}
{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttdados NO-UNDO SERIALIZE-NAME "dados"
        field etbcod as char
        field codigoSeguro as char
        field tstatus as char serialize-name "status"
        field segnum as char.

hSaida = temp-table ttdados:HANDLE.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

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

/*
find neuclien where neuclien.cpfCnpj =  dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) exclusive no-wait no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod exclusive no-wait no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = if locked clien then 500 else 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfCnpj = ?
           then ""
           else ttentrada.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.
*/


create ttdados.
ttdados.etbcod       = ttentrada.etbcod.
ttdados.codigoSeguro = ttentrada.codigoSeguro.
ttdados.segnum       = "0".
ttdados.tstatus      = "500".

run /admcom/barramento/progr/buscacertificado.p ( input int(ttentrada.etbcod),
                                                  input ttentrada.codigoSeguro,
                                                  output ttdados.segnum,
                                                  output vstatus).

ttdados.tstatus = string(vstatus).

lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson and vstatus = 200
then do:
      
        put unformatted trim(string(vlcsaida)).
end.
else do:
    create ttsaida.
    ttsaida.tstatus = vstatus.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
