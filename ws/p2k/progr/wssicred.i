                      
function clientewebservices return char 
    (input filial      as integer,
     input nota        as integer,
     input clientephp  as char,
     input webservices as char,
     input metodo      as char,
     input variavel    as char,
     input varresposta as char,
     input entrada     as char,
     input c-char1     as char,
     input c-char2     as char,
     input c-char3     as char,
     input c-char4     as char). /* Caminho do XML a ser enviado.*/
     
    def var varquivo as char.
    def var ctime as char.
    ctime = string(time).

    varquivo = "/u/bsweb/log/"
                    + metodo + "." + string(nota) + "." + ctime + ".xml".

    output to /u/bsweb/log/teste-ws.log.
    put "wget \"" + clientephp +
                        "?ws=" + webservices + 
                        "&metodo=" + metodo + 
                        "&variavel=" + variavel +
                        "&varresposta=" + varresposta +
                        "&entrada=" + entrada + 
                        "&filial=" + string(filial,"999") +
                        "&param1=" + c-char1 +
                        "&param2=" + c-char2 +
                        "&param3=" + c-char3 +
                        "&param4=" + c-char4 +
                        "\"" +
                        " -O " + varquivo + " -q "
                        format "x(1200)".

    output close.

    unix silent value("wget \"" + clientephp +
                        "?ws=" + webservices + 
                        "&metodo=" + metodo + 
                        "&variavel=" + variavel +
                        "&varresposta=" + varresposta +
                        "&entrada=" + entrada + 
                        "&filial=" + string(filial,"999") +
                        "&param1=" + c-char1 +
                        "&param2=" + c-char2 +
                        "&param3=" + c-char3 +
                        "&param4=" + c-char4 +
                        "\"" +
                        " -O " + varquivo + " -q ").

    return varquivo.
    
end function.


