def input  parameter vlcentrada as longchar.

def var vlcsaida   as longchar.


def temp-table ttparcela  no-undo serialize-name "parcelas"
                          field cpfCliente as char
                          field numeroContrato as char
                          field seqParcela as char
                          field vctoParcela as char
                          field valorParcela as char
                          field valorEncargo as char
                          field valorDesconto as char
                          field valorPago as char.


def temp-table ttentrada  no-undo serialize-name "boleto"
        field banco as char
        field nossoNumero as char
        field situacao as char
        field taxaEmissaoBoleto          as char.

def temp-table ttsaida  no-undo serialize-name "return"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.

def var par-recid-boleto as recid.
def var vdtvencimento as date.
def var vstatus as char.
def var tstatus as char.
def var vmensagem_erro as char.


def var par-rectitulo as recid.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


DEFINE DATASET dadosEntrada FOR ttentrada , ttparcela .


hEntrada = DATASET dadosEntrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.
if not avail ttentrada
then do:
        create ttsaida.
        ttsaida.tstatus = 500.
        ttsaida.descricaoStatus = "Entrada Vazia".
        hsaida  = temp-table ttsaida:handle.
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcsaida).
        return.
end.

find banco where banco.numban = int(ttentrada.banco) and banco.situacao = yes no-lock.
if int(ttentrada.banco) = 104
then do:
    find first bancarteira where  bancarteira.bancod   = banco.bancod no-lock no-error.
        find banboleto where banboleto.bancod = bancarteira.bancod and
                banboleto.agencia = bancarteira.agencia and
                banboleto.contacor = bancarteira.contacor and
                banboleto.bancart  = bancarteira.bancart and
                banboleto.nossonumero = int(substring(trim(ttentrada.nossonumero),3))
         no-lock no-error.

      /*find first banboleto where banboleto.bancod = banco.bancod and
                                 banboleto.nossonumero = int(substring(trim(ttentrada.nossonumero),3))
                              no-lock no-error.*/

end.
else do:
       find first bancarteira where  bancarteira.bancod   = banco.bancod no-lock no-error.
        find banboleto where banboleto.bancod = bancarteira.bancod and
              banboleto.agencia = bancarteira.agencia and
              banboleto.contacor = bancarteira.contacor and
              banboleto.bancart  = bancarteira.bancart and
              banboleto.nossonumero = int(ttentrada.nossonumero)
                        no-lock no-error.

end.
if not avail banBoleto
then do:
  create ttsaida.
  ttsaida.tstatus = 500.
  ttsaida.descricaoStatus = "Nosso Numero 1 " + substring(trim(ttentrada.nossonumero),3)
 + " nao existe para banco " + ttentrada.banco.
  hsaida  = temp-table ttsaida:handle.
  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcsaida).
  return.
end.

for each ttparcela.
    find contrato where contrato.contnum = int(ttparcela.numeroContrato) no-lock no-error.
    if not avail contrato
    then do:
        create ttsaida.
        ttsaida.tstatus = 500.
        ttsaida.descricaoStatus = "Contrato Numero " + ttparcela.numeroContrato + " nao existe".
        hsaida  = temp-table ttsaida:handle.
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcsaida).
        return.
    end.
    find first titulo where titulo.titnat = no and titulo.empcod = 19 and titulo.etbcod = contrato.etbcod and
      titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
      titulo.titnum = string(contrato.contnum) and titulo.titpar = int(ttparcela.seqParcela)
      no-lock no-error.
      if not avail titulo
      then do:
          create ttsaida.
          ttsaida.tstatus = 500.
          ttsaida.descricaoStatus = "Parcela Numero " + ttparcela.numeroContrato + "/" + ttparcela.seqParcela
          + " nao existe".
          hsaida  = temp-table ttsaida:handle.
          lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
          message string(vlcsaida).
          return.
      end.
    if titulo.titdtpag <> ? or titulo.titsit <> "LIB"
    then do:
        create ttsaida.
        ttsaida.tstatus = 500.
        ttsaida.descricaoStatus = "Parcela Numero " + ttparcela.numeroContrato + "/" + ttparcela.seqParcela
                                      + " esta PAGA".
        hsaida  = temp-table ttsaida:handle.
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcsaida).
        return.

    end.

end.

tstatus = "".

for each ttparcela.

        par-tabelaorigem = "titulo".
        par-chaveOrigem  = "contnum,titpar".
        par-dadosOrigem  = trim(ttparcela.numeroContrato) + "," + trim(ttparcela.seqParcela).
        par-valorOrigem  = dec(ttparcela.valorPago).

        run bol/vinculaboleto.p (
                input recid(banBoleto),
                input par-tabelaorigem,
                input par-chaveorigem,
                input par-dadosorigem,
                input par-valorOrigem,
                output vstatus,
                output vmensagem_erro).
    if vstatus <> "S"
    then tstatus = "N".
    else tstatus = "S".
end.
if tstatus = "S"
then do:
        create ttsaida.
        ttsaida.tstatus = 200.
        ttsaida.descricaoStatus = "Vinculo do Boleto OK".
end.
else do:
        create ttsaida.
        ttsaida.tstatus = 500.
        ttsaida.descricaoStatus = "Problema no Vinculo do Boleto".
end.

hsaida  = temp-table ttsaida:handle.
lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcsaida).
