/*
#1 17.07.2017 - gerar o log na pasta log e apagar o arquivo
*/
{bsxml.i}
def var vroda as char.
def var varquivoentrada as char.
def var vacao as char.
def var vws as char.
def var ventrada as char.
vws         = os-getenv("ws").
vacao       = os-getenv("acao").
ventrada    = os-getenv("entrada").

ventrada = replace(ventrada,"'","\"").
/*
message "ANTES ENTRADA".
message  ventrada.
message "DEPOIS ENTRADA".
*/

varquivoentrada = "/ws/log/wsprogress." /* #1 */ +
                    vws + "." +
                    vacao + "." +    
                    string(day(today)) + 
                    "." + 
                    string(mtime) +
                    string(etime) +
                    string(next-value(p2k-bsweb)) +
                    ".d".

output to value(varquivoentrada).
put unformatted ventrada skip.
output close.

vroda = "ws/roda" + vws + ".p".

run value(vroda)     (vacao,
                      varquivoentrada).

unix silent value("rm -f " + varquivoentrada). /* #1 */




return.

