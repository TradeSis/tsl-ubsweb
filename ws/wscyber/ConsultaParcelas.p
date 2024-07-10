
/* buscarplanopagamento */
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
   
   
def shared temp-table consultaparcelas
    field tipo_documento as char
    field funcionalidade as char
    field numero_documento as char
    field codigo_contrato as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.



find first consultaparcelas no-error.

vstatus = if avail consultaparcelas
          then "S"
          else "E".
vmensagem_erro = if avail consultaparcelas
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     


{bsxml.i}

    if consultaparcelas.tipo_documento = "1" /* cpF */
    then do:
        find first clien where 
            clien.ciccgc = consultaparcelas.numero_documento
            no-lock no-error.
    end.
    if consultaparcelas.tipo_documento = "2" /* codigo-cliente */
    then do:
        find first clien where 
            clien.clicod = int(consultaparcelas.numero_documento)
            no-lock no-error.
    end.

    if vstatus = "S"
    then do:
        if not avail clien
        then do:
            vstatus = "E".
            vmensagem_erro = "CLIENTE Nao Encontrato".
        end.
        else do:
            vstatus = "S".
            vmensagem_erro = "OK".
        end.
    end.
     
    BSXml("ABREXML","").
    bsxml("abretabela","return").


    bsxml("status",vstatus).
    bsxml("mensagem_erro",vmensagem_erro).
    bsxml("funcionalidade",consultaparcelas.funcionalidade).
    
    if avail clien
    then do:
        
        bsxml("codigo_cliente",string(clien.clicod)).
        bsxml("cpf",clien.ciccgc).
        bsxml("nome",clien.clinom).
        if clien.dtnasc <> ?
        then  bsxml("data_nascimento",string(year(clien.dtnasc),"9999") + "-" +
                                     string(month(clien.dtnasc),"99")   + "-" + 
                                     string( day (clien.dtnasc),"99")   + 
                                     "T00:00:00").
        else  bsxml("data_nascimento","1900-01-01T00:00:00").
        
        bsxml("tipo_cartao","?").
    bsxml("codigo_filial",consultaparcelas.codigo_filial).
    bsxml("numero_pdv",consultaparcelas.numero_pdv).

/*       BSXml("ABRETABELA","contratos"). 
*/

       def var vi as int.
       vi = 0.
       for each estab no-lock,
           each titulo where
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.clifor = clien.clicod and
            titulo.modcod = "CRE" and
            titulo.titdtpag = ? and
            titulo.etbcod = estab.etbcod
            no-lock
            break by titulo.titnum by titulo.titpar.

            if first-of(titulo.titnum)
            then do:
                BSXml("ABREREGISTRO","contratos"). 
                bsxml("filial_contrato",string(titulo.etbcod)).
                bsxml("modalidade",string(titulo.modcod)).
                bsxml("numero_contrato",string(titulo.titnum)).
                bsxml("data_emissao_contrato",string(year(titulo.titdtemi),"9999") + "-" +
                                     string(month(titulo.titdtemi),"99")   + "-" + 
                                     string( day (titulo.titdtemi),"99")   + 
                                     "T00:00:00").
                
/*
                BSXml("ABRETABELA","parcelas"). 
*/
                vi = vi + 1.
            end.

/*
if first-of(titulo.titnum) then do:
*/

            BSXml("ABREREGISTRO","parcelas").
            bsxml("seq_parcela",string(titulo.titpar)).
                bsxml("venc_parcela",string(year(titulo.titdtven),"9999") + "-" +
                                     string(month(titulo.titdtven),"99")   + "-" + 
                                     string( day (titulo.titdtven),"99")   + 
                                     "T00:00:00").
            
            bsxml("vlr_parcela",string(titulo.titvlcob)).
            bsxml("valor_encargos",string(0)).
            bsxml("percentual_encargo_dia",string(0)).

            BSXml("FECHAREGISTRO","parcelas").
/*
end.
*/
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

                /*
               if vi = 3 then
                leave.
*/
            end.


        end.        

/*
        bsxml("FECHATABELA","contratos").
*/
        
    
    end.

    

    bsxml("fechatabela","return").
    BSXml("FECHAXML","").














