def input param vlcentrada as longchar. /* JSON ENTRADA */
//def input param vtmp       as char.     /* CAMINHO PROGRESS_TMP */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */


def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char serialize-name "document"
   field offerId         as char serialize-name "offerId"
   field dueDate         as char serialize-name "dueDate"
   field id              as char serialize-name "id".

DEF TEMP-TABLE ttacordos NO-UNDO serialize-name "acordos"
   FIELD offerId AS CHAR
   FIELD agreementId AS CHAR
   FIELD vtotal AS DEC serialize-name "total"
   FIELD totalWithoutInterest AS DEC
   FIELD discountValue AS DEC
   FIELD discountPercentage AS DEC.
   
DEF TEMP-TABLE ttinstalments NO-UNDO serialize-name "instalments"
   FIELD instalment AS DEC
   FIELD dueDate AS CHAR
   FIELD vvalue AS DEC serialize-name "value"
   FIELD vtotal AS DEC serialize-name "total".
   
DEF TEMP-TABLE tttaxes NO-UNDO serialize-name "taxes"
   FIELD iof_percentage AS DEC 
   FIELD iof_totalValue AS DEC
   FIELD cet_yearPercentage AS DEC 
   FIELD cet_monthPercentage AS DEC
   FIELD cet_totalValue AS DEC
   FIELD interest_yearPercentage AS DEC
   FIELD interest_monthPercentage AS DEC
   FIELD interest_totalValue AS DEC.
   
DEF DATASET dsAcordos  SERIALIZE-NAME "JSON" 
   FOR ttacordos, ttinstalments,  tttaxes.

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


CREATE ttacordos.
ttacordos.offerId = "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a".
ttacordos.agreementId = "123456".
ttacordos.vtotal = 300.
ttacordos.totalWithoutInterest = 300.
ttacordos.discountValue = 100.
ttacordos.discountPercentage = 25.

CREATE ttinstalments.
ttinstalments.instalment = 2.
ttinstalments.dueDate = "2024-09-19".
ttinstalments.vvalue = 150.
ttinstalments.vtotal = 150.

CREATE ttinstalments.
ttinstalments.instalment = 20.
ttinstalments.dueDate = "2024-09-20".
ttinstalments.vvalue = 200.
ttinstalments.vtotal = 200.
 

CREATE tttaxes.
tttaxes.iof_percentage = 50.
tttaxes.iof_totalValue = 11.
tttaxes.cet_yearPercentage = 0.
tttaxes.cet_monthPercentage = 0.
tttaxes.cet_totalValue = 0.
tttaxes.interest_yearPercentage = 0.
tttaxes.interest_monthPercentage = 0.
tttaxes.interest_totalValue = 0.


hsaida =  DATASET dsAcordos:HANDLE.


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
