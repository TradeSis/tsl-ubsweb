def input parameter par-arquivoentrada as char.

{/u/bsweb/progr/bsxml.i}
{/u/bsweb/progr/acha.i}

def var vparam as char.
def var vip    as char.
def var vetbcod as int.

def var vip1 as int.
def var vip2 as int.

input from value(par-arquivoentrada) no-echo.
import unformatted vparam.
input close.

vip = acha("IP",replace(vparam,"&","|")).


vetbcod = 0.

if num-entries(vip,".") = 4 
then do:
        vip1 = int(entry(1,vip,".")).
        vip2 = int(entry(2,vip,".")).
        if vip1 = 172 or vip1 = 192
        then do:
                if vip2 = 17 or vip2 = 23 or vip2 = 168
                then do:
                        vetbcod = int(entry(3,vip,".")).
                        find estab where estab.etbcod = vetbcod no-lock no-error.
                        if not avail estab
                        then vetbcod = 0.
                end.
        end.
end.

/*
if vip = "10.4.0.62" then vetbcod = 13.
*/



def var par-data as date.
par-data = today - 10.
def temp-table ttestab no-undo
        field etbcod as int
index estab etbcod.

/* testa IP */

if vetbcod <> 0
then do:
        create ttestab.
        ttestab.etbcod = vetbcod.
end.
else do:
        /**
    for each neuproposta where neuproposta.dtinclu >= par-data  no-lock.
        find first ttestab where
                ttestab.etbcod = neuproposta.etbcod no-error.
        if not avail ttestab
        then do:
                create ttestab.
                ttestab.etbcod = neuproposta.etbcod.
        end.
    end.
        **/
    find first ttestab no-error.
    if not  avail ttestab
    then do:
        for each agfilcre where agfilcre.tipo = "NEUROTECH" no-lock.
                        find first ttestab where
                ttestab.etbcod = agfilcre.etbcod no-error.
        if not avail ttestab
        then do:
                create ttestab.
                ttestab.etbcod = agfilcre.etbcod.
        end.

        end.


    end.
    find first ttestab no-error.
    if not  avail ttestab
    then do:
        for each estab no-lock.
                        find first ttestab where
                ttestab.etbcod = estab.etbcod no-error.
        if not avail ttestab
        then do:
                create ttestab.
                ttestab.etbcod = estab.etbcod.
        end.

        end.


    end.

end.

def var vtotal as int.

BSXml("ABREXML","").
bsxml("abretabela","return").
vtotal = 0.
for each ttestab  no-lock.
vtotal = vtotal + 1.
end.


for each ttestab no-lock.
find estab where estab.etbcod = ttestab.etbcod no-lock.
 
BSXml("ABREREGISTRO","rows").


        bsxml("id",string(estab.etbcod)).
        bsxml("value",estab.etbnom).

 BSXml("FECHAREGISTRO","rows").


end.
     bsxml("fechatabela","return").

    BSXml("FECHAXML","").

