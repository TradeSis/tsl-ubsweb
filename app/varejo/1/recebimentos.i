





def var valteraprincipal as log.

    def var psicred as recid.
    def var val_tfc as dec init 0.
    for each ttrecebimentos where ttrecebimentos.idpai = {1}.

        
        
        vcodigo_forma  = ttrecebimentos.formaPagamento.
        find first pdvforma where      
                 pdvforma.etbcod     = pdvmov.etbcod and
                 pdvforma.cmocod     = pdvmov.cmocod and
                 pdvforma.DataMov    = pdvmov.DataMov and
                 pdvforma.Sequencia  = pdvmov.Sequencia and
                 pdvforma.ctmcod     = pdvmov.ctmcod and
                 pdvforma.COO        = pdvmov.COO and
                 pdvforma.seqforma   = int(ttrecebimentos.sequencial)
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
                pdvforma.seqforma   = int(ttrecebimentos.sequencial).
        end.                     

        find pdvtforma where pdvtforma.pdvtfcod = vcodigo_forma no-lock no-error.
        pdvforma.crecod       = 1.
        pdvforma.modcod       = pdvtforma.modcod.
        pdvforma.modcod       = if vmodcod = ""  
                                    then if avail pdvtforma 
                                         then pdvtforma.modcod 
                                         else vmodcod 
                                else vmodcod.
        
        
        
        
        
        pdvforma.pdvtfcod     = vcodigo_forma.
        pdvforma.fincod       = int(ttrecebimentos.codigoPlano).
        pdvforma.valor_forma  = dec(ttrecebimentos.valorRecebido).
        pdvforma.valor        = dec(ttrecebimentos.valorRecebido) - dec(ttrecebimentos.troco).
        





        
        if pdvforma.pdvtfcod = "1"
        then do on error undo: 
            find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = 0
                    no-error.
            if not avail pdvmoeda 
            then do: 
                create pdvmoeda. 

                assign 
                    pdvmoeda.etbcod     = pdvmov.etbcod 
                    pdvmoeda.DataMov    = pdvmov.DataMov 
                    pdvmoeda.cmocod     = pdvmov.cmocod 
                    pdvmoeda.COO        = pdvmov.COO 
                    pdvmoeda.Sequencia  = pdvmov.Sequencia 
                    pdvmoeda.ctmcod     = pdvmov.ctmcod 
                    pdvmoeda.seqforma   = pdvforma.seqforma 
                    pdvmoeda.seqfp      = 1 
                    pdvmoeda.titpar     = 0.   
            end.                    
            pdvmoeda.moecod   = pdvforma.modcod. 
            pdvmoeda.valor    = pdvforma.valor.
            
            pdvforma.crecod = 1.
            
        end.


        if vecommerce
        then do on error undo:

            
            
            find first contrsite where contrsite.etbcod       = pdvforma.etbcod and
                                       contrsite.codigoPedido = vnumeropedido
                no-lock no-error.
            if avail contrsite
            then do:

                find contrato where contrato.contnum = contrsite.contnum no-lock.

                pdvforma.contnum      = string(contrato.contnum).
                pdvforma.modcod       = contrato.modcod.
                pdvforma.clifor       = contrato.clicod.
                pdvforma.crecod       = 2.
            
                pdvforma.qtd_parcelas = contrato.nro_parcelas.
                pdvforma.valor_ACF    = contrato.vlf_acrescimo.
                pdvforma.valor        = contrato.vltotal.
                
            end.
        end.
        else for each ttcontrato where ttcontrato.id = ttrecebimentos.id: 
        
            pdvforma.contnum      = ttcontrato.numeroContrato.
            pdvforma.clifor       = int(ttcontrato.codigoCliente).
            pdvforma.crecod       = 2.
            
            pdvforma.qtd_parcelas  = int(ttcontrato.qtdParcelas).
            pdvforma.valor_ACF    = dec(ttcontrato.valorAcrescimo).
            pdvforma.valor        = dec(ttcontrato.valorTotal).


            find contrato where contrato.contnum  = int(pdvforma.contnum) exclusive no-error.
            if not avail contrato
            then do:
                create contrato.
                contrato.contnum       = int(pdvforma.contnum).
            end.     

            
            ASSIGN contrato.vlseguro = 0. 
              contrato.clicod        = int(ttcontrato.codigoCliente).
              contrato.dtinicial     = vdatamov.
              contrato.etbcod        = pdvmov.etbcod.
              contrato.vltotal       = dec(ttcontrato.valorTotal) + dec(ttcontrato.valorEntrada).
              contrato.vlentra       = dec(ttcontrato.valorEntrada).
              contrato.crecod        = pdvforma.fincod.
              contrato.vltaxa        = dec(ttcontrato.valorTFC).
              val_tfc = dec(ttcontrato.valorTFC).
              contrato.modcod        = pdvforma.modcod /*ttcontrato.modalidade*/ .
              contrato.DtEfetiva     = aaaa-mm-dd_todate(ttcontrato.dataEfetivacao).
              contrato.dtinicial    = contrato.DtEfetiva. /* helio 190224 */
              contrato.VlIof         = dec(ttcontrato.valorIof).
              contrato.Cet           = dec(ttcontrato.taxaCet).
              contrato.TxJuros       = dec(ttcontrato.taxaMes).
              contrato.vlf_principal = dec(ttcontrato.valorPrincipal). 
              
              /* 20240725 gabriel - retirado do insertep
              if  vctmcod = "VHS" or vctmcod = "D24"
              then do:
                  contrato.idAdesaoHubSeg = pdvdoc.idAdesaoHubSeg.
                  contrato.vlf_hubseg = contrato.vlf_principal.

                    if vctmcod = "D24"
                    then do:
                        find medadesao where medadesao.idadesao = int(idAdesaoHubSeg) 
                                exclusive no-wait no-error.
                        if avail medadesao
                        then do:
                            medadesao.clicod = pdvdoc.clifor.
                            medadesao.fincod = contrato.crecod.
                            medadesao.contnum = contrato.contnum.
                        end.        
                    end.
                  
              end.
              */
              
              contrato.vlf_acrescimo = dec(ttcontrato.valorAcrescimo).
                                            /* helio 200421
                                            **dec(ttcontrato.valorTotal) - dec(ttcontrato.valorPrincipal) - dec(ttcontrato.valorIof).
                                            */    

              contrato.vlf_principal = 0.            
              contrato.vltotal = 0.
              for each ttparcelas where ttparcelas.idpai = ttcontrato.id.
                    contrato.vltotal = contrato.vltotal + dec(ttparcelas.valorParcela).
                    contrato.vlf_principal = contrato.vlf_principal + dec(ttparcelas.valorPrincipal).
                    
              end.
              
              valteraprincipal = no.
              
              if contrato.vlf_acrescimo < 0   /* 18.06.20 14:18 Novacao total e principal esta vindo iguais */
              then contrato.vlf_acrescimo = 0.

              contrato.nro_parcelas  = int(ttcontrato.qtdParcelas).

              contrato.banco = if true /*true_tolog(ttcontrato.contratoFinanceira)*/
                               then if pdvmov.ctmcod = "P47" 
                                    then 13 
                                    else 10
                               else contrato.banco.
              contrato.tpcontrato = if pdvmov.ctmcod = "P48" and contrato.etbcod <> 982 /* helio 21062024 -- or pdvmov.ctmcod = "RFN" */
                                    then "N"
                                    else "".

                if pdvmov.ctmcod = "P48" 
                then do:

                    
                    contrato.banco = if true /*true_tolog(ttcontrato.contratoFinanceira)*/
                                     then if contrato.modcod = "CPN"
                                          then 13
                                          else 10
                                     else contrato.banco.

                                     
                end.
              
            /*    
            if true_tolog(ttcontrato.contratoFinanceira) /* Marca Financeira */
            then do on error undo:
                            
                run /admcom/progr/fin/sicrecontr_create.p (recid(pdvforma),
                                             contrato.contnum,
                                             output psicred).

                find sicred_contrato where recid(sicred_contrato) = psicred no-lock no-error.
            
            end.
            */
            
            for each ttparcelas where ttparcelas.idpai = ttcontrato.id.

                vtitpar = int(ttparcelas.sequencial).
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

                pdvmoeda.valor = dec(ttparcelas.valorparcela).
                
                pdvmoeda.titdtven = aaaa-mm-dd_todate(ttparcelas.datavencimento).

                /* helio 190324 -retiradao
                *if pdvmoeda.titdtven < pdvmoeda.datamov
                *then pdvmoeda.titdtven = pdvmoeda.datamov.
                */
                
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
                    titulo.vlf_principal = dec(ttparcelas.valorPrincipal).
               
                /* helio 20032024
                if valteraprincipal
                then do:
                    assign
                        titulo.vlf_principal = contrato.vlf_principal / contrato.nro_parcelas.
                end.
                */
                
                /* #02092022 */    
                if  vctmcod = "VHS" or vctmcod = "D24"
                then do:
                    titulo.vlf_hubseg = titulo.vlf_principal.
                end.

                titulo.cobcod = 10. /*if avail  sicred_contrato
                                then sicred_contrato.cobcod
                                else 1.*/
                                

            end.
            /*                        
            for each ttseguro where ttseguro.idpai = ttcontrato.id.
                vtpseguro =  if pdvmov.ctmcod = "P44" or
                                pdvmov.ctmcod = "P47"
                             then 3
                             else  int(tipoSeguro).
                    
                find vndseguro where
                        vndseguro.tpseguro = vtpseguro
                    and vndseguro.etbcod   = pdvmov.etbcod
                    and vndseguro.certifi  = numeroApolice
                       no-error.
                if not avail vndseguro
                then do.
                    create vndseguro.
                    assign
                        vndseguro.tpseguro = vtpseguro.
                        vndseguro.certifi  = numeroApolice.
                        vndseguro.etbcod   = pdvmov.etbcod.
                end.
                find current plani no-lock no-error.
                assign  
                    vndseguro.placod   = if avail plani
                                         then plani.placod 
                                         else ?.
                    vndseguro.prseguro = dec(ttseguro.valorSeguro).
                    vndseguro.pladat   = pdvmov.datamov .
                    vndseguro.dtincl   = pdvmov.datamov .
                    vndseguro.procod   = int(codigoSeguro).
                    vndseguro.clicod   = if avail plani
                                         then plani.desti
                                         else if avail contrato
                                              then contrato.clicod
                                              else ?.
                    vndseguro.codsegur = int(codigoSeguradora).
                    vndseguro.contnum  = int(pdvforma.contnum) .
                    vndseguro.dtivig   = aaaa-mm-dd_todate(ttseguro.dataInicioVigencia).
                    vndseguro.dtfvig   = aaaa-mm-dd_todate(ttseguro.dataFimVigencia).
                    vndseguro.datexp   = today .
                    vndseguro.exportado = no. 
                    vndseguro.numerosorte = numeroSorteio .
                    
                find contrato where contrato.contnum = int(pdvforma.contnum) exclusive.
                
                if dec(ttseguro.valorSeguro) = ? then ttseguro.valorSeguro = "0".
                
                contrato.vlseguro = dec(ttseguro.valorSeguro).
                
                /*contrato.vlf_principal = contrato.vlf_principal - dec(ttseguro.valorSeguro).*/
                
                /* #02092022 */
                if  vctmcod = "VHS" or vctmcod = "D24" 
                then do:
                    contrato.vlf_hubseg = contrato.vlf_principal.
                end.
                for each titulo where titulo.contnum = contrato.contnum.
                    titulo.titdesc        = contrato.vlseguro / contrato.nro_parcela. /* apenas compatibilidade, porque nao usa mais este campo */
                    /*titulo.vlf_principal  = contrato.vlf_principal / contrato.nro_parcelas. helio 20032024 */
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
            */
            /*delete ttcontrato.*/
            
            
        end.
        

            
    end.

    /* Ajusta contrato ADMCOM */
    assign
        vvalor_contrato = 0
        vvalor_vista    = 0.

    find first pdvforma of pdvmov where  
            pdvforma.crecod = 2 
            no-lock no-error.
    if not avail pdvforma
    then find first pdvforma of pdvmov where
            pdvforma.crecod = 1
            no-lock no-error.
             
    for each pdvmoeda of pdvmov no-lock.
        vvalor_contrato = vvalor_contrato + pdvmoeda.valor.

        if pdvforma.crecod = 2 and (pdvmoeda.titpar = 0 or pdvmoeda.moecod <> pdvforma.modcod) 
        then do.
            vvalor_vista = vvalor_vista + pdvmoeda.valor.

        end.
    end. 
    if avail plani
    then do:
    do on error undo:
        find current pdvdoc exclusive. 
        assign
            pdvdoc.fincod = pdvforma.fincod.
            pdvdoc.crecod = pdvforma.crecod.
            pdvdoc.contnum = pdvforma.contnum.

        find current plani exclusive no-error.
            
        if avail plani
        then do:
            /* Deposito CP */
            find first contCP where contCP.etbcod = plani.etbcod and
                                    contCP.placod = plani.placod and
                                    contCP.contnum = ?
                        exclusive no-error.
            if avail contCP
            then do:
                contCP.contnum = int(pdvdoc.contnum).
            end.     
                                     
            plani.pedcod   = pdvdoc.fincod . 
            plani.crecod   = pdvdoc.crecod.
        
            if pdvdoc.crecod = 2  
            then do: 
                find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.        
                plani.modcod = contrato.modcod. 
                create contnf.
                assign
                    contnf.contnum = int(pdvdoc.contnum)
                    contnf.etbcod  = plani.etbcod
                    contnf.placod  = plani.placod
                    contnf.notanum = plani.numero
                    contnf.notaser = plani.serie.
            
            end.    
            else plani.modcod = "VVI".
            find current plani  no-lock.
        end.
        
        find current pdvdoc no-lock.
    end.
    end. 
   
    if pdvforma.crecod = 2
    then do on error undo:
        
        if vvalor_vista > 0
        then do: 
            
            find contrato where contrato.contnum = int(pdvforma.contnum) no-lock.        

            find titulo where
                    titulo.empcod   = 19 and
                    titulo.titnat   = no and
                    titulo.modcod   = contrato.modcod and
                    titulo.etbcod   = contrato.etbcod and
                    titulo.clifor   = contrato.clicod and
                    titulo.titnum   = string(contrato.contnum) and
                    titulo.titpar   = 0 and
                    titulo.titdtemi = contrato.dtinicial
                    no-error.

            if not avail titulo
            then do:
                /* Cria 1 titulo VVI PAGO (Padrao Lebes) */                 
                create titulo. 
                titulo.datexp = today.
                titulo.contnum      = contrato.contnum.
                assign  
                    titulo.empcod   = 19
                    titulo.titnat   = no
                    titulo.modcod   = contrato.modcod 
                    titulo.etbcod   = contrato.etbcod 
                    titulo.clifor   = contrato.clicod
                    titulo.titnum   = string(contrato.contnum) 
                    titulo.titpar   = 0
                    titulo.titdtemi = contrato.dtinicial.
            end.            
            assign
                titulo.moecod   = "PDM"
                titulo.titvlcob = vvalor_vista
                titulo.titdtpag = titulo.titdtemi
                titulo.etbcobra = pdvmov.etbcod
                titulo.titvlpag = titulo.titvlcob
                titulo.titsit   = "PAG"
                titulo.cxacod   = cmon.cxacod
                titulo.cxmdata  = pdvmov.datamov
                titulo.cxmhora  = string(pdvmov.horamov)
                titulo.titdtven = titulo.titdtemi.

                
            /* Le os pdvmoeda e cria TITPAG */ 
            for each pdvmoeda of pdvmov where pdvmoeda.moecod <> "CRE" NO-LOCK.
                /** cria titpag padrao Lebes **/
                find first titpag where 
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar and
                          titpag.cxacod = titulo.cxacod and
                          titpag.cxmdata = titulo.cxmdata and
                          titpag.moecod = pdvmoeda.moecod
                          no-error.
                if not avail titpag
                then do:          
                    create titpag.
                    assign
                        titpag.empcod = titulo.empcod
                        titpag.titnat = titulo.titnat
                        titpag.modcod = titulo.modcod
                        titpag.etbcod = titulo.etbcod
                        titpag.clifor = titulo.clifor
                        titpag.titnum = titulo.titnum
                        titpag.titpar = titulo.titpar
                        titpag.cxacod = titulo.cxacod
                        titpag.cxmdata = titulo.cxmdata
                        titpag.moecod = pdvmoeda.moecod
                        titpag.titobs[3] = "P2K|Seq=" + string(pdvmov.sequencia).
                        /* #2 Juros Cartao */ 
                end.
                titpag.titvlpag = titpag.titvlpag + pdvmoeda.valor.            
            end.    
        end.
   end. 
