def input  parameter vlcentrada as longchar.

{/admcom/progr/seg/defhubperfildin.i new}

def var vlcsaida   as longchar.
def var vsaida as char.

def var lokjson as log.
def var hsaida   as handle.



FUNCTION acha2 returns character
    (input par-oque as char,
     input par-onde as char).
    def var vx as int.
    def var vret as char.
    vret = ?.
    do vx = 1 to num-entries(par-onde,"|").
        if num-entries( entry(vx,par-onde,"|"),"#") = 2 and
           entry(1,entry(vx,par-onde,"|"),"#") = par-oque
        then do:
            vret = entry(2,entry(vx,par-onde,"|"),"#").
            leave.
        end.
    end.
    return vret.
END FUNCTION.

for each produ where
    produ.indicegenerico contains "IDSEGURO#*" no-lock.
    create ttsegprodu.
    ttsegprodu.procod     = produ.procod.
    ttsegprodu.pronom     = produ.pronom.
    run trata_caract_esp.p (input produ.pronom, output ttsegprodu.pronom).
    ttsegprodu.idseguro   = acha2("IDSEGURO",produ.indicegenerico).
end.


hsaida  = temp-table ttsegprodu:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).


/*vsaida  = replace(replace(string(vlcsaida),"[",""),"]","").*/

message string(vlcsaida).
