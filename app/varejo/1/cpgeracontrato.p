/* helio 022023 insert nop crediario admcom */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

DEFINE VARIABLE vstatus                            AS int.


def temp-table ttentrada no-undo serialize-name "entrada"
  field codigoLoja as char /*  0200", */
  field dataTransacao as char /*  2022-07-27", */
  field numeroComponente as char /*  100", */
  field sequencial as char /*  99999", */
  field tipoVenda as char /*  47", */
  field numeroCupom as char /*  1", */
  field codigoCliente as char /*  500306180", */
  field valorTotal as char /*  110.4", */
  field valorTroco as char /*  0", */
  field hora as char /*  133206", */
  field tipoTransacao as char /*  47", */
  field codigoOperador as char /*  21435", */
  field tipoPedido as char /*  F", */
  field numeroCpfCnpj as char /*  15630633449", */
  field agenciaArrecadadora as char /*  Augusto Kauê Pedro Henrique Moura", */
  field codigoVendedor as char /*  21232", */
  field empresaCreditada as char. /*  ,,,,15630633449" */

  def temp-table ttrecebimentos no-undo serialize-name "recebimentos"
     field numSeqForma   as char  
     field codigoForma     as char
     field codigoPlano     as char
     field valorPagoForma   as char
     field numSeqRecCrediario     as char
     field codCliente     as char
     field numeroContrato     as char
     field primeiroVencimento     as char
     field qtdParcelas     as char
     field valorFinanciamento     as char
     field valEncargoFinanc     as char
     field contratoFinanceira     as char
     field valorIof     as char
     field cetAno     as char
     field txMes     as char
     field cet     as char
     field valorAcrescimo   as char
     field dataEmissaoContrato   as char
     field valorTfc   as char
     field codProdutoFinanceiro   as char.

def temp-table ttparcelas no-undo serialize-name "parcelas"     
  field seqParcela  as char
  field vlrParcela  as char
  field dataVencimento as char.

def temp-table ttseguros no-undo serialize-name "seguros"     
    field numSeqForma as char
    field numSeqSeguro as char
    field numeroContrato as char
    field valorSeguro as char
    field numApolice as char
    field numSorteio as char
    field tipoSeguro as char.


