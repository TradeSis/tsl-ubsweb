/* Include configuracao XML */
{ws/p2k/progr/wssicred.i}

/*{admcab.i}*/

def input parameter par-filial   as integer.     
def input parameter par-nota     as integer.
def input parameter par-servico  as char.
def input parameter par-metodo   as char.
def input parameter par-xml      as char.
def input parameter c-char1    as char.
def input parameter c-char2    as char.
def input parameter c-char3    as char.
def input parameter c-char4    as char.
def output parameter par-ret      as char.

def var var-servico-aux     as char.
def var var-wsclient        as char.
def var var-metodo          as char.
def var var-metodo-resp     as char.

assign var-metodo      = par-metodo
       var-metodo-resp = par-metodo + "Result". 

def var vip as char.
vip = "".

def var p-valor as char.
p-valor = "".

case (par-servico):
    
    when "SimulacaoSicredi"
    then do:   
       
        assign
        vip = "sv-ca-ws.lebes.com.br"
        var-servico-aux = "http://" + vip + "/CustomWsServer/Service.asmx?WSDL"
        /*        
        var-wsclient    = "http://filial"
                           + string(par-filial,"999")
                           + "/ws-sicred/clientewssicred.php".
        */
        var-wsclient = "http://localhost/bsweb/ws/p2k/progr/clientewssicred.php".
        
        /*if setbcod = 189
        then var-wsclient   = "http://localhost"
                           + "/ws-sicred/clientewssicred.php".
          */

        
    end.
       
end case.

 
/* CHAMA WEBSERVICES E RECEBE O ARQUIVO DE RETORNO */

unix silent value("chmod 777 " + par-xml).

par-ret = 
  clientewebservices(par-filial,
                     par-nota,
                     var-wsclient,
                     var-servico-aux,
                     var-metodo,
                     "iXml", 
                     var-metodo-resp,
                     par-xml,
                     c-char1,
                     c-char2,
                     c-char3,
                     c-char4).
                         

return par-ret.
