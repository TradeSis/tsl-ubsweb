/* cyber_acordo.i                                                           */
/* colocar este include no wf-movco.p antes de dar run no opetitco.p        
   #1 22/06/2018 Felipe B Novo programa de webservice cyber
*/

/***
{dftempWG.i}
***/

def input  parameter par-oper   as char.
def input  parameter par-clicod as int.
def output parameter par-mensagem as char.

def var vretorno   as char.
def var vcodigoretorno as int.
def var vcpfcnpj   as char.

/***
def shared temp-table tt-novacao
    field ahdt    as date
    field vltotal as dec.

def shared temp-table tt-contratos
    field adacct as char format "x(20)"
    field titnum as char format "x(15)"
    field adacctg as char
    field adahid as char
    field etbcod as int format "999" .
***/

def shared temp-table tt-acordo
    field apahid as char
    field titvlcob as dec
    field titpar  as int
    field titdtven as date
    field apflag as char
    field titjuro as dec.

find clien where clien.clicod = par-clicod no-lock no-error.
if not avail clien then return.

vcpfcnpj = clien.ciccgc.

/*
tem_acordo = no.
find first novacordo where novacordo.clicod   = par-clicod
                       and novacordo.situacao = "PENDENTE"
                    no-lock no-error.
if avail novacordo and
   not can-find(first tit_novacao where 
                       tit_novacao.tipo begins "RENEGOCIACAO"
                   and tit_novacao.id_acordo = string(novacordo.id_acordo))
then tem_acordo = yes.
*/

find first cyber_clien where cyber_clien.clicod   = clien.clicod and
                             cyber_clien.situacao = yes
                       no-lock no-error.
if avail cyber_clien or
   par-oper = "ConsultaAcordo"    
then do.
    /* #1 */

    run ./progr/pdv/chama-ws-cyber_07a.p (input vcpfcnpj,
                              output vretorno,
                              output vcodigoretorno).
    
    if par-oper = "Caixa"
    then do.
        find first tt-acordo no-error.
        if avail tt-acordo
        then do.
            find first tit_novacao
                   where tit_novacao.tipo = "RENEGOCIACAO"
                     and tit_novacao.id_acordo = string(tt-acordo.apahid)
                   no-lock no-error.
                if not avail tit_novacao
                then par-mensagem = 
                        "Cliente possui acordo no CRIC. " + 
                        "Favor ir para o menu de NOVACAO".
        end.
    end.
end.

