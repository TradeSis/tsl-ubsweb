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





