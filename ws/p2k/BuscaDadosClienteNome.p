
def var vstatus as char.   
def var vmensagem_erro as char.
def var vpesquisa as char.   
def var vi as int.
def var vcpf as char.

def shared temp-table buscadadosclientenome
    field nome_cliente as char
    field codigo_filial as char
    field codigo_operador as char
    field numero_pdv    as char.

def temp-table tt-clien no-undo
    field clicod like clien.clicod.

find first buscadadosclientenome no-lock no-error.
if avail buscadadosclientenome
then assign
        vstatus = "S".
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".

{bsxml.i}

/**
vpesquisa = "*" + replace(trim(buscadadosclientenome.nome_cliente)," ","*") +
 "*".
find first clien where clien.clinom matches vpesquisa no-lock no-error.
**/

vi = 0.
vpesquisa = buscadadosclientenome.nome_cliente.

for each clien where clien.clinom contains /*matches*/ vpesquisa
                   no-lock /*use-index clien2*/.
    if clien.clicod = ?
    then next.

    vcpf = trata-numero(clien.ciccgc).
    if vcpf = ""
    then next.

    vi = vi + 1.
    if vi > 400
    then leave.
    create tt-clien.
    tt-clien.clicod = clien.clicod.
end.

find first tt-clien no-lock no-error.
if not avail tt-clien
then assign
        vmensagem_erro = "Cliente nao localizado!"
        vstatus = "N".

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",buscadadosclientenome.codigo_filial).
bsxml("numero_pdv",buscadadosclientenome.numero_pdv).

for each tt-clien no-lock.
    find clien where clien.clicod = tt-clien.clicod no-lock.
    BSXml("ABREREGISTRO","clientes").
    bsxml("codigo_cliente",string(clien.clicod)).
    bsxml("cpf",Texto(clien.ciccgc)).
    bsxml("nome",Texto(clien.clinom)).
    bsxml("data_nascimento", EnviaData(clien.dtnasc)).
    bsxml("pai",Texto(clien.pai)).
    bsxml("mae",Texto(clien.mae)).
    BSXml("fechaREGISTRO","clientes").
end.
   
bsxml("fechatabela","return").
BSXml("FECHAXML","").

