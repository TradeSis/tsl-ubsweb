def input param vlcentrada as longchar. /* JSON ENTRADA */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */

/* MODELO DADOS ENTRADA
{
  "document": "23599482020",
  "offerId": "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "agreementId": "123456",
  "instalment": 1,
  "dueDate": "2024-08-19",
  "agreementTotal": 5000.99,
  "agreementDate": "2021-07-19T16:01:02.636721",
  "paymentMethod": "pix"
}
MODELO DADOS SAIDA 
{
  "offerId": "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "agreementId": "123456",
  "dueDate": "2024-08-19",
  "instalment": 1,
  "instalmentValue": 400.55,
  "paymentMethod": "pix",
  "barCode": "890380038252042154496331179319333330979032437256",
  "digitLine": "770098015294047064053168524816282381253613215287",
  "base64": "JVBERi0xLjQNCiWqq6ytD[generic_base64]==",
  "pixCode": "00020126360014BR.GOV.BCB.PIX01143690558600018052040000530398654074000.005802BR5912QA TEST LTDA6009SAO PAULO62160512PAGAMENTO1QA6304EF69",
  "qrCode": "983874277584054862353623720346605218569864170938"
}
*/

def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char serialize-name "document"
   field offerId         as char serialize-name "offerId"
   field agreementId     as char serialize-name "agreementId"
   field instalment      as dec serialize-name "instalment"
   field dueDate         as char serialize-name "dueDate"
   field agreementTotal  as char serialize-name "agreementTotal"
   field agreementDate   as char serialize-name "agreementDate"
   field paymentMethod   as char serialize-name "paymentMethod".

def temp-table ttpagamento  no-undo serialize-name "pagamento"  /* JSON SAIDA */
    field offerId   as CHAR serialize-name "offerId"
    field agreementId   as CHAR serialize-name "agreementId"
    field dueDate   as DATE serialize-name "dueDate"
    field instalment   as dec serialize-name "instalment"
    field instalmentValue   as dec serialize-name "instalmentValue"
    field paymentMethod   as CHAR serialize-name "paymentMethod"
    field barCode   as CHAR serialize-name "barCode"
    field digitLine   as CHAR serialize-name "digitLine"
    field vbase64   as CHAR serialize-name "base64"
    field pixCode   as CHAR serialize-name "pixCode"
    field qrCode   as CHAR serialize-name "qrCode".


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"  /* JSON SAIDA CASO ERRO */
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.


hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY") no-error.

find first ttentrada no-error.
if not avail ttentrada
then do:
    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Dados de Entrada Invalidos".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.


def var ptpnegociacao as char.
def var par-clicod like clien.clicod.
def var vmessage as log.

find neuclien where neuclien.cpf = dec(ttentrada.document) no-lock no-error.
if not avail neuclien
then do:
     find first clien where clien.ciccgc = ttentrada.document no-lock no-error.
end.
else do:
     find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.
if not avail clien
then do:
     create ttsaida.
     ttsaida.tstatus = 400.
     ttsaida.descricaoStatus = "Dados de Entrada Invalidos".

     hsaida  = temp-table ttsaida:handle.

     lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
     message string(vlcSaida).
     return.
end.
ptpnegociacao = "SERASA".
vmessage = no.

{acha.i}
{aco/acordo.i new} 

def var vdtvencimento as date.
def var vvalor        as dec.
DEF VAR vjuros AS DEC.

find aconegcli where aconegcli.clicod = clien.clicod and
                     aconegcli.id     = ttentrada.offerId 
   no-error.
if not avail aconegcli
then do:
   create ttsaida.
   ttsaida.tstatus = 400.
   ttsaida.descricaoStatus = "Oferta Invalida".

   hsaida  = temp-table ttsaida:handle.

   lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
   message string(vlcSaida).
   return.

end.        
else do:
    if aconegcli.idacordo = ?
    then do:
       create ttsaida.
       ttsaida.tstatus = 400.
       ttsaida.descricaoStatus = "Oferta Sem Acordo ".
    
       hsaida  = temp-table ttsaida:handle.
    
       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
    end.
    if aconegcli.idacordo <> int(ttentrada.agreementId)
    then do:
       create ttsaida.
       ttsaida.tstatus = 400.
       ttsaida.descricaoStatus = "Acordo não corresponde ".
    
       hsaida  = temp-table ttsaida:handle.
    
       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
    end.

