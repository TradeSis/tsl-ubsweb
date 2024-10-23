def input param vlcentrada as longchar. /* JSON ENTRADA */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */

def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field cnpj_raiz         as char serialize-name "cnpj_raiz"
   field document        as char serialize-name "document".
   
DEF TEMP-TABLE ttoffers NO-UNDO SERIALIZE-NAME "offers"
   FIELD id AS char
   FIELD debtOriginalValues AS DEC format ">>>>>>>>>9.99" decimals 2
   FIELD debtCurrentValues AS DEC
   FIELD maxInstalments AS DEC
   FIELD maxInstalmentValue AS DEC
   FIELD atSight AS DEC
   FIELD interest AS DEC
   FIELD discountValue AS DEC
   FIELD discountPercentage AS DEC
   FIELD hasInstalments AS LOG
   field idpai as int SERIALIZE-HIDDEN.
   
DEF TEMP-TABLE ttdebts NO-UNDO SERIALIZE-NAME "debts"
   FIELD dueDate AS date
   FIELD occurrenceDate AS date
   FIELD originalValue AS DEC
   FIELD currentValue AS DEC
   FIELD contractNumber AS CHAR
   FIELD vtype AS CHAR SERIALIZE-NAME "type"
   field idpai as int SERIALIZE-HIDDEN
   field iddebts as char serialize-hidden.
   
DEF TEMP-TABLE ttvalues NO-UNDO SERIALIZE-NAME "values"
   FIELD vvalue AS DEC SERIALIZE-NAME "value"
   FIELD vtotal AS DEC SERIALIZE-NAME "total".
  
DEF TEMP-TABLE ttcompany NO-UNDO SERIALIZE-NAME "company"
   FIELD id AS CHAR
   FIELD businessName AS CHAR
   field idpaidebts as char serialize-hidden.
   
DEF TEMP-TABLE ttcompanyOrigin NO-UNDO SERIALIZE-NAME "companyOrigin"
   FIELD id AS CHAR
   FIELD businessName AS CHAR
   field idpaidebts as char serialize-hidden.

   
DEF DATASET dsOfertas  SERIALIZE-NAME "JSON" 
  FOR ttoffers, ttdebts, ttvalues, ttcompany, ttcompanyOrigin
  DATA-RELATION for1 FOR ttoffers, ttdebts    RELATION-FIELDS(ttoffers.idpai,ttdebts.idpai) NESTED  
  DATA-RELATION for2 FOR ttdebts, ttcompany    RELATION-FIELDS(ttdebts.iddebts,ttcompany.idpaidebts) NESTED
  DATA-RELATION for3 FOR ttdebts, ttcompanyOrigin    RELATION-FIELDS(ttdebts.iddebts,ttcompanyOrigin.idpaidebts) NESTED.  


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"  /* JSON SAIDA CASO ERRO */
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

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
if ttentrada.cnpj_raiz <> "96662168000131"
then do:
     create ttsaida.
     ttsaida.tstatus = 400.
     ttsaida.descricaoStatus = "CNPJ RAIZ INVALIDO".

     hsaida  = temp-table ttsaida:handle.

     lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
     message string(vlcSaida).
     return.
end.




def var ptpnegociacao as char.
def var par-clicod like clien.clicod.
def var vmessage as log.
DEF VAR vmaxparcelas AS INT.
DEF VAR vvalorminparcelas AS dec.
def var vplanoavista as dec.
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

find serasacli where serasacli.clicod = clien.clicod no-lock no-error.
if not avail serasacli
then do:
     create ttsaida.
     ttsaida.tstatus = 400.
     ttsaida.descricaoStatus = "Nao encontrado na base".

     hsaida  = temp-table ttsaida:handle.

     lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
     message string(vlcSaida).
     return.
end.
ptpnegociacao = "SERASA".
vmessage = no.

{acha.i}
{aco/acordo.i new} 

run calcelegiveis (input ptpnegociacao, input clien.clicod, ?).

find first ttnegociacao no-error.
if not avail ttnegociacao
then do:
     create ttsaida.
     ttsaida.tstatus = 204.
     ttsaida.descricaoStatus = ?.

     hsaida  = temp-table ttsaida:handle.

     lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
     message string(vlcSaida).
     return.
end.

