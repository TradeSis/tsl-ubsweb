/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.
def var vidacordo as int64.

{/admcom/progr/api/acentos.i}

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
       
        field cpfCnpj as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelasSelecionadas"
        field numero_contrato   as char /* " : "0016949483", */
        field filial_contrato   as char
        field seq_parcela as char
        field   venc_parcela as char    
        field vlr_parcela as char
        field valor_encargos as char
        field valor_total as char.


DEFINE DATASET parcelasBoleto FOR ttcliente, ttparcelas.

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


hEntrada = DATASET parcelasBoleto:HANDLE.

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


vdtvencimento = ?. 
vvalor        = 0.
for each ttparcelas.
    if vdtvencimento = ? then do:
            vdtvencimento = date(int(entry(2,ttparcelas.venc_parcela,"-")),int(entry(3,ttparcelas.venc_parcela,"-")),
                                    int(entry(1,ttparcelas.venc_parcela,"-"))).
    end.    
   vvalor = vvalor + dec(ttparcelas.valor_total).
end.
if vdtvencimento = ? then vdtvencimento = today.

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


do on error undo:
  find last AoAcordo no-lock no-error.
  vIdAcordo = if avail AoAcordo then aoAcordo.IDAcordo + 1 else 1.
  create AoAcordo.
  AoAcordo.IDAcordo   = vidAcordo.
end.  

run bol/geradadosboleto.p (
      input 104, /* Banco do Boleto */
      input ?,      /* Bancarteira especifico */
      input "api/acordo,parcelasboleto",
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
    
    find current aoacordo exclusive.
    AoAcordo.CliFor     = clien.clicod.
    AoAcordo.DtAcordo   = today.
    AoAcordo.Situacao   = "A".
    AoAcordo.VlAcordo   = vvalor.
    AoAcordo.VlOriginal = vvalor.
    AoAcordo.HrAcordo   = time.
    AoAcordo.DtEfetiva  = ?.
    AoAcordo.HrEfetiva  = ?.

    aoAcordo.bancod      = banboleto.bancod.
    aoAcordo.nossoNumero = banboleto.nossoNumero.
    aoAcordo.negcod      = ?.
    aoAcordo.placod      = ?.
    aoacordo.tipo        = "api/acordo,parcelasboleto".
       
    for each ttparcelas.
        find contrato where contrato.contnum = int(ttparcelas.numero_contrato) no-lock.
        par-tabelaorigem = aoacordo.tipo.
        par-chaveOrigem  = "idacordo,contnum,titpar".
        par-dadosOrigem  = trim(string(AoAcordo.IDAcordo)) + "," + 
                           trim(string(int(ttparcelas.numero_contrato))) + "," +
                           trim(string(int(ttparcelas.seq_parcela))).
        par-valorOrigem  = dec(ttparcelas.valor_total).

        run bol/vinculaboleto.p (
                input recid(banBoleto),
                input par-tabelaorigem,
                input par-chaveorigem,
                input par-dadosorigem,
                input par-valorOrigem,
                output xstatus,
                output vmensagem_erro).
        if xstatus <> "S"
        then vstatus = "N".
        else do:
            vstatus = "S".
            
            if aoacordo.etbcod = 0
            then aoacordo.etbcod = contrato.etbcod.

            create AoAcOrigem.
            AoAcOrigem.IDAcordo = AoAcordo.IDAcordo.
            AoAcOrigem.contnum  = int(ttparcelas.numero_contrato).
            AoAcOrigem.titpar   = int(ttparcelas.seq_parcela).
            AoAcOrigem.vlcob    = dec(ttparcelas.vlr_parcela).
            AoAcOrigem.vljur    = dec(ttparcelas.valor_encargos).
            AoAcOrigem.vltot    = dec(ttparcelas.valor_total).
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

varquivo  = "/u/bsweb/works/apiacordosparcelasboleto" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
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


