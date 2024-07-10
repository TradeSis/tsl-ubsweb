/*
Agosto/2018 - Chamar WS Cyber via SOAP
#1  Felipe gravar ID do contrato
#2 07.06.19 - TP 31325157
*/
def input  param vcpfcnpj       as char.
def output param vretorno       as char.
def output param vcodigoretorno as int.
        
def var vtabela       as char.
def var vtabela-recid as recid.
def var Hdoc          as handle.
def var Hroot         as handle.

def var lReturn as log.
/*** def var vlog    as log /*init yes*/. ***/
def var varqlog as char.
def var vversao as char.
def var vseq    as int.

def var hWebService as handle no-undo.
def var hWSAcordo   as handle no-undo.
def var vHost       as char   no-undo.

def var consultaAcordo         as longchar no-undo.
def var consultaAcordoResponse as longchar no-undo.

def shared temp-table tt-novacao
    field ahid    as char /* #2 */
    field ahdt    as date
    field vltotal as dec.

def shared temp-table tt-contratos
    field adacct  as char format "x(20)"
    field titnum  as char format "x(15)"
    field adacctg as char
    field adahid  as char
    field etbcod  as int  format "999" .

def shared temp-table tt-acordo
    field apahid   as char 
    field titvlcob as dec 
    field titpar   as int 
    field titdtven as date
    field apflag   as char 
    field titjuro  as dec.

def temp-table tt-retorno no-undo
    field ahacct     as char
    field cgccpf     as char format "x(14)"
    field ahacctg    as char
    field ahagagncy  as char
    field ahbank     as char
    field ahbreak    as char
    field ahcndpaym  as char
    field ahcndpayn  as char
    field ahcollid   as char
    field ahcsinitnt as char
    field ahcttype   as char 
    field ahdt       as char
    field ahfreq     as char
    field ahid       as char
    field ahlvl      as char
    field ahnumup    as char
    field ahprd      as char
    field ahpytype   as char
    field ahrate     as char
    field ahrate2    as char    
    field ahregdt    as char
    field ahtotpmt   as char
    field ahtype     as char.
 
def temp-table tt-xml no-undo
    field seq    as int
    field tabela as char
    field campo  as char format "x(40)"
    field valor  as char format "x(20)".

for each tt-novacao.   delete tt-novacao.   end.
for each tt-contratos. delete tt-contratos. end.
for each tt-acordo.    delete tt-acordo.    end.
for each tt-retorno.   delete tt-retorno.   end.
for each tt-xml.       delete tt-xml.       end.

vversao      = os-getenv("versao-wsp2k").
if vversao = ?
then vversao = "".
else vversao = vversao + "_".

run le_tabini.p (0, 0, "Cyber_Host", OUTPUT vhost).

varqlog = "/ws/log/p2k" + vversao + string(today, "99999999") + ".log".

/**********************MAIN***********************************/
create server hWebService.
lReturn = hWebService:CONNECT("-WSDL "
                              + vHost /*'cyber-prod.wsdl'*/
                              + " -nohostverify") no-error.
if not lReturn  
then do:
    run gera-log("Não foi possível se conectar ao servidor").
    return.
end.

run WSAcordo 
set hWSAcordo 
on hWebService no-error.

if not valid-handle(hWSAcordo) 
then do:
    run gera-log("Não foi possível se conectar a PortType hWSAcordo").
    return.
end.

consultaAcordo = 
    '<ns0:consultaAcordo xmlns:ns0="http://service.console.ppware.com.br/">
        <cpfCnpj>' + vcpfcnpj + '</cpfCnpj>
    </ns0:consultaAcordo>'.

function consultaAcordo returns longchar
  (input consultaAcordo as longchar).
   /*in hWSAcordo*/
end function.

/* Function invocation of consultaAcordo operation. */
assign consultaAcordoResponse = consultaAcordo(consultaAcordo) no-error.

if error-status:error        or
   error-status:num-messages > 0
then do:
   run gera-log("Erro na estrutura XML de requisicao").
   return.
end.
      
/* Procedure invocation of consultaAcordo operation. */
run consultaAcordo in hWSAcordo(input consultaAcordo, 
                                output consultaAcordoResponse) no-error.
if error-status:error        or
   error-status:num-messages > 0
then do:
   run gera-log("Erro ao invocar a operation 'consultaAcordo'").
   return.
end.

/*TRATA RETORNO*/
create x-document HDoc           no-error.
Hdoc:load("LONGCHAR", consultaAcordoResponse, false) no-error.
          
if error-status:error          or
   error-status:num-messages > 0 
then do:
   run gera-log("Erro na estrutura XML de retorno").
   return.
end.

create x-noderef hroot           no-error.
hDoc:get-document-element(hroot) no-error.

/*** if vlog
then output to ./ricardo.log. ***/

run obtemnode ("", input hroot) no-error.

/*** if vlog
then output close. ***/

