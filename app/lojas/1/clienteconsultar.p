/* Helio 012024 - CADASTRO RÁPIDO NA PRÉ-VENDA */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "dadosEntrada" 
    field codigoFilial   as int
    field codigoCliente  as int
    field cpfCnpj        as char.   

def var vok as log.

{api/acentos.i}

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttclien serialize-name "cliente" 
    field codigoFilial   as int
    field codigoCliente        as int
    field cpfCnpj        as char
    field nomeCliente         as char 
    field dataNascimento         as date
    field telefone       as char.
    
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vclicod as int.
def var vcpfcnpj as dec.
def var par-certo as log.

hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttentrada no-error.


if not avail ttentrada
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vetbcod = int(ttentrada.codigoFilial).
find estab where estab.etbcod = vetbcod  and
                 estab.tipoloja = "LJ" no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab  then 500 else 400.
  ttsaida.descricaoStatus = "Filial " + string(ttentrada.codigoFilial)
                 + " Nao encontrada ou invalida.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vclicod = int(ttentrada.codigoCliente).
vcpfcnpj = dec(ttentrada.cpfcnpj).

run cpf.p (ttentrada.cpfCnpj, output par-certo).
    if not par-certo    
    then do:
       
        create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = "CPF Invalido".
    
        hsaida  = temp-table ttsaida:handle.
    
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    end.


if vclicod <> ?
then do:
    find clien where clien.clicod = vclicod no-lock no-error.
    if avail clien
    then do:
        find first neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    end.
end.
else do:
    if vcpfcnpj <> ?
    then do:
        find neuclien where neuclien.cpf = vcpfcnpj no-lock no-error.
        if avail neuclien
        then do:
            find clien where clien.clicod = neuclien.clicod no-lock no-error.
        end.
        else do:
            find first clien where clien.ciccgc = ttentrada.cpfcnpj no-lock no-error.
        end.
        
    end.
end.
if avail clien
then do:
    create ttclien.
    ttclien.codigoFilial    = vetbcod.
    ttclien.codigoCliente   = clien.clicod.
    ttclien.cpfCnpj         = clien.ciccgc.
    ttclien.nomeCliente     = clien.clinom.                              
    ttclien.dataNascimento  = clien.dtnasc.
    ttclien.telefone        = trim(string(clien.fone)).                                  
end. 
else do:

    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Cliente Nao Encontrado".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.

end.



hSaida = temp-table ttclien:HANDLE.

lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted trim(string(vlcsaida)).
end.

