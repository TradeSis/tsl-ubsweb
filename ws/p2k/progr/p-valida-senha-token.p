def input parameter par-user as char.
def input parameter par-senha as char.
def output parameter par-ok    as logical.

def var vcha-arquivo-aux as char.
def var clientephp        as char.
def var webservices       as char.
def var metodo            as char.
def var variavel          as char.
def var varresposta       as char.
def var entrada           as char.
def var varquivo          as char.                         
def var vcha-retorno      as char.                   
def var vcont as integer.

assign clientephp  = "http://eteste.lebes.com.br/ws-token/clientews.php" .
assign clientephp  = "http://eteste.lebes.com.br/bsweb/ws/token/clientews.php" .

webservices =
"http://sv-mat-wstoken.lebes.com.br/CustomWsServer/Service.asmx?WSDL".
/*    webservices = "http://192.168.0.53/CustomWsServer/Service.asmx?WSDL" . */
metodo      = "TokenAuthentication".
variavel    = "iUserKey".
varresposta = "TokenAuthenticationResult".
entrada     = par-user + string(par-senha,"999999").              
varquivo    = "/ws/works/token_" + string(mtime).                 

unix silent value("wget \"" + clientephp +
                 "?ws=" + webservices +
                 "&metodo=" + metodo +
                 "&variavel=" + variavel +
                 "&varresposta=" + varresposta +
                 "&entrada=" + entrada + "\"" +
                 " -O " + varquivo + " -q --timeout=30").

unix silent value("chmod 777 " + varquivo).

assign vcha-arquivo-aux = "/usr/dlc/bin/quoter " + varquivo + " > "
                                   + varquivo + ".2".
                                  
unix silent value(vcha-arquivo-aux).

input from value(varquivo + ".2").

assign vcont = 0.

bl_rep:
repeat:
    assign vcont = vcont + 1.

    import vcha-retorno.
    
    if trim(vcha-retorno) = "yes"
        or trim(vcha-retorno) = "no"
    then leave bl_rep.
end.
input close.

if trim(vcha-retorno) = "yes"
then par-ok = yes.
else par-ok = no.

unix silent rm -f value(varquivo).
unix silent rm -f value(varquivo + ".2").

