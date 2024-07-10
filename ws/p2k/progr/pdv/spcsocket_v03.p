/*
#1 jun/2017 - Ricardo - Rotina foi reescrita
#2 out/2018 - Felipe - Log gravado em tabela SPC
*/
def input  parameter p-1        as char. /*qualquer coisa */
def input  parameter p-2        as char. /*string de paramteros*/
def output parameter spc-conecta as log init no.
def output parameter vResposta  as longchar.  /*#2*/

/*def var vresposta as char.*/
def var hSocket   as handle NO-UNDO. 

/*** Log para verificar tempo dos webservices ***/
def var vlog    as log /*init yes*/.
def var varqlog as char.
def var vversao as char.

vversao = os-getenv("versao-wsp2k").
if vversao = ?
then vversao = "".
else vversao = vversao + "_".

varqlog = "/u/bsweb/log/p2k" + vversao + string(today, "99999999") + ".log".

/*** ***/

hide message no-pause. 
pause 0 before-hide.

if p-1 = "" or p-1 = ?
then do.
    run gera-log("Parametro P1 invalido").
    return.
end.

if p-2 = "" or p-2 = ?
then do.
    run gera-log("Parametro P2 invalido").
    return.
end.

if vlog
then run gera-log("Conectando").
            
create socket hSocket.
hSocket:connect("-pf ./progr/pdv/cdlsocket.ini") no-error.
if hSocket:CONNECTED()
then do:
/***
    if vlog
    then run gera-log("Conectado").
***/

    hSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').
    RUN PostRequest (p-1).
    WAIT-FOR READ-RESPONSE OF hSocket.

    if vresposta  = "OK"
    then do:
        if vlog
        then run gera-log("Consultando").

        RUN PostRequest (p-2).
        REPEAT ON STOP UNDO, LEAVE ON QUIT UNDO, LEAVE:
            IF hSocket:connected()
            THEN WAIT-FOR READ-RESPONSE OF hSocket.
            ELSE LEAVE.
        END.
    end.
end.
else do.
    run gera-log("Falha ao conectar ao servidor").
    spc-conecta = no.
    return.
end.
hSocket:disconnect() no-error.
delete object hSocket.
hide message no-pause. 

if vresposta = ""
then run gera-log("Retorno nao recebido").
else do.
    if vlog
    then run gera-log("Retorno recebido").
    spc-conecta = yes.
    
    /*
    unix silent rm -f value(par-arq).
    output to value(par-arq).
    put unformatted string(vresposta). /*#2*/
    output close.
    */
end.


PROCEDURE PostRequest:
    define input parameter vcRequest as char.

    DEFINE VARIABLE mRequest       AS MEMPTR.

    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .

    vresposta = "".
    hSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).
END PROCEDURE.
                        

PROCEDURE getResponse:

    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.

    IF SELF:CONNECTED() = FALSE
    THEN RETURN.

    DO WHILE hSocket:GET-BYTES-AVAILABLE() > 0:
        SET-SIZE(mResponse) = hSocket:GET-BYTES-AVAILABLE() + 1.
        SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
        hSocket:READ(mResponse,1,1,hSocket:GET-BYTES-AVAILABLE()).
        vresposta = vresposta + GET-STRING(mResponse,1).
    end.
    vresposta = left-trim(trim(vresposta)).

END PROCEDURE.


procedure gera-log.
    def input parameter par-texto as char.

    output to value(varqlog) append.
    put unformatted skip string(time, "hh:mm:ss") " WS SPC: " par-texto skip.
    output close.

end procedure.

