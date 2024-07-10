/*VERSAO 2 23062021*/

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.

def var vconta as int.
def var vx as int.
/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

/* SAIDA */

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'creditoCliente'
    field tipo    as char format "x(18)"
    field clicod    as int64 serialize-name 'codigoCliente'
    field cpfCNPJ    as char format "x(18)"    serialize-name 'cpfCNPJ'
    field clinom    as char format "x(40)" serialize-name 'nomeCliente'
    field limite      as char format "x(20)"
    field vctoLimite  as char format "x(30)"
    field comprometido as char format "x(30)"
    field saldoLimite  as char format "x(30)"
    index cli is unique primary clicod asc tipo desc.

DEFINE DATASET conteudoSaida FOR ttclien.

hSaida = DATASET conteudoSaida:HANDLE.
def var lokjson as log.

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

    def var vvlrlimite  as dec.
    def var vvlrdisponivel as dec.
    def var vvctolimite as date.
    def var var-salaberto-principal as dec.
    def var var-salaberto-principalEP as dec.

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

find neuclien where neuclien.cpfCnpj =  dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfCnpj = ?
           then ""
           else ttentrada.cpfCnpj) + " Não cadastrado ".
          

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

def var pstatus as char.
def var pmensagem as char.

def new global shared var setbcod       as int.
setbcod = 200.

run neuro/chamamotorp2.p (neuclien.cpf, "", setbcod, output pstatus, output pmensagem).

    
  find current neuclien no-lock.

  create ttclien.
  ttclien.tipo   = "Global".
  ttclien.clicod = clien.clicod.
  ttclien.clinom = clien.clinom.
  ttclien.cpfCnpj = string(neuclien.cpf).

  vvlrlimite = 0.
  vvctolimite = ?.
  vvlrdisponivel = 0.

  if avail neuclien
  then do:
      vvlrlimite = if neuclien.vctolimite < today
                  then 0
                  else neuclien.vlrlimite.
      vvctolimite = neuclien.vctolimite.
  end.
      ttclien.vctoLimite  =  string(year(vvctolimite),"9999") + "-" +
                            string(month(vvctolimite),"99")   + "-" +
                            string(day(vvctolimite),"99").
      ttclien.Limite   = trim(string(vvlrLimite,">>>>>>>>>>>>>>>>>>9.99")).

      var-propriedades = "" .

      run /admcom/progr/neuro/limites.p (neuclien.cpfcnpj,   output var-propriedades).
        
      var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
      if var-salaberto-principal = ? then var-salaberto-principal = 0.

      vvlrdisponivel = vVlrLimite - var-salaberto-principal.
      if vvlrdisponivel < 0
      then vvlrdisponivel = 0.

      ttclien.comprometido   = trim(string(var-salaberto-principal,">>>>>>>>>>>>>>>>>>9.99")).
      ttclien.saldoLimite    = trim(string(vvlrdisponivel,">>>>>>>>>>>>>>>>>>9.99")).


      create ttclien.
      ttclien.tipo   = "EP".
      ttclien.clicod = clien.clicod.
      ttclien.clinom = clien.clinom.
      ttclien.cpfCnpj = string(neuclien.cpf).

      vvlrlimite = dec(pega_prop("LIMITEEP")).
      var-salaberto-principalEP = dec(pega_prop("LIMITETOMPREP")).
      vvlrdisponivel = dec(pega_prop("LIMITEDISPEP")).

          ttclien.vctoLimite  =  string(year(vvctolimite),"9999") + "-" +
                                string(month(vvctolimite),"99")   + "-" +
                                string(day(vvctolimite),"99").
          ttclien.Limite   = trim(string(vvlrLimite,">>>>>>>>>>>>>>>>>>9.99")).

          ttclien.comprometido   = trim(string(var-salaberto-principalEP,">>>>>>>>>>>>>>>>>>9.99")).
          ttclien.saldoLimite    = trim(string(vvlrdisponivel,">>>>>>>>>>>>>>>>>>9.99")).



lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted string(vlcsaida).
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
