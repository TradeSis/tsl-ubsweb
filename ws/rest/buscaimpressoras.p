def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar. 
def var vsaida as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttsaida  no-undo serialize-name "impressoras"
    field nome as char serialize-name "text"
    field endereco as char serialize-name "value".

unix silent value("lpstat -t | grep device  >zeb.txt").
input from zeb.txt.
repeat.
    create ttsaida.
    import 
        ^
        ^
        ttsaida.nome
        ttsaida.endereco.
end.
input close.
for each ttsaida.
    if ttsaida.nome = ""
    then delete ttsaida.
    else do:
        ttsaida.nome = replace(ttsaida.nome,":","").
        ttsaida.endereco = ttsaida.nome.
    end.        
end.    


hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
/*
lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE, ?, ?, true).
*/

vsaida  = replace(replace(string(vlcsaida),"[",""),"]","").
vsaida = string(vlcsaida).
 
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