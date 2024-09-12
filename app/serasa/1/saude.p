def input param vtmp       as char.     /* CAMINHO PROGRESS_TMP */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hsaida   as handle.             /* HANDLE SAIDA */


def temp-table ttsaude  NO-UNDO serialize-name "saude"  /* JSON SAIDA */
    FIELD vmessage   as char serialize-name "message"
    field vversion   as CHAR serialize-name "version".


create ttsaude. 
ttsaude.vmessage = "Is alive!".
ttsaude.vversion = "3.0.0". 


hsaida  = TEMP-TABLE ttsaude:handle.


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
