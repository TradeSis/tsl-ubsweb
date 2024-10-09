/* {"dadosSaida":{
  "contato":[
  {
    "numeroContrato": "3131525241",
    "dataEmissao": "2024-01-23",
    "saldoDevedorPrincipal": "309.45",
    "somaParcelas": "1151.50",
    "valorParcelaComAcrescimo": "115.15",
    "valroParcelaPrincipal": "103.15",
    "qtdParcelas": "10",
    "qtdParcelasAbertas": "3",
    "proximoVencimento:": "2024-10-23"
  }
  
] }} */
def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var lokJSON as log. 

def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field cpfCnpj as char.

def temp-table ttcontrato no-undo serialize-name "contato"
  field numeroContrato as INT 
  field dataEmissao as DATE
  field saldoDevedorPrincipal as dec 
  field somaParcelas as dec
  field valorParcelaComAcrescimo as dec  
  field valorParcelaPrincipal AS DEC 
  field qtdParcelas as INT 
  field qtdParcelasAbertas as int 
  field proximoVencimento as date.


def var vdias as int init 0.
def var tdias as int init 0.
def var vtitvlpag as dec.
def var vpercpag as dec.
def var velegivel as log.
def var velegivel-contrato as log.
DEF VAR vsaldoDevedorPrincipal AS DEC.
DEF VAR vqtdParcelas AS INT.
DEF VAR vqtdParcelasAbertas AS INT.
DEF VAR vsomaParcelas AS DEC.
DEF VAR vvalorParcelaPrincipal AS DEC.
DEF VAR vproximoVencimento AS DATE.
DEF VAR vvalorParcelaComAcrescimo AS DEC.

DEF VAR json AS CHAR.


hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.
if not avail ttentrada
then do:
  return.
end.
  

find neuclien where neuclien.cpf = dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
     find first clien where clien.ciccgc = ttentrada.cpfCnpj no-lock no-error.
end.
else do:
     find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.
if not avail clien
then do:
  return.
end.

tdias = 0.

find first rfnparam where rfnparam.dtinivig <= today 
                          no-lock no-error.
if avail rfnparam 
then do:
 
    for each contrato of clien no-lock.
      /*disp contrato.contnum format ">>>>>>>>>9" contrato.modcod contrato.dtinicial.*/
        
        vtitvlpag = 0.
        vpercpag  = 0.
        velegivel-contrato = yes.

        if rfnparam.listaModalidades <> ? and
          rfnparam.listaModalidades <> ""
        then do:
            if lookup(string(contrato.modcod),rfnparam.listaModalidades) <> 0
            then.
            else do:
                velegivel-contrato = no.
            end.
        end.
      
        if velegivel-contrato
        then do:
            if rfnparam.permiteNovacao = no AND contrato.tpcontrato = "N"
            then do:
                velegivel-contrato = no.
            end.
        end.

        vsaldoDevedorPrincipal = 0.
        vqtdParcelas    = 0.
        vqtdParcelasAbertas = 0.
        vsomaParcelas = 0.
        vvalorParcelaPrincipal = 0.
        vproximoVencimento  = ?.
        for each titulo where
            titulo.empcod = 19 and titulo.titnat = no and
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum)
            no-lock
                by titulo.titpar. 
            if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
            then.
            else next.
            
            if velegivel-contrato
            then do: 
            
                if rfnparam.carteirasPermitidas <> ? and
                    rfnparam.carteirasPermitidas <> ""
                then do:
                    if lookup(string(titulo.cobcod),rfnparam.carteirasPermitidas) <> 0
                    then .
                    else do:
                        velegivel-contrato = no.
                    end.
                end.
            end.
            if titulo.titpar > 0
            then vqtdParcelas = vqtdParcelas + 1.
            vvalorParcelaPrincipal      = if titulo.vlf_principal > 0
                                          then titulo.vlf_principal
                                          else titulo.titvlcob.
            vvalorParcelaComAcrescimo   = titulo.titvlcob.
            if titulo.titsit = "LIB"
            then do:
            
                if vproximoVencimento = ?
                then vproximoVencimento = titulo.titdtven.
                vdias = today - titulo.titdtven.
                tdias = max(tdias,vdias).
                if titulo.vlf_principal > 0
                then vsaldoDevedorPrincipal = vsaldoDevedorPrincipal + titulo.vlf_principal.
                else vsaldoDevedorPrincipal = vsaldoDevedorPrincipal + titulo.titvlcob.
                vsomaParcelas          = vsomaParcelas          + titulo.titvlcob.
                vqtdParcelasAbertas    = vqtdParcelasAbertas    + 1.
            end.
            if titulo.titsit = "PAG"
            then do:
                vtitvlpag = vtitvlpag + titulo.titvlcob.
            end.
            vpercpag = vtitvlpag / contrato.vltotal * 100.
            
        end.
        
        if velegivel-contrato
        then do:
            if rfnparam.contratoPago > 0
            then do.
                if vpercpag < rfnparam.contratoPago or vpercpag = 100
                then do:
                    velegivel-contrato = no.
                end.
            end.
        end.
         
        if velegivel-contrato
        then do:   
            create ttcontrato.
            ttcontrato.numeroContrato           = contrato.contnum. 
            ttcontrato.dataEmissao              = contrato.dtinicial.
            ttcontrato.saldoDevedorPrincipal    = vsaldoDevedorPrincipal.
            ttcontrato.somaParcelas             = vsomaParcelas.
            ttcontrato.valorParcelaComAcrescimo = vvalorParcelaComAcrescimo.
            ttcontrato.valorParcelaPrincipal    = vvalorParcelaPrincipal.
            ttcontrato.qtdParcelas              = vqtdParcelas.
            ttcontrato.qtdParcelasAbertas       = vqtdParcelasAbertas.
            ttcontrato.proximoVencimento        = vproximoVencimento.
        end.

    end.
    
    if  rfnparam.diasAtrasoMax > 0
    then do:
        if tdias >  rfnparam.diasAtrasoMax
        then do:
            for each ttcontrato.
                delete ttcontrato.
            end.
        end.
    end.
    
end. /* rfnparam */

find first ttcontrato no-error.
if not avail ttcontrato
then do:
    json = "Nenhum contrato selecionado".
    MESSAGE string(json).
    return.
end.
else do:
    hsaida  = temp-table ttcontrato:handle.
    lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
    if lokJson
    then do:
            put unformatted trim(string(vlcsaida)).
    end.
    else do:
        
        hsaida  = temp-table ttcontrato:handle.
    
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    end.
end.


