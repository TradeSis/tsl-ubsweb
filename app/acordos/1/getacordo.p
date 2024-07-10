/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vid as int.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.
def var vematraso as log.
def var vsldparcelas as dec.
def var vvlrjuros as dec.
def var vqtdVezes as int.
def var vvlr_entrada as dec.
def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char
    field idAcordo as char.
{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}



 
def var xtime as int.

def var vmessage as log.
vmessage = no.

{aco/acordo.i new}


DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field tipoPessoa as char
        field codigoCliente as char
        field nome as char
        field cpfCnpj as char
        field celular as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttacordo NO-UNDO SERIALIZE-NAME "acordo"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field idAcordo  as char
        field data_emissao_acordo    as char
        field valor_total_acordo as char
        field qtdContratos  as char
        index x is unique primary idpai asc id asc.
 
DEFINE TEMP-TABLE ttcontratos NO-UNDO SERIALIZE-NAME "contratosOriginais"
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
    field statusContrato    as char
    index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcontrato-parcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field id as char serialize-hidden
    field idPai as char serialize-hidden
    field seq_parcela as char
    field   venc_parcela as char    
    field vlr_parcela as char
    field valor_encargos as char
    field valor_total as char
    field statusParcela as char
    index x is unique primary idpai asc id asc.


DEFINE TEMP-TABLE ttsaidacondicoes NO-UNDO SERIALIZE-NAME "condicao"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field idCondicao    as char
        field nome as char
        field   tipoCondicao as char    
        field valor_entrada as char
        field valor_parcela as char
        field qtdParcelas as char
        field valor_total as char
        field numero_contrato   as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttsaidaparcelasNegociadas NO-UNDO SERIALIZE-NAME "parcelas"
    field id as char serialize-hidden
    field idPai as char serialize-hidden
    field seq_parcela   as char
    field venc_parcela  as char
    field vlr_parcela   as char
    field statusParcela as char.

DEFINE DATASET conteudoSaida FOR ttcliente, ttacordo, ttcontratos, ttcontrato-parcelas ,ttsaidacondicoes,
            ttsaidaparcelasNegociadas
   DATA-RELATION for3 FOR ttcliente, ttacordo       RELATION-FIELDS(ttcliente.id,ttacordo.idpai) NESTED
   DATA-RELATION for3 FOR ttacordo, ttcontratos       RELATION-FIELDS(ttacordo.id,ttcontratos.idpai) NESTED
   DATA-RELATION for4 FOR ttcontratos, ttcontrato-parcelas      RELATION-FIELDS(ttcontratos.id,ttcontrato-parcelas.idpai) NESTED
   DATA-RELATION for4 FOR ttacordo, ttsaidacondicoes      RELATION-FIELDS(ttacordo.id,ttsaidacondicoes.idpai) NESTED
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
def var vqtdOriginais as int.

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


find aoacordo where aoacordo.idAcordo = int(ttentrada.idAcordo) no-lock no-error.

if not avail aoAcordo
then do:

    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Acordo " + ttentrada.idAcordo + " Não encontrado.".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.

end.

