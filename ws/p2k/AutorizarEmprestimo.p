/* 08/2016: Projeto Credito Pessoal */
def NEW shared temp-table tt-profin
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

def var vclicod as int.
def var vclinom as char.
def var vcpf    as char.
def var vok     as log.
def var vlimite as dec.
def var vdtemissao as date.

/* buscarplanopagamento */
def var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
/***
def var vchar as char.
def var vdata as date.
***/
def var vcontnum like geranum.contnum.
def var vcertifi as char.

def shared temp-table AutorizarEmprestimo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field codigo_produto    as char
    field valor_tfc         as char
    field valor_credito     as char
    field data_primeiro_vencimento  as char
    field valor_primeiro_vencimento as char
    field numero_parcelas   as char
    field nsu_venda         as char
    field vendedor          as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char.
  
/* CET */
/***
def var vValorCompra  as decimal.
def var vLoja         as integer.
def var vPrazo        as int.
def var vValorPMT     as decimal.
def var vDiasParaPgto as integer.
def var vProduto      as integer init 3.
def var vPlano        as integer init 842.
***/
def var vcet as dec.
def var vcet_ano as dec.
def var vtx_mes as dec.
def var vvalor_iof as dec.
def var vret-taxa as char.

{bsxml.i}

def var varqlog as char.
varqlog = "/u/bsweb/log/SimulacaoSicredi_" + string(today, "999999") +
          string(time,"HH:MM:SS") + ".log".
varqlog = replace(varqlog,":","").

output to value(varqlog) append.
put unformatted "HINICIO " + string(time,"HH:MM:SS") skip(1).
output close.


find first AutorizarEmprestimo no-lock no-error.
if avail AutorizarEmprestimo
then do.
    assign
        vstatus = "S"
        setbcod = int(AutorizarEmprestimo.codigo_filial)
        /***vloja   = int(AutorizarEmprestimo.codigo_filial)***/.

    find clien where clien.clicod = int(AutorizarEmprestimo.codigo_cliente)
               no-lock no-error.
    if avail clien
    then do.
        assign
            vclicod = clien.clicod
            vclinom = Texto(clien.clinom)
            vcpf    = Texto(clien.ciccgc).
    end.
    else run erro ("CLIENTE Nao Encontrado").
end.
else run erro ("Parametros de Entrada nao recebidos").

output to value(varqlog) append.
put unformatted "2 " + string(time,"HH:MM:SS") skip(1).
output close.


if vstatus = "S"
then do.
    find profin where profin.fincod = int(AutorizarEmprestimo.codigo_produto)
                no-lock no-error.
    if not avail profin
    then run erro ("Produto Financeiro Nao Encontrado").
    else if not profin.situacao
    then run erro ("Produto Financeiro Inativo").
end.

output to value(varqlog) append.
put unformatted "3 " + string(time,"HH:MM:SS") skip(1).
output close.


if vstatus = "S"
then do.
    run ./progr/creditopessoal.p ("Autoriza", setbcod, clien.clicod, 0,
                                  output vlimite,
                                  output vstatus,
                                  output vmensagem_erro).
    find first tt-profin where tt-profin.codigo = 
                                        int(AutorizarEmprestimo.codigo_produto)
                           no-lock no-error.
    if not avail tt-profin or
       tt-profin.saldo < dec(AutorizarEmprestimo.valor_credito)
    then run erro ("Saldo nao disponivel").
end.
    
output to value(varqlog) append.
put unformatted "4 " + string(time,"HH:MM:SS") skip(1).
output close.


if vstatus = "S"
then do:
    do for geranum on error undo on endkey undo.
        /*** Numeracao para CONTRATOS criados na matriz ***/
        find geranum where geranum.etbcod = 999 exclusive no-error.
        if not avail geranum
        then do:
            create geranum.
            assign
                geranum.etbcod  = 999
                geranum.clicod  = 300000000
                geranum.contnum = 300000000.
        end.
        geranum.contnum = geranum.contnum + 1. 
        find current geranum no-lock. 
        vcontnum = geranum.contnum.
    end.
