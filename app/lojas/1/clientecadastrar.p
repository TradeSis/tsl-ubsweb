/* Helio 012024 - CADASTRO RÁPIDO NA PRÉ-VENDA */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "dadosEntrada" 
    field codigoFilial   as int
    field cpfCnpj        as char
    field nomeCliente         as char 
    field dataNascimento         as date
    field telefone       as char.

def var vok as log.

{api/acentos.i}

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttclien serialize-name "cliente" 
    field codigoFilial   as int
    field codigoCliente        as int.
    
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var par-clicod as int.
def var vcpfcnpj as dec.

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
find estab where estab.etbcod = vetbcod  no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab  then 500 else 404.
  ttsaida.descricaoStatus = "Estabelecimento de origem " + string(ttentrada.codigoFilial)
                 + " N�o encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


vcpfcnpj = dec(ttentrada.cpfcnpj).
if vcpfcnpj = ?
then do:

  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "CPF nao Informado".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.
def var par-certo as log. /* faltou def */

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

    if ttentrada.nomeCliente = ? or trim(ttentrada.nomeCliente) = "" or num-entries(trim(ttentrada.nomeCliente)," ") < 2
    then do:
        create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = "NOME Invalido".
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    end.
    def var vdtnasc as date.
    def var vdia as int.
    def var vmes  as int.
    def var vano    as int.
    vano = year(today) - 18. /* 18 anos */
    vmes = month(today).
    vdia = day(today).
    vdtnasc = date(vmes,vdia,vano).

    if ttentrada.datanascimento = ? or ttentrada.datanascimento > vdtnasc or
        year(ttentrada.datanascimento)  < year(today) - 100
    then do:
      
        create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = "DATA NASCIMENTO Invalida".
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.

    end.

    if ttentrada.telefone = ? or trim(ttentrada.telefone) = "" or
        length(trim(ttentrada.telefone)) < 10 
    then do:
       
        create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = "TELEFONE Invalido".
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    end.
    vok = no.
    def var vx as char.
    def var vconta as int.
    vx = substring(ttentrada.telefone,4,1).
    do vconta = 4 to  length(ttentrada.telefone):
        if substring(ttentrada.telefone,vconta,1) <> vx
        then do:
            vok = yes.
            leave.
        end.    
    end.
    if vok = no
    then do:
        create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = "TELEFONE Invalido!".
      
        hsaida  = temp-table ttsaida:handle.
      
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    end.    


if vcpfcnpj <> ?
then do:
    find neuclien where neuclien.cpf = vcpfcnpj no-lock no-error.
    if avail neuclien
    then do:
        find clien where clien.clicod = neuclien.clicod no-lock no-error.
    end.
    else do:
        find clien where clien.ciccgc = ttentrada.cpfcnpj no-lock no-error.
    end.
end.

if avail clien
then do on error undo:
create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "CPF ja  cadastrado ,codigo=" + string(clien.clicod).

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

 run p-geraclicod.p (output par-clicod).
do on error undo.
    create clien.
    assign
        clien.clicod = par-clicod .
        clien.ciccgc = trim(string(dec(ttentrada.cpfCnpj),"99999999999")).
        clien.clinom = removeacento(ttentrada.nomeCliente).
        clien.tippes = yes.
        clien.etbcad = vetbcod.
        clien.dtnasc = ttentrada.dataNascimento.
        clien.fone = ttentrada.telefone.
        clien.datexp = today.

    find neuclien where  neuclien.cpfcnpj = dec(clien.ciccgc) no-lock no-error.
    if not avail neuclien
    then do:
        create neuclien.
        neuclien.cpfcnpj = dec(clien.ciccgc).
        neuclien.tippes  = clien.tippes.
        neuclien.etbcod  = clien.etbcad.
        neuclien.dtcad   = today.
        neuclien.nome_pessoa = clien.clinom.
        neuclien.clicod = clien.clicod.
    end.
        
    create ttclien.
    ttclien.codigoFilial    = vetbcod.
    ttclien.codigoCliente   = par-clicod.


end.


hSaida = temp-table ttclien:HANDLE.

lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted trim(string(vlcsaida)).
end.
