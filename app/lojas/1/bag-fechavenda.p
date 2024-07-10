/* helio 07062023 Desconto de funcion�rio no Lebes Bag. */
/* helio 102022 - BAG  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/loj/bagdefs.i new}

def temp-table ttentrada serialize-name "bag" like ttbag.

define dataset dadosEntrada for ttentrada, ttitens.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttitenssaida serialize-name "itens" 
    field sequencial as char
    field codigoProduto   as char
    field descricao     as char
    field quantidade    as char
    field valorUnitario as char
    field descontoProduto as char /* helio 07062023 */
    field valorTotal    as char
    field mercadologico as char
    field quantidadeConvertida as char.

define dataset conteudoSaida for ttbag, ttitenssaida.


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
                    exclusive no-wait no-error.
if not avail bagLoja
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab then 500 else 404.
  ttsaida.descricaoStatus = "bag " + string(ttentrada.idbag) + " / CPF " + string(ttentrada.cpf,"99999999999")
                 + " Não encontrada.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.



if int(ttentrada.pid) <> bagLojas.pid and 
   bagLojas.dtfec  = ? and
   bagLojas.dtalt    = today and
   bagLojas.hralt    >= time - (60 * 15)
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab then 500 else 404.
  ttsaida.descricaoStatus = "bag sendo Usada por outro Terminal - aguarde " + string((60 * 15) - (time - bagLojas.hralt), "HH:MM:SS").

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

bagLojas.catcod         = int(ttentrada.categoria).
bagLojas.pid            = 0.
bagLojas.dtalt          = today.
bagLojas.hralt          = time.

baglojas.dtvenda = today.

for each bagprodu of baglojas.
  delete bagprodu.
end.

for each ttitens. 

  create bagprodu.
  bagprodu.etbcod   = baglojas.etbcod.
  bagprodu.idbag    = baglojas.idbag.
  bagprodu.cpf      = baglojas.cpf.
  bagprodu.procod   = ttitens.codigoProduto.
  bagprodu.qtd      = ttitens.quantidade.
  bagprodu.seq      = ttitens.sequencial.
  bagprodu.valorUnitario = ttitens.valorUnitario.
  bagprodu.descontoProduto = ttitens.descontoProduto. /* helio 07062023 */
  bagprodu.valorTotal    = ttitens.valorTotal.
  bagprodu.quantidadeConvertida = ttitens.quantidadeConvertida.  
  
  find produ where produ.procod = bagprodu.procod no-lock no-error.
  
  create ttitenssaida.
  ttitenssaida.sequencial       = string(bagprodu.seq).
  ttitenssaida.codigoProduto    = string(bagprodu.procod).
  ttitenssaida.quantidade       = string(bagprodu.qtd).
  ttitenssaida.valorUnitario = trim(string(bagprodu.valorUnitario,">>>>>>>>>>>>>>>>>>>>9.99")).
  ttitenssaida.descontoProduto = trim(string(bagprodu.descontoProduto,">>>>>>>>>>>>>>>>>>>>9.99")). /* helio 07062023 */
  ttitenssaida.valorTotal    = trim(string(bagprodu.valorTotal,">>>>>>>>>>>>>>>>>>>>9.99")).
  ttitenssaida.descricao    = if avail produ then removeAcento(produ.pronom) else "-".
  ttitenssaida.quantidadeconvertida = string(bagprodu.quantidadeConvertida).
    
end.

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
                             string(day(bagLojas.dtinc),"99") + " " + string(baglojas.hrinc,"HH:MM:SS").
    ttbag.datasaida    = string(year(today)) + "-" + 
                             string(month(today),"99") + "-" + 
                             string(day(today),"99") + " " + string(time,"HH:MM:SS").


create ttcliente.
ttcliente.clicod        = baglojas.clicod.
ttcliente.nome          = baglojas.nome.
ttcliente.cpf           = baglojas.cpf.
ttcliente.cep           = baglojas.cep.
ttcliente.logradouro    = baglojas.logradouro.
ttcliente.numero        = baglojas.numero.
ttcliente.complemento   = baglojas.complemento.
ttcliente.bairro        = baglojas.bairro.
ttcliente.cidade        = baglojas.cidade.
ttcliente.estado        = baglojas.ufecod.
ttcliente.email         = baglojas.email.
ttcliente.celular       = baglojas.celular.


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
