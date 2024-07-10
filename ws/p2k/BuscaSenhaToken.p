{/u/bsweb/progr/acha.i}

{bsxml.i}

/* buscarplanopagamento */
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.

def shared temp-table BuscaSenhaToken
    field usuario as char
    field senha as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

def var par-user as char.
def var p-ok as log.

find first buscasenhatoken no-lock no-error.

vstatus = if avail buscasenhatoken
          then "S"
          else "E".
vmensagem_erro = if avail buscasenhatoken
                 then ""
                 else "Parametros de Entrada nao recebidos.".     

/***
def var vi as int.
def var vlista-user as char extent 19 FORMAT "X(15)"
          init["Roni",
               "Manoel Enildo",
               "Ivane",
               "Sandro",
               "Emerson",
               "Clair",
               "Sandra",
               "P2k",
               "crm",
               "Debora",
               "Rita",
               "Joao",
            "Debora_swat",
            "Rita_cre",
            "Priscila_cre",
            "Fernanda_cre",
            "credito1",
            "credito2",
            "credito3"
            ].

do vi = 1 to 19.
    if buscasenhatoken.usuario = vlista-user[vi]
    then leave.
end.

    par-user = "".

    case vi:
        when 1 then assign par-user = "roni-sup|371500".
        when 2 then assign par-user = "manoelenildo|124200".
        when 3 then assign par-user = "ivanesup|133500".
        when 4 then assign par-user = "sandrosup|356100".
        when 5 then assign par-user = "emerson|825700".
        when 6 then assign par-user = "clair|123100".
        when 7 then assign par-user = "sandrasup|391400".
        when 8 then assign par-user = "p2k|053000".
        when 9 then assign par-user = "crm|959700".
        when 10 then assign par-user = "Debora_swat|352500".
        when 11 then assign par-user = "Rita_cre|317600".
        when 12 then assign par-user = "joao|202500".
        when 13 then assign par-user = "Debora_swat|352500".
        when 14 then assign par-user = "Rita_cre|317600".
        when 15 then assign par-user = "Priscila_cre|578124".
        when 16 then assign par-user = "Fernanda_cre|236438".
        when 17 then assign par-user = "credito1|298479".
        when 18 then assign par-user = "credito2|90823".
        when 19 then assign par-user = "credito3|901887".
    end case.
***/

find first tbgenerica where tbgenerica.TGtabela = "Token"
                        and tbgenerica.tgcodigo = buscasenhatoken.usuario
                        and tbgenerica.tgsituacao
                      no-lock no-error.
if avail tbgenerica
then par-user = tbgenerica.tgdescricao.

if par-user = ""
then do:
    par-user = buscasenhatoken.usuario.
    p-ok = no.
    vmensagem_erro = "Usuario " + par-user + " Invalido".
end.
else do:
    run ./progr/p-valida-senha-token.p 
                (input par-user,
                 input trim(buscasenhatoken.senha), 
                 output p-ok).
end.
     
BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",buscasenhatoken.codigo_filial).
bsxml("numero_pdv",buscasenhatoken.numero_pdv).
bsxml("usuario",buscasenhatoken.usuario).
    
if p-ok
then bsxml("resposta","SIM").
else bsxml("resposta","NAO").
   
bsxml("fechatabela","return").
BSXml("FECHAXML","").

