{/u/bsweb/progr/bsxml.i}
def var vroda as char.
def var varquivoentrada as char.

def var vacao as char.
def var vws as char.
def var ventrada as char.
vws         = os-getenv("ws").
vacao       = os-getenv("acao").
ventrada    = os-getenv("entrada").

ventrada = replace(ventrada,"'","\"").

varquivoentrada = "/u/bsweb/works/wsprogress." + 
                    vws + "." +
                    vacao + "." +    
                    string(day(today)) + 
                    "." + string(time) + ".d".

output to value(varquivoentrada).
    put unformatted ventrada skip.
output close.

vroda = "ws/roda" + vws + ".p".

run value(vacao + ".p") (/*vacao,*/
                         varquivoentrada).



unix silent value("rm -f " + varquivoentrada).


return.




