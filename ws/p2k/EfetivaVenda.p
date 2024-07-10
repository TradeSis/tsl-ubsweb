def new global shared var setbcod    like estab.etbcod.

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).

    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
                              
/* buscarplanopagamento */
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
   
def new shared temp-table ttcampanhas
        field tipo_campanha as char             /**
                                                  "1" = Cuponagem; 
                                                  "2" = Desconto (No caso das campanhas: dinheiro na mão e dinheiro na troca retornar: "1")
                                                **/  
        field descricao_campanha as char       /**
                                                    // "Dinheiro na mão";"Dinheiro na troca";etc...
                                               **/     
        field valor as dec
        field codigo_campanha as char.          /**
                                                    // Código da campanha no ADMCOM
                                                **/    
 

def shared temp-table formapagamentoEntrada
    field codigo_forma_pagamento as char  /**"1" = Dinheiro; 
                                             "2" = Cheque; 
                                             "7" = Cheque pré datado; 
                                             "9" = Cartão de débito; 
                                             "11" = Cartão de crédito; 
                                             "93" = Crediário Lebes; 
                                             "1000" = Cartão Presente; 
                                             "102" = Bônus de crédito ou vale-troca
                                             **/
    field codigo_plano_pagamento as char
    field data_primeira_parcela as char
    field valor_total_forma as char
    field valor_parcela as char
    field valor_entrada as char.

    def var vcodigo_forma_pagamento as char   .
    def var vcodigo_plano_pagamento as char   .
    def var vdata_primeira_parcela as char    .
    def var vvalor_total_forma as char        .
    def var vvalor_parcela as char            .
    def var vvalor_entrada as char.


def shared temp-table produtosEntrada 
    field codigo_produto as char
    field descricao_produto as char
    field quantidade as char
    field preco_unitario as char
    field preco_total as char.

    def var vcodigo_produto as char      .
    def var vdescricao_produto as char   .
    def var vquantidade as char          .
    def var vpreco_unitario as char      .
    def var vpreco_total as char.


def shared temp-table EfetivaVenda
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_cliente as char
    field codigo_contrato as char
    field numero_comprovante as char
    field numero_cupom_fiscal as char
    field valor_total_contrato as char
    field valor_acrescimos as char
    field valor_iof as char
    field valor_desconto as char
    field codigo_operador as char.

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
def var vtipo_campanha as char.
 def var vvalor as dec.
 def var vcodigo_campanha as int.

find first efetivavenda no-error.
/* STATUS: "S" = SUCESSO; "E" = ERRO, "N" = COM SUCESSO, MAS SEM RETORNO DE DADOS */

setbcod = if avail efetivavenda
          then int(efetivavenda.codigo_filial)
          else 0.

vstatus = if avail efetivavenda
          then "S"
          else "E".
vmensagem_erro = if avail efetivavenda
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     


{bsxml.i}

   /** vmensagem_erro = "VENDA - " + efetivavenda.codigo_contrato + 
            " - Efetivado".
      **/
      
    for each produtosEntrada.

        find produ where produ.procod = int(produtosEntrada.codigo_produto) no-lock no-error.
        if avail produ
        then do:
            create wf-movim.
            wf-movim.wrec = recid(produ).
            wf-movim.movqtm = int(produtosEntrada.quantidade).
            wf-movim.movpc  = dec(produtosEntrada.preco_unitario).
        end.
    end.

    vplano-aux = 0.
    for each formapagamentoEntrada.
        find first finan where fincod = int(formapagamentoEntrada.codigo_plano_pagamento) 
                no-lock no-error.
        if avail finan
        then vplano-aux = finan.fincod.
    end.
 
    BSXml("ABREXML","").
    bsxml("abretabela","return").


       bsxml("status",vstatus).

       bsxml("mensagem_erro",vmensagem_erro).
 

        /**
        BONUS=VAL|VAL-BONUS-U=50|PRODUTO-USADO=S|GERA-DESPESA=S|FORNECEDOR=113826|EMITE-RECIBO=S
        **/


        /*******  Inicio promocao DINHEIRO-NA-MAO  *********/
            parametro-out = "".
            parametro-in = "DINHEIRO-NA-MAO=S|PLANO=" + string(vplano-aux) + "|"
                        + "ALTERA-PRECO=N|".
            run ./promo-venda.p(input parametro-in ,
                              output parametro-out).

        find first tt-valpromo no-error.
        if avail tt-valpromo
        then vcodigo_campanha = tt-valpromo.tipo.
        
        vtipo_campanha = acha("BONUS",parametro-out).                      
        vvalor         = dec(acha("VAL-BONUS-U",parametro-out)).
        if vvalor = ? 
        then  vvalor = 0.
        
        if vvalor > 0
        then do: 
            create ttcampanhas.
            ttcampanhas.tipo_campanha = vtipo_campanha.
            ttcampanhas.descricao_campanha = "DINHEIRO NA MAO".
            ttcampanhas.valor = vvalor.
            ttcampanhas.codigo_campanha = string(vcodigo_campanha).
        end.
        else do:
            create ttcampanhas.
            ttcampanhas.tipo_campanha = "".
            ttcampanhas.descricao_campanha = "SEM CAMPANHA".
            ttcampanhas.valor = 0.
            ttcampanhas.codigo_campanha = "0".
        
        end.
 
             BSXml("ABREREGISTRO","campanhasLista"). 
             for each ttcampanhas.
                 BSXml("ABREREGISTRO","campanha").
                bsxml("tipo_campanha",ttcampanhas.tipo_campanha).
                bsxml("descricao_campanha",ttcampanhas.descricao_campanha).
                bsxml("valor",string(ttcampanhas.valor,">>>>>>>>9.99")).
                bsxml("codigo_campanha",ttcampanhas.codigo_campanha).
                BSXml("FECHAREGISTRO","campanha").
              end.     
            BSXml("FECHAREGISTRO","campanhasLista"). 
               
    bsxml("fechatabela","return").
    BSXml("FECHAXML","").
















