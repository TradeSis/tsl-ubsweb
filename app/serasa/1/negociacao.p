def input param vlcentrada as longchar. /* JSON ENTRADA */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */

def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char 
   field offer_id         as char.

DEF TEMP-TABLE ttoffers NO-UNDO serialize-name "offers"
   FIELD offerId AS CHAR
   FIELD vtype AS CHAR serialize-name "type".
   
DEF TEMP-TABLE ttinstalments NO-UNDO serialize-name "instalments"
   FIELD id AS CHAR
   FIELD vtotal AS DEC serialize-name "total"
   FIELD totalWithoutInterest AS DEC
   FIELD discountValue AS DEC
   FIELD discountPercentage AS DEC
   FIELD instalment AS DEC.

DEF TEMP-TABLE ttdueDate NO-UNDO SERIALIZE-NAME "dueDate"
   FIELD dueDate AS date
   field idpai as char serialize-hidden.

DEF TEMP-TABLE ttvalues NO-UNDO SERIALIZE-NAME "values"
   FIELD vvalue AS DEC SERIALIZE-NAME "value"
   FIELD vtotal AS DEC SERIALIZE-NAME "total"
   field idpai as char serialize-hidden.
   
DEF TEMP-TABLE tttaxes NO-UNDO serialize-name "taxes"
   FIELD iof_percentage AS DEC 
   FIELD iof_totalValue AS DEC
   FIELD cet_yearPercentage AS DEC 
   FIELD cet_monthPercentage AS DEC
   FIELD cet_totalValue AS DEC
   FIELD interest_yearPercentage AS DEC
   FIELD interest_monthPercentage AS DEC
   FIELD interest_totalValue AS DEC
   field idpai as char serialize-hidden.
   
DEF DATASET dsNegociacao  SERIALIZE-NAME "JSON" 
   FOR ttoffers, ttinstalments, ttdueDate, ttvalues, tttaxes
   DATA-RELATION for1 FOR ttinstalments, ttdueDate    RELATION-FIELDS(ttinstalments.id,ttdueDate.idpai) NESTED
   DATA-RELATION for2 FOR ttinstalments, ttvalues    RELATION-FIELDS(ttinstalments.id,ttvalues.idpai) NESTED
   DATA-RELATION for3 FOR ttinstalments, tttaxes    RELATION-FIELDS(ttinstalments.id,tttaxes.idpai) NESTED.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"  /* JSON SAIDA CASO ERRO */
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vdata as date.
hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY") no-error.

find first ttentrada no-error.
if not avail ttentrada
then do:
    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Dados de Entrada Invalidos".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.



def var ptpnegociacao as char.
def var par-clicod like clien.clicod.
def var vmessage as log.
def var vqtdparcelas as int.
def var vtemparcelamento as log.

find neuclien where neuclien.cpf = dec(ttentrada.document) no-lock no-error.
if not avail neuclien
then do:
     find first clien where clien.ciccgc = ttentrada.document no-lock no-error.
end.
else do:
     find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.
if not avail clien
then do:
     create ttsaida.
     ttsaida.tstatus = 400.
     ttsaida.descricaoStatus = "Dados de Entrada Invalidos".

     hsaida  = temp-table ttsaida:handle.

     lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
     message string(vlcSaida).
     return.
end.
ptpnegociacao = "SERASA".
vmessage = no.

{acha.i}
{aco/acordo.i new} 

find aconegcli where aconegcli.clicod = clien.clicod and
                     aconegcli.id     = ttentrada.offer_id
   no-lock no-error.
if not avail aconegcli
then do:
   create ttsaida.
   ttsaida.tstatus = 400.
   ttsaida.descricaoStatus = "Oferta Invalida".

   hsaida  = temp-table ttsaida:handle.

   lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
   message string(vlcSaida).
   return.

end.                        
else do:
   if aconegcli.idacordo <> ?
   then do:
      create ttsaida.
      ttsaida.tstatus = 400.
      ttsaida.descricaoStatus = "Oferta Possui acordo " + string(aconegcli.idacordo).
   
      hsaida  = temp-table ttsaida:handle.
   
      lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
      message string(vlcSaida).
      return.
   end.
