{/u/bsweb/progr/acha.i}
             
def var par-ok  as log.
/* buscarplanopagamento */
def var vcod as int.
def var vatraso as log.
def var vspc_descr_motivo as char.
def var vspc_cod_motivo_cancelamento as char.
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var cestcivil as char.
def var vcartao as char /***int***/.
def var vi as int.   
def var vcarro as char.
def var vobs as char.
def var vmen-spc as char.
def var vdat-spc as date.
def var vcon-spc as char.
def var vale-spc as char.
def var vcre-spc as char.
def var vche-spc as char.
def var vfil-spc as char.
def var vnac-spc as char.
def var vinstrucao as char.
def var vsituacao-instrucao as char.
def var vcnpj as log.
def var vrecebe-email-promo as char.

def var vperc15 as dec decimals 2.
def var vperc45 as dec decimals 2.
def var vperc46 as dec decimals 2.
def var vmedia  as dec decimals 2.

def var v-estoque-loja as int.

/* PDV hiscli2.p */
def NEW SHARED var pagas-db as int.

def NEW SHARED var maior-atraso as int /***like plani.pladat***/.
def NEW SHARED var vencidas like clien.limcrd.
def NEW SHARED var v-mes as int format "99".
def NEW SHARED var v-ano as int format "9999".
def NEW SHARED var v-acum like clien.limcrd.
def NEW SHARED var qtd-contrato as int format ">>>9".
def NEW SHARED var parcela-paga    as int format ">>>>9".
def NEW SHARED var parcela-aberta  as int format ">>>>9".
def NEW SHARED var qtd-15       as int format ">>>>9".
def NEW SHARED var qtd-45       as int format ">>>>9".
def NEW SHARED var qtd-46       as int format ">>>>9".
def NEW SHARED var vrepar       as log format "Sim/Nao".
def NEW SHARED var v-media      like clien.limcrd.
def NEW SHARED var ult-compra   like plani.pladat.
def NEW SHARED var sal-aberto   like clien.limcrd.
def NEW SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def NEW SHARED var cheque_devolvido like plani.platot.
def NEW SHARED var vclicod like clien.clicod.
def NEW SHARED var vtotal like plani.platot.
def NEW SHARED var vqtd        as int.
def NEW SHARED var proximo-mes like clien.limcrd.

/* SPC */
def var par-spc     as log init yes.
def var spc-conecta as log init yes.
def var vlibera-cli as log.
def NEW shared temp-table tp-contrato like fin.contrato.
/* */

def shared temp-table ConsultaEstoque
    field filial as int
    field codigo as char
    field descricao as char
    field fornecedor as char
    field mercadologico as char.

def temp-table tt-retorno
    field etbcod as integer
    field procod as char
    field quantidade-disponivel as char
    field quantidade-reservada as char
    field quantidade-total as char.
    
                     
                    
def var vestoq_depos as int.
def var vreservas as int.
def var vdisponivel as int.
                    
find first ConsultaEstoque no-error.

vstatus = if avail ConsultaEstoque
          then "S"
          else "E".
vmensagem_erro = if avail ConsultaEstoque
                 then "S"
                 else "Parametros de Entrada nao recebidos.".     
                 
if ConsultaEstoque.filial = 0
then do:

    for each estab where estab.tipo = "normal"
                      or estab.tipo = "outlet" no-lock,

        each estoq where estoq.etbcod = estab.etbcod 
                     and estoq.procod = integer(ConsultaEstoque.codigo)
                         no-lock.
    
        create tt-retorno.
        assign
           tt-retorno.etbcod                = estoq.etbcod
           tt-retorno.procod                = string(estoq.procod)
           tt-retorno.quantidade-disponivel = string(estoq.estatual)
           tt-retorno.quantidade-reservada  = "0"
           tt-retorno.quantidade-total      = tt-retorno.quantidade-disponivel.

    end.

end.
else do:

    find first estoq where estoq.etbcod = integer(ConsultaEstoque.filial)
                       and estoq.procod = integer(ConsultaEstoque.codigo)
                         no-lock.
    if avail estoq
    then do:
    
        create tt-retorno.
        assign
           tt-retorno.etbcod                = estoq.etbcod
           tt-retorno.procod                = string(estoq.procod)
           tt-retorno.quantidade-disponivel = string(estoq.estatual)
           tt-retorno.quantidade-reservada  = "0"
           tt-retorno.quantidade-total      = tt-retorno.quantidade-disponivel.
    
    end.
    
end.
    
run p-calcula-estoque-deposito (input 900,
                                input ConsultaEstoque.codigo).
      

{/u/bsweb/progr/bsxml.i}
    vcnpj = no.
        
    BSXml("ABREXML","").
    bsxml("abretabela","return").




    BSXml("ABREREGISTRO","estoques").    
    
    
                       
    for each tt-retorno no-lock  by tt-retorno.etbcod.
    
        BSXml("ABREREGISTRO","estoque").
        bsxml("loja",string(tt-retorno.etbcod)).
        bsxml("codigo-produto",tt-retorno.procod).
        bsxml("quantidade-disponivel",tt-retorno.quantidade-disponivel).
        bsxml("quantidade-reservada",tt-retorno.quantidade-reservada).
        bsxml("quantidade-total",tt-retorno.quantidade-total).
        BSXml("FECHAREGISTRO","estoque").         
        
    end.         
        
    BSXml("FECHAREGISTRO","estoques").    
        

   
    
    bsxml("fechatabela","return").
    BSXml("FECHAXML","").
                  
                  
                  
                  

procedure p-calcula-estoque-deposito:

    def input parameter p-etbcod as integer.
    def input parameter p-procod as integer.

    setbcod = int(p-etbcod).

    run corte_disponivel.p (input  p-procod,
                            output vestoq_depos,
                            output vreservas,
                            output vdisponivel).
    
    create tt-retorno.
    assign tt-retorno.etbcod                = p-etbcod
           tt-retorno.procod                = string(p-procod)
           tt-retorno.quantidade-disponivel = string(vdisponivel)
           tt-retorno.quantidade-reservada  = string(vreservas)
           tt-retorno.quantidade-total      =
                        string(vreservas + vdisponivel) .
 


end. 

                  
