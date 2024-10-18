def input param vlcentrada as longchar. /* JSON ENTRADA */

def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */


def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char
   field offerId         as char 
   field dueDate         as date 
   field id              as char.

DEF TEMP-TABLE ttacordos NO-UNDO serialize-name "acordos"
   FIELD offerId AS CHAR
   FIELD agreementId AS CHAR
   FIELD vtotal AS DEC serialize-name "total"
   FIELD totalWithoutInterest AS DEC
   FIELD discountValue AS DEC
   FIELD discountPercentage AS DEC
   field vlr_divida as dec.
   
DEF TEMP-TABLE ttinstalments NO-UNDO serialize-name "instalments"
   FIELD instalment AS DEC
   FIELD dueDate AS date
   FIELD vvalue AS DEC serialize-name "value"
   FIELD vtotal AS DEC serialize-name "total".
   
DEF TEMP-TABLE tttaxes NO-UNDO serialize-name "taxes"
   FIELD iof_percentage AS DEC 
   FIELD iof_totalValue AS DEC
   FIELD cet_yearPercentage AS DEC 
   FIELD cet_monthPercentage AS DEC
   FIELD cet_totalValue AS DEC
   FIELD interest_yearPercentage AS DEC
   FIELD interest_monthPercentage AS DEC
   FIELD interest_totalValue AS DEC.
   
DEF DATASET dsAcordos  SERIALIZE-NAME "JSON" 
   FOR ttacordos, ttinstalments,  tttaxes.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"  /* JSON SAIDA CASO ERRO */
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.


hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY") no-error.

find first ttentrada no-error.
if not avail ttentrada
then do:
    create ttsaida.
    ttsaida.tstatus = 422.
    ttsaida.descricaoStatus = "Dados de Entrada Invalidos".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.



def var ptpnegociacao as char.
def var par-clicod like clien.clicod.
def var vmessage as log.

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
     ttsaida.tstatus = 422.
     ttsaida.descricaoStatus = "Cliente nao encontrado".

     hsaida  = temp-table ttsaida:handle.

     lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
     message string(vlcSaida).
     return.
end.
ptpnegociacao = "SERASA".
vmessage = no.

{acha.i}
{aco/acordo.i new} 

def var vdtvencimento as date.

DEF VAR vjuros AS DEC.

find aconegcli where aconegcli.clicod = clien.clicod and
                     aconegcli.id     = ttentrada.offerId
   no-error.
if not avail aconegcli
then do:
   create ttsaida.
   ttsaida.tstatus = 422.
   ttsaida.descricaoStatus = "Oferta Invalida".

   hsaida  = temp-table ttsaida:handle.

   lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
   message string(vlcSaida).
   return.

end.        
/* else do:
    if aconegcli.idacordo <> ?
    then do:
       create ttsaida.
       ttsaida.tstatus = 422.
       ttsaida.descricaoStatus = "Oferta Possui acordo " + string(aconegcli.idacordo).
    
       hsaida  = temp-table ttsaida:handle.
    
       lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
       message string(vlcSaida).
       return.
    end.
end. */
else do:

find aconegcli where aconegcli.clicod = clien.clicod and
                     aconegcli.id     = ttentrada.offerId
   no-error.
   
   if aconegcli.idacordo <> ?
   then do:
		find aoacordo of aconegcli no-lock.
		if aoacordo.dtacordo = today  and time - aoacordo.hracordo <= 3600
		then DO:	
            RUN criaAcordo.		
		END.			
		else do:
			create ttsaida.
           ttsaida.tstatus = 422.
           ttsaida.descricaoStatus = "Oferta Possui acordo " + string(aconegcli.idacordo).
        
           hsaida  = temp-table ttsaida:handle.
        
           lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
           message string(vlcSaida).
           return. 
			
		END.
   end.

end.

run calcelegiveis (ptpnegociacao, clien.clicod,  aconegcli.negcod).
find first ttnegociacao where ttnegociacao.negcod = aconegcli.negcod no-error.
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

