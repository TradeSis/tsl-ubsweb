/*  p2k_geraped.p                                                             */
/*  envio de pre-venda para P2K                                               */
{admcab.i}
def var varq as char.
def var num_pedido  as int.
def input parameter par-rec as recid.

def shared temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor  as dec.


find plani where recid(plani) = par-rec no-lock.
if plani.movtdc <> 30               /* somente pre-vendas sao enviadas      */
then leave.
if plani.notped = "U"               /* excluidas nao sao enviadas           */ 
then next.
if plani.etbcod <> setbcod          /* somente pre-vendas da filial         */ 
then next.

varq = "/usr/admcom/p2k/PD" + string(plani.etbcod,"9999")       + 
              string(plani.numero,"99999999")   + ".csi".

function formatadata returns character 
    (input par-data  as date).  
    def var vdata as char. 
    if par-data <> ? 
    then vdata = 
                 string(year (par-data), "9999") +
                 string(month(par-data), "99") + 
                 string(day  (par-data), "99")  . 
    else vdata = "00000000". 
    return vdata. 
end function.

def var vhora as int.
vhora = int(
        substr(string(Plani.horinc,"HH:MM:SS"),1,2) +
        substr(string(Plani.horinc,"HH:MM:SS"),4,2) +
        substr(string(Plani.horinc,"HH:MM:SS"),7,2)) no-error .
find clien where clien.clicod = plani.desti no-lock.
def var Codigo_CPF_CNPJ as char format "x(18)" .
def var Digito_CPF_CNPJ as char format "xx".

run p2k_cpfcliente.p (input clien.clicod,
                      output Codigo_CPF_CNPJ, 
                      output Digito_CPF_CNPJ).


output to value(varq).
/* Registro tipo 01 - Capa de pedido            */
put unformatted 
    "01"                format "xx"         /*        Tipo_Reg              */
    Plani.Etbcod        format "99999"      /*        Codigo_Loja           */
    plani.numero        format "9999999999" /*        Numero_Pedido         */
    "3"                 format "x"          /*        Status_Pedido         */
    0                   format "99999"      /*        Num_Componente        */
    formatadata(Plani.pladat) format "xxxxxxxx"   /*  Data                  */
    vhora               format "999999"     /*        Hora                  */
    string(Plani.desti, "99999999999999999999")     format "x(20)"      
                                            /*        Codigo_Cliente        */
    string(dec(Codigo_CPF_CNPJ) , "999999999999999999")
                        format "x(18)"      /*        Codigo_CPF_CNPJ       */
    Digito_CPF_CNPJ     format "xx"         /*        Digito_CPF_CNPJ       */

   (if plani.notobs[1] <> "" or clien.clicod = 0
    then plani.notobs[1]
    else Clien.clinom)  format "x(40)"      /*        Nome_Cliente          */

   (if clien.clicod = 0
    then ""
    else Clien.endereco[1]) format "x(30)"  /*        End_Cliente           */
   (if clien.clicod = 0
    then 0
    else Clien.numero[1])   format "99999"  /*        Num_End_Cliente       */
   (if clien.clicod = 0
    then ""
    else Clien.compl[1])    format "x(35)"  /*        Compl_End_Cliente     */
   (if clien.clicod = 0
    then ""
    else Clien.cidade[1])  format "x(35)"    /*        Cidade_End_Cliente    */
   (if clien.clicod = 0
    then ""
    else Clien.ufecod[1])  format "xxx"      /*        Estado_End_Cliente    */
    
    "BRA"               format "xxx"        /*        Pais_End_Cliente      */
   (if clien.clicod = 0
    then ""
    else Clien.cep[1])   format "x(10)"      /*        CEP_End_Cliente       */
    
    "1"                 format "x"          /*        Tipo_Desconto         */
    0               format "9999999999999"  /*        Desconto              */
    Plani.etbcod        format "99999"      /*        Codigo_Loja_Trs       */
    formatadata(pladat) format "xxxxxxxx"   /*        Data_Trs              */
    0                   format "99999"      /*        Componente_Trs        */
    0                   format "999999"     /*        Nsu_Trs               */
    0                   format "999999"     /*        Codigo_Vendedor       */
   (if clien.tippes
    then 1 
    else 2)             format "9"          /*        Tipo_CPF_CNPJ         */
    1                   format "9"          /*        Tipo                  */
    formatadata(pladat) format "xxxxxxxx"   /*        Data_Vencimento       */
    0                   format "99999999"   /*        Data_Cancel           */
    1                   format "9"          /*        Tipo_Acrescimo        */
    0                format "9999999999999" /*        Acrescimo             */
    plani.numero        format "9999999999" /*        Numero_PV             */
    skip.
    
