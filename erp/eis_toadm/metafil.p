def input parameter par-arquivoentrada as char.

{/u/bsweb/progr/bsxml.i}
{/u/bsweb/progr/acha.i}

def var vi as int.

def buffer btabaux for tabaux.
def var vaux-cha1 as char.
def var vaux-cha2 as char.
def var vetbcod as int.
def var xetbcod as int.
def var vetbnom as char.
def var vparam  as char.
def var vip as char.

def var vip1 as int.
def var vip2 as int.


def temp-table metafil no-undo
    field etb as char
    field ano    as char
    field mes    as char
    field dia    as char
    field segmetmov as char
    field segmetmod as char
    field garmet as char
    field rfqmet as char  
    index etbano is unique primary etb asc ano asc mes asc dia asc.
    
def var v-return-mode        as log  no-undo.  
v-return-mode = 
    TEMP-TABLE metafil:READ-XML("FILE", 
                                par-arquivoentrada , 
                                "EMPTY", 
                                ? /* v-schemapath*/ , 
                                ?,  
                                ?, 
                                ? ). 
                                                        

BSXml("ABREXML","").
bsxml("abretabela","return").
    
    for each metafil.
                
                        
        /*BSXml("ABREREGISTRO","rows").*/

        find first duplic where  
                        duplic.duppc = int(metafil.mes) and
                        duplic.fatnum = int(metafil.etb) 
                      exclusive no-wait no-error.
        if not avail duplic
        then do:                  
            create duplic.
            assign
            duplic.duppc = int(metafil.mes)
            duplic.fatnum = int(metafil.etb).
        end.    

        vaux-cha1 = "".
        find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") +
                                                            ";" + string(duplic.duppc,"99")
                                                
                exclusive no-wait no-error.
                if avail tabaux
                then do:
                        vaux-cha1 = entry(1,tabaux.valor_campo,";").
                        delete tabaux.
                end.
                
        find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") +
                                                            ";" + string(duplic.duppc,"99")
                                                
                    exclusive no-wait   no-error.
        if not avail tabaux
        then if locked tabaux
             then next.

                                  
        if not avail tabaux
        then do:
            create tabaux.
            assign
                tabaux.tabela = "META-VENDA-31"
                tabaux.nome_campo = string(duplic.fatnum,"999") +
                              ";" + string(duplic.duppc,"99")
                tabaux.tipo_campo = "INT"                        
                                        .
        end. 
        tabaux.valor_campo = vaux-cha1 + ";" +
                             string(metafil.segmetmov).
        vaux-cha2 = "".
        
        find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") +
                                ";" + string(duplic.duppc,"99")
                    exclusive no-wait   no-error.
                if avail btabaux
                then do:
                        vaux-cha2 = entry(1,btabaux.valor_campo,";").
                        delete btabaux.
                end.
                
        find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") +
                                ";" + string(duplic.duppc,"99")
                    exclusive no-wait no-error.
        if not avail btabaux
        then if locked btabaux
             then next.
             
        if not avail btabaux
        then do:
            create btabaux.
            assign
                btabaux.tabela = "META-VENDA-41"
                btabaux.nome_campo = string(duplic.fatnum,"999") +
                                        ";" + string(duplic.duppc,"99")
                btabaux.tipo_campo = "INT" .
        end.        
                
        btabaux.valor_campo = vaux-cha2 + ";" +
                              string(metafil.segmetmod).
        duplic.dupven = today.
 
        /* GARANTIA */
        find tabmeta where tabmeta.codtm  = 5 and
                   tabmeta.anoref = int(metafil.ano) and
                   tabmeta.mesref = int(metafil.mes) and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = int(metafil.etb) and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-wait no-error.
        if not avail tabmeta
        then do:
            if locked tabmeta
            then next.
            
            create tabmeta.
            assign
                tabmeta.codtm  = 5
                tabmeta.anoref = int(metafil.ano)
                tabmeta.mesref = int(metafil.mes)
                tabmeta.diaref = 0
                tabmeta.etbcod = int(metafil.etb)
                tabmeta.funcod = 0
                tabmeta.clacod = 0
            .
        end.
        assign
            tabmeta.val_meta = dec(metafil.garmet).
        /* GARANTIA*/          
        
        /* RFQ */
        find tabmeta where tabmeta.codtm  = 6 and
                   tabmeta.anoref = int(metafil.ano) and
                   tabmeta.mesref = int(metafil.mes) and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = int(metafil.etb) and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-wait no-error.
        if not avail tabmeta
        then do:
            if locked tabmeta
            then next.
            
            create tabmeta.
            assign
                tabmeta.codtm  = 6
                tabmeta.anoref = int(metafil.ano)
                tabmeta.mesref = int(metafil.mes)
                tabmeta.diaref = 0
                tabmeta.etbcod = int(metafil.etb)
                tabmeta.funcod = 0
                tabmeta.clacod = 0
            .
        end.
        assign
            tabmeta.val_meta = dec(metafil.rfqmet).
            
        /* GARANTIA*/          
 
        
        /*bsxml("etbcod",string(metafil.filial)).
        bsxml("ano",   string(metafil.mes)).
        bsxml("mes",   string(metafil.ano)).
        bsxml("dia",   string(metafil.dia)).
        bsxml("segmetamoveis",  string(metafil.segmetamoveis)).
        bsxml("segmetamoda",    string(metafil.segmetamoda)).
        bsxml("garmetamoveis",  string(metafil.garmetamoveis)).
        bsxml("rfqmetamoveis",  string(metafil.rfqmetamoveis)).
        bsxml("alterado","OK").


     BSXml("FECHAREGISTRO","rows").
          */

end.

        bsxml("alterado","OK - " + string(time,"HH:MM:SS") ).
    
     bsxml("fechatabela","return").

    BSXml("FECHAXML","").

