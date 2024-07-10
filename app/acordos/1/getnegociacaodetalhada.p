/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vid as int.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char
    field idNegociacao as char.
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

DEFINE TEMP-TABLE ttcontratos NO-UNDO SERIALIZE-NAME "contratos"
    field id as char serialize-hidden
    field idPai as char serialize-hidden
    field filial_contrato as char
    field modalidade    as char
    field numero_contrato   as char /* " : "0016949483", */
    field data_emissao_contrato as char /*" : "2014-02-08",*/
    field valor_contrato    as char
    field valor_total_pago  as char
    field valor_total_pendente as char
    field valor_total_encargo as char
    field valor_total_divida as char
    field qtdParcelas   as char
    index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcontrato-parcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field id as char serialize-hidden
    field idPai as char serialize-hidden
    field seq_parcela as char
    field   venc_parcela as char    
    field vlr_parcela as char
    field valor_encargos as char
    field valor_total as char
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

DEFINE TEMP-TABLE ttsaidaparcelasNegociadas NO-UNDO SERIALIZE-NAME "parcelasNegociadas"
    field id as char serialize-hidden
    field idPai as char serialize-hidden
    field idCondicao    as char
    field seq_parcela   as char
    field venc_parcela  as char
    field vlr_parcela   as char.

DEFINE DATASET conteudoSaida FOR ttcliente, ttnegociacoes, ttcontratos, ttcontrato-parcelas ,ttsaidacondicoes,
            ttsaidaparcelasNegociadas
   DATA-RELATION for3 FOR ttcliente, ttnegociacoes       RELATION-FIELDS(ttcliente.id,ttnegociacoes.idpai) NESTED
   DATA-RELATION for3 FOR ttnegociacoes, ttcontratos       RELATION-FIELDS(ttnegociacoes.id,ttcontratos.idpai) NESTED
   DATA-RELATION for4 FOR ttcontratos, ttcontrato-parcelas      RELATION-FIELDS(ttcontratos.id,ttcontrato-parcelas.idpai) NESTED
   DATA-RELATION for4 FOR ttnegociacoes, ttsaidacondicoes      RELATION-FIELDS(ttnegociacoes.id,ttsaidacondicoes.idpai) NESTED
   DATA-RELATION for4 FOR ttsaidacondicoes, ttsaidaparcelasNegociadas      RELATION-FIELDS(ttsaidacondicoes.id,ttsaidaparcelasNegociadas.idpai) NESTED.


hSaida = DATASET conteudoSaida:HANDLE.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.

def var vqtdParcelas as int.
def var vvlrParcelas as dec.
def var vjuros as dec.

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


run cob/ajustanovacordo.p (input clien.clicod, output p-temacordo).

run calcelegiveis ("ACORDO ONLINE", clien.clicod, ?).


find first ttnegociacao where ttnegociacao.negcod = int(ttentrada.idNegociacao) no-error.

if not avail ttnegociacao
then do:

    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Negociacao " + ttentrada.idNegociacao + " Não encontrada.".

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

