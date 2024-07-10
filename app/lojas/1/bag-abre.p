/* helio 102022 - BAG */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{loj/bagdefs.i new}

define dataset dadosEntrada for ttbag, ttcliente.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttnovabag no-undo serialize-name "conteudoSaida"
    field estabOrigem as int
    field idBag   as int
    field cpf      as dec decimals 0
    field datacriacao as char.




def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.

hEntrada = dataset dadosEntrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttbag no-error.
if not avail ttbag
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vetbcod = int(ttbag.estabOrigem).
find estab where estab.etbcod = vetbcod  no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab  then 500 else 404.
  ttsaida.descricaoStatus = "Estabelecimento de origem " + string(ttbag.estabOrigem)
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find first bagLojas where bagLojas.etbcod   = vetbcod and
                    baglojas.idbag    = 0 and /* inicialmente é zero */
                    bagLojas.cpf      = int64(ttbag.cpf) exclusive no-wait no-error.
if avail bagLoja
then do:

  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Cliente " + string(ttbag.cpf)
                 + " ja tem bag cadastrada.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


find first ttcliente.


create bagLojas.
ASSIGN
bagLojas.etbcod         = vetbcod.
baglojas.idbag          = 0.
baglojas.cpf         = ttcliente.cpf   .

baglojas.consultor      = int(ttbag.consultor).
bagLojas.dtinc          = today.
bagLojas.hrinc          = time.
bagLojas.catcod         = 0.
bagLojas.observacao     = "".
bagLojas.dtalt          = today.
bagLojas.hralt          = time.
bagLojas.pidUso         = int(ttbag.pid).
bagLojas.dtfec          = ?.

    baglojas.clicod      = ttcliente.clicod.
    baglojas.Nome        = ttcliente.Nome  .
    baglojas.celular     = ttcliente.celular.
    baglojas.cep         = ttcliente.cep    .
    baglojas.logradouro  = ttcliente.logradouro.
    baglojas.Numero      = ttcliente.Numero .
    baglojas.complemento = ttcliente.complemento.
    baglojas.bairro      = ttcliente.bairro .
    baglojas.cidade      = ttcliente.cidade .
    baglojas.ufecod      = ttcliente.estado.



create ttnovabag.
ttnovabag.estabOrigem  = bagLojas.etbcod.
ttnovabag.idBag        = bagLojas.idBag.
ttnovabag.cpf          = bagLojas.cpf.
ttnovabag.datacriacao  = string(year(bagLojas.dtinc)) + "-" + 
                         string(month(bagLojas.dtinc),"99") + "-" + 
                         string(day(bagLojas.dtinc),"99").
                                                                

hSaida = temp-table ttnovabag:HANDLE.

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
