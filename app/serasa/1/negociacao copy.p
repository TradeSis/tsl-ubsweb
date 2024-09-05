def input param vlcentrada as longchar. /* JSON ENTRADA */
//def input param vtmp       as char.     /* CAMINHO PROGRESS_TMP */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */


def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char serialize-name "document" /* CPJ/CNPJ do consumidor */
   field offer_id         as char serialize-name "offerId".

DEF TEMP-TABLE ttnegociacao NO-UNDO SERIALIZE-NAME "negociacao"
   FIELD offerId AS CHAR
   FIELD vtype AS CHAR SERIALIZE-NAME "type".

DEF TEMP-TABLE ttinstalments NO-UNDO SERIALIZE-NAME "instalments"
   FIELD id AS CHAR
   FIELD vtotal AS DEC SERIALIZE-NAME "total"
   FIELD totalWithoutInterest AS DEC
   FIELD discountValue AS DEC
   FIELD discountPercentage AS DEC
   FIELD instalment AS DEC.
   
DEF TEMP-TABLE ttdueDate NO-UNDO SERIALIZE-NAME "dueDate"
   FIELD dueDate AS CHAR.
   
DEF TEMP-TABLE ttvalues NO-UNDO SERIALIZE-NAME "values"
   FIELD vvalue AS DEC SERIALIZE-NAME "value"
   FIELD vtotal AS DEC SERIALIZE-NAME "total".
  
DEF TEMP-TABLE tttaxes NO-UNDO SERIALIZE-NAME "taxes"
   FIELD iof_percentage AS DEC
   FIELD iof_totalValue AS DEC
   FIELD cet_yearPercentage AS DEC
   FIELD cet_monthPercentage AS DEC
   FIELD cet_totalValue AS DEC
   FIELD interest_yearPercentage AS DEC
   FIELD interest_monthPercentage AS DEC
   FIELD interest_totalValue AS DEC.
   
DEF DATASET dsNegociacao  SERIALIZE-NAME "JSON" 
   FOR ttnegociacao, ttinstalments, ttdueDate, ttvalues, tttaxes.
  

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


CREATE ttnegociacao.
ttnegociacao.offerId = "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a".
ttnegociacao.vtype = "EQUALS".

CREATE ttinstalments.
ttinstalments.id = "1".
ttinstalments.vtotal = 300.
ttinstalments.totalWithoutInterest = 300.
ttinstalments.discountValue = 100.
ttinstalments.discountPercentage = 25.
ttinstalments.instalment = 1.

CREATE ttinstalments.
ttinstalments.id = "2".
ttinstalments.vtotal = 2.
ttinstalments.totalWithoutInterest = 2.
ttinstalments.discountValue = 2.
ttinstalments.discountPercentage = 2.
ttinstalments.instalment = 2.

CREATE ttdueDate.
ttdueDate.dueDate = "2024-08-19".

CREATE ttdueDate.
ttdueDate.dueDate = "2024-08-20".

CREATE ttdueDate.
ttdueDate.dueDate = "2024-08-21".

CREATE ttvalues.
ttvalues.vvalue = 300.
ttvalues.vtotal = 300.
 

CREATE tttaxes.
tttaxes.iof_percentage = 0.
tttaxes.iof_totalValue = 0.
tttaxes.cet_yearPercentage = 0.
tttaxes.cet_monthPercentage = 0.
tttaxes.cet_totalValue = 0.
tttaxes.interest_yearPercentage = 0.
tttaxes.interest_monthPercentage = 0.
tttaxes.interest_totalValue = 0.


hsaida =  DATASET dsNegociacao:HANDLE.


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
