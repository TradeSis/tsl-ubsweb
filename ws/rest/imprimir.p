def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar. 

def new shared temp-table ttimpressoras no-undo serialize-name "impressoras"
    field impressora    as char.
    
def new shared temp-table ttentrada  no-undo serialize-name "produtos"
    field codigo       as int
    field nome          as char 
    field quantidade   as int
    field tamanho          as char 
    field preco         as char
    field ordem        as char.


def temp-table ttsaida  no-undo serialize-name "resultado"
    field tstatus        as int serialize-name "status"
    field Mensagem      as char.

def var lokjson as log.
def var himprimirentrada as handle.
def var hsaida   as handle.
def var vsaida as char.
def var vprodutos as char.

DEFINE DATASET imprimir
        FOR ttimpressoras, ttentrada. 

himprimirEntrada = DATASET imprimir:HANDLE.


lokJSON = himprimirentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

        
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
    find first ttimpressoras no-error.
    run  geraetiqueta.p ("imprimir",if avail ttimpressoras then ttimpressoras.impressora else "").
    
    create ttsaida.
    ttsaida.tstatus = 200.
    ttsaida.mensagem = "Arquivo gerado e impresso para Produtos: " + vprodutos.
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

