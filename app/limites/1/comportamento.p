/* HUBSEG 19/10/2021 */


def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.

{/admcom/progr/api/acentos.i}

{neuro/achahash.i}
{neuro/varcomportamento.i}

pause 0 before-hide.

def var vdec as dec.
DEFINE VARIABLE lokJSON                  AS LOGICAL.

/* SAIDA */

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'Cliente'
    field cpfCNPJ    as char format "x(18)"    serialize-name 'cpfCNPJ'
    field clinom    as char format "x(40)" serialize-name 'nomeCliente'
    field clicod    as char format "x(12)" serialize-name 'codigoCliente'
    index cli is unique primary clicod asc.

DEFINE TEMP-TABLE ttcredito NO-UNDO   serialize-name 'creditoCliente'
    field clicod        as char format "x(12)" serialize-hidden
    field limite      as char format "x(20)"
    field vctoLimite  as char format "x(30)"
    field comprometido as char format "x(30)"
    field saldoLimite  as char format "x(30)"
    field tempoRelacionamento as char
    index cli is unique primary clicod asc .

DEFINE TEMP-TABLE ttmodalComportamento NO-UNDO   serialize-name 'comportamentoModalidade'
    field clicod        as char format "x(12)" serialize-hidden
    field modcod        as char serialize-name  'modcod'
    field comprometido  as char
    field dcomprometido  as dec  serialize-hidden
    index cli is unique primary clicod asc modcod asc .


DEFINE TEMP-TABLE ttcomportamento NO-UNDO   serialize-name 'comportamentoCliente'
    field clicod        as char format "x(12)"
            serialize-hidden
    field atributo      as char format "x(20)"
            serialize-name 'atributo'
    field valorAtributo as char format "x(30)"
            serialize-name 'valorAtributo'
    index cli is unique primary clicod asc atributo asc.

DEFINE DATASET conteudoSaida FOR ttclien, ttcredito, ttmodalComportamento ,ttcomportamento
  DATA-RELATION clicred FOR ttclien, ttcredito
        RELATION-FIELDS(ttclien.clicod,ttcredito.clicod) NESTED
  DATA-RELATION cliprofin FOR ttclien, ttmodalComportamento
        RELATION-FIELDS(ttclien.clicod,ttmodalComportamento.clicod) NESTED

  DATA-RELATION clicomp FOR ttclien, ttcomportamento
        RELATION-FIELDS(ttclien.clicod,ttcomportamento.clicod) NESTED.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

    def var vvlrlimite as dec.
    def var vvctolimite as date.
    def var vcomprometido as dec.
    def var vcomprometidohubseg as dec.
    
    def var vsaldoLimite as dec.
/* LE ENTRADA */
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
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

/*if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfCnpj = ?
           then ""
           else ttentrada.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.*/

hSaida = DATASET conteudoSaida:HANDLE.


    create ttclien.
    ttclien.clicod    = string(neuclien.clicod).
    ttclien.cpfCNPJ   = ttentrada.cpfCnpj.
    ttclien.clinom     = removeacento(if avail clien then clien.clinom else neuclien.Nome_Pessoa).

    create ttcredito.
    ttcredito.clicod = ttclien.clicod.
    ttcredito.tempoRelacionamento = if avail clien then string(today - clien.dtcad) else ?.
    vvlrlimite = 0.
    vvctolimite = ?.
    vcomprometido = 0.
    vsaldoLimite = 0.

    if avail neuclien
    then do:
        vvlrlimite = if neuclien.vctolimite < today
                    then 0
                    else neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.

    if avail clien
    then
    for each titulo where titulo.clifor = clien.clicod no-lock.
        if titulo.titsit = "LIB"
        then do:
            find first ttmodalcomportamento where
                    ttmodalcomportamento.clicod = string(clien.clicod) and
                    ttmodalcomportamento.modcod = titulo.modcod
                no-error.
            if not avail ttmodalcomportamento
            then do:
                create ttmodalcomportamento.
                ttmodalcomportamento.clicod = string(clien.clicod).
                ttmodalcomportamento.modcod = titulo.modcod.
            end.
            ttmodalcomportamento.dcomprometido = ttmodalcomportamento.dcomprometido +
                            titulo.titvlcob.
            /* para json */
            ttmodalcomportamento.comprometido = trim(string(ttmodalcomportamento.dcomprometido,">>>>>>>>>>>9.99")).
        end.
    end.

/*    ttclien.tempoRelacionamento = string(today - clien.dtcad). */


    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)".

    var-propriedades = "".
    run neuro/comportamento.p (neuclien.clicod,?,output var-propriedades). /* hubseg */
    do il = 1 to num-entries(var-propriedades,"#") with down.

        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).

        create ttcomportamento.
        ttcomportamento.clicod = ttclien.clicod.
        ttcomportamento.atributo        = vcampo.
        ttcomportamento.valoratributo   = r1.
        if vcampo = "LIMITETOMPR"
        then do:
            vcomprometido = dec(r1).
        end.
        if vcampo = "LIMITETOMHUBSEG"
        then do:
            vcomprometidohubseg = dec(r1).
        end.
        
        if neuclien.clicod = ?
        then do:
            if vcampo = "LIMITE" or vcampo = "LIMITEDISP"
            then do:
                ttcomportamento.valoratributo = trim(string(vlrlimite,"->>>>>>>>>9.99")).
            end.
        end.        
    end.
    vcomprometido = vcomprometido - vcomprometidohubseg. /*hubseg */
    
    vsaldoLimite = vvlrlimite - vcomprometido.
    if vvctolimite < today or vvctolimite = ? or
        vsaldoLimite < 0
    then vsaldoLimite = 0.

    ttcredito.limite        = trim(string(vvlrlimite,">>>>>>>>>>>9.99")).
    ttcredito.vctolimite    =   string(year(vvctolimite),"9999") + "-" +
                          string(month(vvctolimite),"99")   + "-" +
                          string(day(vvctolimite),"99").

    ttcredito.comprometido  = trim(string(vcomprometido,">>>>>>>>>>>9.99")).
    ttcredito.saldoLimite   = trim(string(vsaldoLimite,">>>>>>>>>>>9.99")).



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