{/admcom/progr/api/acentos.i}
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}
{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttdados NO-UNDO SERIALIZE-NAME "dados"
        field codigoLoja as char
        field dataTransacao as char
        field numeroComponente as char
        field sequencial as char
        field situacao as char
        field descricaoSituacao as char.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def dataset dadosEntrada for ttentrada, ttrecebimentos, ttparcelas, ttseguros.



hEntrada = dataset dadosEntrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar", vlcentrada, "EMPTY").

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
find first ttrecebimentos no-error.

ttrecebimentos.contratoFinanceira = "true". /* fixo */
/* */
def var vctmcod like pdvmov.ctmcod.
def var vmodcod like contrato.modcod.
def var vdatamov as date.
def var vnsu as int.
def var vvencod as int.
def var par-num  as int.
def var vplacod  like plani.placod.
def var vmovtdc  as int init 5. 
def var vmovseq  as int.
def var par-ser as char.

vctmcod =  if tipovenda = "44"
     then "P44"
     else if tipovenda = "47"
          then "P47"
          else "10".
                         
vmodcod = if vctmcod = "P44"
          then "CP0"
          else if vctmcod = "P47" 
               then "CP1" 
              else vmodcod.
vdatamov = aaaa-mm-dd_todate(ttentrada.dataTransacao).
vnsu     = int(ttentrada.sequencial).
            
do on error undo:    

  find cmon where
      cmon.etbcod = int(ttentrada.codigoLoja) and
      cmon.cxacod = int(ttentrada.numeroComponente)
      no-lock no-error.
  if not avail cmon 
  then do on error undo: 
      create cmon. 
      assign 
      cmon.cmtcod = "PDV" 
      cmon.etbcod = int(ttentrada.codigoLoja)
      cmon.cxacod = int(ttentrada.numeroComponente)
      cmon.cmocod = int(string(cmon.etbcod) + string(cmon.cxacod,"999")) 
      cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                "Cx " + string(cmon.cxacod). 
  end.

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
      create ttsaida.
      ttsaida.tstatus = 400.
      ttsaida.descricaoStatus = "Já Incluido".
    
      hsaida  = temp-table ttsaida:handle.
    
      lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
      message string(vlcSaida).
      return.
  end.    

  pdvmov.valortot   = dec(valorTotal).
  pdvmov.valortroco = dec(ttentrada.valorTroco).

  pdvmov.codigo_operador =  codigoOperador.

  pdvmov.HoraMov    = hora_totime(ttentrada.hora).
  pdvmov.EntSai     = yes.
  pdvmov.statusoper = "".

  find first pdvdoc of pdvmov where pdvdoc.seqreg = 1 no-error.
  if not avail pdvdoc
  then do:
      create pdvdoc.
      assign 
      pdvdoc.etbcod    = pdvmov.etbcod
      pdvdoc.DataMov   = pdvmov.DataMov
      pdvdoc.cmocod    = pdvmov.cmocod
      pdvdoc.COO       = pdvmov.COO
      pdvdoc.Sequencia = pdvmov.Sequencia
      pdvdoc.ctmcod    = pdvmov.ctmcod
      pdvdoc.seqreg    = 1
      /*pdvdoc.titcod    = ?*/ .
  end.    
  pdvdoc.valor_encargo = dec(valEncargoFinanc). 
  pdvdoc.valor        = pdvmov.valortot.

  if pdvdoc.tipo_venda = 0
  then pdvdoc.tipo_venda = 7.

  pdvdoc.clifor         = dec(ttentrada.codigoCliente) no-error.

  if pdvdoc.clifor = ? or pdvdoc.clifor = 0
  then pdvdoc.clifor = 1.
end.

vvencod = int(codigoVendedor) no-error.
if vvencod = ?
then vvencod = 150.

find plani where plani.etbcod = pdvdoc.etbcod and
                 plani.placod = pdvdoc.placod 
    NO-LOCK no-error.
if not avail plani or
  pdvdoc.placod = 0 or
  pdvdoc.placod = ?
then do:
    run /admcom/bs/bas/grplanum.p (pdvmov.etbcod, "", output vplacod, output par-num).

    par-ser = string(cmon.cxacod,"999") +  
      string(pdvmov.datamov,"999999").
    par-num = pdvmov.sequencia.

end.

do on error undo.  
/*
plani.biss = Somar o valor do campo recebimentos.recebimentoCrediario.parcelas.vlrParcela de todas as parcelas
plani.modcod = buscar o modcod associado ao codProdutoFinanceiro na tabela profin
plani.notObs = Se o tamanho da string no campo cabecario.empresaCreditada for maior que 21 caracteres 
          envia: CONCAT("Deposito="+cabecario.empresaCreditada+";Favorecido="+cabecario.agenciaArrecadadora+";")
          Se não: ";;"
*/
    create plani. 
    assign 
    plani.modcod = vmodcod
    plani.placod   = vplacod 
    plani.etbcod   = pdvdoc.etbcod 
    plani.numero   = par-num  
    plani.cxacod   = cmon.cxacod 
    plani.emite    = pdvdoc.etbcod 
    plani.serie = string(cmon.cxacod,"999") + string(day(vdatamov),"99") + string(month(vdatamov),"99") + string(year(vdatamov))
    
    plani.movtdc   = vmovtdc  
    plani.desti    = int(pdvdoc.clifor) 
    plani.pladat   = pdvmov.datamov 
    plani.dtinclu  = plani.pladat 
    plani.horincl  = pdvmov.horamov  
    plani.notsit   = no 
    plani.datexp   = today 

    plani.vlserv   = 0
    plani.vencod  =  vvencod. 
    plani.pedcod    = int(ttrecebimentos.codigoPlano).
    plani.crecod = 2.

    
    assign
        plani.notped = "C|" + string(pdvmov.coo) + "|" +  string(cmon.cxacod) + "|" .
        plani.ufdes  = pdvdoc.chave_nfe.

    assign
    pdvdoc.placod = plani.placod.
    pdvdoc.pstatus = yes. /* FECHADO */ 
    
          vmovseq = vmovseq + 1.
          create movim.
          assign
              movim.movtdc = plani.movtdc
              movim.etbcod = plani.etbcod
              movim.placod = plani.placod
              movim.emite  = plani.emite
              movim.desti  = plani.desti
              movim.movdat = plani.pladat
              movim.movhr  = plani.horincl
              movim.movseq = vmovseq.
              movim.procod = int(ttrecebimentos.codProdutoFinanceiro).
              movim.movqtm = 1.
              movim.movpc  = dec(ttrecebimentos.valorFinanciamento) +  dec(ttrecebimentos.valortfc).
              movim.movalicms = 98 /* #3 */.
    
    
    
/*
    find first ttdepositoCP no-error. 
    if avail ttdepositoCP 
    then do: 
        create contCP. 
        contCP.etbcod = plani.etbcod. 
        contCP.placod = plani.placod. 
        contCP.contnum = ?. 
        contcp.banco   = ttdepositoCP.banco. 
        contCP.agencia = ttdepositoCP.agencia. 
        contCP.tipoConta = ttdepositoCP.tipoConta. 
        contCP.numeroConta = ttdepositoCP.numeroConta.

    find first ttcliente no-error.
    if avail ttcliente
    then do:
        contcp.clicod    = int(ttcliente.codigoCliente).
        contcp.cpfdesti  = dec(ttcliente.cpfCnpj).
        contcp.nomedesti = ttcliente.nome.
    end.
*/

end.
def var vcodigo_forma as char.

    vcodigo_forma  = ttrecebimentos.codigoForma.
    find first pdvforma where      
            pdvforma.etbcod     = pdvmov.etbcod and
            pdvforma.cmocod     = pdvmov.cmocod and
            pdvforma.DataMov    = pdvmov.DataMov and
            pdvforma.Sequencia  = pdvmov.Sequencia and
            pdvforma.ctmcod     = pdvmov.ctmcod and
            pdvforma.COO        = pdvmov.COO and
            pdvforma.seqforma   = int(ttrecebimentos.numseqforma)
            no-error.
    if not avail pdvforma 
    then do: 
        create pdvforma.
        assign
            pdvforma.etbcod     = pdvmov.etbcod
            pdvforma.DataMov    = pdvmov.DataMov
            pdvforma.cmocod     = pdvmov.cmocod
            pdvforma.COO        = pdvmov.COO
            pdvforma.Sequencia  = pdvmov.Sequencia
            pdvforma.ctmcod     = pdvmov.ctmcod 
            pdvforma.seqforma   = int(ttrecebimentos.numseqforma).
    end.                     

    find pdvtforma where pdvtforma.pdvtfcod = vcodigo_forma no-lock no-error.
    pdvforma.crecod       = 1.
    pdvforma.modcod       = if vmodcod = ""
                            then if avail pdvtforma
                                then pdvtforma.modcod
                                else vmodcod
                            else vmodcod.
    pdvforma.pdvtfcod     = vcodigo_forma.
    pdvforma.fincod       = int(ttrecebimentos.codigoPlano).
    pdvforma.valor_forma  = dec(ttrecebimentos.valorPagoForma).
    pdvforma.valor        = dec(ttrecebimentos.valorPagoForma).

      pdvforma.contnum      = ttrecebimentos.numeroContrato.
      pdvforma.clifor       = int(pdvdoc.clifor).
      pdvforma.crecod       = 2.
      
      pdvforma.qtd_parcelas  = int(ttrecebimentos.qtdParcelas).
      pdvforma.valor_ACF    = dec(ttrecebimentos.valorAcrescimo).
      pdvforma.valor        = dec(ttrecebimentos.valorPagoForma).


      find contrato where contrato.contnum  = int(pdvforma.contnum) exclusive no-error.
      if not avail contrato
      then do:
          create contrato.
          contrato.contnum       = int(pdvforma.contnum).
          create contnf.
          contnf.contnum = contrato.contnum.
          contnf.etbcod = plani.etbcod.
          contnf.placod = plani.placod.
          contnf.notanum = plani.numero.
          contnf.notaser = plani.serie.
        
      end.     

      ASSIGN
        contrato.clicod        = pdvdoc.clifor.
        contrato.dtinicial     = aaaa-mm-dd_todate(dataTransacao).
        contrato.etbcod        = pdvmov.etbcod.
        contrato.vltotal       = dec(ttrecebimentos.valorFinanciamento) +
                                 dec(ttrecebimentos.valorAcrescimo) +
                                 dec(ttrecebimentos.valorIof) +
                                 dec(ttrecebimentos.valorTFC).
        contrato.vlentra       = 0.
        contrato.crecod        = pdvforma.fincod.
        contrato.vltaxa        = dec(ttrecebimentos.valorTFC).
        
        def var val_tfc as dec.
        val_tfc = dec(ttrecebimentos.valorTFC).
        
        contrato.modcod        = pdvforma.modcod /*ttrecebimentos.modalidade*/ .
        contrato.DtEfetiva     = aaaa-mm-dd_todate(ttrecebimentos.dataEmissaoContrato).
        contrato.VlIof         = dec(ttrecebimentos.valorIof).
        contrato.Cet           = dec(ttrecebimentos.Cet).
        contrato.TxJuros       = dec(ttrecebimentos.txMes).
        contrato.vlf_acrescimo = dec(ttrecebimentos.valorAcrescimo) +  dec(ttrecebimentos.valorIof).

        contrato.vlf_principal = dec(ttrecebimentos.valorFinanciamento) + dec(ttrecebimentos.valorTFC).

        plani.protot   = contrato.vlf_principal.
        plani.platot   = contrato.vlf_principal.
        plani.biss     = contrato.vltotal.

def var valteraprincipal as log.        
        valteraprincipal = no.
        /* #27092022 helio */
        if contrato.vlf_acrescimo > 0 and contrato.vlf_acrescimo <= 5.00
        then do:
              contrato.vlf_principal = contrato.vlf_principal + contrato.vlf_acrescimo.
              contrato.vlf_acrescimo = 0.   
              valteraprincipal = yes.
        end.
        
        /* #27092022 */
        
        
        if contrato.vlf_acrescimo < 0   /* 18.06.20 14:18 Novacao total e principal esta vindo iguais */
        then contrato.vlf_acrescimo = 0.

        contrato.nro_parcelas  = int(ttrecebimentos.qtdParcelas).

        contrato.banco = if true_tolog(ttrecebimentos.contratoFinanceira)
                         then if pdvmov.ctmcod = "P47" 
                              then 13 
                              else 10
                         else contrato.banco.
        contrato.tpcontrato = if pdvmov.ctmcod = "P48"
                              then "N"
                              else "".

        if true /* true_tolog(ttrecebimentos.contratoFinanceira) /* Marca Financeira */*/
        then do on error undo:
            def var psicred as recid.                    
                run /admcom/progr/fin/sicrecontr_create.p (recid(pdvforma),
                                        contrato.contnum,
                                        output psicred).

                find sicred_contrato where recid(sicred_contrato) = psicred no-lock no-error.        
        end.
      
      for each ttparcelas.
        def var vtitpar as int.
          vtitpar = int(ttparcelas.seqParcela).
          find first pdvmoeda where      
               pdvmoeda.etbcod       = pdvmov.etbcod and
               pdvmoeda.cmocod       = pdvmov.cmocod and
               pdvmoeda.DataMov      = pdvmov.DataMov and
               pdvmoeda.Sequencia    = pdvmov.Sequencia and
               pdvmoeda.ctmcod       = pdvmov.ctmcod and
               pdvmoeda.COO          = pdvmov.COO and
               pdvmoeda.seqforma     = pdvforma.seqforma and
               pdvmoeda.seqfp        = 1 and
               pdvmoeda.titpar       = vtitpar
              no-error.
          if not avail pdvmoeda
          then do: 
              create pdvmoeda.
              /*pdvmoeda.titcod   = next-value(titcod).*/
              assign
                   pdvmoeda.etbcod       = pdvmov.etbcod
                   pdvmoeda.DataMov      = pdvmov.DataMov
                   pdvmoeda.cmocod       = pdvmov.cmocod
                   pdvmoeda.COO          = pdvmov.COO
                   pdvmoeda.Sequencia    = pdvmov.Sequencia
                   pdvmoeda.ctmcod       = pdvmov.ctmcod
                   pdvmoeda.seqforma     = pdvforma.seqforma
                   pdvmoeda.seqfp        = 1
                   pdvmoeda.titpar       = vtitpar.   
          end.                  
          assign
              pdvmoeda.contrato_p2k = pdvforma.contnum.
          pdvmoeda.clifor = contrato.clicod.
          pdvmoeda.titnum = string(contrato.contnum).
          pdvmoeda.moecod = pdvforma.modcod.
          pdvmoeda.modcod = pdvforma.modcod.

          pdvmoeda.valor = dec(ttparcelas.vlrparcela).
          pdvmoeda.titdtven = aaaa-mm-dd_todate(ttparcelas.datavencimento).

          /*220720*/
          if pdvmoeda.titdtven < pdvmoeda.datamov
          then pdvmoeda.titdtven = pdvmoeda.datamov.
  
          find first titulo where titulo.contnum = contrato.contnum and
                            titulo.titpar  = pdvmoeda.titpar  
                  no-error.
          if not avail titulo
          then do:
              find first titulo where
              titulo.empcod     = 19 and
              titulo.titnat     = no and
              titulo.modcod     = pdvmoeda.modcod and
              titulo.etbcod     = pdvmoeda.etbcod and
              titulo.clifor     = pdvmoeda.clifor and
              titulo.titnum     = pdvmoeda.titnum and 
              titulo.titpar     = pdvmoeda.titpar and
              titulo.titdtemi   = pdvmoeda.datamov
              no-error.
              if not avail titulo
              then do:
                  create titulo. 
                  titulo.datexp = today.
              end.           
              titulo.contnum  = contrato.contnum. 
              
              assign            
              titulo.empcod     = 19
              titulo.titnat     = no
              titulo.modcod     = pdvmoeda.modcod 
              titulo.etbcod     = pdvmoeda.etbcod 
              titulo.clifor     = pdvmoeda.clifor 
              titulo.titnum     = pdvmoeda.titnum 
              titulo.titpar     = pdvmoeda.titpar 
              titulo.titdtemi   = pdvmoeda.datamov
              titulo.titdtven   = pdvmoeda.titdtven.
              titulo.titsit     = "LIB".
          end.        
          assign
              titulo.modcod     = contrato.modcod
              titulo.titvlcob   = pdvmoeda.valor
              titulo.titnumger  = pdvmoeda.contrato_p2k 
              titulo.tpcontrato = contrato.tpcontrato.

          assign
              titulo.vlf_acrescimo  = contrato.vlf_acrescimo / contrato.nro_parcelas.
              titulo.vlf_principal  = contrato.vlf_principal / contrato.nro_parcelas.
         
          /* #27092022 helio */
          if valteraprincipal
          then do:
              assign
                  titulo.vlf_principal = contrato.vlf_principal / contrato.nro_parcelas.
          end.
          
          titulo.cobcod = if psicred <> ?
                          then sicred_contrato.cobcod
                          else 1.
                          
                 
      end.
                              
      for each ttseguros where tipoSeguro <> ?.
        def var vtpseguro as int.
          vtpseguro =  if pdvmov.ctmcod = "P44" or
                          pdvmov.ctmcod = "P47"
                       then 3
                       else  int(tipoSeguro).

/*def temp-table ttseguros no-undo serialize-name "seguros"     
    field numSeqForma as char
    field numSeqSeguro as char
    field numeroContrato as char
    field valorSeguro as char
    field numApolice as char
    field numSorteio as char
    field tipoSeguro as char.
9*/              
          find vndseguro where
                  vndseguro.tpseguro = vtpseguro
              and vndseguro.etbcod   = pdvmov.etbcod
              and vndseguro.certifi  = ttseguros.numApolice
                 no-error.
          if not avail vndseguro
          then do.
              create vndseguro.
              assign
                  vndseguro.tpseguro = vtpseguro.
                  vndseguro.certifi  = numApolice.
                  vndseguro.etbcod   = pdvmov.etbcod.
          end.
          find current plani no-lock no-error.
          assign  
              vndseguro.placod   = if avail plani
                                   then plani.placod 
                                   else ?.
              vndseguro.prseguro = dec(ttseguros.valorSeguro).
              vndseguro.pladat   = pdvmov.datamov .
              vndseguro.dtincl   = pdvmov.datamov .
              vndseguro.procod   = int(tipoSeguro).
              vndseguro.clicod   = if avail plani
                                   then plani.desti
                                   else if avail contrato
                                        then contrato.clicod
                                        else ?.
              vndseguro.codsegur = int(9839).
              vndseguro.contnum  = int(pdvforma.contnum) .
/*              vndseguro.dtivig   = aaaa-mm-dd_todate(ttseguros.dataInicioVigencia).
              vndseguro.dtfvig   = aaaa-mm-dd_todate(ttseguros.dataFimVigencia).
              */
              vndseguro.datexp   = today .
              vndseguro.exportado = no. 
              vndseguro.numerosorte = numSorteio .
              
          find contrato where contrato.contnum = int(pdvforma.contnum) exclusive.
          contrato.vlseguro = dec(ttseguros.valorSeguro).
          
          contrato.vlf_principal = contrato.vlf_principal - dec(ttseguros.valorSeguro).
          
          if  vctmcod = "VHS" or vctmcod = "D24" 
          then do:
              contrato.vlf_hubseg = contrato.vlf_principal.
          end.
          for each titulo where titulo.contnum = contrato.contnum.
              titulo.titdesc        = contrato.vlseguro / contrato.nro_parcela. /* apenas compatibilidade, porque nao usa mais este campo */
              titulo.vlf_principal  = contrato.vlf_principal / contrato.nro_parcelas.
              if  vctmcod = "VHS" or vctmcod = "D24"
              then do:
                  titulo.vlf_hubseg = titulo.vlf_principal.
              end.
          end.                
              
          find current plani exclusive no-error.
          if avail plani
          then  do:
              plani.seguro  = plani.seguro  + contrato.vlseguro.

      /* cria movim seguro prestamista */

          /*** Seguro eh um item da nota */
          vmovseq = vmovseq + 1.
          create movim.
          assign
              movim.movtdc = plani.movtdc
              movim.etbcod = plani.etbcod
              movim.placod = plani.placod
              movim.emite  = plani.emite
              movim.desti  = plani.desti
              movim.movdat = plani.pladat
              movim.movhr  = plani.horincl
              movim.movseq = vmovseq
              movim.procod = vndseguro.procod
              movim.movqtm = 1
              movim.movpc  = vndseguro.prseguro
              movim.movalicms = 98 /* #3 */.

          end.
          
      /* movim seguro */                                    
                                          
      end.


/* */
vstatus = if avail contrato then 200 else 400.

create ttdados .
ttdados.codigoLoja        = ttentrada.codigoLoja.
ttdados.dataTransacao     = ttentrada.dataTransacao.
ttdados.numeroComponente  = ttentrada.numeroComponente.
ttdados.sequencial        = ttentrada.sequencial.
ttdados.situacao          = string(vstatus).
ttdados.descricaoSituacao = if avail contrato then "Contrato " + string(contrato.contnum) + " Criado"
                            else " ERRO ".



hSaida = temp-table ttdados:HANDLE.
lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson and vstatus = 200
then do:
      
        put unformatted trim(string(vlcsaida)).
end.
else do:
    create ttsaida.
    ttsaida.tstatus = vstatus.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.


