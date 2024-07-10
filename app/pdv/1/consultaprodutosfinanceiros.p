/* 
15042021 helio ID 68725
*/

/* 08/2016: Projeto Credito Pessoal */

def input  parameter vlcentrada as longchar.
def var vlog as char.

vlog = "/ws/log/apipdv_buscaDadosContratoNf" + string(today,"99999999") + ".log".

{/admcom/progr/api/acentos.i}
{/u/bsweb/progr/bsxml.i}
def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.


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

def temp-table ttjson_profin no-undo serialize-name "produtos"
    field codigo_produto    as char
    field nome_produto      as char
    field saldo_produto     as char.
    

def temp-table consultaProdutosFinanceiros no-undo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field tipo_documento    as char
    field numero_documento  as char.

def temp-table ttjson no-undo serialize-name "dados"
FIELD pstatus as char serialize-name "status"
FIELD mensagem_erro as char 
FIELD codigo_filial as char 
FIELD numero_pdv as char 
field codigo_cliente as char
field cpf as char
field nome as char
field data_nascimento as char
field valor_limite as char.

def dataset dsReturn serialize-name "return" for ttjson, ttjson_profin. 

hentrada = temp-table consultaProdutosFinanceiros:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

hsaida = dataset dsReturn:handle.

find first ConsultaProdutosFinanceiros no-lock no-error.

if avail ConsultaProdutosFinanceiros
then do.
    assign
        vstatus = "S"
        setbcod = int(ConsultaProdutosFinanceiros.codigo_filial).

    run /admcom/progr/api/numero_documento.p (ConsultaProdutosFinanceiros.tipo_documento,
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

create ttjson.
ttjson.pstatus       = vstatus.
ttjson.mensagem_erro = vmensagem_erro.
ttjson.codigo_filial = string(ConsultaProdutosFinanceiros.codigo_filial).
ttjson.numero_pdv    = string(ConsultaProdutosFinanceiros.numero_pdv).
ttjson.codigo_cliente = string(vclicod).
ttjson.cpf =  vcpf.
ttjson.nome = Texto(vclinom).
ttjson.data_nascimento = EnviaData(vdtnasc).

ttjson.valor_limite      = trim(string(vlimite,"->>>>>>>>>>9.99")).


find first tt-profin no-lock no-error.
if avail tt-profin
then do.
    for each tt-profin no-lock.
        create ttjson_profin.
        ttjson_profin.codigo_produto = string(tt-profin.codigo).
        ttjson_profin.nome_produto   = tt-profin.nome.
        ttjson_profin.saldo_produto  = trim(string(tt-profin.saldo,">>>>>>>>>9.99")).
    end.
end.

procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.



lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
put unformatted string(vlcsaida).

/*lokJson = hsaida:WRITE-JSON("FILE", "saida.json", TRUE).
os-command silent cat saida.json.
*/



procedure log.

    def input parameter par-texto as char.

    output to value(vlog) append.
    put unformatted "  ->  " string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","")
            " "
            par-texto skip.
    output close.

end procedure.

