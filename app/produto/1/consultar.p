/*PRPK - helio 21042022 - nova tabela */
def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "produtos"
    field produto as int.


def temp-table ttsaida  no-undo serialize-name "produto"
    field Codigo       as int
    field Nome as char
    field Preco  as char
    field Grade  as char.

/* indice generico - multimix*/
def var vgrade as char.
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
                                                                                                 


hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada.

find produ where produ.procod = ttentrada.produto no-lock no-error.

find first estoq of produ no-lock no-error.

    create ttsaida.
    ttsaida.Codigo = ttentrada.produto.
    ttsaida.Nome = if avail produ
                   then produ.pronom
                   else "DESCONHECIDO".
    ttsaida.Preco = if avail estoq
                    then trim(string(estoq.estvenda,">>>>>9.99"))
                    else "0.00".

    vgrade = acha2("GRADE",produ.indicegenerico).    
    if vgrade = ? then vgrade = "".
    if vgrade <> ""
    then do:
        ttsaida.grade = vgrade.
    end.
    
hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
/*
lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE, ?, ?, true).
*/

vsaida  = replace(replace(string(vlcsaida),"[",""),"]","").

message vsaida.
/*


message "
\{\"prods\":[\{
    \"Produto\":\"1212\",
        \"Nome\":\"" + string(vlcentrada) + " \",
            \"Preco\":\"67.00\"
            \}
                                    ]\}".
*/
