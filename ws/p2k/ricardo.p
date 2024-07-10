def temp-table tt-modal like modal.
def var mmodal as char extent 3 init ["CRE", "CP0", "CP1"].

/* buscarplanopagamento */
def new global shared var setbcod       as int.

def var vi        as int.
def var vstatus   as char.   
def var vbloqueia as log.
def var vmensagem as char.
def var vjuros    as dec.   
def var vsaldojur as dec.
def var vmensagem_erro as char.
def var vvalor_contrato       as dec.
def var vvalor_total_pendente as dec.
def var vvalor_total_pago     as dec.
def var vvalor_total_encargo  as dec.
def buffer btitulo for titulo.
   
def shared temp-table consultaparcelas
    field tipo_documento as char
    field funcionalidade as char
    field numero_documento as char
    field codigo_contrato as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

{bsxml.i}

do vi = 1 to 3.
    create tt-modal.
    tt-modal.modcod = mmodal[vi].
end.

find first consultaparcelas no-lock no-error.
if avail consultaparcelas
then do.
    if consultaparcelas.tipo_documento = "1" /* cpF */
    then
        find first clien where clien.ciccgc = consultaparcelas.numero_documento
            no-lock no-error.

    if consultaparcelas.tipo_documento = "2" /* codigo-cliente */
    then 
        find clien where clien.clicod = int(consultaparcelas.numero_documento)
            no-lock no-error.

    if not avail clien
    then assign
            vstatus = "N"
            vmensagem_erro = "Cliente Nao Encontrado".
    else assign
            vstatus = "S"
            vmensagem_erro = "OK".
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("funcionalidade",consultaparcelas.funcionalidade).
    
if vstatus = "S" /* avail clien*/
then do:        
    bsxml("codigo_cliente",string(clien.clicod)).
    bsxml("cpf", Texto(clien.ciccgc)).
    bsxml("nome",Texto(clien.clinom)).
    if clien.dtnasc <> ?
    then bsxml("data_nascimento",string(year(clien.dtnasc),"9999") + "-" +
                                 string(month(clien.dtnasc),"99")   + "-" + 
                                 string( day (clien.dtnasc),"99")   + 
                                 "T00:00:00").
    else bsxml("data_nascimento","1900-01-01T00:00:00").
        
    bsxml("tipo_cartao","?").
    bsxml("codigo_filial",consultaparcelas.codigo_filial).
    bsxml("numero_pdv",consultaparcelas.numero_pdv).

/*       BSXml("ABRETABELA","contratos"). 
*/
    vabe = yes.
    vi = 0.
    for each estab no-lock,
        each tt-modal no-lock,
        each titulo where
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.modcod = tt-modal.modcod and /* "CRE"  */
            titulo.etbcod = estab.etbcod and
            titulo.clifor = clien.clicod and
            (if (consultaparcelas.funcionalidade = "P" or
                 consultaparcelas.funcionalidade = "N")
                then titulo.titdtpag = ? 
                else true) and
            (if consultaparcelas.codigo_contrato <> ? and
                consultaparcelas.codigo_contrato <> "" and
                consultaparcelas.codigo_contrato <> "?"
              then titulo.titnum = consultaparcelas.codigo_contrato
              else true)
            no-lock
            break by titulo.titnum
                  by titulo.titpar.
        
        
        if first-of(titulo.titnum)
        then     vabe = no.
        
        if N anf titulo.titdtven > today + 60 
        then next.
                
                
        if vabe = no
        then do:
            vabe = yes.
            BSXml("ABREREGISTRO","contratos"). 
            bsxml("filial_contrato",string(titulo.etbcod)).
            bsxml("modalidade",string(titulo.modcod)).
            bsxml("numero_contrato",string(int(titulo.titnum),"9999999999")).
            bsxml("data_emissao_contrato",EnviaData(titulo.titdtemi)).
            vvalor_contrato = 0. 
            vvalor_total_pago = 0.
            vvalor_total_pendente = 0.
            vvalor_total_encargo = 0.
            for each btitulo where
                        btitulo.empcod = 19 and
                        btitulo.titnat = no and
                        btitulo.modcod = titulo.modcod and
                        btitulo.etbcod = titulo.etbcod and
                        btitulo.clifor = titulo.clifor and
                        btitulo.titnum = titulo.titnum and
                        btitulo.titdtemi = titulo.titdtemi
                        no-lock.
                vvalor_contrato = vvalor_contrato + btitulo.titvlcob.
                if btitulo.titdtpag = ?
                then vvalor_total_pendente = vvalor_total_pendente + 
                                             btitulo.titvlcob.
                else vvalor_total_pago     = vvalor_total_pago     + 
                                             btitulo.titvlcob.

                if (consultaparcelas.funcionalidade = "P" or
                    consultaparcelas.funcionalidade = "N") and
                   btitulo.titdtpag <> ?
                then next.

                /** BASE MATRIZ  */
                vjuros = 0.
                if btitulo.titdtpag = ?
                then run juro_titulo.p (0, btitulo.titdtven, btitulo.titvlcob,
                               output vjuros).
