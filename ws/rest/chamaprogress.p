
/* {/u/bsweb/progr/bsxml.i}
def var vroda as char.
def var varquivoentrada as char.
*/

def var vacao as char.
def var vws as char.
def var ventrada as longchar.
vws         = os-getenv("ws").
vacao       = os-getenv("acao").
ventrada    = os-getenv("entrada").
if vws = ? then vws = "PADRAO".
if vacao = ? then vacao = "save_user". 
if ventrada = ? then ventrada = "\{\"firstname\":\"\",\"lastname\":\"\",\"phone\":\"\",\"email\":\"\"\}".

/*
ventrada = replace(ventrada,"'","\"").

varquivoentrada = "/u/bsweb/works/wsprogress." + 
                    vws + "." +
                    vacao + "." +    
                    string(day(today)) + 
                    "." + string(time) + ".d".

message vws vacao string(day(today))  string(time) varquivoentrada.

output to value(varquivoentrada).
    put unformatted ventrada skip.
output close.

vroda = "ws/roda" + vws + ".p".
*/

run value(vacao + ".p") (/*vacao,*/
                         ventrada).



return.




