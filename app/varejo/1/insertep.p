/*  helio 24102022 - ID 152286 - Valor de nova��o - Principal menor que as parcelas - fim*/

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.


DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    var verro as char no-undo.
verro = "".
def var tiposervico as char.
DEFINE var lcJsonsaida      AS LONGCHAR.

def var vecommerce as log.
/*helio*/ def var vidacordo as char. def var vt as int. def var vint64 as int64.
def var voriginal as dec.
def var vtpseguro as int.
def var vctmcod  like pdvmov.ctmcod.
def var vmodcod     like contrato.modcod.
def var vdatamov as date. /* 01.12.2017 */
def var vnsu     as int.
def var vseqreg as int.

def var vmovseq as int.
def var vcodigo_forma  as char. 
def var vtitpar as int.

def var vultima as dec.
def var vtotal as dec.
def var vtotalsemjuros as dec.
def var vtitvlcobsemjuros as dec.
def var vtitvlcob as dec.
def var vi as int.
def var vmes as int.
def var vano as int.
def var vdia as int.
def var vvenc as date.
def var vseqforma as int.
def var vseqfp as int.

def var vvalor_vista as dec.
def var vvalor_contrato as dec.

{/admcom/barramento/functions.i}

{varejo/1/insertep.i}

/* LE ENTRADA */
lokJSON = hinsertEpEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


/**def var vsaida as char.
find first ttinsertep.
vsaida = "./json/"  
                           + trim(ttinsertep.codigoLoja)  + "_"
                           + trim(ttinsertep.dataTransacao) + "_"
                           + trim(ttinsertep.numeroComponente) + "_"
                           + trim(ttinsertep.nsuTransacao) + "_"
                           + "insertep.json".
hinsertepEntrada:WRITE-JSON("FILE",vsaida, true).
**/

    
if verro <> ""
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = verro.
  hsaida  = temp-table ttsaida:handle.
  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).

  return.
end.