end.

output to value(varqlog) append.
put unformatted "5 " + string(time,"HH:MM:SS") skip(1).
output close.


BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_cliente",string(vclicod)).
bsxml("cpf", vcpf).
bsxml("nome",vclinom).
bsxml("numero_contrato", string(vcontnum, "9999999999")).

if avail AutorizarEmprestimo
then do.
    bsxml("codigo_filial",AutorizarEmprestimo.codigo_filial).
    bsxml("numero_pdv",   AutorizarEmprestimo.numero_pdv).
end.
else do.
    bsxml("codigo_filial","").
    bsxml("numero_pdv","").
end.

if vstatus = "S"
then do.
    /*** Data de emissao do contrato ***/
    vdtemissao = today.
    
    /*48775 
    if time > 55800 /*** 15h30min  60 * 60 * 15 + (60 * 30) ***/
    then vdtemissao = vdtemissao + 1.
    
    repeat.
        if weekday(vdtemissao) = 1 /* domingo */
        then vdtemissao = vdtemissao + 1.
        else if weekday(vdtemissao) = 7 /* sabado */
        then vdtemissao = vdtemissao + 2.

        /*** verificar dtesp ***/
        find first dtesp where dtesp.etbcod = 999 and
                               dtesp.datesp = vdtemissao
                         no-lock no-error.
        if avail dtesp
        then do.
            vdtemissao = vdtemissao + 1.
            next.
        end.

        leave.
    end.
    48775 ***/
    
end.

/***
if vstatus = "S"
then do.
    vprazo = int(AutorizarEmprestimo.numero_parcelas).
    vvalorpmt = dec(AutorizarEmprestimo.valor_primeiro_vencimento).

    vchar = AutorizarEmprestimo.data_primeiro_vencimento.
    vdata = date(int(substring(vchar,6,2)),
                 int(substring(vchar,9,2)),
                 int(substring(vchar,1,4))) no-error.
    if vdata <> ?
    then vdiasparapgto = vdata - today.
    else vdiasparapgto = 30.

    vvalorcompra = (dec(AutorizarEmprestimo.valor_credito) +
                    dec(AutorizarEmprestimo.valor_tfc)) * 1.08.

    {ws/p2k/progr/chama-cal-tx-wssicred.i}

    assign vCET         = round(decimal(vret-CET),2).
    assign vCET_Ano     = round(decimal(vret-CETAnual),2).
    assign vvalor_iof   = dec(vret-valoriof).
end.
***/

bsxml("tipo_operacao","CDC").
bsxml("cet",string(vcet,">>>>>>>>>>9.99")).
bsxml("cet_ano",string(vcet_ano,">>>>>>>>>>9.99")).
bsxml("tx_mes",vret-taxa).
bsxml("valor_iof",string(vvalor_iof,">>>>>>>>>9.99")).

if vstatus = "S"
then do.
    if AutorizarEmprestimo.codigo_seguro_prestamista = "569131"
    then do on error undo.
        /* Gerar Numero do Certificado */
        find geraseguro where geraseguro.tpseguro = 3
                          and geraseguro.etbcod   = setbcod
                        exclusive no-error.
        if not avail geraseguro
        then do.
            create geraseguro.
            assign
                geraseguro.tpseguro = 3
                geraseguro.etbcod   = setbcod.
        end.
        assign
            geraseguro.sequencia = geraseguro.sequencia + 1.

        vcertifi = string(setbcod, "999") +
                   "3" /* tpserv P2K Credito Pessoal */ +
                   string(geraseguro.sequencia, "9999999").
        find current geraseguro no-lock.
    end.    
end.

bsxml("numero_bilhete",vcertifi).
bsxml("numero_sorte",  "").
bsxml("data_emissao", EnviaData(vdtemissao)).

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.

