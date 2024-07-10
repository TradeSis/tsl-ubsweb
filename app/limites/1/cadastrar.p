/* helio 06022023 - https://trello.com/c/W5Gpd4wV/980-problema-no-retorno-api-de-limites-admcom-id-158338
            tratamento erro quando nao informam o vctolimite */

/* HUBSEG 19/10/2021 */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "cliente"
    field cpfCnpj as dec decimals 2
    field nomeCliente as char
    field dataNascimento as char
    field limite as char
    field vctoLimite as char.

def var vvlrold as dec.
def var vvctoold as date.

def var vconta as int.
def var vx as int.
/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

/* SAIDA */

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'creditoCliente'
    field tipo    as char format "x(18)"
    field clicod    as int64 serialize-name 'codigoCliente'
    field cpfCNPJ    as char format "x(18)"    serialize-name 'cpfCNPJ'
    field clinom    as char format "x(40)" serialize-name 'nomeCliente'
    field limite      as char format "x(20)"
    field vctoLimite  as char format "x(30)"
    field comprometido as char format "x(30)"
    field saldoLimite  as char format "x(30)"
    index cli is unique primary clicod asc tipo desc.

DEFINE DATASET conteudoSaida FOR ttclien.

hSaida = DATASET conteudoSaida:HANDLE.
def var lokjson as log.

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

    def var vvlrlimite  as dec.
    def var vvlrdisponivel as dec.
    def var vvctolimite as date.
    def var var-salaberto-hubseg as dec.
    def var var-salaberto-principal as dec.
    def var var-salaberto-principalEP as dec.
    

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

find neuclien where neuclien.cpfCnpj =  dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do on error undo:
    create neuclien.
    neuclien.CpfCnpj         = ttentrada.CpfCnpj.
    neuclien.DtCad           = today.
    neuclien.Nome_Pessoa     = ttentrada.nomeCliente.
    neuclien.DtNasc          = today /*ttentrada.DtNasc */ .
    /*
    neuclien.Nome_Mae        = ttentrada.Nome_Mae
    */
    neuclien.etbcod          = 200 /*ttentrada.etbcod*/ .
    neuclien.tippes          = yes.



    find clien where clien.ciccgc = trim(string(ttentrada.cpfCnpj)) no-lock no-error.
    if avail clien
    then do:
        if clien.clicod <> ?
        then neuclien.Clicod          = clien.Clicod.
    end.

end.

do on error undo:
    release clien.
    if neuclien.clicod <> ?
    then find clien where clien.clicod = neuclien.clicod no-lock no-error.

    find current neuclien exclusive.

    if avail neuclien
    then do:


        vvlrold     = neuclien.vlrlimite.
        vvctoold    = neuclien.vctolimite.
        
        neuclien.VlrLimite       = dec(ttentrada.limite).
        neuclien.VctoLimite      = date(int(entry(2,ttentrada.VctoLimite,"-")),
                                        int(entry(3,ttentrada.VctoLimite,"-")),
                                        int(entry(1,ttentrada.VctoLimite,"-")))
                                            no-error. /* helio 06022023 - tratamento erro quando nao informam o vctolimite */
    
        run neuro/gravaneuclilog.p
                    (neuclien.cpfcnpj,
                     "APiLimite",
                     time,
                     200,
                     0,
                     "",
                     "De " +
                         (if vvlrold = ?
                           then "-"
                          else trim(string(vvlrold,">>>>>9.99"))) +
                         "-"   +
                            (if neuclien.vlrlimite = ?
                             then "-"
                          else trim(string(neuclien.vlrlimite,">>>>>9.99"))) +
                         " " +
                             (if vvctoold = ?
                             then "-"
                          else string(vvctoold,"99/99/9999")) +
                         "-"   +
                             (if neuclien.vctolimite = ?
                             then "-"
                              else string(neuclien.vctolimite,"99/99/9999"))
                        
                                ).
    
    end.
    if avail clien
    then do:
        neuclien.Clicod          = clien.Clicod.
    end.

end.

def var pstatus as char.
def var pmensagem as char.

  find current neuclien no-lock.

  create ttclien.
  ttclien.tipo   = "Global".
  ttclien.clicod = if avail clien then clien.clicod else ?.
  ttclien.clinom = neuclien.nome_pessoa.
  ttclien.cpfCnpj = string(neuclien.cpf).

  vvlrlimite = 0.
  vvctolimite = ?.
  vvlrdisponivel = 0.

  if avail neuclien
  then do:
      vvlrlimite = if neuclien.vctolimite < today
                  then 0
                  else neuclien.vlrlimite.
      vvctolimite = neuclien.vctolimite.
  end.
      ttclien.vctoLimite  =  string(year(vvctolimite),"9999") + "-" +
                            string(month(vvctolimite),"99")   + "-" +
                            string(day(vvctolimite),"99").
      ttclien.Limite   = trim(string(vvlrLimite,">>>>>>>>>>>>>>>>>>9.99")).

      var-propriedades = "" .

          run /admcom/progr/neuro/limites.p (neuclien.cpfcnpj,   output var-propriedades).

          var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
          if var-salaberto-principal = ? then var-salaberto-principal = 0.

          var-salaberto-HUBSEG = dec(pega_prop("LIMITETOMHUBSEG")).
          if var-salaberto-HUBSEG = ? then var-salaberto-HUBSEG = 0.
            var-salaberto-principal = var-salaberto-principal - var-salaberto-HUBSEG.          

      vvlrdisponivel = vVlrLimite - var-salaberto-principal.
      if vvlrdisponivel < 0
      then vvlrdisponivel = 0.

      ttclien.comprometido   = trim(string(var-salaberto-principal,">>>>>>>>>>>>>>>>>>9.99")).
      ttclien.saldoLimite    = trim(string(vvlrdisponivel,">>>>>>>>>>>>>>>>>>9.99")).


      create ttclien.
      ttclien.tipo   = "EP".
      ttclien.clicod = if avail clien then clien.clicod else ?.
      ttclien.clinom = neuclien.nome_pessoa.
      ttclien.cpfCnpj = string(neuclien.cpf).

      vvlrlimite = dec(pega_prop("LIMITEEP")).
      var-salaberto-principalEP = dec(pega_prop("LIMITETOMPREP")).
      vvlrdisponivel = dec(pega_prop("LIMITEDISPEP")).

          ttclien.vctoLimite  =  string(year(vvctolimite),"9999") + "-" +
                                string(month(vvctolimite),"99")   + "-" +
                                string(day(vvctolimite),"99").
          ttclien.Limite   = trim(string(vvlrLimite,">>>>>>>>>>>>>>>>>>9.99")).

          ttclien.comprometido   = trim(string(var-salaberto-principalEP,">>>>>>>>>>>>>>>>>>9.99")).
          ttclien.saldoLimite    = trim(string(vvlrdisponivel,">>>>>>>>>>>>>>>>>>9.99")).



lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted string(vlcsaida).
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 500.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
