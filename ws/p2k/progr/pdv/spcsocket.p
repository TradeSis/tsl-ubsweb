/***
{admcab.i}
***/

def input  parameter p-1        as char. /*qualquer coisa */
def input  parameter p-2        as char. /*string de paramteros*/
def input  parameter par-tam    as int.
def input  parameter par-arq    as char.
def output parameter par-ok     as log init no /*** WS ***/.
def output parameter spc-conecta as log.

def var sb   as memptr.
def var vb   as memptr.
def var v1   as char.
def var v2   as char.
def var vb2  as memptr.
def var vb3  as memptr.
def var p-3  as char. /*string de retorno*/

def var vp-write2 as int.
def var vp-read2  as int.
def var sh as handle NO-UNDO. 
def var varqlog as char.
def var vlog    as log.

hide message no-pause. 
pause 0 before-hide.

varqlog = par-arq + ".log".

if vlog and p-1 = ""
then do.
    output to value(varqlog) append.
    put "Parametro P1 invalido" skip.
    output close.
    return.
end.

if vlog
then do.
    output to value(varqlog) append.
    put "Conectando ao CDL ..." skip.
    output close.
end.

create socket sh no-error. 
if sh:connect( "-pf ./progr/pdv/cdlsocket.ini" )
then do: 
    if vlog
    then do.
        output to value(varqlog) append.
        put "Conectado ao CDL ..." skip.
        output close.
    end.

    assign
        vp-write2 = 50
        vp-read2  = 4.

    set-size(sb)=2001.
    assign put-string(sb,1) = p-1.
    sh:write(sb, 1, 50).

    set-size(vb)=2001.
    sh:read(vb , 1, 4).
    assign v1 = get-string(vb,1).
    
    if substr(string(v1,"x(10)"),1,2) = "OK"
    then do:
        if vlog
        then do.
            output to value(varqlog) append.
            put "Consultando ..." skip.
            output close.
        end.

        if p-2 <> ""
        then do:
            assign
                vp-write2 = length(string(p-2))
                vp-read2  = par-tam.

            set-size(sb)  = 30001.
            set-size(vb2) = 30001.
            set-size(vb3) = 30000.

            assign put-string(sb,1) = p-2.
            sh:write(sb, 1, vp-write2).

            sh:read(vb2, 1 , vp-read2).
            assign v2 = get-string(vb2, 1).

            p-3 = v2.

            /* 19/12 */
            if index(p-3, "FIM") = 0
            then do. /* segunda leitura */
                vp-read2 = min(sh:GET-BYTES-AVAILABLE(), par-tam).

                if vlog
                then do.
                    output to value(varqlog) append.
                    put "Consultando (2) ..." skip.
                    output close.
                end.

                sh:read(vb3, 1, vp-read2).
                assign v2 = get-string(vb3, 1).
                p-3 = p-3 + v2.
            end.            
        end.
        else p-3 = v1.
    end.
end.
else do.
    if vlog
    then do.
        output to value(varqlog) append.
        put "Falha ao conectar ao servidor" skip.
        output close.
    end.
    spc-conecta = no.
    return.
end.
sh:disconnect().
hide message no-pause. 

spc-conecta = yes.

if p-3 = ""
then do.
    if vlog
    then do.
        output to value(varqlog) append.
        put "Retorno nao recebido" skip.
        output close.
    end.
end.
else do.
    par-ok = yes.

    output to value(par-arq).
    put unformatted p-3.
    output close.

    /***WS if opsys = "unix"
    then unix silent chmod 777 value(par-arq).***/
end.

