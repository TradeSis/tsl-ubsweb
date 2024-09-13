def input param vlcentrada as longchar. /* JSON ENTRADA */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */

/* MODELO DADOS ENTRADA
{
  "document": "23599482020",
  "offerId": "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "agreementId": "123456"
}
MODELO DADOS SAIDA 
{
  "offerId": "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
  "status": true,
  "message": "[PT] Acordo cancelado [EN] Deal canceled. "
}
*/

def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char 
   field offerId         as char 
   field agreementId     as char .

def temp-table ttcancelaacordo  no-undo serialize-name "cancelaacordo"  /* JSON SAIDA */
    field offerId   as CHAR serialize-name "offerId"
    field vstatus   as log serialize-name "status"
    field vmessage   as CHAR serialize-name "message".


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



create ttcancelaacordo. 
ttcancelaacordo.offerId = "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a".
ttcancelaacordo.vstatus = true.
ttcancelaacordo.vmessage = "[PT] Acordo cancelado [EN] Deal canceled. ".


hsaida  = TEMP-TABLE ttcancelaacordo:handle.


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
