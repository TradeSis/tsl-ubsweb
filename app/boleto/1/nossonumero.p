def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.

/**
{"dadosEntrada":{
        "cpfCliente": "00315554037",
        "dataVencimentoBoleto": "2021-05-15",
        "valorTotalBoleto": "99.90",
        "taxaEmissaoBoleto": "1.00",
        "banco": "104"
}}
**/

def new shared temp-table ttentrada  no-undo serialize-name "dadosEntrada"
    field cpfCliente       as char
    field dataVencimentoBoleto          as char
    field valorTotalBoleto   as char
    field taxaEmissaoBoleto          as char
    field banco         as char.

/**
{
    "status": "200",
    "descricaoStatus": "tudo Certo",
    "nossoNumero": 626159120
}**/

def temp-table ttsaida  no-undo serialize-name "return"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char
    field nossoNumero as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.

def var par-recid-boleto as recid.
def var vdtvencimento as date.
def var vstatus as char.
def var vmensagem_erro as char.



hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.
if not avail ttentrada
then do:
        create ttsaida.
        ttsaida.tstatus = 500.
        ttsaida.descricaoStatus = "Entrada Vazia".
end.

find neuclien where neuclien.cpf =  dec(ttentrada.cpfcliente) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfcliente) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfcliente = ?
           then ""
           else ttentrada.cpfcliente) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.


    vdtvencimento = date(     /**"2021-05-15"**/
                     int(substr(ttentrada.dataVencimentoBoleto,6,2)),
                     int(substr(ttentrada.dataVencimentoBoleto,9,2)),
                     int(substr(ttentrada.dataVencimentoBoleto,1,4))) no-error.
    if vdtvencimento < today
    then do:

          create ttsaida.
          ttsaida.tstatus = 400.
          ttsaida.descricaoStatus = "Data Vencimento Invalida".
          hsaida  = temp-table ttsaida:handle.

          lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
          message string(vlcSaida).
          return.

    end.

    run bol/geradadosboleto.p (
                    input ttentrada.banco, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "api/boleto",
                    input clien.clicod,
                    input "",
                    input vdtvencimento,
                    input dec(ttentrada.valorTotalBoleto),
                    input dec(ttentrada.taxaEmissaoBoleto ),
                    output par-recid-boleto,
                    output vstatus,
                    output vmensagem_erro).

    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock
        no-error.
    if vstatus = "S" and avail banBoleto
    then do:
        create ttsaida.
        ttsaida.tstatus = 200.
        ttsaida.descricaoStatus = "Nosso Numero Gerado para banco " + ttentrada.banco.
        ttsaida.nossoNumero = banboleto.impnossonumero.
    end.
    else do:
        create ttsaida.
        ttsaida.tstatus = 500.
        ttsaida.descricaoStatus = vmensagem_erro.
    end.

hsaida  = temp-table ttsaida:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).


message string(vlcsaida).
