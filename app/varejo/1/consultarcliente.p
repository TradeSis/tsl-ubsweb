
def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var lokJSON as log. 
def var vent-dtnasc     as date.
def var vent-celular    as char.
def var vent-cpfcnpj    as dec.
def var vdataNascimento as char.
def var vcelular as char.
def var vcpfcnpj as dec.

def temp-table ttentrada no-undo serialize-name "cliente"
    field cpfCnpj as char
    field dataNascimento as char
    field celular       as char.

{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

def temp-table ttcliente no-undo serialize-name "cliente"
    field tstatus  as int  serialize-name "status"
    field possuiCrediario as log  init ?
    field limiteDisponivel      as char init 0
    field celularValido        as log init false
    field codigoCliente as int init ?.
    
    
{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.


hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttentrada no-error.
if not avail ttentrada
then do:
  create ttcliente.
  ttcliente.tstatus = 500.

  hsaida  = temp-table ttcliente:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vcpfCnpj = dec(ttentrada.cpfCnpj) no-error.
vent-dtnasc                    = date(int(entry(2,ttentrada.dataNascimento,"-")),
                                      int(entry(3,ttentrada.dataNascimento,"-")),
                                      int(entry(1,ttentrada.dataNascimento,"-"))) no-error.


vent-celular = ttentrada.celular no-error.
if vcpfcnpj = 0 or vcpfcnpj = ? or vent-dtnasc = ? or vent-celular = ? or vent-celular = ""
then do:
  create ttcliente.
  ttcliente.tstatus = 400.

  hsaida  = temp-table ttcliente:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) no-lock no-error.
if avail clien
then do:
    find neuclien where neuclien.clicod =  clien.clicod no-lock no-error.
end.    

if not avail clien
then do:

  create ttcliente.
  ttcliente.tstatus = 404.

  hsaida  = temp-table ttcliente:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

    var-propriedades = "" .

    run /admcom/progr/neuro/comportamento.p (clien.clicod, ?,   output var-propriedades).

    var-salaberto = dec(pega_prop("LIMITETOM")).
    if var-salaberto = ? then var-salaberto = 0.

    var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
    if var-salaberto-principal = ? then var-salaberto-principal = 0.

    var-salaberto-hubseg = dec(pega_prop("LIMITETOMHUBSEG")).
    if var-salaberto-hubseg = ? then var-salaberto-hubseg = 0.


            vvctoLimite  = if avail neuclien
                           then neuclien.vctolimite
                           else ?.
            vvlrLimite   = if vvctolimite = ? or vvctolimite < today
                           then 0
                           else if avail neuclien
                                then neuclien.vlrlimite
                                else 0.


            vvlrdisponivel = vVlrLimite - (var-salaberto-principal - var-salaberto-hubseg).
            if vvlrdisponivel < 0
            then vvlrdisponivel = 0.


create ttcliente.
ttcliente.tstatus = 200.

ttcliente.codigoCliente                 = clien.clicod.
ttcliente.possuicrediario                 = avail neuclien.
vcelular =  RemoveAcento(clien.FAX).
vdataNascimento                = string(year(clien.dtnasc),"9999") + "-" + string(month(clien.dtnasc),"99")   + "-" + string(day(clien.dtnasc),"99").

ttcliente.celularValido =  ttentrada.celular = vcelular and
                           ttentrada.dataNascimento = vdataNascimento.

if ttcliente.celularValido
then ttcliente.limiteDisponivel   = trim(string(vvlrdisponivel,"->>>>>>>>9.99")).
else ttcliente.limiteDisponivel = "null".

hsaida  = temp-table ttcliente:handle.
lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted trim(string(vlcsaida)).
end.
else do:
    create ttcliente.
    ttcliente.tstatus = 500.

    hsaida  = temp-table ttcliente:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