if aoAcordo.clifor <> clien.clicod
then do:

    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Acordo " + ttentrada.idAcordo + " Nao Pertence a este CPF.".

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

    
    find aconegoc of aoAcordo no-lock.

    create ttacordo.
    ttacordo.id                 = string(aoAcordo.idAcordo).
    ttacordo.idPai              = ttcliente.id.
    ttacordo.IDAcordo       = string(aoAcordo.idAcordo).
    ttacordo.data_emissao_acordo   = string(year(aoacordo.DtAcordo)) + "-" + string(month(aoacordo.DtAcordo),"99") + "-" + string(day(aoacordo.DtAcordo),"99").        
    ttacordo.valor_total_acordo = trim(string(aoAcordo.VlAcordo,"->>>>>>>>>>9.99")).
    vqtdOriginais = 0.
    for each aoacorigem of aoacordo no-lock
        by aoacorigem.contnum by aoacorigem.titpar.

        find contrato where contrato.contnum = aoacorigem.contnum no-lock.
        find first ttcontratos where ttcontratos.numero_contrato = string(contrato.contnum) no-error.
        if not avail ttcontratos 
        then do:

            create ttcontratos.
            ttcontratos.id = string(contrato.contnum) .
            ttcontratos.idpai = ttacordo.id.
            ttcontratos.filial_contrato = string(contrato.etbcod).
            ttcontratos.modalidade      = contrato.modcod.
            ttcontratos.numero_contrato = string(contrato.contnum).        
            ttcontratos.data_emissao_contrato   = string(year(contrato.dtinicial)) + "-" + string(month(contrato.dtinicial),"99") + "-" + string(day(contrato.dtinicial),"99").        
            ttcontratos.valor_contrato      = trim(string(contrato.vltotal,"->>>>>>>>>>>>9.99")).
            vqtdOriginais = vqtdOriginais + 1.
            vematraso = no.    
            vqtdParcelas = 0.
            vvlrParcelas = 0.
            vsldParcelas = 0.
            vvlrJuros = 0.
    
        end.

        find titulo where titulo.empcod = 19 and titulo.titnat = no and
            titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
            titulo.etbcod = contrato.etbcod and 
            titulo.titnum = string(aoacorigem.contnum) and 
            titulo.titpar = aoacorigem.titpar 
            no-lock.
        vqtdParcelas = vqtdParcelas + 1.
        vsldParcelas = vsldParcelas + if titulo.titsit = "LIB" then titulo.titvlcob else 0.
        vvlrParcelas = vvlrParcelas + aoacorigem.vlcob.
        vvlrjuros    = vvlrJuros    + aoacorigem.vljur.
        if titulo.titdtven < today and titulo.titsit = "LIB"
        then vemAtraso = yes.

        create ttcontrato-parcelas.
        ttcontrato-parcelas.id = string(titulo.titpar).
        ttcontrato-parcelas.idpai =  ttcontratos.id .
        ttcontrato-parcelas.seq_parcela     = string(titulo.titpar). 
        ttcontrato-parcelas.venc_parcela    =   string(year(titulo.titdtven)) + "-" + 
                            string(month(titulo.titdtven),"99") + "-" + 
                            string(day(titulo.titdtven),"99").        
        ttcontrato-parcelas.vlr_parcela      = trim(string(aoacorigem.vlcob,"->>>>>>>>>>>>9.99")).
        ttcontrato-parcelas.valor_encargos      = trim(string(aoacorigem.vljur,"->>>>>>>>>>>>9.99")).
        ttcontrato-parcelas.valor_total      = trim(string(aoacorigem.vltot,"->>>>>>>>>>>>9.99")).
        ttcontrato-parcelas.statusParcela        = if vemAtraso 
                                                    then "ATR"
                                                    else titulo.titsit.

        ttacordo.qtdContratos       = trim(string(vqtdOriginais,"->>>>>>>>>>9")).
        ttcontratos.valor_total_pago      = trim(string(contrato.vltotal - vvlrParcelas,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_pendente      = trim(string(vvlrParcelas,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_encargo      = trim(string(vvlrJuros,"->>>>>>>>>>>>9.99")).
        ttcontratos.valor_total_divida      = trim(string(vvlrParcelas + vvlrJuros,"->>>>>>>>>>>>9.99")).
        ttcontratos.statusContrato        = if vemAtraso 
                                            then "ATR"
                                            else if vsldParcelas > 0 then "LIB" else "PAG".
        ttcontratos.qtdParcelas      = trim(string(vqtdParcelas,"->>>>>>>>>>>>9")).        
       
    end.

    vqtdVezes = 0.
    vvlr_entrada = 0.
    vvlr_parcela = 0.
    find first aoacparcela of aoacordo no-lock no-error.
    if avail aoacparcela
    then do:
        release contrato.
        find contrato where contrato.contnum = aoacparcela.contnum no-lock no-error.
        for each aoacparcela of aoacordo no-lock.
            if aoacparcela.parcela = 0 
            then vvlr_entrada = aoacparcela.vlcobrado.
            else do:
                if vvlr_parcela = 0
                then vvlr_parcela = aoacparcela.vlcobrado.
                vqtdVezes = vqtdVezes + 1.
            end.
        end.

        create ttsaidacondicoes. 
        ttsaidacondicoes.id            = string(1).
        ttsaidacondicoes.idPai         = ttacordo.id .
        ttsaidacondicoes.IDCondicao    = string(1).
        ttsaidacondicoes.nome          = caps(entry(2,aoacordo.tipo)).
        ttsaidacondicoes.tipoCondicao  = if vqtdvezes = 0 then "AVISTA" else "CREDIARIO".
        ttsaidacondicoes.valor_entrada = trim(string(vvlr_entrada,"->>>>>>>>>>9.99")).
        ttsaidacondicoes.valor_parcela = trim(string(vvlr_parcela,"->>>>>>>>>>9.99")).
        ttsaidacondicoes.qtdParcelas   = trim(string(vqtdvezes,"->>>>>>>>>>9")).
        ttsaidacondicoes.valor_total   = trim(string(aoAcordo.VlAcordo,"->>>>>>>>>>9.99")).
        ttsaidacondicoes.numero_contrato = if avail contrato
                                           then string(contrato.contnum)
                                           else ?.
        

        for each aoacparcela of aoacordo no-lock.
            vemAtraso = no.
            release titulo.
            if avail contrato
            then  do:                                         
                find titulo where titulo.empcod = 19 and titulo.titnat = no and
                    titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
                    titulo.etbcod = contrato.etbcod and 
                    titulo.titnum = string(aoacparcela.contnum) and 
                    titulo.titpar = aoacparcela.parcela 
                    no-lock no-error.
                if avail titulo
                then do:
                    if titulo.titdtven < today and titulo.titsit = "LIB"
                    then vemAtraso = yes.
                end.             
            end.
            create ttsaidaparcelasNegociadas.  
            ttsaidaparcelasNegociadas.id             = string(aoacparcela.parcela).
            ttsaidaparcelasNegociadas.idPai          = string(1).
            ttsaidaparcelasNegociadas.seq_parcela    = string(aoacparcela.parcela).
            ttsaidaparcelasNegociadas.venc_parcela   = string(year(DtVencimento)) + "-" + 
                                                            string(month(DtVencimento),"99") + "-" + 
                                                            string(day(DtVencimento),"99").
            ttsaidaparcelasNegociadas.vlr_parcela    = trim(string(aoacparcela.vlcobrado,"->>>>>>>>>>9.99")).
            ttsaidaparcelasNegociadas.statusParcela        = if vemAtraso 
                                                        then "ATR"
                                                        else if avail titulo
                                                             then titulo.titsit
                                                             else "ABE".
        end.
        
    end.



def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apiacordosgetacordo" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
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


