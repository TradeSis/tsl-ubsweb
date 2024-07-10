/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vid as int.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.
{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}




 
def var xtime as int.

def var vmessage as log.
vmessage = no.

{aco/acordo.i new}

def buffer bttnegociacao for ttnegociacao.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field tipoPessoa as char
        field codigoCliente as char
        field nome as char
        field cpfCnpj as char
        field celular as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttnegociacoes NO-UNDO SERIALIZE-NAME "negociacoes"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field idNegociacao  as char
        field descritivo    as char
        field valor_total_divida as char
        field qtdContratos  as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttsaidacondicoes NO-UNDO SERIALIZE-NAME "condicoes"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field idCondicao    as char
        field nome as char
        field   tipoCondicao as char    
        field valor_entrada as char
        field valor_parcela as char
        field qtdParcelas as char
        field valor_total as char
        index x is unique primary idpai asc id asc.


DEFINE DATASET conteudoSaida FOR ttcliente, ttnegociacoes, ttsaidacondicoes
   DATA-RELATION for3 FOR ttcliente, ttnegociacoes       RELATION-FIELDS(ttcliente.id,ttnegociacoes.idpai) NESTED
   DATA-RELATION for4 FOR ttnegociacoes, ttsaidacondicoes      RELATION-FIELDS(ttnegociacoes.id,ttsaidacondicoes.idpai) NESTED.


hSaida = DATASET conteudoSaida:HANDLE.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

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

if not avail clien
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

end.


create ttcliente.
ttcliente.id = string(clien.clicod).

ttcliente.tipoPessoa =   string(clien.tippes,"F/J").

codigoCliente = string(clien.clicod).
ttcliente.nome = removeacento(clien.clinom).
ttcliente.cpfCnpj = clien.ciccgc.

ttcliente.celular   = Texto(clien.FAX).

run cob/ajustanovacordo.p (input clien.clicod, output p-temacordo).

run calcelegiveis ("ACORDO ONLINE", clien.clicod, input ?).

for each ttnegociacao.
    
    find aconegoc of ttnegociacao no-lock.

    create ttnegociacoes.
    ttnegociacoes.id                 = string(ttnegociacao.negcod).
    ttnegociacoes.idPai              = ttcliente.id.
    ttnegociacoes.IDNegociacao       = string(ttnegociacao.negcod).
    ttnegociacoes.descritivo         = aconegoc.negnom.
    ttnegociacoes.valor_total_divida = trim(string(ttnegociacao.vlr_divida,"->>>>>>>>>>9.99")).
    ttnegociacoes.qtdContratos       = trim(string(ttnegociacao.qtd,"->>>>>>>>>>9")).

    for each ttcondicoes.
      delete ttcondicoes.
   end.  
    run montacondicoes (input ttnegociacao.negcod,?).
    vid = 0.
    for each ttcondicoes where ttcondicoes.negcod = ttnegociacao.negcod.
        
        find acoplanos where
            acoplanos.negcod  = ttcondicoes.negcod and
            acoplanos.placod  = ttcondicoes.placod
            no-lock.

        create ttsaidacondicoes. 
        ttsaidacondicoes.id            = string(ttcondicoes.placod).
        ttsaidacondicoes.idPai         = ttnegociacoes.id .
        ttsaidacondicoes.IDCondicao    = string(ttcondicoes.placod).
        ttsaidacondicoes.nome          = ttcondicoes.planom.
        ttsaidacondicoes.tipoCondicao  = if acoplanos.qtd_vezes = 0 then "AVISTA" else "CREDIARIO".
        ttsaidacondicoes.valor_entrada = trim(string(ttcondicoes.vlr_entrada,"->>>>>>>>>>9.99")).
        ttsaidacondicoes.valor_parcela = trim(string(ttcondicoes.vlr_parcela,"->>>>>>>>>>9.99")).
        ttsaidacondicoes.qtdParcelas   = trim(string(acoplanos.qtd_vezes,"->>>>>>>>>>9")).
        ttsaidacondicoes.valor_total   = trim(string(ttcondicoes.vlr_acordo,"->>>>>>>>>>9.99")).
    
    end.

end.    
         



def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apiacordosgetnegociacoes" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).
if lokJson
then do:
    os-command value("cat " + varquivo).
    os-command value("rm -f " + varquivo).
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


