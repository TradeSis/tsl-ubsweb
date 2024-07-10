/* helio 07062023 Desconto de funcion�rio no Lebes Bag. */
/* helio 102022 - BAG  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/loj/bagdefs.i new}

def temp-table ttentrada no-undo serialize-name "bag"
    field estabOrigem as int
    field idbag       as int
    field cpf         as dec decimals 0
    field pid         as int.
    
define dataset dadosEntrada for ttentrada.


{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */



DEFINE VARIABLE lokJSON                  AS LOGICAL.

define dataset conteudoSaida for ttbag, ttitens.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vetbdest as int.

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

if bagLojas.pid <> 0 and 
   int(ttentrada.pid) <> bagLojas.pid and 
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

bagLojas.pid            = int(ttentrada.pid).
bagLojas.dtalt          = today.
bagLojas.hralt          = time.

for each bagprodu of baglojas no-lock.
    create ttitens.  
    ttitens.sequencial    = bagprodu.seq.
    ttitens.codigoProduto = bagprodu.procod.
    ttitens.quantidade    = bagprodu.qtd.
    ttitens.quantidadeConvertida = bagprodu.quantidadeConvertida.
      
    find produ where produ.procod = bagprodu.procod no-lock no-error.
  
  ttitens.quantidade       = bagprodu.qtd.
  ttitens.valorUnitario = bagprodu.valorUnitario.
  ttitens.descontoProduto = bagprodu.descontoProduto. /* helio 07062023 + */
  ttitens.valorTotal    = bagprodu.valorTotal.
  ttitens.descricao    = if avail produ then removeAcento(produ.pronom) else "-".
    
end.

create ttbag.
ttbag.estabOrigem       = bagLojas.etbcod.
ttbag.idBag             = baglojas.idBag.
ttbag.cpf               = dec(baglojas.cpf).
ttbag.consultor         = baglojas.consultor.
ttbag.categoria         = bagLojas.catcod.
ttbag.pid               = ttentrada.pid.
ttbag.nome              = baglojas.nome.
ttbag.dtfec = baglojas.dtfec.
    ttbag.datacriacao  = string(year(bagLojas.dtinc)) + "-" + 
                             string(month(bagLojas.dtinc),"99") + "-" + 
                             string(day(bagLojas.dtinc),"99").
    ttbag.datasaida    = string(year(bagLojas.dtfec)) + "-" + 
                             string(month(bagLojas.dtfec),"99") + "-" + 
                             string(day(bagLojas.dtfec),"99").


hSaida = dataset conteudoSaida:HANDLE.

def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apilojasbagresgata" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
os-command value("rm -f " + varquivo).