end.

    FIND aconegoc WHERE aconegoc.negcod = aconegcli.negcod NO-LOCK.
    run calcelegiveis (input ptpnegociacao, input clien.clicod, aconegcli.negcod).
    
    FIND FIRST ttnegociacao where ttnegociacao.negcod = aconegcli.negcod.
    
    CREATE ttoffers.
    ttoffers.offerId = aconegcli.id.
    
    FIND aconegoc WHERE aconegoc.negcod = aconegcli.negcod NO-LOCK.
    run montacondicoes (INPUT aconegoc.negcod, ?).
    
    vtemparcelamento = no.
    for each ttcondicoes.
        find acoplanos where 
                            acoplanos.negcod  = aconegcli.negcod and
                            acoplanos.placod  = ttcondicoes.placod
                            no-lock.

        ttcondicoes.perc_desc = acoplanos.perc_desc.
        ttcondicoes.perc_acres = acoplanos.perc_acres. 
        ttcondicoes.calc_juro = acoplanos.calc_juro.
        ttcondicoes.qtd_vezes = acoplanos.qtd_vezes + (if acoplanos.com_entrada then 1 else 0).
        ttcondicoes.dias_max_primeira = acoplanos.dias_max_primeira.

        CREATE ttinstalments.
        ttinstalments.id = string(ttcondicoes.placod).
        ttinstalments.vtotal = ttcondicoes.vlr_acordo.
       
        ttinstalments.totalWithoutInterest = ttcondicoes.vlr_acordo.
        ttinstalments.discountValue = ttnegociacao.vlr_divida - ttcondicoes.vlr_acordo.
        ttinstalments.discountPercentage = round(((ttinstalments.discountValue * 100) / ttnegociacao.vlr_divida) ,2).
        ttinstalments.instalment = ttcondicoes.qtd_vezes.

         do vdata = today to today + 2.
            CREATE ttdueDate.
            ttdueDate.dueDate = vdata.
            ttdueDate.idpai = ttinstalments.id.
         end.

        vqtdparcelas= 0.
        for each ttparcelas of ttcondicoes where ttparcelas.vlr_parcela > 0.
            vqtdparcelas = vqtdparcelas + 1.
        end.

        if vqtdparcelas > 1 
        then vtemparcelamento = yes.

         for each ttparcelas where ttparcelas.negcod = ttnegociacao.negcod and
                  ttparcelas.placod = ttcondicoes.placod.
               CREATE ttvalues.
               ttvalues.vvalue = ttparcelas.vlr_parcela.
               ttvalues.vtotal = ttparcelas.vlr_parcela.
               ttvalues.idpai = ttinstalments.id.
         end.      
         CREATE tttaxes.
         tttaxes.iof_percentage = 0.
         tttaxes.iof_totalValue = 0.
         tttaxes.cet_yearPercentage = 0.
         tttaxes.cet_monthPercentage = 0.
         tttaxes.cet_totalValue = 0.
         tttaxes.interest_yearPercentage = 0.
         tttaxes.interest_monthPercentage = 0.
         tttaxes.interest_totalValue = 0.
         tttaxes.idpai = ttinstalments.id.
         
    end.
    ttoffers.vtype = (if vtemparcelamento = true then "DIFFERENTS" else "EQUALS").



hsaida =  DATASET dsNegociacao:HANDLE.


lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).

/* export LONG VAR*/
DEF VAR vMEMPTR AS MEMPTR  NO-UNDO.
DEF VAR vloop   AS INT     NO-UNDO.
if length(vlcsaida) > 30000
then do:
    COPY-LOB FROM vlcsaida TO vMEMPTR.
    DO vLOOP = 1 TO LENGTH(vlcsaida): 
        put unformatted GET-STRING(vMEMPTR, vLOOP, 1). 
    END.
end.
else do:
    put unformatted string(vlcSaida).
end.  