for each ttinsertep.

        /*
        */
        
    vctmcod  = "NEP".
                   
    vdatamov = aaaa-mm-dd_todate(ttinsertep.dataTransacao).
    vnsu     = int(ttinsertep.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttinsertep.codigoLoja) and
            cmon.cxacod = int(ttinsertep.numeroComponente)
            no-lock no-error.
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttinsertep.codigoLoja)
            cmon.cxacod = int(ttinsertep.numeroComponente)
            cmon.cmocod = int(string(cmon.etbcod) + string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.

    do on error undo:
    find first pdvmov where
        pdvmov.etbcod = cmon.etbcod and
        pdvmov.cmocod = cmon.cmocod and
        pdvmov.datamov = vdatamov and
        pdvmov.sequencia = vnsu and
        pdvmov.ctmcod = vctmcod and
        pdvmov.coo    = int(vnsu)
        no-error.
    if not avail pdvmov
    then do:            
        create pdvmov.
        pdvmov.etbcod = cmon.etbcod.
        pdvmov.cmocod = cmon.cmocod.
        pdvmov.datamov = vdatamov.
        pdvmov.sequencia = vnsu.
        pdvmov.ctmcod = vctmcod.
        pdvmov.coo    = int(vnsu).
    end.        
    else do:
        verro = "JA INCLUIDO O MOVIMENTO filial=" + string(cmon.etbcod) + 
            " Pdv=" + string(cmon.cxacod) + 
            " data=" + string(vdatamov,"99999999") + 
            " nsu=" + string(vnsu) + 
            " tipo=" + vctmcod.

          create ttsaida.
        ttsaida.tstatus = 400.
        ttsaida.descricaoStatus = verro.
        hsaida  = temp-table ttsaida:handle.
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).

        return.
    end.    

    pdvmov.valortot   = dec(valorTotalRecebido).
    pdvmov.valortroco = dec(valortroco).

    pdvmov.codigo_operador =  codigoOperador.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = yes.
    pdvmov.statusoper = "".
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

    end.
    
    vseqreg = 0.


    /* RECEBIMENTOS */
    
    {varejo/1/recebimentos.i ttinsertep.id}
    
    voriginal = 0.
    vmodcod = "".
    vidacordo = ?.
           
    def var vconta as int.
    for each pdvdoc of pdvmov no-lock.
        vconta  = vconta + 1.
    end.

    for each pdvdoc of pdvmov.
        vconta = vconta - 1. 
    
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                         titulo.titpar   = pdvdoc.titpar
                         exclusive no-wait no-error.
        if avail titulo
        then do: 
            /* helio 
                acha acordo */
            for each cybacorigem where cybacorigem.contnum = int(pdvdoc.contnum) no-lock.
                do vt = 1 to num-entries(cybacorigem.ParcelasLista).
                    if int(entry(vt,cybacorigem.ParcelasLista)) = titulo.titpar
                    then do:
                        vidacordo = string(cybacorigem.idacordo).
                        leave.
                    end.
                end.
                if vidacordo <> ? then leave.
            end.     

            voriginal = voriginal + pdvdoc.titvlcob.

            run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                 recid(titulo)).

            assign     
                titulo.moecod   = if pdvmov.ctmcod = "P7" 
                                  then "PDM"
                                  else vctmcod
                titulo.etbcobra = pdvdoc.etbcod 
                titulo.datexp   = today 
                titulo.cxmdata  = pdvdoc.datamov 
                titulo.cxmhora  = string(pdvmov.horamov) 
                titulo.cxacod   = cmon.cxacod.
                
                
                if pdvmov.ctmcod = "P48" 
                then do:
                    
                    titulo.moecod = if pdvmov.ctmcod = "P48" then "NOV" else vctmcod.
                    if titulo.modcod begins "CP"
                    then vmodcod = "CPN". /* Se origem for CP */
                    
                    find first pdvforma of pdvmov where (pdvforma.modcod = "CRE") no-lock no-error.

                    
                    do on error undo, next.
                    if vidacordo <>  ?
                    then find first tit_novacao  where
                         tit_novacao.ori_empcod   = titulo.empcod and
                         tit_novacao.ori_titnat   = titulo.titnat and
                         tit_novacao.ori_modcod   = titulo.modcod and
                         tit_novacao.ori_etbcod   = titulo.etbcod and
                         tit_novacao.ori_clifor   = titulo.clifor and
                         tit_novacao.ori_titnum   = titulo.titnum and
                         tit_novacao.ori_titpar   = titulo.titpar and
                         tit_novacao.ori_titdtemi = titulo.titdtemi and
                         tit_novacao.id_acordo   = vidacordo and
                         tit_novacao.tipo         = ""
                        exclusive no-wait no-error.
                    if not avail tit_novacao
                    then 
                    find first tit_novacao use-index tit_novacao3 where
                         tit_novacao.ori_empcod   = titulo.empcod and
                         tit_novacao.ori_titnat   = titulo.titnat and
                         tit_novacao.ori_modcod   = titulo.modcod and
                         tit_novacao.ori_etbcod   = titulo.etbcod and
                         tit_novacao.ori_clifor   = titulo.clifor and
                         tit_novacao.ori_titnum   = titulo.titnum and
                         tit_novacao.ori_titpar   = titulo.titpar and
                         tit_novacao.ori_titdtemi = titulo.titdtemi and
                         tit_novacao.tipo         = ""
                        exclusive no-wait no-error.
                    if not avail tit_novacao
                    then do:
                        create tit_novacao.
                        assign
                         tit_novacao.ori_empcod   = titulo.empcod
                         tit_novacao.ori_titnat   = titulo.titnat
                         tit_novacao.ori_modcod   = titulo.modcod
                         tit_novacao.ori_etbcod   = titulo.etbcod
                         tit_novacao.ori_clifor   = titulo.clifor
                         tit_novacao.ori_titnum   = titulo.titnum
                         tit_novacao.ori_titpar   = titulo.titpar
                         tit_novacao.ori_titdtemi = titulo.titdtemi
                         tit_novacao.ori_titvlcob = titulo.titvlcob
                         tit_novacao.ori_titdtven = titulo.titdtven.
                         tit_novacao.id_acordo    = vidacordo.
                    end.                         
                    
                        assign
                         tit_novacao.tipo         = "RENEGOCIACAO"
                         tit_novacao.ger_contnum  = if avail pdvforma then int(pdvforma.contnum) else ?
                         tit_novacao.ori_titdtpag = titulo.titdtpag
                         tit_novacao.ori_titdtpag = pdvmov.datamov
                         tit_novacao.dtnovacao    = pdvmov.datamov
                         tit_novacao.hrnovacao    = pdvmov.horamov
                         tit_novacao.etbnovacao   = pdvmov.etbcod
                         tit_novacao.funcod       = int(pdvmov.codigo_operador)
                         tit_novacao.datexp       = today
                         tit_novacao.exportado    = no.
                         vidacordo = tit_novacao.id_acordo.
                    end.   
                    
                end.

    
        end.
        
    end.
    do on error undo.
        find first pdvforma of pdvmov where pdvforma.modcod = "CRE" no-lock no-error.
        if avail pdvforma
        then do on error undo:
            find contrato where contrato.contnum = int(pdvforma.contnum) exclusive no-error.
            if avail contrato
            then do:
                if contrato.etbcod = 982
                then vmodcod = "RFN".
                if vmodcod <> ""
                then contrato.modcod = vmodcod.
                                
                /* 24102022 ID 152286 - Valor de nova��o - Principal menor que as parcelas*/
                def var voriginal_financiado as dec.
                def var voriginal_desconto as dec.
                def var vfinanciado as dec.
                def var vdesconto   as dec.

                /* nova formula                */

                voriginal_financiado = voriginal - contrato.vlentra.
                if voriginal_financiado < 0 then voriginal_financiado = 0.

                vfinanciado = (contrato.vltotal - contrato.vlentra) /*SEM IOF- contrato.vliof*/ - contrato.vlseguro. 
                
                voriginal_desconto = voriginal_financiado - vfinanciado.
                if voriginal_desconto < 0
                then voriginal_desconto = 0.
                
                /* helio 20032024
                contrato.vlf_principal = if voriginal_financiado > 0
                                         then if voriginal_desconto > 0
                                              then voriginal_financiado - voriginal_desconto
                                              else voriginal_financiado 
                                         else 0.
                */
                contrato.vlf_acrescimo  = vfinanciado - contrato.vlf_principal.
                
                /***/
                                                
                /** ID 152286
                    antiga formula
                    contrato.vlf_principal = if voriginal < contrato.vltotal - contrato.vliof - contrato.vlseguro
                                         then voriginal
                                         else contrato.vltotal - contrato.vliof - contrato.vlseguro.
                contrato.vlf_acrescimo = contrato.vltotal - contrato.vlentra - contrato.vliof - contrato.vlseguro - contrato.vlf_principal.
                if contrato.vlf_acrescimo < 0
                then contrato.vlf_acrescimo = 0.
                **/
                /* ID 152286 - Valor de nova��o - Principal menor que as parcelas - fim*/
                
                    /* helio 02092022 - projeto Criar Produtos - ADM */
                     if contrato.vlf_acrescimo < 1
                     then contrato.crecod = 501. 
                     else contrato.crecod = 500.
                    
                
                for each titulo where titulo.contnum = contrato.contnum.
                    titulo.modcod = contrato.modcod.

                    /* ID 152286 */
                    /* helio 20032024
                    if titulo.titpar = 0
                    then do:
                        titulo.vlf_principal = 0.
                        titulo.vlf_acrescimo = 0.
                    end.
                    else do:
                    *    titulo.vlf_principal = contrato.vlf_principal / contrato.nro_parcelas.
                    *    titulo.vlf_acrescimo = contrato.vlf_acrescimo / contrato.nro_parcelas.
                    end.  
                    */              
                    
                    if vidacordo <> ?
                    then do:
                        vint64 = int64(vidacordo) no-error.
                        if vint64 <> ?
                        then do:
                            find first cybacparcela where cybacparcela.idacordo = int64(vidacordo) and
                                                          cybacparcela.parcela  = titulo.titpar
                                                          no-error.
                            if avail cybacparcela and cybacparcela.contnum = ?
                            then cybacparcela.contnum =  contrato.contnum.
                        end.
                    end.       
                end.
            end.
        end.
    end.
end.

  find pdvtmov where pdvtmov.ctmcod = vctmcod no-lock no-error.
  create ttsaida.
  ttsaida.tstatus = 200.
  ttsaida.descricaoStatus = "Efetivado filial=" + string(cmon.etbcod) + 
            " Pdv=" + string(cmon.cxacod) + 
            " data=" + string(vdatamov,"99999999") + 
            " nsu=" + string(vnsu) + 
            " tipo=" + vctmcod + "-" + (if avail pdvtmov then pdvtmov.ctmnom else ""). 

  hsaida  = temp-table ttsaida:handle.
  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).