vdtvencimento = ttentrada.dueDate.
if weekday(vdtvencimento) = 7 /* sabado */ 
then vdtvencimento = vdtvencimento + 2.
if weekday(vdtvencimento) = 1 /* domingo */ 
then vdtvencimento = vdtvencimento + 1.

for each ttcondicoes.
    delete ttcondicoes.
end.  
for each ttparcelas.
    delete ttparcelas.
end.  
run montacondicoes (input aconegcli.negcod, int(ttentrada.id)).
find first ttcondicoes where ttcondicoes.negcod = ttnegociacao.negcod and
                         ttcondicoes.placod = int(ttentrada.id)
                         no-error.

ttcondicoes.dtvenc1 = vdtvencimento.
def var vdia as int.
def var vmes as int.
def var vano as int.
def var vtitdtven as date.
def var vtitpar as int.

vdia = day(vdtvencimento).
vmes = month(vdtvencimento).
vano = year(vdtvencimento).

for each ttParcelas where ttparcelas.negcod = ttnegociacao.negcod and
                 ttparcelas.placod = ttcondicoes.placod
        break  by  ttParcelas.titpar.
    if first(ttparcelas.titpar)
    then ttparcelas.dtven = vdtvencimento.
    else do:
        vtitdtven = date(vmes, 
                         IF VMES = 2 
                         THEN IF Vdia > 28 
                              THEN 28 
                              ELSE Vdia 
                         ELSE if Vdia > 30 
                              then 30 
                              else vdia, 
                         vano).
        ttparcelas.dtven = vtitdtven.
    end.
    vmes = vmes + 1.
    if vmes > 12 
    then assign vano = vano + 1
                vmes = 1.    
end.

do on error undo:

    create AoAcordo.
    AoAcordo.IDAcordo   = next-value(aoacordo).
    AoAcordo.CliFor     = clien.clicod.
    AoAcordo.DtAcordo   = today.
    AoAcordo.Situacao   = "A".
    AoAcordo.VlAcordo   = ttcondicoes.vlr_acordo.
    AoAcordo.VlOriginal = ttnegociacao.vlr_aberto.
    AoAcordo.HrAcordo   = time.
    AoAcordo.DtEfetiva  = ?.
    AoAcordo.HrEfetiva  = ?.
    aoAcordo.negcod     = ttnegociacao.negcod.
    aoAcordo.placod     = ttcondicoes.placod.
    aoAcordo.vlr_divida = ttnegociacao.vlr_divida.
