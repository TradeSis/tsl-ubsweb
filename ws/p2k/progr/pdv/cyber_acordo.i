
/* cyber_acordo.i                                                           */
/* colocar este include no wf-movco.p antes de dar run no opetitco.p        */

/***
{admcab.i}
{dftempWG.i}
****/

def input  parameter sretorno as char.
def input  parameter vclicod like clien.clicod.
def output parameter par-mensagem as char.

find clien where clien.clicod = vclicod no-lock no-error.
if not avail clien then return.

/*****************************************************************    
colocar da seguinte forma abaixo       
        sretorno = "CAIXA".
        {cyber_acordo.i}
        sretorno = "".
        run opetitco.p
***********************************/
/*************************************
colocar as 3 linhas abaixo no programa novacao2.p apos a leitura do clien  
        sretorno = "NOVACAO".
        {cyber_acordo.i}
        sretorno = "".
*******************************************/        
        
def var tem_acordo as log.
def var vretorno   as char.
def var vcodigoretorno as int.
def var tem-acordo as log.
def var vcpjcnpj   as char format "x(14)".

vcpjcnpj = clien.ciccgc.

def new shared temp-table tt-contratos
    field adacct as char format "x(20)"
    field titnum as char format "x(15)"
    field adacctg as char
    field adahid as char
    field etbcod as int format "999" .

def new shared  temp-table tt-acordo
    field apahid as char
    field titvlcob as dec
    field titpar  as int
    field titdtven as date
    field apflag as char
    field titjuro as dec.

/*
tem_acordo = no.
find first novacordo no-lock no-error.
if avail novacordo and
   not can-find(first tit_novacao where 
                       tit_novacao.tipo begins "RENEGOCIACAO"
                   and tit_novacao.id_acordo = string(novacordo.id_acordo))
then tem_acordo = yes.
*/

if sretorno = "CAIXA" or
   sretorno = "NOVACAO" 
then do.
    find first cyber_clien where cyber_clien.clicod   = clien.clicod and
                                 cyber_clien.situacao = yes
                        no-lock no-error.
    if avail cyber_clien
    then do.
        tem_acordo = no.
        run ./progr/pdv/chama-ws-cyber.p (input vcpjcnpj,
                              output vretorno,
                              output vcodigoretorno).
        find first tt-acordo no-error.
        if avail tt-acordo
        then tem_acordo = yes.
   
        if tem_acordo 
        then do.    
            find first tit_novacao
                   where tit_novacao.tipo begins "RENEGOCIACAO"
                     and tit_novacao.id_acordo = string(tt-acordo.apahid)
                   no-lock no-error.

            if sretorno = "CAIXA"
            then do.
                if not avail tit_novacao
                then par-mensagem = 
                        "Cliente possui acordo no CRIC. " + 
                        "Favor ir para o menu de NOVACAO.".
            end.
            else run novacordo_cyber.
                /* run cyber_novacao_acordo.p(clien.clicod). */
        end.
    end.
end.



procedure novacordo_cyber:
    /*** 14/01/2016 faltava gravar campo tp-novacordo.char1. ***/
    def var vbanco       as int.
    def var val-origem   as dec.
    def var vcom-entrada as log.
    def var vchar1       as char.
    def var vct          as int.
    def var vparpri      as int.
    def var vparult      as int.
    def var vavencer     as dec.

/*** REVISAR PROGRAMACAO PARA P2K

    vbanco = 0.
    for each tt-contratos no-lock:
        assign
            vparpri = 0
            vparult = 0
            vavencer = 0.
                 
        for each tp-titulo where tp-titulo.modcod = "CRE" and
                tp-titulo.titsit = "LIB" and
                tp-titulo.titnum = tt-contratos.titnum
                no-lock
                by tp-titulo.titpar.

            vavencer = vavencer  + tp-titulo.titvlcob.
            val-origem = val-origem + tp-titulo.titvlcob.
            if tp-titulo.cobcod = 10
            then vbanco = 10.

            if vparpri = 0
            then vparpri = tp-titulo.titpar.
            else vparult = tp-titulo.titpar.
        end.    

        vct = vct + 1.
        vchar1 = vchar1 + "CONTRATO" + string(vct) + "=" +
                 tt-contratos.titnum + ";" +
                 string(vavencer)  + ";" +
                 string(vparpri) + ";" +
                 string(vparult) + "|".
        
        find first tp-contrato where 
                       tp-contrato.contnum = int(tt-contratos.titnum)
                       no-error.
        if not avail tp-contrato
        then do:          
            create tp-contrato.
            assign
                tp-contrato.clicod  = clien.clicod
                tp-contrato.contnum = int(tt-contratos.titnum).
        end.            
    end.
    vcom-entrada = no.

    create tp-novacordo.
    assign
        tp-novacordo.clicod    = clien.clicod
        tp-novacordo.valor_ori = val-origem
        tp-novacordo.destino   = vbanco
        tp-novacordo.char1     = vchar1.
    for each tt-acordo no-lock by tt-acordo.titpar:
        assign
            tp-novacordo.id_acordo     = dec(tt-acordo.apahid)
            tp-novacordo.Valor_acordo  = tp-novacordo.Valor_acordo +
                                                tt-acordo.titvlcob
            tp-novacordo.Valor_liquido = tp-novacordo.Valor_liquido + 
                                                tt-acordo.titvlcob
            tp-novacordo.Qtd_parcelas  = tt-acordo.titpar.

        if tt-acordo.titpar = 0
        then assign
            vcom-entrada = yes
            tp-novacordo.Dtinclu       = tt-acordo.titdtven
            tp-novacordo.Valor_entrada = tt-acordo.titvlcob
            tp-novacordo.Valor_liquido = tp-novacordo.Valor_liquido -
                                            tt-acordo.titvlcob. 
    end.
    
    if vcom-entrada 
    then tp-novacordo.Qtd_parcelas = tp-novacordo.Qtd_parcelas + 1.

    find first tt-contratos no-error.
    if avail tt-contratos
    then tp-novacordo.etb_acordo = tt-contratos.etbcod.
    tp-novacordo.situacao = "PENDENTE".

***/
    
end procedure.