end.


if ttentrada.paymentMethod <> "boleto"
then do:
    create ttsaida.
       ttsaida.tstatus = 400.
       ttsaida.descricaoStatus = "Metodo de Pagamento Invalido".
    
       hsaida  = temp-table ttsaida:handle.
    
       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
end.
DEF VAR par-recid-boleto AS RECID.
DEF VAR vstatus AS CHAR.
DEF VAR vmensagem_erro AS CHAR.
find aoacordo where aoacordo.idacordo = aconegcli.idacordo no-lock.

if aoacordo.dtcanc <> ?
then do:
    create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = "Acordo Cancelado, não pode pagar".
    
        hsaida  = temp-table ttsaida:handle.
    
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
end.

find AoAcParcela of aoacordo where AoAcParcela.Parcela = int(ttentrada.instalment) no-lock no-error.
if not avail AoAcParcela
then do:
    create ttsaida.
       ttsaida.tstatus = 400.
       ttsaida.descricaoStatus = "Parcela invalida".
    
       hsaida  = temp-table ttsaida:handle.
    
       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
end.

run bol/geradadosboleto.p (
      input 104, /* Banco do Boleto */
      input ?,      /* Bancarteira especifico */
      input "SERASA",
      input clien.clicod,
      input "Acordo: " + string(aoacordo.idacordo) + if aoacparcela.parcela = 0 then ""
                                                    else ("/" + string(AoAcParcela.parcela)),
      input aoacparcela.DtVencimento,
      input aoacparcela.VlCobrado,
      input 0,
      output par-recid-boleto,
      output vstatus,
      output vmensagem_erro).

find banBoleto where recid(banBoleto) = par-recid-boleto no-lock
      no-error.
if not avail banboleto
then do:
    create ttsaida.
       ttsaida.tstatus = 400.
       ttsaida.descricaoStatus = "Erro na geralcao do Boleto".
    
       hsaida  = temp-table ttsaida:handle.
    
       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
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
    then do:      
          run bol/vinculaboleto.p (
                input recid(banBoleto),
                input ptpnegociacao,
                input "idacordo,parcela",
                input string(aoacparcela.idacordo) + "," +
                        string(aoacparcela.parcela),
                input AoAcParcela.VlCobrado,
                OUTPUT vstatus,
                output vmensagem_erro).      
            if vstatus = "S"
            then do: 
                create ttpagamento.  
                ttpagamento.offerId = aconegcli.id. 
                ttpagamento.agreementId = string(aoacordo.idacordo). 
                ttpagamento.dueDate = aoacparcela.DtVencimento. 
                ttpagamento.instalment = aoacparcela.parcela. 
                ttpagamento.instalmentValue = aoacparcela.VlCobrado. 
                ttpagamento.paymentMethod = ttentrada.paymentMethod. 
                ttpagamento.barCode = banboleto.codigoBarras. 
                ttpagamento.digitLine = banboleto.linhaDigitavel.  
                /*ttpagamento.vbase64 = "JVBERi0xLjQNCiWqq6ytD[generic_base64]==".*/ 
                /*
*ttpagamento.pixCode = "00020126360014BR.GOV.BCB.PIX01143690558600018052040000530398654074000.005802BR5912QA TEST LTDA6009SAO PAULO62160512PAGAMENTO1QA6304EF69".
*ttpagamento.qrCode = "983874277584054862353623720346605218569864170938".
                */
            end.
    end.
    

find first ttpagamento.

hsaida  = TEMP-TABLE ttpagamento:handle.
lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).

/* export LONG VAR*/
DEF VAR vMEMPTR AS MEMPTR  NO-UNDO.
DEF VAR vloop   AS INT     NO-UNDO.
if length(vlcsaida) > 30000
then do:
    COPY-LOB FROM vlcsaida TO vMEMPTR.
    DO vLOOP = 1 TO LENGTH(vlcsaida): 
        put unformatted GET-STRING(vMEMPTR, vLOOP, 1). 
    END.
end.
else do:
    put unformatted string(vlcSaida).
end.  
