
/* #082022 helio bau */

def var vacao as char.
def var vws as char.
def var ventrada as longchar.
vws         = os-getenv("ws").
vacao       = os-getenv("acao").
ventrada    = os-getenv("entrada").

if vacao <> ?
then do:
    if search(vacao + ".p") <> ?
    then  run value(vacao + ".p") (ventrada).



return.




