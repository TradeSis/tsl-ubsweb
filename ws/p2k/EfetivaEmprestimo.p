/* 08/2016: Projeto Credito Pessoal */

def var vcpf    as char.
def var vok     as log.
def var vlimite as dec.
def var vchar   as char.
def var vdata   as date.
def var vhora   as int.
def var vvltotal as dec.
def var vdtemissao as date.
def var vcontrato_p2k as char.

/* buscarplanopagamento */
def var setbcod        as int.
def var vstatus        as char.   
def var vmensagem_erro as char.

def shared temp-table parcelas 
    field seq_parcela as char
    field vlr_parcela as char
    field venc_parcela as char
    field numero_contrato as char.

def shared temp-table EfetivaEmprestimo
    field codigo_filial     as char
    field codigo_operador   as char
    field numero_pdv        as char
    field codigo_cliente    as char
    field numero_contrato   as char
    field codigo_produto    as char
    field valor_tfc         as char
    field valor_credito     as char
    field nsu_venda         as char
    field vendedor          as char
    field codigo_seguro_prestamista as char
    field valor_seguro_prestamista  as char
    field numero_bilhete    as char
    field numero_sorte      as char
    field data_emissao      as char.
  
/* CET */
def var vPrazo        as int.
def var vValorCompra  as decimal.
def var vValorPMT     as decimal.
def var vProduto      as integer init 3.
def var vPlano        as integer init 842.

{bsxml.i}

find first EfetivaEmprestimo no-lock no-error.
if avail EfetivaEmprestimo
then do.
    assign
        vstatus = "S"
        setbcod = int(EfetivaEmprestimo.codigo_filial)
        vvalorcompra = dec(EfetivaEmprestimo.valor_credito).
    
    find clien where clien.clicod = int(EfetivaEmprestimo.codigo_cliente)
               no-lock no-error.
    if avail clien
    then assign
            vcpf    = Texto(clien.ciccgc).
    else run erro ("CLIENTE Nao Encontrado").
