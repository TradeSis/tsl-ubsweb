
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char
    field numero_contrato   as char.
    
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def var lokJson as log.

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.

def var vcontnum as int64.
def var vstatus as char.
def var vmensagem_erro as char.
    /* Numeracao Contratos **/
vstatus = "S".
    
    do for geranum on error undo on endkey undo:
        find geranum where geranum.etbcod = 999 
            exclusive-lock 
            no-wait 
            no-error.
        if not avail geranum
        then do:
            if not locked geranum
            then do:
                create geranum.
                assign
                    geranum.etbcod  = 999
                    geranum.clicod  = 300000000
                    geranum.contnum = 300000000.
                vcontnum = geranum.contnum.    
                find current geranum no-lock.
            end.
            else do: /** LOCADO **/
                vstatus = "E".
                vmensagem_erro = "Tente novamente". 
            end.
        end.
        else do:
            geranum.contnum = geranum.contnum + 1. 
            find current geranum no-lock. 
            vcontnum = geranum.contnum.
        end.
    end.
if vstatus = "S"
then do:
  create ttsaida.
  ttsaida.tstatus = 200.
  ttsaida.numero_contrato = string(vcontnum).
  ttsaida.descricaoStatus = "".
end.
else do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.numero_contrato = ?.
  ttsaida.descricaoStatus = vmensagem_erro.

end.

  hsaida  = temp-table ttsaida:handle.
  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).





