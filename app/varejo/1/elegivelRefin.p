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

def temp-table ttcontato no-undo serialize-name "contato"
  field numeroContrato as char 
  field dataEmissao as char
  field saldoDevedorPrincipal as char 
  field somaParcelas as char
  field valorParcelaComAcrescimo as char 
  field valroParcelaPrincipal as char 
  field qtdParcelas as char 
  field qtdParcelasAbertas as char 
  field proximoVencimento as char.

hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.
if not avail ttentrada
then do:
  return.
end.
   
create ttcontato.
ttcontato.numeroContrato           = "3131525241". 
ttcontato.dataEmissao              = "2024-01-23".
ttcontato.saldoDevedorPrincipal    = "309.45".
ttcontato.somaParcelas             = "1151.50".
ttcontato.valorParcelaComAcrescimo = "115.15".
ttcontato.valroParcelaPrincipal    = "103.15".
ttcontato.qtdParcelas              = "10".
ttcontato.qtdParcelasAbertas       = "3".
ttcontato.proximoVencimento        = "2024-10-23".

create ttcontato.
ttcontato.numeroContrato           = "62621525241". 
ttcontato.dataEmissao              = "2024-01-24".
ttcontato.saldoDevedorPrincipal    = "609.45".
ttcontato.somaParcelas             = "2251.50".
ttcontato.valorParcelaComAcrescimo = "225.15".
ttcontato.valroParcelaPrincipal    = "203.15".
ttcontato.qtdParcelas              = "20".
ttcontato.qtdParcelasAbertas       = "6".
ttcontato.proximoVencimento        = "2024-10-26".


hsaida  = temp-table ttcontato:handle.
lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted trim(string(vlcsaida)).
end.
else do:
    
    hsaida  = temp-table ttcontato:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
