/* 
15042021 helio ID 68725
*/

/* 08/2016: Projeto Credito Pessoal */

def var vstatus as char.   
def var vmensagem_erro as char.

def var setbcod as int.
def var vclicod like clien.clicod.
def var vclinom as char.
def var vcpf    as char.
def var vdtnasc as date.
def var vok     as log.
def var vlimite as dec.

/*** ***/

def NEW SHARED temp-table tt-profin
    field codigo     as int
    field nome       as char
    field avencer    as dec
    field disponivel as dec
    field saldo      as dec
    field modcod     as char
    field tfc        as dec
    field token      as log
    field deposito   as char
    field codsicred  as int.

def shared temp-table ConsultaProdutosFinanceiros
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field tipo_documento    as char
    field numero_documento  as char.

{bsxml.i}

find first ConsultaProdutosFinanceiros no-lock no-error.

if avail ConsultaProdutosFinanceiros
then do.
    assign
        vstatus = "S"
        setbcod = int(ConsultaProdutosFinanceiros.codigo_filial).

    run ./progr/numero_documento.p (ConsultaProdutosFinanceiros.tipo_documento,
                                ConsultaProdutosFinanceiros.numero_documento,
                                output vclicod).
    if vclicod = 0
    then run erro("Cliente nao encontrado").
    else do.
        find clien where clien.clicod = vclicod no-lock.
        assign
            vclinom = Texto(clien.clinom)
            vcpf    = Texto(clien.ciccgc)
            vdtnasc = clien.dtnasc.
    end.
end.
else run erro ("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.
    run /admcom/progr/neuro/creditopessoal_v2101.p ("Consulta", setbcod, clien.clicod, 0,
                                  output vlimite,
                                  output vstatus, output vmensagem_erro).
end.

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",ConsultaProdutosFinanceiros.codigo_filial).
bsxml("numero_pdv",ConsultaProdutosFinanceiros.numero_pdv).
bsxml("codigo_cliente", string(vclicod)).
bsxml("cpf",  vcpf).
bsxml("nome", Texto(vclinom)).
bsxml("data_nascimento", EnviaData(vdtnasc)).
bsxml("valor_limite",string(vlimite,"->>>>>>>>>9.99")).

find first tt-profin no-lock no-error.
if avail tt-profin
then do.
    BSXml("ABREREGISTRO","listaprodutos").
    for each tt-profin no-lock.
        BSXml("ABREREGISTRO", "produtos").
        bsxml("codigo_produto",string(tt-profin.codigo)).
        bsxml("nome_produto", tt-profin.nome).
        bsxml("saldo_produto",string(tt-profin.saldo,">>>>>>>>>9.99")).
        BSXml("FECHAREGISTRO","produtos").
    end.
    BSXml("FECHAREGISTRO","listaprodutos").
end.

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.
