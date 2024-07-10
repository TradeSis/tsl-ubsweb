/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.

def var vdtvencimento as date.
def var vvalor        as dec.
def var par-recid-boleto    as recid.
def var vstatus as char.
def var xstatus as char.
def var vmensagem_erro  as char.
def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.
def var vidacordo as int.
def var vassociado as log.

{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def var xtime as int.

def var vmessage as log.
vmessage = no.

{aco/acordo.i new}

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field cpfCnpj as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttnegociacaoSelecionada NO-UNDO SERIALIZE-NAME "negociacaoSelecionada"
        field idNegociacao   as char /* " : "0016949483", */
        field idCondicao   as char.

DEFINE DATASET negociacaoBoleto FOR ttcliente, ttnegociacaoSelecionada.

def temp-table ttboleto serialize-name "boleto"
    field Banco as char
    field Agencia as char
    field codigoCedente as char
    field contaCorrente as char
    field Carteira as char
    field nossoNumero   as char
    field DVnossoNumero as char
    field dtEmissao as char
    field dtVencimento as char
    field fatorVencimento as char
    field numeroDocumento as char
    field CNPJ_CPF as char
    field sacadoNome as char
    field sacadoEndereco as char
    field sacadoCEP as char
    field sacadoCidade as char
    field sacadoUF as char
    field linhaDigitavel as char
    field codigoBarras as char
    field VlPrincipal as char.


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


hEntrada = DATASET negociacaoBoleto:HANDLE.

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

    /* helio 27042023 - fixo today + 3, cuidando se for final de semana */
    /* helio 23/05/2023 - trocar o vencimento para 10 dias.
    vdtvencimento = today + 3. 
    */
    vdtvencimento = today + 7. /*Helio 27/05/2024 */ 

    if weekday(vdtvencimento) = 7 /* sabado */ 
    then vdtvencimento = vdtvencimento + 2.
    if weekday(vdtvencimento) = 1 /* domingo */ 
    then vdtvencimento = vdtvencimento + 1.

    for each ttcondicoes.
        delete ttcondicoes.
    end.  
    for each ttparcelas.
        delete ttparcelas.
    end.  
    run montacondicoes (input ttnegociacao.negcod, int(ttnegociacaoSelecionada.idCondicao)).
    find first ttcondicoes where ttcondicoes.negcod = ttnegociacao.negcod and
                             ttcondicoes.placod = int(ttnegociacaoSelecionada.idCondicao)
                             no-error.
 
vvalor        = if avail ttcondicoes
                then ttcondicoes.vlr_entrada
                else 0.


if vdtvencimento < today
then do:

    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Data Vencimento Invalida".
    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.

end.
if vvalor <= 0
then do:

    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Somatório de Parcelas Invalido".
    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.

end.

find last AoAcordo no-lock no-error.
    
vIdAcordo = if avail AoAcordo then aoAcordo.IDAcordo + 1 else 1.


run bol/geradadosboleto.p (
      input 104, /* Banco do Boleto */
      input ?,      /* Bancarteira especifico */
      input "api/acordo,negociacaoboleto",
      input clien.clicod,
      input "Acordo: " + string(vidAcordo),
      input vdtvencimento,
      input vvalor,
      input 0,
      output par-recid-boleto,
      output vstatus,
      output vmensagem_erro).

find banBoleto where recid(banBoleto) = par-recid-boleto no-lock
no-error.
if vstatus <> "S"
then do:
  create ttsaida.
  ttsaida.tstatus = 500.
  ttsaida.descricaoStatus = vmensagem_erro.
end.

if banboleto.bancod = 104
then do:
    run api/barramentoemitir.p 
            (recid(banboleto),  
                output vstatus , 
                output vmensagem_erro).
    if vstatus <> "S"
    then do:
      create ttsaida.
      ttsaida.tstatus = 500.
      ttsaida.descricaoStatus = vmensagem_erro.
    end.
end.
else do:
  create ttsaida.
  ttsaida.tstatus = 500.
  ttsaida.descricaoStatus = "BANCO NAO HOMOLOGADO".
  vstatus = "N".
end.

if vstatus = "S"
then do on error undo:

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

    aoAcordo.bancod      = banboleto.bancod.
    aoAcordo.nossoNumero = banboleto.nossoNumero.
    aoacordo.tipo        = "api/acordo,negociacaoboleto".

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
        
            if AoAcParcela.Parcela = 0
            then do:
                par-tabelaorigem = "api/acordo,negociacaoboleto".
                par-chaveOrigem  = "idacordo,parcela".
                par-dadosOrigem  = string(aoacparcela.idacordo) + "," +
                              string(aoacparcela.parcela).
                par-valorOrigem  = AoAcParcela.VlCobrado.
                run bol/vinculaboleto.p (
                      input recid(banBoleto),
                      input par-tabelaorigem,
                      input par-chaveorigem,
                      input par-dadosorigem,
                      input par-valorOrigem,
                      output xstatus,
                      output vmensagem_erro).      
                if xstatus <> "S"
                then do:
                    create ttsaida.
                    ttsaida.tstatus = 500.
                    ttsaida.descricaoStatus = vmensagem_erro.
                    vstatus = "N".
                    leave.
                end.
                else do:
                    vstatus = "S".                                   
                end.
            end.
        end.            
        
    end.
end.

if vstatus = "S"
then do: 
    find banco where banco.bancod = banboleto.bancod no-lock. 
    find banCarteira of banBoleto no-lock.

    create ttboleto.
    ttboleto.Banco           = string(banco.numban).
    ttboleto.Agencia         = string(banboleto.agencia).
    ttboleto.codigoCedente   = banCarteira.banCedente.
    ttboleto.contaCorrente   = string(banboleto.contacor).
    ttboleto.Carteira        = banboleto.banCart.
    ttboleto.nossoNumero     = banboleto.impnossonumero.
    ttboleto.DVnossoNumero   = string(banBoleto.DvNossoNumero).
    ttboleto.dtEmissao       = string(month(banboleto.dtemissao),"99") +
                              string(day(  banboleto.dtemissao),"99") +
                              string(year(banboleto.dtemissao ),"9999").
    ttboleto.dtVencimento    = string(month(banboleto.dtvencimento),"99") +
                              string(day(  banboleto.dtvencimento),"99") +
                              string(year(banboleto.dtvencimento ),"9999"). 
    ttboleto.fatorVencimento = string(banboleto.fatorVencimento,"9999").
    ttboleto.numeroDocumento = banboleto.Documento.
    ttboleto.CNPJ_CPF        = clien.ciccgc.
    ttboleto.sacadoNome      = removeacento(clien.clinom).
    ttboleto.sacadoEndereco  = removeacento(clien.endereco[1]).
    ttboleto.sacadoCEP       = string(clien.cep[1],"99999999").
    ttboleto.sacadoCidade    = removeacento(string(clien.cidade[1])).
    ttboleto.sacadoUF        = string(clien.uf[1]).
    ttboleto.linhaDigitavel  = banboleto.linhaDigitavel.
    ttboleto.codigoBarras    = banboleto.codigoBarras.
    ttboleto.VlPrincipal     = trim(string(banboleto.vlCobrado,">>>>>>>9.99")).

end.
else do:
    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
      

hSaida = temp-table ttboleto:HANDLE.


def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apiacordosnegociacaoboleto" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).
if lokJson
then do:
    os-command value("cat " + varquivo).
    os-command value("rm -f " + varquivo).
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


