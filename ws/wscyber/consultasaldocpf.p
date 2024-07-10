
/* buscarplanopagamento */
def new global shared var setbcod       as int.
   
def shared temp-table consultasaldocpf
   field cpfcnpj as char.
 
find first consultasaldocpf.
def var vchavecontrato as char format "x(25)".
def var vjuros as dec.
def var vtjuros as dec. 
def var vsaldojur as dec.
def var vmodcod as char.
{bsxml.i}

def var vexistecpf as log.
    vexistecpf = yes.
    for each clien where clien.ciccgc = consultasaldocpf.cpfcnpj NO-LOCK.
        find first cyber_clien of clien no-lock no-error.
        if not avail cyber_clien
        then vexistecpf = no.
    end.

    BSXml("ABREXML","").
    bsxml("abretabela","return").
    
    bsxml("wsNomeWebService","wscyber").
    bsxml("wsCodigoRetorno",if vexistecpf then "1" else "2").
    bsxml("wsException","").
    bsxml("wsNomeMetodo","consultasaldocpf").
    bsxml("wsQtdReg","1").
    bsxml("wsMensagemRetorno","").

    for each cyber_contrato of cyber_clien no-lock.
        BSXml("ABREREGISTRO","contratoLista").
        bsxml("grupo","2").

        vchavecontrato = string(cyber_contrato.etbcod ,"999") +
                         string(cyber_contrato.contnum,"99999999999"). 

        bsxml("contrato",vchavecontrato).
        vtjuros = 0.
/***
        for each cyber_parcela of cyber_contrato no-lock.
            find titulo of cyber_parcela no-lock.
***/
         find contrato where contrato.contnum = cyber_contrato.contnum
                       no-lock no-error.

        vmodcod = if avail contrato
                then if contrato.modcod <> ""
                     then contrato.modcod
                     else "CRE"
                else "CRE".

        for each titulo where 
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = vmodcod and
                titulo.etbcod = cyber_contrato.etbcod and 
                titulo.clifor = cyber_contrato.clicod and 
                titulo.titnum = string(cyber_contrato.contnum) 
            no-lock.

            find clien where clien.clicod = titulo.clifor no-lock.
            vjuros = 0.
            if titulo.titsit = "LIB"
            then run /admcom/progr/juro_titulo.p
                        (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* helio 07112020 */
                         titulo.titdtven,
                         titulo.titvlcob,
                         output vjuros).                
            vtjuros = vtjuros + vjuros.                  
        end.
        bsxml("vlJuros",string(vtjuros ,">>>>>>>>>9.99")).
        bsxml("vlMulta","000").

/***
        for each cyber_parcela of cyber_contrato no-lock.
            find titulo of cyber_parcela no-lock.
***/
        for each titulo where 
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = vmodcod and
                titulo.etbcod = cyber_contrato.etbcod and 
                titulo.clifor = cyber_contrato.clicod and 
                titulo.titnum = string(cyber_contrato.contnum) 
            no-lock.

            find clien where clien.clicod = titulo.clifor no-lock.

            vjuros = 0.
            if titulo.titsit = "LIB"
            then run /admcom/progr/juro_titulo.p
                    (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* helio 07112020 */
                     titulo.titdtven,
                     titulo.titvlcob,
                     output vjuros).

            BSXml("ABREREGISTRO","parcelaLista").
            bsxml("grupo","2").
            BSXml("contrato",vchavecontrato).
            BSXml("nrParcela",string(titulo.titpar)).
            bsxml("vlParcJuros", string(vjuros ,">>>>>>>>>9.99")).
            bsxml("vlParcMulta","000").
            BSXml("fechaREGISTRO","parcelaLista").
        end.
        BSXml("fechaREGISTRO","contratoLista").
    end.
        
    bsxml("fechatabela","return").
    BSXml("FECHAXML","").

