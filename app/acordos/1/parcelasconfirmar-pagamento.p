/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.

def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.
def var vidacordo as int.

def var precmov as recid.

{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.
def var vvalor as dec.
def var vstatus as char.

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field cpfCnpj as char
        field formaPagamento as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelasSelecionadas"
        field numero_contrato   as char /* " : "0016949483", */
        field filial_contrato   as char
        field seq_parcela as char
        field   venc_parcela as char    
        field vlr_parcela as char
        field valor_encargos as char
        field valor_total as char.


DEFINE DATASET parcelasPagamento FOR ttcliente, ttparcelas.

def new shared temp-table ttpdvdoc no-undo
    field contnum   like contrato.contnum
    field titpar    like titulo.titpar
    field titvlcob  as dec
    field encargos as dec
    field vlrtotal as dec.
    

def temp-table ttmovimento serialize-name "formaPagamento"
    field nsu   as char
    field idAcordo as char.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.

def var vqtdParcelas as int.
def var vvlrParcelas as dec.
def var vvlrJuros   as dec.
def var vjuros       as dec.


hEntrada = DATASET parcelasPagamento:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttcliente no-error.
if not avail ttcliente
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find neuclien where neuclien.cpfCnpj =  dec(ttcliente.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttcliente.cpfCnpj) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttcliente.cpfCnpj = ?
           then ""
           else ttcliente.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find last AoAcordo no-lock no-error.
    
vIdAcordo = if avail AoAcordo then aoAcordo.IDAcordo + 1 else 1.

do on error undo:

    create AoAcordo.
    AoAcordo.IDAcordo   = vidAcordo.
    AoAcordo.CliFor     = clien.clicod.
    AoAcordo.DtAcordo   = today.
    AoAcordo.Situacao   = "A".
    AoAcordo.HrAcordo   = time.
    AoAcordo.DtEfetiva  = ?.
    AoAcordo.HrEfetiva  = ?.
    aoAcordo.bancod      = ?.
    aoAcordo.nossoNumero = ?.
    aoAcordo.negcod      = ?.
    aoAcordo.placod      = ?.
    aoacordo.tipo        = "api/acordos,parcelaspagamento".

end.

vvalor        = 0.
for each ttparcelas.
    
    create ttpdvdoc.
    ttpdvdoc.contnum    =   int(ttparcelas.numero_contrato).
    ttpdvdoc.titpar     =   int(ttparcelas.seq_parcela).
    ttpdvdoc.titvlcob   =   dec(ttparcelas.vlr_parcela).
    ttpdvdoc.encargos   =   dec(ttparcelas.valor_encargos).
    ttpdvdoc.vlrtotal   =   dec(ttparcelas.valor_total).
      
    vvalor = vvalor + ttpdvdoc.vlrtotal.
    find contrato where contrato.contnum = int(ttparcelas.numero_contrato) no-lock.
    if aoacordo.etbcod = 0
    then aoacordo.etbcod = contrato.etbcod.

    create AoAcOrigem.
    AoAcOrigem.IDAcordo = AoAcordo.IDAcordo.
    AoAcOrigem.contnum  = ttpdvdoc.contnum .
    AoAcOrigem.titpar   = ttpdvdoc.titpar.
    AoAcOrigem.vlcob    = ttpdvdoc.titvlcob.
    AoAcOrigem.vljur    = ttpdvdoc.encargos.
    AoAcOrigem.vltot    = ttpdvdoc.vlrtotal.

end.

if vvalor <= 0
then do:

    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Somatorio de Parcelas Invalido".
    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.

end.


run aco/pgerapgtoparcela.p (output precmov, input ttcliente.formaPagamento, vidacordo).


find pdvmov where recid(pdvmov) = precmov no-lock no-error.

if avail pdvmov
then do:
    find aoacordo where AoAcordo.IDAcordo   = vidAcordo.
    AoAcordo.DtEfetiva  = today.
    AoAcordo.HrEfetiva  = time.
    AoAcordo.VlAcordo   = vvalor.
    AoAcordo.VlOriginal = vvalor.
    
    aoacordo.Situacao    = "F".
    aoacordo.ctmcod      = pdvmov.ctmcod.
    aoacordo.etbcod      = pdvmov.etbcod.
    aoacordo.cmocod      = pdvmov.cmocod.
    aoacordo.Sequencia   = pdvmov.Sequencia.
    
    create ttmovimento.
    ttmovimento.nsu = string(pdvmov.Sequencia).
    ttmovimento.idAcordo = string(vidacordo).

    hSaida = temp-table ttmovimento:HANDLE.

    varquivo  = "/u/bsweb/works/apiacordosparcelasconfirmar-pagamento" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

    lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE) no-error.
    if lokJson
    then do:
        os-command value("cat " + varquivo).
      /*  os-command value("rm -f " + varquivo). */
    end.
    else do:
        hsaida  = temp-table ttsaida:handle.

       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
    end.
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 500.
    ttsaida.descricaoStatus = "Erro na Geracao do Movimento".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.