for each ttnegociacao.
   
   find aconegoc of ttnegociacao no-lock.
   ttnegociacao.negnom = aconegoc.negnom.
    
   find first aconegcli where aconegcli.clicod = clien.clicod and
                              aconegcli.dtneg  = today and
                              aconegcli.negcod = ttnegociacao.negcod
      no-lock no-error.                              
   if not avail aconegcli
   then do:
         create aconegcli.
         aconegcli.clicod = clien.clicod.
         aconegcli.dtneg  = today.
         aconegcli.negcod = ttnegociacao.negcod.
         aconegcli.id = GUID(GENERATE-UUID). 
   end.
   else do:
         if aconegcli.idacordo <> ?
         then do:
               delete ttnegociacao.
               next.
         end.
   end.
   
   run montacondicoes (INPUT aconegoc.negcod, ?).
    
   vmaxparcelas = 0.
   vvalorminparcelas = 0.
   vplanoavista = 0.
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
        
        vmaxparcelas = max(vmaxparcelas, ttcondicoes.qtd_vezes).
        
        
        vqtdparcelas= 0.
        for each ttparcelas of ttcondicoes where ttparcelas.vlr_parcela > 0.
            vqtdparcelas = vqtdparcelas + 1.
        end.

        if vqtdparcelas > 1 
        then vtemparcelamento = yes.

        for each ttparcelas of ttcondicoes where ttparcelas.vlr_parcela > 0.
            
            if vqtdparcelas = 1 and ttparcelas.titpar = 0
            then vplanoavista = ttparcelas.vlr_parcela.
        
            if vvalorminparcelas = 0 
            then vvalorminparcelas = ttparcelas.vlr_parcela.
            else vvalorminparcelas = min(vvalorminparcelas, ttparcelas.vlr_parcela).
        end. 

   end.

    
   CREATE ttoffers.
   ttoffers.id = aconegcli.id.
   ttoffers.idpai = ttnegociacao.negcod.
   ttoffers.debtOriginalValues = round(ttnegociacao.vlr_aberto,2).
   ttoffers.debtCurrentValues = round(ttnegociacao.vlr_divida,2).
   ttoffers.interest = round(ttnegociacao.vlr_divida - ttnegociacao.vlr_aberto,2).
   ttoffers.atSight = round(vplanoavista,2).                                                               
   ttoffers.discountValue = (if vplanoavista = 0 then 0 else ttnegociacao.vlr_divida - vplanoavista).  
   ttoffers.discountPercentage = truncate(((ttoffers.discountValue * 100) / ttnegociacao.vlr_divida) ,2).
   ttoffers.hasInstalments = vtemparcelamento. 
   if vtemparcelamento
   then do:
        ttoffers.maxInstalments = ?.
        ttoffers.maxInstalmentValue = ?.
   end.        
   else do:
        ttoffers.maxInstalments = vmaxparcelas.                                                        
        ttoffers.maxInstalmentValue = round(vvalorminparcelas,2).                                              
   end.        
          

   for each ttcontrato where ttcontrato.negcod = ttnegociacao.negcod.
      CREATE ttdebts.
      ttdebts.dueDate = ttcontrato.dt_venc.
      ttdebts.occurrenceDate = ttcontrato.dt_venc.
      ttdebts.originalValue = round(ttcontrato.vlr_aberto,2).
      ttdebts.currentValue = round(ttcontrato.vlr_divida,2).
      ttdebts.contractNumber = string(ttcontrato.contnum).
      ttdebts.vtype = if ttcontrato.modcod BEGINS "CP" then "EMPRESTIMO" else "CREDIARIO".
      ttdebts.idpai = ttoffers.idpai. 
      ttdebts.iddebts = string(ttcontrato.contnum).

      CREATE ttcompany.
      ttcompany.id = ttentrada.cnpj_raiz.
      ttcompany.businessName = "DREBES E CIA LTDA".
      ttcompany.idpaidebts = ttdebts.iddebts.

      CREATE ttcompanyOrigin.
      ttcompanyOrigin.id = ttentrada.cnpj_raiz.
      ttcompanyOrigin.businessName = "DREBES E CIA LTDA".
      ttcompanyOrigin.idpaidebts = ttdebts.iddebts.

   end.   

end.



hsaida =  DATASET dsOfertas:HANDLE.


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
