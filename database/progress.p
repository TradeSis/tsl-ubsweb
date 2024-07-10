/* progress.p */

/*VERSAO 2 23062021*/


def var vacao as char.
def var vws as char.
def var ventrada as longchar.
def var vtmp    as char.
def var vpropath as char.

vws         = os-getenv("ws").
vacao       = os-getenv("acao").
ventrada    = os-getenv("entrada").
vpropath    = os-getenv("PROPATH"). /* HELIO 27/02/2024 - para vers�o windows */


vtmp    = os-getenv("tmp").

/* 
message "vws" vws.
message "vacao" vacao.

message "vpropath" vpropath.
message "vtmp" vtmp.
*/
if vtmp = ? then vtmp = "./".

propath = vpropath. /* HELIO 27/02/2024 - para vers�o windows */

if vacao <> ?
then do:
    
    if search(vacao + ".p") <> ?
    then  run value(vacao + ".p") ( ventrada /*, vtmp */).
end.


return.