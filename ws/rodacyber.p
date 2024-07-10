{bsxml.i} 
def input parameter vacao as char.
def input parameter varquivoentrada as char.
def var xmltabela as char.

def new global shared var setbcod       as int.
def new global shared var vtime as int.

def new shared var vtiposervidor as char.
def new shared temp-table tt-estab
        field etbcod as int
        field etbnom as char.

/* cyber nao tera
def new shared temp-table controle
   field loja as int
   field acao as char
   field tabela as char.
*/

   
def new shared temp-table consultasaldocpf
   field cpfcnpj as char.

    
def new shared temp-table consultasaldocontrato
   field contrato as char.
 
 
/* cyber nao tera controle

run controle (varquivoentrada).

find first controle no-error.
if not avail controle
then do:    
        BSXml("ABRE","").
        BSXml("resultado","3").
        BSXml("alerta","CONTROLE INEXISTE").
        BSXml("fecha","").
        return.
end.

setbcod = controle.loja.
*/


/* cyber não teste loja
find estab where estab.etbcod = setbcod no-lock no-error.
if not avail estab
then do:    
        BSXml("ABRE","").
        BSXml("resultado","3").
        BSXml("alerta","LOJA INVALIDA " + string(setbcod)).
        BSXml("fecha","").
        return.
end.
**/

output to /u/bsweb/log/wscyber.log append.
put unformatted skip
    "1rodawscyber.p "              skip
    " acao " vacao " " skip
/*    " tabela " controle.tabela " " skip*/
    " vacao=" vacao skip
    " varquivoentrada=" varquivoentrada
    skip "FIM mostrar parametros rodawscyber.p"
    skip.
output close.

/*if vacao   = "" /*or
   controle.tabela = ""*/
then*/
 do:
    output to /u/bsweb/log/wscyber.log append.

        put unformatted skip
            "2  rodawscyber vai rodar procedure   " vacao skip.
    output close.
    run value(vacao) (varquivoentrada).
end.
/*
else do:
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
        "3  rodawscyber vai rodar procedure "  controle.tabela skip.
    output close.

    run value(controle.tabela) 
             (varquivoentrada). /* chama procedure local,
                                          que importa temps */
end.
*/

/*if vacao = "" /*or
   controle.tabela = ""*/
then*/
 do:
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
        "4  rodawscyber vai rodar ws/wscyber/" vacao ".p " skip.
    output close.
 
    run value("ws/wscyber/" + vacao + ".p"). /* chama programa relativo 
                                                a funcao no webservice */
end.
/*
else do:
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
        "5  rodawscyber vai rodar ws/wscyber/"  controle.tabela ".p" skip.
    output close.

    run value("ws/wscyber/" + controle.tabela + ".p").                                                 
end.
*/

def var vtabela as char.
def var vloop   as int.
def var vi      as int.
def var vlinha  as char.


/* 
procedure controle.
def input parameter varquivoentrada as char.
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
        "6  rodabscrud procedure controle " skip.
    output close.

def var v-return-mode        as log  no-undo.

    v-return-mode = 
        TEMP-TABLE controle:READ-XML("FILE", 
                                  varquivoentrada , 
                                  "EMPTY", 
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ , 
                                  ? /*v-field-type-map*/ , 
                                  ? /*v-verify-schema-mode*/ ).

end procedure.
*/

 


procedure consultaacordo.
    def input parameter varquivoentrada as char.
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
            "7  rodawscyber procedure consultaacordo " 
            varquivoentrada skip.
    output close.


def var v-return-mode        as log  no-undo.

    /***
    v-return-mode = 
        TEMP-TABLE consultasaldocpf:READ-XML("FILE", 
                                  varquivoentrada , 
                                  "EMPTY", 
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ , 
                                  ? /*v-field-type-map*/ , 
                                  ? /*v-verify-schema-mode*/ ).

    
    output to /u/bsweb/log/wscyber.log append.
        for each consultasaldocpf.
            put unformatted skip
                "cpfcnpj " consultasaldocpf.cpfcnpj skip.
        end.    
    output close.
    ****/
    

end procedure.




procedure consultasaldocpf.
    def input parameter varquivoentrada as char.
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
            "7  rodawscyber procedure consultasaldocpf " 
            varquivoentrada skip.
    output close.


def var v-return-mode        as log  no-undo.

    v-return-mode = 
        TEMP-TABLE consultasaldocpf:READ-XML("FILE", 
                                  varquivoentrada , 
                                  "EMPTY", 
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ , 
                                  ? /*v-field-type-map*/ , 
                                  ? /*v-verify-schema-mode*/ ).

    
    output to /u/bsweb/log/wscyber.log append.
        for each consultasaldocpf.
            put unformatted skip
                "cpfcnpj " consultasaldocpf.cpfcnpj skip.
        end.    
    output close.


end procedure.




procedure consultasaldocontrato.
    def input parameter varquivoentrada as char.
    output to /u/bsweb/log/wscyber.log append.
        put unformatted skip
            "7  rodawscyber procedure consultasaldocontrato " 
            varquivoentrada skip.
    output close.


def var v-return-mode        as log  no-undo.

    v-return-mode = 
        TEMP-TABLE consultasaldocontrato:READ-XML("FILE", 
                                  varquivoentrada , 
                                  "EMPTY", 
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ , 
                                  ? /*v-field-type-map*/ , 
                                  ? /*v-verify-schema-mode*/ ).

    
    output to /u/bsweb/log/wscyber.log append.
        for each consultasaldocontrato.
            put unformatted skip
                "cntrato " consultasaldocontrato.contrato skip.
        end.    
    output close.


end procedure.