/* passa da temporaria tt-xml para temp shared */
vtabela = "".
for each tt-xml by tt-xml.seq.

    /***if vlog
    then disp
        tt-xml.seq format ">>9"
        tt-xml.tabela
        tt-xml.campo format "x(20)"
        tt-xml.valor format "x(20)"
        skip.***/

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
            vtabela-recid = recid(tt-retorno).
            create tt-novacao.
        end.
        if tt-xml.tabela = "tt-acordo" and
           tt-xml.campo = "apahid" /* #2 */
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
         then vcodigoretorno = int(tt-xml.valor).
     end.

     if tt-xml.tabela = "tt-contratos"
     then do:  
        find first tt-contratos where recid(tt-contratos) = vtabela-recid. 
        if tt-xml.campo = "adacct"  
        then assign   
                 tt-contratos.adacct = tt-xml.valor   
                 tt-contratos.titnum = string(int(substring(tt-xml.valor,4))) 
                 tt-contratos.etbcod = int(substr(tt-xml.valor,1,3)).

        if tt-xml.campo = "adahid"
        then 
            tt-contratos.adahid = tt-xml.valor. /*#1*/
     end.          

     if tt-xml.tabela = "tt-retorno"
     then do:  
        find first tt-retorno where recid(tt-retorno) = vtabela-recid.
        find first tt-novacao /*#2*/ where tt-novacao.ahid = tt-retorno.ahid.
        
        if tt-xml.campo = "ahacct" 
        then assign  
             tt-retorno.ahacct = tt-xml.valor
             tt-retorno.cgccpf = tt-xml.valor.
             
        if tt-xml.campo = "ahcollid" 
        then assign tt-retorno.ahcollid = tt-xml.valor.
            
        if tt-xml.campo = "ahdt" 
        then assign tt-retorno.ahdt   = tt-xml.valor
                    tt-novacao.ahdt   = 
                    date(int(substr(tt-xml.valor, 1, 2)),
                         int(substr(tt-xml.valor, 3, 2)),
                         int(substr(tt-xml.valor, 5)) ).
        
        if tt-xml.campo = "ahfreq" 
        then assign tt-retorno.ahfreq   = tt-xml.valor.
            
        if tt-xml.campo = "ahid" 
        then assign tt-retorno.ahid     = tt-xml.valor
                    tt-novacao.ahid     = tt-xml.valor /* #2 */.
       
        if tt-xml.campo = "ahprd" 
        then assign tt-retorno.ahprd    = tt-xml.valor.

        if tt-xml.campo = "ahpytype" 
        then assign tt-retorno.ahpytype = tt-xml.valor.
       
        if tt-xml.campo = "ahrate" 
        then assign tt-retorno.ahrate   = tt-xml.valor.

        if tt-xml.campo = "ahregdt" 
        then assign tt-retorno.ahregdt  = tt-xml.valor.
        
        if tt-xml.campo = "ahtotpmt" 
        then assign tt-retorno.ahtotpmt = tt-xml.valor.
            
        if tt-xml.campo = "ahtype" 
        then assign tt-retorno.ahtype   = tt-xml.valor.
    end.
        
    if tt-xml.tabela = "tt-acordo"
    then do:  
        find first tt-acordo where recid(tt-acordo) = vtabela-recid no-error.
        if avail tt-acordo
        then do:
            if tt-xml.campo = "apahid" 
            then assign tt-acordo.apahid   = tt-xml.valor.
        
            if tt-xml.campo = "apamt" 
            then assign tt-acordo.titvlcob = dec(tt-xml.valor).
            
            if tt-xml.campo = "apdetid" 
            then assign tt-acordo.titpar   = int(tt-xml.valor).
        
            if tt-xml.campo = "apduedt" 
            then assign tt-acordo.titdtven = 
                            date(int(substr(tt-xml.valor,1,2)) , 
                                 int(substr(tt-xml.valor,3,2)) ,
                                 int(substr(tt-xml.valor,5,4)) ).
        
            if tt-xml.campo = "apflag" 
            then assign tt-acordo.apflag   = tt-xml.valor.
            
            if tt-xml.campo = "apintamt" 
            then assign tt-acordo.titjuro  = dec(tt-xml.valor).
        end.
    end.

    delete tt-xml.
end.

/******retira valores dos nodos******/
procedure obtemnode.

    def input parameter par-pai as char.
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
    def var vok as log.
            
    create x-noderef hc.

    /***if vlog
    then put unformatted
            "Inicio Pai=" par-pai " Name=" vh:name
            skip.***/

    do loop = 1 to vh:num-children.
    
        vh:get-child(hc,loop).

        /***if vlog
        then put unformatted
             "Vh=" vh:num-children
             " subtype=" vh:subtype
             " name=" vh:name

             " hc"
             " subtype=" hc:subtype 
             " name=" hc:name
             " node-value=" hc:node-value
             skip.***/

        if hc:subtype = "Element"
        then do:
            vok = no.
            if vh:name = "acordoAgrHdrLista"
            then assign
                    par-pai = "tt-retorno"
                    vok = yes.

            if vh:name = "contratos"
            then assign
                    par-pai = "tt-contratos"
                    vok = yes.
            
            if vh:name = "paymentSchedules"
            then assign
                    par-pai = "tt-acordo"
                    vok = yes.
        end.
    
        if hc:subtype = "text"
        then do:
            vseq = vseq + 1.
            create tt-xml.
            tt-xml.seq    = vseq.
            tt-xml.tabela = par-pai.
            tt-xml.campo  = vh:name.
            tt-xml.valor  = hc:node-value.
        end.

        if hc:num-children > 0
        then run obtemnode (par-pai, input hc:handle).
    end.

    /***if vlog
    then put unformatted
            "Fim " vh:name
            skip.***/
 
    /* #2 */
    if vh:name = "contratos" or
       vh:name = "paymentSchedules"
    then do.
        vseq = vseq + 1.
        create tt-xml.
        tt-xml.seq    = vseq.
        tt-xml.tabela = "/" + vh:name.
    end.
    
end procedure.


/*** Log para verificar tempo dos webservices ***/
procedure gera-log.
    def input parameter par-texto as char.

    output to value(varqlog) append.
    put unformatted skip string(time, "hh:mm:ss") " WS Cyber: " par-texto skip.
    output close.

end procedure.


/*DESCONECTA E DELETA VAR HANDLE*/
delete object hdoc.
delete object hroot.
delete object hWSAcordo.
hWebService:DISCONNECT().
delete object hWebService.

