/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.
{/admcom/progr/api/acentos.i}

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

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field tipoPessoa as char
        field codigoCliente as char
        field nome as char
        field cpfCnpj as char
        field celular as char
        field email as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttendereco NO-UNDO SERIALIZE-NAME "endereco"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field cep as char
        field logradouro as char
        field numero as char
        field complemento as char
        field bairro as char
        field cidade as char
        field uf as char
 index x is unique primary idpai asc id asc.


DEFINE DATASET conteudoSaida FOR ttcliente, ttendereco
   DATA-RELATION for3 FOR ttcliente, ttendereco       RELATION-FIELDS(ttcliente.id,ttendereco.idpai) NESTED.


hSaida = DATASET conteudoSaida:HANDLE.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.


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
           else ttentrada.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
find carro where carro.clicod = clien.clicod no-lock no-error.

    var-propriedades = "" .

    run /admcom/progr/neuro/comportamento.p (clien.clicod, ?,   output var-propriedades).

    var-salaberto = dec(pega_prop("LIMITETOM")).
    if var-salaberto = ? then var-salaberto = 0.

    var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
    if var-salaberto-principal = ? then var-salaberto-principal = 0.

    var-salaberto-hubseg = dec(pega_prop("LIMITETOMHUBSEG")).
    if var-salaberto-hubseg = ? then var-salaberto-hubseg = 0.


            vvctoLimite  = if avail neuclien
                           then neuclien.vctolimite
                           else ?.
            vvlrLimite   = if vvctolimite = ? or vvctolimite < today
                           then 0
                           else neuclien.vlrlimite.
            vvlrdisponivel = vVlrLimite - var-salaberto-principal - var-salaberto-hubseg.
            if vvlrdisponivel < 0
            then vvlrdisponivel = 0.


create ttcliente.
         ttcliente.id = "1".

         ttcliente.tipoPessoa =   string(clien.tippes,"F/J").

         codigoCliente = string(clien.clicod).
         ttcliente.nome = removeacento(clien.clinom).
         ttcliente.cpfCnpj = clien.ciccgc.

         ttcliente.celular   = Texto(clien.FAX).
         ttcliente.email     = texto(clien.zona).
         

create ttendereco.
        ttendereco.id = ttcliente.id + ".1".
        ttendereco.idpai = ttcliente.id.
        ttendereco.cep   = Texto(clien.cep[1]).
        ttendereco.logradouro   = Texto(clien.endereco[1]).
        ttendereco.numero   = texto(string(clien.numero[1])).
        ttendereco.complemento   = Texto(clien.compl[1]).
        ttendereco.bairro   = Texto(clien.bairro[1]).
         ttendereco.cidade   = Texto(clien.cidade[1]).
         ttendereco.uf   = Texto(clien.ufecod[1]).




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
