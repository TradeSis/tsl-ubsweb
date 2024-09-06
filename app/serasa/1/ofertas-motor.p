def input param vlcentrada as longchar. /* JSON ENTRADA */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */

def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field cnpj_raiz         as char serialize-name "cnpj_raiz"
   field document        as char serialize-name "document".
   
DEF TEMP-TABLE ttoffers NO-UNDO SERIALIZE-NAME "offers"
   FIELD id AS CHAR
   FIELD debtOriginalValues AS DEC 
   FIELD debtCurrentValues AS DEC
   FIELD maxInstalments AS DEC
   FIELD maxInstalmentValue AS DEC
   FIELD atSight AS DEC
   FIELD interest AS DEC
   FIELD discountValue AS DEC
   FIELD discountPercentage AS DEC
   FIELD hasInstalments AS LOG.
   
DEF TEMP-TABLE ttdebts NO-UNDO SERIALIZE-NAME "debts"
   FIELD dueDate AS CHAR
   FIELD occurrenceDate AS CHAR
   FIELD originalValue AS DEC
   FIELD currentValue AS DEC
   FIELD contractNumber AS CHAR
   FIELD vtype AS CHAR SERIALIZE-NAME "type"
   field idpai as char SERIALIZE-HIDDEN
   field iddebts as char serialize-hidden.
   
DEF TEMP-TABLE ttvalues NO-UNDO SERIALIZE-NAME "values"
   FIELD vvalue AS DEC SERIALIZE-NAME "value"
   FIELD vtotal AS DEC SERIALIZE-NAME "total".
  
DEF TEMP-TABLE ttcompany NO-UNDO SERIALIZE-NAME "company"
   FIELD id AS CHAR
   FIELD businessName AS CHAR
   field idpaidebts as char serialize-hidden.
   
DEF TEMP-TABLE ttcompanyOrigin NO-UNDO SERIALIZE-NAME "companyOrigin"
   FIELD id AS CHAR
   FIELD businessName AS CHAR
   field idpaidebts as char serialize-hidden.

   
DEF DATASET dsOfertas  SERIALIZE-NAME "JSON" 
  FOR ttoffers, ttdebts, ttvalues, ttcompany, ttcompanyOrigin
  DATA-RELATION for1 FOR ttoffers, ttdebts    RELATION-FIELDS(ttoffers.id,ttdebts.idpai) NESTED  
  DATA-RELATION for2 FOR ttdebts, ttcompany    RELATION-FIELDS(ttdebts.iddebts,ttcompany.idpaidebts) NESTED
  DATA-RELATION for3 FOR ttdebts, ttcompanyOrigin    RELATION-FIELDS(ttdebts.iddebts,ttcompanyOrigin.idpaidebts) NESTED.  


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

CREATE ttoffers.
ttoffers.id = "1". //"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a".
ttoffers.debtOriginalValues = 200.
ttoffers.debtCurrentValues = 400.
ttoffers.maxInstalments = 8.
ttoffers.maxInstalmentValue = 50.
ttoffers.atSight = 300.
ttoffers.interest = 200.
ttoffers.discountValue = 100.
ttoffers.discountPercentage = 25.
ttoffers.hasInstalments = TRUE.


CREATE ttdebts.
ttdebts.dueDate = "2020-04-17".
ttdebts.occurrenceDate = "2020-04-17".
ttdebts.originalValue = 150.
ttdebts.currentValue = 250.
ttdebts.contractNumber = "123456".
ttdebts.vtype = "[PT] Cartao de Credito [EN] Credit card".
ttdebts.idpai = "1". //"8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a".
ttdebts.iddebts = "1".


CREATE ttcompany.
ttcompany.id = "29939269000110".
ttcompany.businessName = "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda.".
ttcompany.idpaidebts = "1".

CREATE ttcompanyOrigin.
ttcompanyOrigin.id = "29939269000110".
ttcompanyOrigin.businessName = "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda.".
ttcompanyOrigin.idpaidebts = "1".

hsaida =  DATASET dsOfertas:HANDLE.


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
