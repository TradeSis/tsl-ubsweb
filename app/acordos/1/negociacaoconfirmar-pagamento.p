/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.

def var precmov as recid.
def var vnovacao as log.
def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

def var vidacordo as int.
def var vvalor as dec.

{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */
def var vmessage as log.
vmessage = no.

{aco/acordo.i new}

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field cpfCnpj as char
        field formaPagamento as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttnegociacaoSelecionada NO-UNDO SERIALIZE-NAME "negociacaoSelecionada"
        field idNegociacao   as char /* " : "0016949483", */
        field idCondicao   as char.

DEFINE DATASET negociacaoPagamento FOR ttcliente, ttnegociacaoSelecionada.

def temp-table ttmovimento serialize-name "formaPagamento"
    field nsu   as char
    field idAcordo  as char.

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


hEntrada = DATASET negociacaoPagamento:HANDLE.

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

run cob/ajustanovacordo.p (input clien.clicod, output p-temacordo).

find first ttnegociacaoSelecionada. 

run calcelegiveis ("ACORDO ONLINE", clien.clicod,  int(ttnegociacaoSelecionada.idNegociacao)).


find first ttnegociacao where ttnegociacao.negcod = int(ttnegociacaoSelecionada.idNegociacao) no-error.

if not avail ttnegociacao
then do:

    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Negociacao " + ttnegociacaoSelecionada.idNegociacao + " Nao encontrada.".

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
    AoAcordo.VlAcordo   = vvalor.
    AoAcordo.VlOriginal = vvalor.
    AoAcordo.HrAcordo   = time.
    AoAcordo.DtEfetiva  = ?.
    AoAcordo.HrEfetiva  = ?.
    aoAcordo.negcod     = ttnegociacao.negcod.
    aoAcordo.placod     = int(ttnegociacaoSelecionada.idCondicao).

    for each ttcontrato  where ttcontrato.negcod = ttnegociacao.negcod.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.
        
        for each titulo where titulo.empcod = 19 and titulo.titnat = no and
          titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
          titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
          and titulo.titsit = "LIB"
          no-lock
          by titulo.titdtven by titulo.titpar .

            vjuros = 0.
            if titulo.titdtven < today
            then do:
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                            titulo.titdtven,
                            titulo.titvlcob,
                            output vjuros).

            end.
            if aoacordo.etbcod = 0
            then aoacordo.etbcod = contrato.etbcod.

            create AoAcOrigem.
            AoAcOrigem.IDAcordo = AoAcordo.IDAcordo.
            AoAcOrigem.contnum  = contrato.contnum.
            AoAcOrigem.titpar   = titulo.titpar.
            AoAcOrigem.vlcob    = titulo.titvlcob.
            AoAcOrigem.vljur    = vjuros.
            AoAcOrigem.vltot    = titulo.titvlcob + vjuros.
    
        end.
        
    end.

    for each ttcondicoes.
        delete ttcondicoes.
    end.  
    for each ttparcelas.
        delete ttparcelas.
    end.  
    run montacondicoes (input ttnegociacao.negcod, int(ttnegociacaoSelecionada.idCondicao)).
    vnovacao = no.
    for each ttcondicoes where ttcondicoes.negcod = ttnegociacao.negcod and
                             ttcondicoes.placod = int(ttnegociacaoSelecionada.idCondicao).
      
        find acoplanos where
          acoplanos.negcod  = ttcondicoes.negcod and
          acoplanos.placod  = ttcondicoes.placod
          no-lock.
   
        for each ttParcelas where ttparcelas.negcod = ttnegociacao.negcod and
                                ttparcelas.placod = ttcondicoes.placod
            by  ttParcelas.titpar.

    
            create aoacparcela.          
            AoAcParcela.IDAcordo     = aoAcordo.IDAcordo. 
            AoAcParcela.contnum      = ?. /* na Efetivacao */
            AoAcParcela.Parcela      = ttParcelas.titpar.
            AoAcParcela.DtVencimento = ttparcelas.dtvenc.
            AoAcParcela.VlCobrado    = ttparcelas.vlr_parcela.
            AoAcParcela.dtBaixa      = ?.
            AoAcParcela.Situacao     = "A".
            AoAcParcela.DtEnvio      = ?.
            AoAcParcela.Enviar       = no.
            AoAcParcela.VlJuros      = 0.
            if AoAcParcela.Parcela > 0
            then vnovacao = yes.        
        end.            
        
    end.
end.

if vnovacao
then do:
    run aco/pnegconfpgnovacao.p   (output precmov, input ttcliente.formaPagamento, aoacordo.idacordo).
end.
else do:
    run aco/pnegconfpgtovista.p (output precmov, input ttcliente.formaPagamento, aoacordo.idacordo).
end.

find pdvmov where recid(pdvmov) = precmov no-lock no-error.

if avail pdvmov
then do:
    create ttmovimento.
    ttmovimento.nsu = string(pdvmov.Sequencia).
    ttmovimento.idAcordo = string(vidacordo).

    hSaida = temp-table ttmovimento:HANDLE.

    varquivo  = "/u/bsweb/works/apiacordosnegociacaoconfirmar-pagamento" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
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