/***
                run bstitjuro.p (input recid(btitulo),
                             input today,
                             output vjuros,
                             output vsaldojur).
***/            
                /** BASE LOJA
                p2kcalcjur.p (input recid(btitulo),
                             input today,
                             output vjuros,
                             output vsaldojur). */

                vvalor_total_encargo = vvalor_total_encargo + vjuros.
            end.        

            bsxml("valor_contrato",string(vvalor_contrato,">>>>>>>>>>>>9.99")).
            bsxml("valor_total_pago",
                                string(vvalor_total_pago,">>>>>>>>>>>>9.99")).
            bsxml("valor_total_pendente",string(vvalor_total_pendente,
                            ">>>>>>>>>>>>9.99")).
            bsxml("valor_total_encargo",string(vvalor_total_encargo,
                            ">>>>>>>>>>>>9.99")).

            vi = vi + 1.
        end.

        BSXml("ABREREGISTRO","parcelas").
        bsxml("seq_parcela",string(titulo.titpar)).
        bsxml("venc_parcela",string(year(titulo.titdtven),"9999") + "-" +
                             string(month(titulo.titdtven),"99")   + "-" + 
                             string(day(titulo.titdtven),"99")   + 
                                     "T00:00:00").
        bsxml("vlr_parcela",string(titulo.titvlcob,">>>>>>>>9.99")).

        /** BASE MATRIZ  */
        vjuros = 0.
        if titulo.titdtpag = ?
        then run juro_titulo.p (0, titulo.titdtven, titulo.titvlcob,
                               output vjuros).
/***
            run bstitjuro.p (input recid(titulo),
                             input today,
                             output vjuros,
                             output vsaldojur).
***/            
        /** BASE LOJA
             p2kcalcjur.p (input recid(titulo),
                             input today,
                             output vjuros,
                             output vsaldojur).
            */

        bsxml("valor_encargos",string(vjuros,">>>>>>>>>>9.99")).
        bsxml("percentual_encargo_dia",string(0)).

        if titulo.titdtpag <> ?
        then bsxml("data_pagamento",string(year(titulo.titdtpag),"9999") + "-" +
                                    string(month(titulo.titdtpag),"99") + "-" +
                                    string( day (titulo.titdtpag),"99") + 
                                     "T00:00:00").
        else bsxml("data_pagamento","1900-01-01T00:00:00").

        bsxml("valor_desconto",if titulo.titvlpag = 0 or
                                  titulo.titvlpag >= titulo.titvlcob
                               then string("0.00")
                               else string(titulo.titvlcob - titulo.titvlpag,
                                    ">>>>>>>>>>9.99")).
        
        BSXml("FECHAREGISTRO","parcelas").

        if last-of(titulo.titnum)
        then do:
/*
    array(
        'codigo_produto' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'descricao_produto' => array('name'=>'tipo_documento','type'=>'xsd:string'),
        'quantidade' => array('name'=>'numero_documento','type'=>'xsd:int'),
        'preco_unitario' => array('name'=>'codigo_filial','type'=>'xsd:decimal'),
        'preco_total' => array('name'=>'codigo_operador','type'=>'xsd:decimal')
    )
*/

            BSXml("ABREREGISTRO","produtos").
            find last produ no-lock.
            bsxml("codigo_produto",string(produ.procod)).
            bsxml("descricao_produto",produ.pronom).
            bsxml("quantidade",string(1)).
            bsxml("preco_unitario",string(1.50)).
            bsxml("preco_total",string(1.50)).
            BSXml("FECHAREGISTRO","produtos").
            BSXml("ABREREGISTRO","produtos").

            find prev produ no-lock.
            bsxml("codigo_produto",string(produ.procod)).
            bsxml("descricao_produto",produ.pronom).
            bsxml("quantidade",string(1)).
            bsxml("preco_unitario",string(1.50)).
            bsxml("preco_total",string(1.50)).
            BSXml("FECHAREGISTRO","produtos").
            
/*
               bsxml("fechatabela","parcelas"). 
*/
            BSXml("FECHAREGISTRO","contratos"). 

        end.        

    end. /* estab */

/***
    /* Cyber */
    if consultaparcelas.funcionalidade <> "N" and
       clien.clicod > 1
    then do.
        run ./progr/pdv/cyber_acordo.i ("CAIXA", clien.clicod,
                                        output vmensagem).
        if vmensagem <> ""
        then vbloqueia = yes.
    end.
***/
    bsxml("aviso", vmensagem).
    bsxml("bloqueia", if vbloqueia then "sim" else "nao").
end.
/***/

bsxml("fechatabela","return").
BSXml("FECHAXML","").

