/* #112022Gestão de itens promocionais - 2 - bloqueio de quantidade vendida em itens promocionais */

def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.
def var hentrada   as handle.
def var hsaida     as handle.

def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vpromocaoLimite as char.

def temp-table ttentrada serialize-name "entrada"
    field sequenciaCampanha as char
    field codigoFilial      as char
    field codigoProduto     as char
    field qtdSolicitada        as char.

def temp-table ttretorno serialize-name "return"
    field sequenciaCampanha as char
    field codigoFilial      as char
    field codigoProduto     as char
    field qtdSolicitada     as char
    field qtdVendida        as char
    field qtdLimite         as char
    field promocaoLimite   as char. /* true/false */

def var vqtdVendida as int.
def var vqtdLimite  as int.
def var vqtdSolicitada as int.
hentrada = temp-table ttentrada:handle.
hsaida   = temp-table ttretorno:handle.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada.

vpromocaoLimite = "false".
vqtdSolicitada = int(ttentrada.qtdSolicitada).
vqtdVendida     = 0.
vqtdLimite      = 0.
/* Verifica se Promocao Ativa ainda */

find first ctpromoc  where
            ctpromoc.sequencia = int(ttentrada.sequencia) and 
            ctpromoc.linha = 0 and  
            ctpromoc.dtfim >= today and
            ctpromoc.situacao = "L"
    no-lock no-error.
if not avail ctpromoc
then do:
    vpromocaoLimite = "inativa".
end.    
if avail ctpromoc and vqtdSolicitada > 0
then do:
    find promqtd where 
        promqtd.sequencia = ctpromoc.sequencia and
        promqtd.etbcod = int(ttentrada.codigoFilial) and
        promqtd.procod = int(ttentrada.codigoProduto)     
        no-lock no-error.
    if avail promqtd
    then do:
        vqtdVendida = 0.
        for each movim where movim.movtdc = 5 and
                         movim.etbcod = promqtd.etbcod and
                         movim.procod = promqtd.procod and
                         movim.movdat >= ctpromoc.dtInicio and
                         movim.movdat <= ctpromoc.dtfim
               no-lock.
            vqtdVendida = vqtdVendida + movim.movqtm.
        end.
        vqtdLimite = promqtd.qtdLimite.
        if vqtdVendida + vqtdSolicitada > promqtd.qtdLimite
        then vpromocaoLimite = "true".
    end.
    else do:
        find promqtd where 
            promqtd.sequencia = ctpromoc.sequencia and
            promqtd.etbcod = 0 and
            promqtd.procod = int(ttentrada.codigoProduto)     
            no-lock no-error.
        if avail promqtd
        then do:
            vqtdVendida = 0.
            for each estab no-lock.
                for each movim where movim.movtdc = 5 and
                         movim.etbcod = estab.etbcod and
                         movim.procod = promqtd.procod and
                         movim.movdat >= ctpromoc.dtInicio and
                         movim.movdat <= ctpromoc.dtfim
                       no-lock.
                    vqtdVendida = vqtdVendida + movim.movqtm.
                end.
            end.    
            vqtdLimite = promqtd.qtdLimite.
            if vqtdVendida + vqtdSolicitada > promqtd.qtdLimite
            then vpromocaoLimite = "true".
        end.
    end.
end.

create ttretorno.
ttretorno.sequenciaCampanha     =   ttentrada.sequenciaCampanha.
ttretorno.codigoFilial          = ttentrada.codigoFilial.
ttretorno.codigoProduto         = ttentrada.codigoProduto.
ttretorno.qtdSolicitada         = ttentrada.qtdSolicitada.
ttretorno.qtdVendida            = string(vqtdVendida).
ttretorno.qtdLimite             = string(vqtdLimite).
ttretorno.promocaoLimite        = vpromocaoLimite.


        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcsaida).
/*** 
def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.
          
varquivo  = "/u/bsweb/works/verificacaocarteiradestino" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".


lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
/*os-command value("rm -f " + varquivo)*/
***/

