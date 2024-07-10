def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar. 
def var vsaida as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "produtos"
    field produto as int.


def temp-table ttsaida  no-undo serialize-name "prods"
    field Produto       as int
    field Nome as char
    field Preco  as char.

hEntrada = temp-table ttentrada:HANDLE.  

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").
    
find first ttentrada.

find produ where produ.procod = ttentrada.produto no-lock no-error.

find first estoq of produ no-lock no-error.

    create ttsaida.
    ttsaida.produto = ttentrada.produto.
    ttsaida.Nome = if avail produ
                   then produ.pronom
                   else "DESCONHECIDO".
    ttsaida.Preco = if avail estoq
                    then string(estoq.estvenda,">>>>>9.99")
                    else "0.00".

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