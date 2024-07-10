def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttsaida  no-undo serialize-name "impressoras"
    field nome      as char format "x(30)" serialize-name "text"
    field endereco  as char format "x(40)" serialize-name "value".

input THROUGH value("lpstat -t 2>/dev/null |grep device").
repeat.
    create ttsaida.
    import        ^        ^        ttsaida.nome        ttsaida.endereco.
    ttsaida.nome = replace(ttsaida.nome,":","").
end.
input close.

for each ttsaida where ttsaida.nome = "". delete ttsaida. end.


find first ttsaida no-error.
if not avail ttsaida
then do:

  create ttsaida.
  ttsaida.nome = "NENHUMA IMPRESSORA ENCONTRADA".
  ttsaida.endereco = "NENHUMA IMPRESSORA ENCONTRADA".
end.
else do:
    for each ttsaida.
        ttsaida.endereco = ttsaida.nome.
    end.

end.


hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
/*
lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE, ?, ?, true).
*/
/*
vsaida  = replace(replace(string(vlcsaida),"[",""),"]","").
*/
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
