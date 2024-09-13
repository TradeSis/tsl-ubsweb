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
    field dueDate   as CHAR serialize-name "dueDate"
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



create ttpagamento. 
ttpagamento.offerId = "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a".
ttpagamento.agreementId = "123456".
ttpagamento.dueDate = "2024-08-19".
ttpagamento.instalment = 1.
ttpagamento.instalmentValue = 400.55.
ttpagamento.paymentMethod = "pix".
ttpagamento.barCode = "890380038252042154496331179319333330979032437256".
ttpagamento.digitLine = "770098015294047064053168524816282381253613215287".
ttpagamento.vbase64 = "JVBERi0xLjQNCiWqq6ytD[generic_base64]==".
ttpagamento.pixCode = "00020126360014BR.GOV.BCB.PIX01143690558600018052040000530398654074000.005802BR5912QA TEST LTDA6009SAO PAULO62160512PAGAMENTO1QA6304EF69".
ttpagamento.qrCode = "983874277584054862353623720346605218569864170938".



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
