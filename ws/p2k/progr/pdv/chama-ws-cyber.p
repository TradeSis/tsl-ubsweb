    def input  param  vcpjcnpj      as char.
    def output param  vretorno      as char.
    def output param  vcodigoretorno as int.

def shared temp-table tt-contratos
    field adacct as char format "x(20)"
    field titnum as char format "x(15)"
    field adacctg as char
    field adahid as char
    field etbcod as int format "999" .


def shared  temp-table tt-acordo
    field apahid as char
        field titvlcob as dec
        field titpar  as int
        field titdtven as date
    field apflag as char
        field titjuro as dec.
 
    def var clientephp as char.
    def var varquivo   as char.

    for each tt-acordo. delete tt-acordo. end.
    for each tt-contratos. delete tt-contratos. end.

    clientephp = "http://sv-ca-ac/bsweb/ws/wscyber/cliente/clientecyber.php".

    varquivo = "wsretorno.cyber." + string(time) + ".xml".          
    unix silent  value("wget \"" + clientephp +
                        "?param1=" + vcpjcnpj +
                        "\"" +
                        " -O " + varquivo + " -q ").
                            


        
def var vtabela as char.
def var vtabela-recid as recid. 
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",varquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).
def temp-table tt-retorno
    field ahacct as char
        field cgccpf as char format "x(14)"
    field ahacctg as char
    field ahagagncy as char
    field ahbank as char
    field ahbreak as char
    field ahcndpaym as char
    field ahcndpayn as char
    field ahcollid as char
    field ahcsinitnt as char
    field ahcttype as char
    field ahdt as char
    field ahfreq as char
    field ahid as char
    field ahlvl as char
    field ahnumup as char
    field ahprd as char
    field ahpytype as char
    field ahrate as char
    field ahrate2 as char    
    field ahregdt as char
    field ahtotpmt as char
    field ahtype as char.
 
def temp-table tt-xml
    field seq as int
    field tabela as char
    field campo  as char format "x(40)"
    field valor as char format "x(20)".


def var vseq as int.
    
run obtemnode (input hroot).
unix silent value("rm -f " + varquivo).


procedure obtemnode.
    
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
            
    create x-noderef hc.
                   
    do loop = 1 to vh:num-children.
    
        vh:get-child(hc,loop).
    
        if hc:subtype = "Element"
        then do:
            if vh:name = "acordoAgrHdrLista"
            then do:
                vtabela = "tt-retorno".
            end.
            if vh:name = "contratos"
            then do:
                vtabela = "tt-contratos".
            end.
            if vh:name = "paymentSchedules"
            then do:
                vtabela = "tt-acordo".
            end.
        end.
    
        if hc:subtype = "text"
        then do:
            vseq = vseq + 1.
            create tt-xml.
            tt-xml.seq = vseq.
            tt-xml.tabela = vtabela.
            tt-xml.campo = vh:name.
            tt-xml.valor = hc:node-value.
        end.
        run obtemnode (input hc:handle).
    end.
end procedure.

/* passa da temporaria tt-xml para temp shared */
vtabela = "".
for each tt-xml by tt-xml.seq.
    if tt-xml.tabela <> vtabela
    then do:
        if tt-xml.tabela = "tt-contratos"
        then do: 
            create tt-contratos. 
            vtabela-recid = recid(tt-contratos).
        end.
        if tt-xml.tabela = "tt-retorno"
        then do: 
            create tt-retorno. 
            vtabela-recid = recid(tt-retorno).        end.
        if tt-xml.tabela = "tt-acordo"
        then do: 
            create tt-acordo. 
            vtabela-recid = recid(tt-acordo).        
        end.
        if tt-xml.tabela = ""
        then do:
        
        end.
        vtabela = tt-xml.tabela.
     end.
     if tt-xml.tabela = ""
     then do:
         if tt-xml.campo = "wsMensagemRetorno"
         then vretorno = tt-xml.valor.
         if tt-xml.campo = "wsCodigoRetorno"
         then do:
            vcodigoretorno = int(tt-xml.valor).
         end.
        
     end.

        if tt-xml.tabela = "tt-contratos"
        then do:  
            find first tt-contratos where recid(tt-contratos) = vtabela-recid.
            if tt-xml.campo = "adacct"  
            then assign   
                    tt-contratos.adacct = tt-xml.valor   
                    tt-contratos.titnum = string(int(substring(tt-xml.valor,4))) 
                    tt-contratos.etbcod = int(substr(tt-xml.valor,1,3)).
        end.
        if tt-xml.tabela = "tt-retorno"
        then do:  
            find first tt-retorno  where 
                    recid(tt-retorno) = vtabela-recid.
            if tt-xml.campo = "ahacct" 
            then assign  
                    tt-retorno.ahacct = tt-xml.valor                                         tt-retorno.cgccpf = tt-xml.valor.
            if tt-xml.campo = "ahcollid" 
            then assign tt-retorno.ahcollid = tt-xml.valor.
            if tt-xml.campo = "ahdt" 
            then assign tt-retorno.ahdt   = tt-xml.valor.
            if tt-xml.campo = "ahfreq" 
            then assign tt-retorno.ahfreq = tt-xml.valor.
            if tt-xml.campo = "ahid" 
            then assign tt-retorno.ahid      = tt-xml.valor.
            if tt-xml.campo = "ahprd" 
            then assign tt-retorno.ahprd   = tt-xml.valor.
            if tt-xml.campo = "ahpytype" 
            then assign tt-retorno.ahpytype = tt-xml.valor.
            if tt-xml.campo = "ahrate" 
            then assign tt-retorno.ahrate = tt-xml.valor.
            if tt-xml.campo = "ahregdt" 
            then assign tt-retorno.ahregdt = tt-xml.valor.
            if tt-xml.campo = "ahtotpmt" 
            then assign tt-retorno.ahtotpmt = tt-xml.valor.
            if tt-xml.campo = "ahtype" 
            then assign tt-retorno.ahtype = tt-xml.valor.
        end.
        if tt-xml.tabela = "tt-acordo"
        then do:  
            find first tt-acordo  where 
                    recid(tt-acordo) = vtabela-recid.
            if tt-xml.campo = "apahid" 
            then assign tt-acordo.apahid = tt-xml.valor.
            if tt-xml.campo = "apamt" 
            then assign  
                tt-acordo.titvlcob = dec(tt-xml.valor).
            if tt-xml.campo = "apdetid" 
            then assign tt-acordo.titpar  = int(tt-xml.valor).
            if tt-xml.campo = "apduedt" 
            then assign  
                tt-acordo.titdtven = 
                            date(int(substr(tt-xml.valor,1,2)) , 
                                 int(substr(tt-xml.valor,3,2)) ,
                                 int(substr(tt-xml.valor,5,4)) 
                                 ).
            if tt-xml.campo = "apflag" 
            then assign tt-acordo.apflag = tt-xml.valor.
            if tt-xml.campo = "apintamt" 
            then assign  
                    tt-acordo.titjuro = dec(tt-xml.valor).
        end.

    delete tt-xml.

end.