for each ttnegociacao where ttnegociacao.negcod = int(ttentrada.idNegociacao).
    
    find aconegoc of ttnegociacao no-lock.

    create ttnegociacoes.
    ttnegociacoes.id                 = string(ttnegociacao.negcod).
    ttnegociacoes.idPai              = ttcliente.id.
    ttnegociacoes.IDNegociacao       = string(ttnegociacao.negcod).
    ttnegociacoes.descritivo         = aconegoc.negnom.
    ttnegociacoes.valor_total_divida = trim(string(ttnegociacao.vlr_divida,"->>>>>>>>>>9.99")).
    ttnegociacoes.qtdContratos       = trim(string(ttnegociacao.qtd,"->>>>>>>>>>9")).


    for each ttcontrato  where ttcontrato.negcod = ttnegociacao.negcod.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.

        vqtdParcelas = 0.
        for each titulo where titulo.empcod = 19 and titulo.titnat = no and
            titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
            titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
            and titulo.titsit = "LIB"
            no-lock.
            vqtdParcelas = vqtdParcelas + 1.
            vvlrParcelas = vvlrParcelas + titulo.titvlcob.
        end.
        if vqtdParcelas = 0 then next.

        create ttcontratos.
        ttcontratos.id = string(contrato.contnum) .
        ttcontratos.idpai = ttnegociacoes.id.
        filial_contrato = string(contrato.etbcod).
        modalidade      = contrato.modcod.
        numero_contrato = string(contrato.contnum).        

        data_emissao_contrato   = string(year(contrato.dtinicial)) + "-" + string(month(contrato.dtinicial),"99") + "-" + string(day(contrato.dtinicial),"99").        
        ttcontratos.valor_contrato      = trim(string(contrato.vltotal,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_pago      = trim(string(contrato.vltotal - ttcontrato.vlr_aberto,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_pendente      = trim(string(ttcontrato.vlr_aberto,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_encargo      = trim(string(ttcontrato.vlr_divida - ttcontrato.vlr_aberto,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_divida      = trim(string(ttcontrato.vlr_divida,"->>>>>>>>>>>>9.99")).
        ttcontratos.qtdParcelas      = trim(string(ttcontrato.qtd_parcelas - ttcontrato.qtd_pagas,"->>>>>>>>>>>>9")).

        for each titulo where titulo.empcod = 19 and titulo.titnat = no and
            titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
            titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
            and titulo.titsit = "LIB"
            no-lock
            by titulo.titdtven by titulo.titpar .


            vjuros = 0.
            if titulo.titdtven < today
            then do:
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                            titulo.titdtven,
                            titulo.titvlcob,
                            output vjuros).

            end.

            create ttcontrato-parcelas.
            ttcontrato-parcelas.id = string(titulo.titpar).
            ttcontrato-parcelas.idpai =  ttcontratos.id .
            ttcontrato-parcelas.seq_parcela     = string(titulo.titpar). 
            ttcontrato-parcelas.venc_parcela    =   string(year(titulo.titdtven)) + "-" + 
                                string(month(titulo.titdtven),"99") + "-" + 
                                string(day(titulo.titdtven),"99").        
            ttcontrato-parcelas.vlr_parcela      = trim(string(titulo.titvlcob,"->>>>>>>>>>>>9.99")).
            ttcontrato-parcelas.valor_encargos      = trim(string(vjuros,"->>>>>>>>>>>>9.99")).
            ttcontrato-parcelas.valor_total      = trim(string(titulo.titvlcob + vjuros,"->>>>>>>>>>>>9.99")).
        end.

    end.
    
    for each ttcondicoes.
      delete ttcondicoes.
   end.  
    run montacondicoes (input ttnegociacao.negcod, ?).
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
    
        for each ttParcelas where ttparcelas.negcod = ttnegociacao.negcod and
                 ttparcelas.placod = ttcondicoes.placod.
                 
            create ttsaidaparcelasNegociadas.  
            ttsaidaparcelasNegociadas.id             = string(ttparcelas.titpar).
            ttsaidaparcelasNegociadas.idPai          = string(ttcondicoes.placod).
            ttsaidaparcelasNegociadas.idCondicao     = string(ttcondicoes.placod).
            ttsaidaparcelasNegociadas.seq_parcela    = string(ttparcelas.titpar).
            ttsaidaparcelasNegociadas.venc_parcela   = string(year(ttparcelas.dtvenc)) + "-" + 
                                                            string(month(ttparcelas.dtvenc),"99") + "-" + 
                                                            string(day(ttparcelas.dtvenc),"99").
            ttsaidaparcelasNegociadas.vlr_parcela    = trim(string(ttparcelas.vlr_parcela,"->>>>>>>>>>9.99")).
        end.
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


