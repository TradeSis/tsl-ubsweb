def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.

def new shared temp-table ttentrada  no-undo serialize-name "produtos"
    field codigo       as int
    field nome          as char
    field grade         as char
    field quantidade   as int.


def temp-table ttsaida  no-undo serialize-name "resultado"
    field tstatus        as int serialize-name "status"
    field Mensagem      as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.
def var vsaida as char.
def var vprodutos as char.

hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

vprodutos = "".
for each ttentrada.
    vprodutos = vprodutos +
            (if vprodutos = ""
             then ""
             else ",")
             +
             string(ttentrada.codigo).
end.

if vprodutos <> ""
then do:
    run  etiqueta/1/geraetiquetammix.p ("geraarquivomix","").

    create ttsaida.
    ttsaida.tstatus = 200.
    ttsaida.mensagem = "Arquivo gerados para Produtos: " + vprodutos.
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 300.
    ttsaida.mensagem = "Nao encontrei produtos de entrada.".

end.

hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).

vsaida  = string(vlcsaida).

message vsaida.