end.
else run erro ("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.
    find profin where profin.fincod = int(EfetivaEmprestimo.codigo_produto)
                no-lock no-error.
    if not avail profin
    then run erro ("Produto Financeiro Nao Encontrado").
    else if not profin.situacao
    then run erro ("Produto Financeiro Inativo").
end.

if vstatus = "S"
then do.
    vprazo = 0.
    for each parcelas where dec(parcelas.vlr_parcela) > 0
                      by int(parcelas.seq_parcela).
        vprazo = vprazo + 1.
        vvltotal = vvltotal + dec(parcelas.vlr_parcela).
    end.

    if vprazo = 0 or
       vvltotal = 0
    then run erro("Parcelas nao informadas").
end.

if vstatus = "S"
then do.
    find contrato where contrato.contnum =
                                        int(EfetivaEmprestimo.numero_contrato)
                  no-lock no-error.
    if avail contrato
    then run erro("Contrato ja cadastrado").
end.

if vstatus = "S"
then do on error undo.
    vchar = EfetivaEmprestimo.Data_Emissao.
    vdtemissao = date(int(substring(vchar,6,2)),
                      int(substring(vchar,9,2)),
                      int(substring(vchar,1,4))) no-error.
    if vdtemissao = ?
    then vdtemissao = today.
    /* 48775 */
    vdtemissao = today.
    /* 48775  */

    create contrato.
    assign
        contrato.contnum   = dec(EfetivaEmprestimo.numero_contrato)
        contrato.clicod    = int(EfetivaEmprestimo.codigo_cliente)
        contrato.dtinicial = vdtemissao
        contrato.etbcod    = setbcod
        contrato.vltotal   = vvltotal
        contrato.crecod    = 2
        contrato.datexp    = 01/01/1970 /*** Alterado na integr.Datahub ***/
        /*** Campos diferentes ***/
        contrato.banco     = 13
        contrato.modcod    = profin.modcod
        contrato.vltaxa    = dec(EfetivaEmprestimo.valor_tfc)
        contrato.vlseguro  = dec(EfetivaEmprestimo.valor_seguro_prestamista)
        contrato.dtefetiva = vdtemissao.

       /* 68725  19/04/2021 helio */
       contrato.vlf_principal = vvalorcompra.
       contrato.vlf_acrescimo = vvltotal - vvalorcompra.
       contrato.nro_parcela   = 0.
        for each parcelas where dec(parcelas.vlr_parcela) > 0.
            contrato.nro_parcela = contrato.nro_parcela + 1.
        end.        
       /* 68725  19/04/2021 helio */

    for each parcelas where dec(parcelas.vlr_parcela) > 0
                      by int(parcelas.seq_parcela).

        vchar = parcelas.venc_parcela.
        vdata = date(int(substring(vchar,6,2)),
                     int(substring(vchar,9,2)),
                     int(substring(vchar,1,4))) no-error.
        vcontrato_p2k = string(int(EfetivaEmprestimo.numero_contrato)).

        find titulo where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = profin.modcod
                      and titulo.etbcod   = setbcod
                      and titulo.clifor   = contrato.clicod
                      and titulo.titnum   = vcontrato_p2k
                      and titulo.titpar   = int(parcelas.seq_parcela) + 1
                      and titulo.titdtemi = vdtemissao
                    no-lock no-error.                    
        if not avail titulo
        then do.
            create titulo.
            assign
                titulo.contnum   =  contrato.contnum /* VERUS */
                
                titulo.empcod    = 19
                titulo.titnat    = no
                titulo.modcod    = profin.modcod
                titulo.etbcod    = setbcod
                titulo.clifor    = contrato.clicod
                titulo.titnum    = vcontrato_p2k
                titulo.titpar    = int(parcelas.seq_parcela) + 1
                titulo.titdtemi  = vdtemissao
                titulo.titdtven  = vdata
                titulo.titvlcob  = dec(parcelas.vlr_parcela)
                titulo.titsit    = "LIB"
                titulo.titnumger = EfetivaEmprestimo.numero_contrato
                titulo.vencod    = int(EfetivaEmprestimo.vendedor)
                titulo.titchepag = "P2K=EfetivaEmprestimo".

                titulo.vlf_principal = round(contrato.vlf_principal / contrato.nro_parcela,2).        /* 68725  19/04/2021 helio */
                
                    
        end.
    end.

    if dec(EfetivaEmprestimo.valor_tfc) > 0
    then do on error undo.
        vhora = time.
        find clitaxas where clitaxas.clicod  = clien.clicod
                        and clitaxas.tabela  = "TFC"
                        and clitaxas.data    = today
                        and clitaxas.hora    = vhora
                      no-lock no-error.
        if not avail clitaxas
        then do.
            create clitaxas.
            assign
                clitaxas.clicod  = clien.clicod
                clitaxas.tabela  = "TFC"
                clitaxas.data    = today
                clitaxas.hora    = vhora
                clitaxas.etbcod  = setbcod
                clitaxas.vltaxa  = dec(EfetivaEmprestimo.valor_tfc)
                clitaxas.nsu     = int(EfetivaEmprestimo.nsu_venda)
                clitaxas.cxacod  = int(EfetivaEmprestimo.numero_pdv)
                clitaxas.contnum = contrato.contnum.
        end.
    end.
end.

BSXml("ABREXML","").
bsxml("abretabela","return").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).

if avail EfetivaEmprestimo
then do.
    bsxml("codigo_cliente",EfetivaEmprestimo.codigo_cliente).
    bsxml("cpf", vcpf).
    bsxml("numero_contrato", EfetivaEmprestimo.numero_contrato).
    bsxml("codigo_filial", EfetivaEmprestimo.codigo_filial).
    bsxml("numero_pdv",    EfetivaEmprestimo.numero_pdv).
    bsxml("codigo_produto",EfetivaEmprestimo.codigo_produto).
    bsxml("valor_credito", EfetivaEmprestimo.valor_credito).
    bsxml("numero_bilhete",EfetivaEmprestimo.numero_bilhete).
end.
else do.
    bsxml("codigo_filial", "").
    bsxml("numero_pdv",    "").
    bsxml("codigo_produto","").
    bsxml("valor_credito", "").
    bsxml("numero_bilhete","").    
end.
bsxml("numero_sorte",  "").

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.