/* Registro tipo 02 . Item de pedido       */
def var vmovalicms as dec.
def var vsittributaria as char.

for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod no-lock.

    find produ of movim no-lock. 
    if (produ.pronom begins "CHEQUE PRESENTE" or 
        produ.pronom begins "CARTAO PRESENTE" or 
        produ.procod = 10000)
    then next.

    if produ.proipiper = 12 
    then assign vsittributaria = "T"
                vmovalicms = 12. 
    else if produ.proipiper = 99 
    then assign vsittributaria = "F"
                vmovalicms = 0. 
    else assign vsittributaria = "T"
                vmovalicms = 17.
    
    find clafis where clafis.codfis = produ.codfis no-lock no-error.
    def var par-imposto as dec.
    par-imposto = 0.
    if avail clafis and clafis.dec1 > 0
    then do.
        par-imposto = clafis.dec1.
    end.
    
    find first tbprice where  
                    tbprice.etb_venda   = plani.etbcod  and
                    tbprice.nota_venda  = plani.numero  and
                    tbprice.data_venda  = plani.pladat  and
                    tbprice.char1       = "PRE-VENDA"   and
                    tbprice.etb_compra  = 0             and
                    tbprice.nota_compra = produ.procod no-lock no-error.
    put unformatted
        2               format "99"         /* Tipo_Reg */ 
        Plani.etbcod    format "99999"      /* Codigo_Loja */ 
        Plani.notass    format "9999999999" /* Numero_Pedido */ 
        Movim.movseq    format "999999"     /* Seq_Item_Pedido */ 
        0               format "99999"      /* Num_Componente */ 
        plani.vencod    format "999999"     /* Codigo_Vendedor */ 
        string(Movim.procod,"99999999999999999999")    
                    format "x(20)"      /* Codigo_Produto */ 
        Movim.procod    format "99999999999999" /* Cod_Autom_Prod */ 
        Movim.movqtm * 1000   format "99999999"   /* Quant_Produto */ 
        Produ.prounven  format "xx"         /* Unid_Venda_Prod */ 
        Movim.movpc  * 100   format "9999999999999"  /* Valor_Unitario */ 
        Movim.movqtm * movim.movpc * 100
                        format "9999999999999"  /* Val_Total_Item */ 
        1               format "9"              /* Tipo_Desconto */ 
        0               format "9999999999999"  /* Desconto_Unit */ 
        Plani.etbcod    format "99999"          /* Loja_Item_Entg */ 
        "00000"         format "x(5)"           /* Depos_Item_Entg */ 
        "RL"            format "xx"             /* Forma_Entrega */ 
        0               format "99999999"       /* Qtd_Item_Entfut */ 

        vsittributaria  format "x"              /* Situacao_Tributaria */ 

        vmovalicms      format "99999"          /* Perc_Tributacao */ 


        Produ.pronom    format "x(40)"          /* Descr_Compl_Trunc */ 
        1               format "9999999999999"  /* Qtd_Unid_Venda_Prod */ 
        Produ.pronom    format "x(71)"          /* Descricao Completa */ 
        if avail tbprice
        then tbprice.serial  
        else ""         format "x(30)"          /* Nao Serial */
        produ.codfis    format "99999999"       /* Codigo_NCM */ 
        par-imposto     format "99999"          /* Percent_Imp_Medio */ 
        skip.
end.

put unformatted
    "03"            format "xx"     /* tipo_reg */
    1    format "99999" /* Numero_Pedido */ 
    plani.crecod    format "99999" /* forma */
    plani.crecod    format "99999" /* plani */
    plani.platot * 100   format "9999999999999"  
    skip.
    

for each tt-cartpre.
    put unformatted 
    "06"    format "xx" 
    "01"    format "xx"
    plani.etbcod format "99999"
    Plani.notass    format "9999999999" /* Numero_Pedido */ 
    tt-cartpre.numero "99999"
    plani.vencod    format "999999"     /* Codigo_Vendedor */ 
    "01" format "x(30)"
    tt-cartpre.valor * 100   format "9999999999999"  
    skip.
end.

put unformatted 
    "99"                format "xx"         /*        Tipo_Reg              */
    skip.


output close.


