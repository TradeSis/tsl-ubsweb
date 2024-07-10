{admcab.i new}
setbcod = 189.
def new shared var vdata-teste-promo as date init ?.
def new shared workfile wf-movim
    field wrec    as   recid
        field movqtm like movim.movqtm
            field lipcor    like liped.lipcor
                field movalicms like movim.movalicms
                    field desconto like movim.movdes
                        field movpc like movim.movpc
                            field precoori like movim.movpc
                                field vencod  like func.funcod.
                                

def var parametro-out as char.
def var parametro-in  as char.
def new shared temp-table tt-valpromo 
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.

def var vplano-aux as int.
find last finan where fincod = 120 no-lock.
vplano-aux = finan.fincod.


/*******  Inicio promocao DINHEIRO-NA-MAO  *********/
find produ where produ.procod = 400683 no-lock.
disp produ.clacod.
create wf-movim.
wf-movim.wrec = recid(produ).
wf-movim.movqtm = 1.
wf-movim.movpc  = 500.
wf-movim.vencod = 99999.

parametro-out = "".
parametro-in = "DINHEIRO-NA-MAO=S|PLANO=" + string(vplano-aux) + "|"
            + "ALTERA-PRECO=N|".
            run ./promo-venda.p(input parametro-in ,
                              output parametro-out).

message "parametro out" parametro-out. pause.
for each tt-valpromo.
    disp tt-valpromo.
end.