/*
    aoAcordo.bancod      = banboleto.bancod.
    aoAcordo.nossoNumero = banboleto.nossoNumero.
*/
    aoacordo.tipo        = ptpnegociacao.

    aconegcli.idacordo   = aoacordo.idacordo.

    CREATE ttacordos.
    ttacordos.offerId = aconegcli.id.
    ttacordos.agreementId = string(AoAcordo.IDAcordo).
    ttacordos.vtotal = round(AoAcordo.VlAcordo,2) .
    ttacordos.totalWithoutInterest = round(AoAcordo.VlAcordo,2).
    ttacordos.discountValue = round((ttnegociacao.vlr_divida - AoAcordo.VlAcordo), 2).
    ttacordos.discountPercentage = round(((ttacordos.discountValue * 100) / ttnegociacao.vlr_divida) ,2).
    
    for each ttcontrato  where ttcontrato.negcod = ttnegociacao.negcod.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.
        
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
            
            if aoacordo.etbcod = 0
            then aoacordo.etbcod = contrato.etbcod.
            create AoAcOrigem.
            AoAcOrigem.IDAcordo = AoAcordo.IDAcordo.
            AoAcOrigem.contnum  = contrato.contnum.
            AoAcOrigem.titpar   = titulo.titpar.
            AoAcOrigem.vlcob    = titulo.titvlcob.
            AoAcOrigem.vljur    = vjuros.
            AoAcOrigem.vltot    = titulo.titvlcob + vjuros.
        
        end.
        
    end.
    for each ttcondicoes where ttcondicoes.negcod = ttnegociacao.negcod and
                             ttcondicoes.placod = int(ttentrada.id).
      
        find acoplanos where
          acoplanos.negcod  = ttcondicoes.negcod and
          acoplanos.placod  = ttcondicoes.placod
          no-lock.
   
        for each ttParcelas where ttparcelas.negcod = ttnegociacao.negcod and
                                ttparcelas.placod = ttcondicoes.placod
            by  ttParcelas.titpar.

            vtitpar = ttParcelas.titpar + (if acoplanos.com_entrada then 1 else 0).
            create aoacparcela.          
            AoAcParcela.IDAcordo     = aoAcordo.IDAcordo. 
            AoAcParcela.contnum      = ?. /* na Efetivacao */
            AoAcParcela.Parcela      = vtitpar.
            AoAcParcela.DtVencimento = ttparcelas.dtvenc.
            AoAcParcela.VlCobrado    = ttparcelas.vlr_parcela.
            AoAcParcela.dtBaixa      = ?.
            AoAcParcela.Situacao     = "A".
            AoAcParcela.DtEnvio      = ?.
            AoAcParcela.Enviar       = no.
            AoAcParcela.VlJuros      = 0.
            AoAcParcela.segprestamista = ttparcelas.segprestamista.
            AoAcParcela.vlr_parcelaOriginal = ttparcelas.vlr_parcelaOriginal.

            CREATE ttinstalments.
            ttinstalments.instalment = vtitpar.
            ttinstalments.dueDate = AoAcParcela.DtVencimento.
            ttinstalments.vvalue =  round(AoAcParcela.VlCobrado,2).
            ttinstalments.vtotal =  round(AoAcParcela.VlCobrado,2).
            CREATE tttaxes.
            tttaxes.iof_percentage = 0.
            tttaxes.iof_totalValue = 0.
            tttaxes.cet_yearPercentage = 0.
            tttaxes.cet_monthPercentage = 0.
            tttaxes.cet_totalValue = 0.
            tttaxes.interest_yearPercentage = 0.
            tttaxes.interest_monthPercentage = 0.
            tttaxes.interest_totalValue = 0.

        end.            
        
    end.
end.            
            





hsaida =  DATASET dsAcordos:HANDLE.


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


PROCEDURE criaAcordo.
    CREATE ttacordos.
        ttacordos.offerId = aconegcli.id.
        ttacordos.agreementId = string(AoAcordo.IDAcordo).
        ttacordos.vtotal = round(AoAcordo.VlAcordo,2).
        ttacordos.totalWithoutInterest = round(AoAcordo.VlAcordo,2).
        ttacordos.discountValue = round(aoacordo.vlr_divida - AoAcordo.VlAcordo,2).		
        ttacordos.discountPercentage = round(((ttacordos.discountValue * 100) / aoacordo.vlr_divida) ,2).
        
        for each aoacparcela of aoacordo no-lock.
            CREATE ttinstalments.
            ttinstalments.instalment = aoacparcela.parcela.
            ttinstalments.dueDate = AoAcParcela.DtVencimento.
            ttinstalments.vvalue =  round(AoAcParcela.VlCobrado,2).
            ttinstalments.vtotal =  round(AoAcParcela.VlCobrado,2).
            CREATE tttaxes.
            tttaxes.iof_percentage = 0.
            tttaxes.iof_totalValue = 0.
            tttaxes.cet_yearPercentage = 0.
            tttaxes.cet_monthPercentage = 0.
            tttaxes.cet_totalValue = 0.
            tttaxes.interest_yearPercentage = 0.
            tttaxes.interest_monthPercentage = 0.
            tttaxes.interest_totalValue = 0.
        end.
END PROCEDURE.
